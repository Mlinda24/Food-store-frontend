import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/delivery_request.dart';
import '../../widgets/driver/stat_card.dart';
import '../../widgets/driver/schedule_item.dart';
import '../../widgets/dialogs/new_request_dialog.dart';
import '../../widgets/dialogs/update_status_dialog.dart';
import '../../widgets/driver/status_chip.dart';
import '../../widgets/driver/progress_timeline.dart';
import '../../widgets/driver/info_section.dart';
import 'available_orders_screen.dart';
import 'delivery_history_screen.dart';
import 'driver_analytics_screen.dart';
import 'driver_settings_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _showActiveDeliveryFullView = false;
  bool _dialogVisible = false;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.delivery_dining, 'label': 'Available'},
    {'icon': Icons.history, 'label': 'History'},
    {'icon': Icons.analytics, 'label': 'Analytics'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false)
          .addListener(_onProviderUpdate);
    });
  }

  @override
  void dispose() {
    Provider.of<DriverProvider>(context, listen: false)
        .removeListener(_onProviderUpdate);
    super.dispose();
  }

  // ── LISTENER ─────────────────────────────────────────────────────────────
  void _onProviderUpdate() {
    final provider = Provider.of<DriverProvider>(context, listen: false);
    if (!provider.isLoading && provider.pendingOrder != null && !_dialogVisible) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_dialogVisible && provider.pendingOrder != null) {
          _showNewRequestDialog(provider.pendingOrder!);
        }
      });
    }
  }

  // ── POPUP DIALOG ──────────────────────────────────────────────────────────
  void _showNewRequestDialog(DeliveryRequest order) {
    _dialogVisible = true;
    final provider = Provider.of<DriverProvider>(context, listen: false);
    provider.consumePendingOrder();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewRequestDialog(
        request: order,
        onAccept: () async {
          Navigator.pop(context);
          _dialogVisible = false;
          await provider.acceptOrder(order);
          if (mounted) {
            _showSnackBar('Order accepted! Head to ${order.restaurantName}.');
            setState(() {
              _selectedIndex = 0;
              _showActiveDeliveryFullView = true;
            });
          }
        },
        onDecline: () {
          Navigator.pop(context);
          _dialogVisible = false;
          provider.declineOrder(order);
          _showSnackBar('Order declined', isError: true);
        },
      ),
    ).then((_) => _dialogVisible = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      duration: const Duration(seconds: 2),
    ));
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final provider = Provider.of<DriverProvider>(context, listen: false);
      await provider.updateOrderStatus(orderId, newStatus);
      if (newStatus == 'delivered') {
        _showSnackBar('Delivery completed! Great job! 🎉');
        setState(() => _showActiveDeliveryFullView = false);
      } else {
        _showSnackBar('Status updated to: ${_statusLabel(newStatus)}');
      }
    } catch (_) {
      _showSnackBar('Failed to update status', isError: true);
    }
  }

  String _statusLabel(String s) => const {
        'accepted': 'Accepted',
        'driver_arrived': 'Arrived at Restaurant',
        'picked_up': 'Picked Up',
        'delivered': 'Delivered',
      }[s] ??
      s;

  // ── ORDER DETAIL BOTTOM SHEET ─────────────────────────────────────────────
  // Opens a live-updating sheet. The sheet uses Consumer<DriverProvider> so
  // it always reads the current status of the order — it never captures a
  // stale snapshot. This prevents the "jumps straight to delivered" bug that
  // occurred when isActive / order.status were closed over at open-time.
  void _showOrderDetailSheet(DeliveryRequest order,
      {bool isAvailable = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Use a builder that receives a fresh context so Provider works inside.
      builder: (sheetCtx) => _OrderDetailSheet(
        orderId: order.id,
        initialOrder: order,
        isAvailable: isAvailable,
        onAccept: (o) async {
          final provider =
              Provider.of<DriverProvider>(context, listen: false);
          try {
            await provider.acceptOrder(o);
            _showSnackBar(
                'Order accepted! Head to ${o.restaurantName}.');
            setState(() {
              _selectedIndex = 0;
              _showActiveDeliveryFullView = true;
            });
          } catch (_) {
            _showSnackBar('Failed to accept order', isError: true);
          }
        },
        onDecline: (o) {
          final provider =
              Provider.of<DriverProvider>(context, listen: false);
          provider.declineOrder(o);
          _showSnackBar('Order declined', isError: true);
        },
        onUpdateStatus: (orderId, ns) {
          _updateOrderStatus(orderId, ns);
          if (ns == 'delivered') {
            setState(() => _showActiveDeliveryFullView = false);
          }
        },
        buildContact: (o) => _buildContactSection(o),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final driverName = auth.currentUser?.name ?? 'Driver';

    final bg =
        theme.isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final text = theme.isDarkMode
        ? AppTheme.darkPrimaryText
        : AppTheme.lightPrimaryText;

    if (provider.isLoading && !provider.isOnline) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            title: Text(driverName, style: TextStyle(color: text))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(provider, driverName, text,
          theme.isDarkMode
              ? AppTheme.darkSecondaryText
              : AppTheme.lightSecondaryText),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: _selectedIndex == 0
            ? _buildDashboard(provider, theme, text)
            : _buildScreen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.isDarkMode
            ? AppTheme.darkCardBackground
            : AppTheme.lightCardBackground,
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: theme.isDarkMode
            ? AppTheme.darkSecondaryText
            : AppTheme.lightSecondaryText,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: _navItems
            .map((n) => BottomNavigationBarItem(
                  icon: Icon(n['icon'] as IconData),
                  label: n['label'] as String,
                ))
            .toList(),
      ),
    );
  }

  AppBar _buildAppBar(
      DriverProvider provider, String name, Color text, Color sub) {
    return AppBar(
      backgroundColor:
          Provider.of<ThemeProvider>(context).isDarkMode
              ? AppTheme.darkBackground
              : AppTheme.lightBackground,
      elevation: 0,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: text)),
        Text(
          _selectedIndex == 0
              ? 'Driver Dashboard'
              : _navItems[_selectedIndex]['label'] as String,
          style: TextStyle(fontSize: 12, color: sub),
        ),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: provider.isOnline
                ? AppTheme.success.withOpacity(0.2)
                : AppTheme.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    provider.isOnline ? AppTheme.success : AppTheme.error),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    provider.isOnline ? AppTheme.success : AppTheme.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              provider.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    provider.isOnline ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: provider.isOnline,
              onChanged: (v) async {
                await provider.toggleOnlineStatus(v);
                if (mounted) {
                  _showSnackBar(
                      v ? 'You are now online' : 'You are now offline');
                }
              },
              activeColor: AppTheme.success,
              inactiveThumbColor: AppTheme.error,
              inactiveTrackColor: AppTheme.error.withOpacity(0.3),
            ),
          ]),
        ),
      ],
    );
  }

  // ── DASHBOARD ─────────────────────────────────────────────────────────────
  Widget _buildDashboard(
      DriverProvider provider, ThemeProvider theme, Color text) {
    final active = provider.activeDelivery;
    final stats = provider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Active delivery views
        if (active != null && _showActiveDeliveryFullView)
          _buildActiveExpanded(active),
        if (active != null && !_showActiveDeliveryFullView)
          _buildActiveBanner(active),

        // Stats grid
        Row(children: [
          Expanded(
              child: StatCard(
                  title: "Today's Earnings",
                  value: 'MK${stats.todayEarnings.toInt()}',
                  icon: Icons.attach_money,
                  color: AppTheme.primaryRed)),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  title: 'Total Deliveries',
                  value: '${stats.totalDeliveries}',
                  icon: Icons.delivery_dining,
                  color: AppTheme.success)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: StatCard(
                  title: 'Rating',
                  value: stats.rating > 0
                      ? '${stats.rating.toStringAsFixed(1)} ★'
                      : '5.0 ★',
                  icon: Icons.star,
                  color: AppTheme.yellow)),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  title: 'Active Orders',
                  value: active != null ? '1' : '0',
                  icon: Icons.shopping_bag,
                  color: AppTheme.warning)),
        ]),
        const SizedBox(height: 24),

        // ── Schedule card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.getCardGlowGradient(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Schedule",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text)),
                  // Show count badge
                  if (provider.acceptedHistory.isNotEmpty ||
                      provider.availableOrders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.acceptedHistory.length + provider.availableOrders.length} orders',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Accepted/active orders (all of them, not just current) ──
              // acceptedHistory is newest-first; the active one is at [0].
              if (provider.acceptedHistory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Accepted',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedText,
                          letterSpacing: 0.5)),
                ),
                ...provider.acceptedHistory.map((order) {
                  final isCurrentlyActive =
                      active != null && active.id == order.id;
                  // Use the live version if it's the active order
                  final displayOrder =
                      isCurrentlyActive ? active : order;

                  String scheduleStatus;
                  if (isCurrentlyActive) {
                    scheduleStatus =
                        displayOrder.status == 'accepted'
                            ? 'Ready for Pickup'
                            : displayOrder.status == 'picked_up'
                                ? 'Out for Delivery'
                                : displayOrder.status == 'delivered'
                                    ? 'Delivered ✓'
                                    : 'In Progress';
                  } else {
                    scheduleStatus =
                        displayOrder.status == 'delivered'
                            ? 'Delivered ✓'
                            : 'Previously Accepted';
                  }

                  return ScheduleItem(
                    orderId: displayOrder.id,
                    restaurant: displayOrder.restaurantName,
                    customer: displayOrder.customerName,
                    time: displayOrder.estimatedTime,
                    status: scheduleStatus,
                    onTap: () => _showOrderDetailSheet(displayOrder),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],

              // ── Available orders (all of them) ─────────────────────────
              if (provider.availableOrders.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text('Available',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mutedText,
                          letterSpacing: 0.5)),
                ),
                ...provider.availableOrders.map((order) => ScheduleItem(
                      orderId: order.id,
                      restaurant: order.restaurantName,
                      customer: order.customerName,
                      time: order.estimatedTime,
                      status: 'Available',
                      onTap: () => _showOrderDetailSheet(
                        order,
                        isAvailable: true,
                      ),
                    )),
              ],

              // ── Empty states ─────────────────────────────────────────────
              if (provider.acceptedHistory.isEmpty &&
                  provider.availableOrders.isEmpty &&
                  provider.isOnline)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: Text(
                          'No orders right now. Pull down to refresh.',
                          style:
                              TextStyle(color: AppTheme.mutedText))),
                ),

              if (!provider.isOnline)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: Text('Go online to start receiving orders.',
                          style:
                              TextStyle(color: AppTheme.mutedText))),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── ACTIVE DELIVERY BANNER (collapsed) ───────────────────────────────────
  Widget _buildActiveBanner(DeliveryRequest d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _showActiveDeliveryFullView = true),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delivery_dining,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Delivery',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('Order #${d.id}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(
                      d.restaurantName.isNotEmpty
                          ? '${d.restaurantName}  →  ${d.customerName}'
                          : d.customerName,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.arrow_forward,
                  color: Colors.white, size: 20),
            ),
          ]),
        ),
      ),
    );
  }

  // ── ACTIVE DELIVERY EXPANDED ──────────────────────────────────────────────
  Widget _buildActiveExpanded(DeliveryRequest d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Order #${d.id}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText)),
          Row(children: [
            StatusChip(status: d.status),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () =>
                  setState(() => _showActiveDeliveryFullView = false),
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ]),
        const SizedBox(height: 16),

        ProgressTimeline(status: d.status),
        const SizedBox(height: 24),

        InfoSection(
          icon: Icons.restaurant,
          title: 'Pickup from',
          subtitle: d.restaurantName,
          address: d.restaurantAddress.isNotEmpty
              ? d.restaurantAddress
              : 'Fetching address…',
        ),
        const SizedBox(height: 16),

        InfoSection(
          icon: Icons.home,
          title: 'Deliver to',
          subtitle: d.customerName,
          address: d.deliveryAddress.isNotEmpty
              ? d.deliveryAddress
              : 'Address not provided',
        ),
        const SizedBox(height: 16),

        _buildContactSection(d),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.fastfood,
                size: 20, color: AppTheme.mutedText),
            const SizedBox(width: 12),
            Expanded(
                child: Text(d.items,
                    style:
                        const TextStyle(color: AppTheme.secondaryText))),
            const Spacer(),
            const Icon(Icons.attach_money,
                size: 20, color: AppTheme.primaryRed),
            const SizedBox(width: 4),
            Text('MK${d.earnings.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed)),
          ]),
        ),
        const SizedBox(height: 24),

        if (d.status != 'delivered')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => UpdateStatusDialog(
                    currentStatus: d.status,
                    onStatusUpdate: (ns) {
                      _updateOrderStatus(d.id, ns);
                      if (ns == 'delivered') {
                        setState(
                            () => _showActiveDeliveryFullView = false);
                      }
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Update Delivery Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  setState(() => _showActiveDeliveryFullView = false),
              icon: const Icon(Icons.check_circle),
              label: const Text('Delivery Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
      ]),
    );
  }

  // ── CONTACT SECTION ───────────────────────────────────────────────────────
  Widget _buildContactSection(DeliveryRequest d) {
    final theme = Provider.of<ThemeProvider>(context);
    final textColor = theme.isDarkMode
        ? AppTheme.darkPrimaryText
        : AppTheme.lightPrimaryText;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.contact_phone,
                size: 20, color: AppTheme.primaryRed),
          ),
          const SizedBox(width: 12),
          Text('Customer Contact',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                      content: Text('Calling ${d.customerPhone ?? ''}...'),
                      backgroundColor: AppTheme.success)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(d.customerPhone ?? 'No phone',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green)),
                    ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Opening SMS...'),
                      backgroundColor: AppTheme.success)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.message, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('SMS',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue)),
                    ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── SCREEN ROUTER ─────────────────────────────────────────────────────────
  Widget _buildScreen(int index) {
    switch (index) {
      case 1:
        return const AvailableOrdersScreen();
      case 2:
        return const DeliveryHistoryScreen();
      case 3:
        return const DriverAnalyticsScreen();
      case 4:
        return const DriverSettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _OrderDetailSheet
// A live-updating bottom sheet that always reads the order's current status
// from DriverProvider instead of from a closed-over snapshot.
//
// Logic:
//   - If provider.activeDelivery.id == orderId  → show Update Status button
//   - Else if isAvailable == true               → show Accept / Decline
//   - Else                                      → read-only badge
// ═════════════════════════════════════════════════════════════════════════════
class _OrderDetailSheet extends StatelessWidget {
  final String orderId;
  final DeliveryRequest initialOrder; // used for static fields (name, addr…)
  final bool isAvailable;
  final Future<void> Function(DeliveryRequest) onAccept;
  final void Function(DeliveryRequest) onDecline;
  final void Function(String orderId, String newStatus) onUpdateStatus;
  final Widget Function(DeliveryRequest) buildContact;

  const _OrderDetailSheet({
    required this.orderId,
    required this.initialOrder,
    required this.isAvailable,
    required this.onAccept,
    required this.onDecline,
    required this.onUpdateStatus,
    required this.buildContact,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<DriverProvider, ThemeProvider>(
      builder: (ctx, provider, theme, _) {
        final isDark = theme.isDarkMode;
        final bg = isDark
            ? AppTheme.darkCardBackground
            : AppTheme.lightCardBackground;
        final text =
            isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
        final sub =
            isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

        // Always use the live active-delivery object when this is the active
        // order; fall back to the snapshot for history/available orders.
        final liveActive = provider.activeDelivery;
        final isNowActive =
            liveActive != null && liveActive.id == orderId;
        final order = isNowActive ? liveActive : initialOrder;

        // If the order just got delivered and the sheet is still open,
        // auto-close it so the driver isn't stuck looking at a delivered sheet.
        if (isNowActive && order.status == 'delivered') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx);
          });
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              // drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: sub.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order #${order.id}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: text)),
                                const SizedBox(height: 2),
                                Text(order.restaurantName,
                                    style: TextStyle(
                                        fontSize: 13, color: sub)),
                              ]),
                          StatusChip(status: order.status),
                        ]),

                    const SizedBox(height: 20),

                    // ── Progress timeline (active orders only) ────────────
                    if (isNowActive) ...[
                      ProgressTimeline(status: order.status),
                      const SizedBox(height: 24),
                    ],

                    // ── Restaurant ────────────────────────────────────────
                    InfoSection(
                      icon: Icons.restaurant,
                      title: 'Pickup from',
                      subtitle: order.restaurantName,
                      address: order.restaurantAddress.isNotEmpty
                          ? order.restaurantAddress
                          : 'Address not available',
                    ),
                    const SizedBox(height: 16),

                    // ── Customer ──────────────────────────────────────────
                    InfoSection(
                      icon: Icons.home,
                      title: 'Deliver to',
                      subtitle: order.customerName,
                      address: order.deliveryAddress.isNotEmpty
                          ? order.deliveryAddress
                          : 'Address not provided',
                    ),
                    const SizedBox(height: 16),

                    // ── Contact ───────────────────────────────────────────
                    buildContact(order),

                    // ── Items & earnings ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.fastfood,
                            size: 20, color: AppTheme.mutedText),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(order.items,
                                style: const TextStyle(
                                    color: AppTheme.secondaryText))),
                        const Spacer(),
                        const Icon(Icons.attach_money,
                            size: 20, color: AppTheme.primaryRed),
                        const SizedBox(width: 4),
                        Text('MK${order.earnings.toInt()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed)),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── Action buttons ────────────────────────────────────
                    // Case 1: currently the active delivery → Update Status
                    if (isNowActive && order.status != 'delivered')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Close the sheet BEFORE opening the dialog so
                            // the dialog sits on top of the dashboard, not the
                            // sheet, and setState in onUpdateStatus works.
                            Navigator.pop(ctx);
                            showDialog(
                              context: context,
                              builder: (_) => UpdateStatusDialog(
                                // Use the LIVE status, never the snapshot.
                                currentStatus: order.status,
                                onStatusUpdate: (ns) =>
                                    onUpdateStatus(order.id, ns),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Update Delivery Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),

                    // Case 2: available order → Accept / Decline
                    if (isAvailable && !isNowActive) ...[
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDecline(order);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppTheme.error.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Decline',
                                style: TextStyle(color: AppTheme.error)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await onAccept(order);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Accept',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ]),
                    ],

                    // Case 3: completed or declined → read-only badge
                    if (!isNowActive && !isAvailable)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: order.status == 'declined'
                                ? AppTheme.error.withOpacity(0.1)
                                : AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: order.status == 'declined'
                                  ? AppTheme.error.withOpacity(0.4)
                                  : AppTheme.success.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            order.status == 'declined'
                                ? 'Order was declined'
                                : 'Delivery completed ✓',
                            style: TextStyle(
                              color: order.status == 'declined'
                                  ? AppTheme.error
                                  : AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}