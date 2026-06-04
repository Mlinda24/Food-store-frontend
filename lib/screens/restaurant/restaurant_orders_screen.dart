import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _selectedTab = 'Active';
  final List<String> _tabs = ['Active', 'Ready', 'Past'];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
    // Auto-refresh every 15 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _silentRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.loadRestaurantOrders();
    await provider.loadStats();
  }

  Future<void> _silentRefresh() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.loadRestaurantOrders();
    await provider.loadStats();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'MK0';
    double numValue;
    if (value is double) {
      numValue = value;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else {
      numValue = 0;
    }
    return 'MK${numValue.toStringAsFixed(0)}';
  }

  Future<void> _updateOrderStatus(
      dynamic order, String newStatus, String statusName) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    final orderId = order['id'].toString();
    final bool isAccepting = newStatus == 'confirmed';
    final bool isDeclining = newStatus == 'cancelled';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text(isAccepting
            ? 'Accept Order'
            : isDeclining
                ? 'Decline Order'
                : 'Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order['id']}'),
            const SizedBox(height: 8),
            if (isAccepting) ...[
              Text('Order Total: ${_formatCurrency(order['total_price'])}'),
              const SizedBox(height: 4),
              Text(
                'Platform Fee (10%): ${_formatCurrency(
                  (double.tryParse(order['total_price']?.toString() ?? '0') ??
                          0) *
                      0.1,
                )}',
              ),
              const SizedBox(height: 4),
              Text(
                'Your earnings: ${_formatCurrency(
                  (double.tryParse(order['total_price']?.toString() ?? '0') ??
                          0) *
                      0.9,
                )}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.success),
              ),
              const SizedBox(height: 8),
              Text(
                'Earnings will be credited to your wallet immediately upon confirmation.',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getSecondaryTextColor(context)),
              ),
            ],
            if (isDeclining)
              const Text('Are you sure you want to decline this order?'),
            if (!isAccepting && !isDeclining)
              Text('Mark order as $statusName?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style:
                    TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccepting
                  ? AppTheme.success
                  : isDeclining
                      ? AppTheme.error
                      : AppTheme.primaryRed,
            ),
            child: Text(isAccepting
                ? 'Yes, Accept'
                : isDeclining
                    ? 'Yes, Decline'
                    : 'Yes, $statusName'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 12),
              Text('Updating order...'),
            ],
          ),
          duration: Duration(seconds: 15),
        ),
      );
    }

    final success = await provider.updateOrderStatus(orderId, newStatus);

    if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      // Reload both orders and stats so counts update immediately
      await provider.loadRestaurantOrders();
      await provider.loadStats();

      if (isAccepting) {
        _showSnackBar(
            'Order #${order['id']} accepted! Earnings credited to your wallet.');
      } else if (isDeclining) {
        _showSnackBar('Order #${order['id']} declined.');
      } else {
        _showSnackBar('Order #${order['id']} marked as $statusName.');
      }
    } else {
      _showSnackBar(
        'Failed to update order. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);
    final isLoading = provider.isLoadingOrders;
    final allOrders = provider.orders;

    final activeOrders = allOrders
        .where((o) =>
            o['status'] == 'pending' ||
            o['status'] == 'confirmed' ||
            o['status'] == 'preparing')
        .toList();

    final readyOrders = allOrders.where((o) => o['status'] == 'ready').toList();

    final pastOrders = allOrders
        .where((o) =>
            o['status'] == 'picked_up' ||
            o['status'] == 'delivered' ||
            o['status'] == 'cancelled')
        .toList();

    final List<dynamic> orders;
    if (_selectedTab == 'Active') {
      orders = activeOrders;
    } else if (_selectedTab == 'Ready') {
      orders = readyOrders;
    } else {
      orders = pastOrders;
    }

    return Column(
      children: [
        // ── Tab Bar with live counts ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = _selectedTab == tab;

              int count = 0;
              if (tab == 'Active') count = activeOrders.length;
              if (tab == 'Ready') count = readyOrders.length;
              if (tab == 'Past') count = pastOrders.length;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected ? AppTheme.primaryButtonGradient : null,
                      color:
                          isSelected ? null : AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppTheme.getMutedTextColor(context)
                                  .withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tab,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Order List ───────────────────────────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64,
                              color: AppTheme.getMutedTextColor(context)),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedTab orders',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.getSecondaryTextColor(context)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: orders.length,
                        itemBuilder: (context, index) =>
                            _buildOrderCard(context, orders[index]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final items = order['items'] as List? ?? [];
    final status = order['status'] ?? 'pending';
    final paymentStatus = order['payment_status']?.toString() ?? 'unpaid';
    final isPaid = paymentStatus == 'paid';

    DateTime orderTime;
    try {
      orderTime =
          DateTime.parse(order['created'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      orderTime = DateTime.now();
    }

    final difference = DateTime.now().difference(orderTime);
    final timeAgo = difference.inMinutes < 60
        ? '${difference.inMinutes} min ago'
        : difference.inHours < 24
            ? '${difference.inHours} hours ago'
            : '${difference.inDays} days ago';

    String customerName = 'Customer';
    String customerPhone = 'No phone';
    final customerAddress = order['delivery_address'] ?? '';

    if (order['customer_name'] != null) {
      customerName = order['customer_name'].toString();
    } else if (order['customer'] != null) {
      if (order['customer'] is Map) {
        customerName = order['customer']['username'] ?? 'Customer';
        customerPhone = order['customer']['phone'] ?? 'No phone';
      } else {
        customerName = 'Customer #${order['customer']}';
      }
    }
    if (order['customer_phone'] != null) {
      customerPhone = order['customer_phone'].toString();
    }

    final orderTotal =
        double.tryParse(order['total_price']?.toString() ?? '0') ?? 0;
    final restaurantEarnings = orderTotal * 0.9;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  // Order status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(status)),
                    ),
                  ),
                  // Payment status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppTheme.success.withOpacity(0.15)
                          : AppTheme.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isPaid ? '💰 Paid' : '⏳ Unpaid',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? AppTheme.success : AppTheme.warning),
                    ),
                  ),
                  Text(
                    'ORD-${order['id']}',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.getMutedTextColor(context)),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(
                    fontSize: 10, color: AppTheme.getMutedTextColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Customer info ─────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person,
                    size: 14, color: AppTheme.getMutedTextColor(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.getPrimaryTextColor(context))),
                    Text(customerPhone,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getSecondaryTextColor(context))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (customerAddress.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on,
                    size: 12, color: AppTheme.getMutedTextColor(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customerAddress,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.getSecondaryTextColor(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const Divider(height: 16, color: AppTheme.deepCrimson),

          // ── Items ─────────────────────────────────────────────────────────
          if (items.isNotEmpty) ...[
            Column(
              children: (items as List).take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['quantity']}x ${item['menu_item_name']}',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatCurrency(item['price']),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryRed),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (items.length > 2)
              Text(
                '+${items.length - 2} more items',
                style: TextStyle(
                    fontSize: 11, color: AppTheme.getMutedTextColor(context)),
              ),
            const Divider(height: 16, color: AppTheme.deepCrimson),
          ],

          // ── Total ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Total:',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getPrimaryTextColor(context))),
              Text(
                _formatCurrency(order['total_price']),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed),
              ),
            ],
          ),

          // ── Earnings badge ────────────────────────────────────────────────
          if (status == 'confirmed' ||
              status == 'preparing' ||
              status == 'ready' ||
              status == 'picked_up')
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 14, color: AppTheme.success),
                      const SizedBox(width: 4),
                      Text('Your Earnings:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.success)),
                    ],
                  ),
                  Text(
                    _formatCurrency(restaurantEarnings),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ── Action Buttons ────────────────────────────────────────────────

          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateOrderStatus(order, 'cancelled', 'Declined'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                    ),
                    child: Text('Decline',
                        style: TextStyle(fontSize: 13, color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateOrderStatus(order, 'confirmed', 'Confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'Accept Order',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

          if (status == 'confirmed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _updateOrderStatus(order, 'preparing', 'Preparing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Start Preparing',
                    style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
            ),

          if (status == 'preparing')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order, 'ready', 'Ready'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Mark as Ready',
                    style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
            ),

          if (status == 'ready')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateOrderStatus(order, 'cancelled', 'Cancelled'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(fontSize: 13, color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateOrderStatus(order, 'picked_up', 'Picked Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Picked Up',
                        style: TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),
              ],
            ),

          if (status == 'picked_up')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _updateOrderStatus(order, 'delivered', 'Delivered'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: AppTheme.success, width: 1.5),
                ),
                child: Text('Mark Delivered',
                    style: TextStyle(fontSize: 13, color: AppTheme.success)),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'picked_up':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'picked_up':
        return 'Picked Up';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
