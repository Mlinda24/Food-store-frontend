import '../../services/order_service.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/order_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _selectedTab = 'Active';
  final List<String> _tabs = ['Active', 'Ready', 'Past'];
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  // Maps API status strings to display tabs
  static const _activeStatuses = {'pending', 'confirmed', 'preparing', 'driver_assigned', 'driver_arrived'};
  static const _readyStatuses = {'ready'};
  static const _pastStatuses = {'picked_up', 'delivered', 'cancelled'};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final orders = await OrderService.getOrders();
      setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<dynamic> get _filteredOrders {
    return _orders.where((o) {
      final status = o['status'] as String? ?? '';
      if (_selectedTab == 'Active') return _activeStatuses.contains(status);
      if (_selectedTab == 'Ready') return _readyStatuses.contains(status);
      return _pastStatuses.contains(status);
    }).toList();
  }

  Future<void> _updateStatus(dynamic order, String newStatus) async {
    try {
      await OrderService.updateOrderStatus(order['id'], newStatus);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order['id']} updated to $newStatus'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryButtonGradient : null,
                        color: isSelected ? null : AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(tab, textAlign: TextAlign.center,
                        style: TextStyle(color: isSelected ? Colors.white : AppTheme.secondaryText, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                            const SizedBox(height: 12),
                            Text('Failed to load orders', style: TextStyle(color: AppTheme.secondaryText)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppTheme.primaryRed,
                        child: _filteredOrders.isEmpty
                            ? Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.inbox_outlined, size: 64, color: AppTheme.mutedText),
                                  const SizedBox(height: 16),
                                  Text('No $_selectedTab orders', style: TextStyle(fontSize: 16, color: AppTheme.secondaryText)),
                                ]),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) => _buildOrderCard(_filteredOrders[index]),
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final status = order['status'] as String? ?? '';
    final items = (order['items'] as List?) ?? [];
    final total = double.tryParse(order['total_price']?.toString() ?? '0') ?? 0;
    final createdStr = order['created'] as String?;
    final created = createdStr != null ? DateTime.tryParse(createdStr) : null;
    final timeAgo = created != null ? _timeAgo(created) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_statusLabel(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _statusColor(status))),
                ),
                const SizedBox(width: 12),
                Text('#${order['id']}', style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              ]),
              Text(timeAgo, style: TextStyle(fontSize: 11, color: AppTheme.mutedText)),
            ],
          ),
          const SizedBox(height: 12),

          // Customer
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.secondaryBackground, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person, size: 16, color: AppTheme.mutedText),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order['customer_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              Text(order['customer_phone'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
            ])),
          ]),
          const SizedBox(height: 8),

          // Address
          if (order['delivery_address'] != null)
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 8),
              Expanded(child: Text(order['delivery_address'], style: TextStyle(fontSize: 12, color: AppTheme.secondaryText))),
            ]),

          const Divider(height: 24, color: AppTheme.deepCrimson),

          // Items
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${item['quantity']}x ${item['menu_item_name'] ?? item['display_name'] ?? ''}',
                style: TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
              Text('MK${item['total'] ?? item['price']}', style: TextStyle(fontSize: 13, color: AppTheme.primaryText)),
            ]),
          )),

          const Divider(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
            Text('MK${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
          ]),

          // Action buttons based on status
          ..._buildActionButtons(order, status),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(dynamic order, String status) {
    if (status == 'pending') {
      return [
        const SizedBox(height: 16),
        Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 100, child: OutlinedButton(
            onPressed: () => _updateStatus(order, 'cancelled'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: BorderSide(color: AppTheme.error.withOpacity(0.5))),
            ),
            child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.error)),
          )),
          const SizedBox(width: 16),
          SizedBox(width: 100, child: ElevatedButton(
            onPressed: () => _updateStatus(order, 'confirmed'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
          )),
        ])),
      ];
    } else if (status == 'confirmed') {
      return [
        const SizedBox(height: 16),
        Center(child: SizedBox(width: 140, child: ElevatedButton(
          onPressed: () => _updateStatus(order, 'preparing'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.kitchen, size: 14), SizedBox(width: 6),
            Text('Start Preparing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
          ]),
        ))),
      ];
    } else if (status == 'preparing') {
      return [
        const SizedBox(height: 16),
        Center(child: SizedBox(width: 100, child: ElevatedButton(
          onPressed: () => _updateStatus(order, 'ready'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.done_all, size: 14), SizedBox(width: 6),
            Text('Ready', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
          ]),
        ))),
      ];
    } else if (status == 'ready') {
      return [
        const SizedBox(height: 16),
        Center(child: SizedBox(width: 120, child: OutlinedButton(
          onPressed: () => _updateStatus(order, 'picked_up'),
          style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.teal, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.local_shipping, size: 14, color: AppTheme.teal), SizedBox(width: 6),
            Text('Picked Up', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.teal)),
          ]),
        ))),
      ];
    }
    return [];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppTheme.warning;
      case 'confirmed': return AppTheme.primaryRed;
      case 'preparing': return AppTheme.warning;
      case 'ready': return AppTheme.success;
      case 'picked_up': return AppTheme.teal;
      case 'delivered': return AppTheme.success;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.mutedText;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'driver_assigned': return 'Driver Assigned';
      case 'driver_arrived': return 'Driver Arrived';
      case 'ready': return 'Ready for Pickup';
      case 'picked_up': return 'Picked Up';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

