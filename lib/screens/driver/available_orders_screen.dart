import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/delivery_request.dart';
import '../../widgets/driver/status_chip.dart';
import '../../widgets/driver/info_section.dart';

/// Available Orders screen.
/// Reads directly from DriverProvider._availableOrders – the same list
/// the dashboard uses – so they are always in sync.
/// Tapping a card opens a full detail bottom sheet with Accept / Decline.
class AvailableOrdersScreen extends StatelessWidget {
  const AvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    final text =
        isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final sub =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final card =
        isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;

    if (!provider.isOnline) {
      return _emptyState(
        icon: Icons.wifi_off,
        title: 'You are offline',
        message: 'Switch to Online to see available orders.',
        text: text,
        sub: sub,
      );
    }

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = provider.availableOrders;

    if (orders.isEmpty) {
      return _emptyState(
        icon: Icons.inbox_outlined,
        title: 'No available orders',
        message: 'Pull down to refresh.',
        text: text,
        sub: sub,
        action: TextButton.icon(
          onPressed: () => provider.refreshAvailableOrders(),
          icon: const Icon(Icons.refresh, color: AppTheme.primaryRed),
          label: const Text('Refresh',
              style: TextStyle(color: AppTheme.primaryRed)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshAvailableOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _OrderCard(
          order: orders[i],
          cardColor: card,
          textColor: text,
          subColor: sub,
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    required Color text,
    required Color sub,
    Widget? action,
  }) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: AppTheme.mutedText),
        const SizedBox(height: 16),
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 8),
        Text(message,
            style: TextStyle(fontSize: 14, color: sub),
            textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 16), action],
      ]),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final DeliveryRequest order;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const _OrderCard({
    required this.order,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  // ── Detail bottom sheet ───────────────────────────────────────────────────
  void _showDetailSheet(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;
    final bg =
        isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final text =
        isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final sub =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, scrollController) => Container(
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
                  // ── Header ────────────────────────────────────────────────
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
                        // Earnings badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'MK${order.earnings.toInt()}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ]),

                  const SizedBox(height: 16),

                  // Distance & time chips
                  Row(children: [
                    if (order.distance.isNotEmpty) ...[
                      _chip(Icons.route, order.distance, sub),
                      const SizedBox(width: 10),
                    ],
                    _chip(Icons.timer, order.estimatedTime, sub),
                  ]),

                  const SizedBox(height: 20),

                  // Restaurant
                  InfoSection(
                    icon: Icons.restaurant,
                    title: 'Pickup from',
                    subtitle: order.restaurantName,
                    address: order.restaurantAddress.isNotEmpty
                        ? order.restaurantAddress
                        : 'Address not available',
                  ),
                  const SizedBox(height: 16),

                  // Customer / delivery
                  InfoSection(
                    icon: Icons.home,
                    title: 'Deliver to',
                    subtitle: order.customerName,
                    address: order.deliveryAddress.isNotEmpty
                        ? order.deliveryAddress
                        : 'Address not provided',
                  ),
                  const SizedBox(height: 16),

                  // Items row
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
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── Accept / Decline ──────────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          final provider = Provider.of<DriverProvider>(
                              context,
                              listen: false);
                          provider.declineOrder(order);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Order declined'),
                            backgroundColor: AppTheme.error,
                            duration: Duration(seconds: 2),
                          ));
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
                          final provider = Provider.of<DriverProvider>(
                              context,
                              listen: false);
                          try {
                            await provider.acceptOrder(order);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                  'Order accepted! Head to ${order.restaurantName}.'),
                              backgroundColor: AppTheme.success,
                              duration: const Duration(seconds: 2),
                            ));
                          } catch (_) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Failed to accept order'),
                              backgroundColor: AppTheme.error,
                              duration: Duration(seconds: 2),
                            ));
                          }
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
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.primaryRed),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.primaryRed)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context, listen: false);

    return GestureDetector(
      // ── Tap anywhere on the card to see full details ─────────────────────
      onTap: () => _showDetailSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryRed.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.restaurant,
                  color: AppTheme.primaryRed, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurantName,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    Text(
                      order.restaurantAddress.isNotEmpty
                          ? order.restaurantAddress
                          : 'Tap for details',
                      style: TextStyle(fontSize: 12, color: subColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                'MK${order.earnings.toInt()}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ]),

          const Divider(height: 20),

          // ── Summary row ──────────────────────────────────────────────────
          _row(Icons.person_outline, order.customerName, subColor),
          const SizedBox(height: 6),
          _row(
              Icons.location_on_outlined,
              order.deliveryAddress.isNotEmpty
                  ? order.deliveryAddress
                  : 'Delivery address not provided',
              subColor,
              maxLines: 2),
          const SizedBox(height: 6),
          Row(children: [
            if (order.distance.isNotEmpty) ...[
              _iconText(Icons.route, order.distance, subColor),
              const SizedBox(width: 16),
            ],
            _iconText(Icons.timer, order.estimatedTime, subColor),
            const Spacer(),
            // "Tap for details" hint
            Text('Tap for details',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryRed.withOpacity(0.7),
                    fontStyle: FontStyle.italic)),
          ]),

          const SizedBox(height: 14),

          // ── Quick action buttons (still available on the card) ───────────
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => provider.declineOrder(order),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: AppTheme.error.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Decline',
                    style:
                        TextStyle(color: AppTheme.error, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await provider.acceptOrder(order);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                              content: Text(
                                  'Order accepted! Head to ${order.restaurantName}.'),
                              backgroundColor: AppTheme.success));
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text('Failed to accept order'),
                              backgroundColor: AppTheme.error));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Accept',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, Color sub, {int maxLines = 1}) {
    return Row(children: [
      Icon(icon, size: 15, color: AppTheme.mutedText),
      const SizedBox(width: 6),
      Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 12, color: sub),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _iconText(IconData icon, String label, Color sub) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.mutedText),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: sub)),
    ]);
  }
}