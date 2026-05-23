import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../models/models.dart';
import '../../providers/restaurant_provider.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _selectedTab = 'Active';
  final List<String> _tabs = ['Active', 'Ready', 'Past'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    provider.loadRestaurantOrders();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _acceptOrder(dynamic order) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.updateOrderStatus(order['id'], 'confirmed');
    _loadOrders();
    _showSnackBar('Order ${order['id']} accepted!');
  }

  Future<void> _declineOrder(dynamic order) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.updateOrderStatus(order['id'], 'cancelled');
    _loadOrders();
    _showSnackBar('Order ${order['id']} declined', isError: true);
  }

  Future<void> _markAsPreparing(dynamic order) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.updateOrderStatus(order['id'], 'preparing');
    _loadOrders();
    _showSnackBar('Order ${order['id']} is now being prepared');
  }

  Future<void> _markAsReady(dynamic order) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.updateOrderStatus(order['id'], 'ready');
    _loadOrders();
    _showSnackBar('Order ${order['id']} is ready for pickup!');
  }

  Future<void> _markAsDelivered(dynamic order) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.updateOrderStatus(order['id'], 'delivered');
    _loadOrders();
    _showSnackBar('Order ${order['id']} has been delivered');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);
    final isLoading = provider.isLoadingOrders;
    final allOrders = provider.orders;

    // Filter orders by status
    final activeOrders = allOrders.where((o) => 
      o['status'] == 'pending' || o['status'] == 'confirmed' || o['status'] == 'preparing'
    ).toList();
    
    final readyOrders = allOrders.where((o) => o['status'] == 'ready').toList();
    
    final pastOrders = allOrders.where((o) => 
      o['status'] == 'delivered' || o['status'] == 'cancelled'
    ).toList();

    List<dynamic> orders;
    if (_selectedTab == 'Active') {
      orders = activeOrders;
    } else if (_selectedTab == 'Ready') {
      orders = readyOrders;
    } else {
      orders = pastOrders;
    }

    return Column(
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
                      gradient: isSelected ? AppTheme.primaryButton : null,
                      color: isSelected ? null : AppTheme.secondaryBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Orders List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppTheme.mutedText),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedTab orders',
                            style: TextStyle(fontSize: 16, color: AppTheme.secondaryText),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(context, orders[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final items = order['items'] as List? ?? [];
    final total = order['total_price'] ?? 0;
    final status = order['status'] ?? 'pending';
    final orderTime = DateTime.parse(order['created'] ?? DateTime.now().toIso8601String());
    final difference = DateTime.now().difference(orderTime);
    final timeAgo = difference.inMinutes < 60 
        ? '${difference.inMinutes} min ago' 
        : '${difference.inHours} hours ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ORD-${order['id']}',
                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Customer Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, size: 16, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['customer']?['username'] ?? 'Customer',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                    ),
                    Text(
                      order['customer']?['phone'] ?? 'No phone',
                      style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['delivery_address'] ?? 'No address',
                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.deepCrimson),
          // Items
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['quantity']}x ${item['menu_item_name']}',
                      style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                    ),
                    Text(
                      'MK${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, color: AppTheme.primaryText),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
              ),
              Text(
                'MK${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
              ),
            ],
          ),

          // Action Buttons based on status
          const SizedBox(height: 16),
          if (status == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: () => _declineOrder(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                      ),
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),

          if (status == 'confirmed')
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => _markAsPreparing(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warning,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.kitchen, size: 14),
                      SizedBox(width: 6),
                      Text('Start Preparing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

          if (status == 'preparing')
            Center(
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => _markAsReady(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: 14),
                      SizedBox(width: 6),
                      Text('Ready', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

          if (status == 'ready')
            Center(
              child: SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () => _markAsDelivered(order),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.teal, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping, size: 14, color: AppTheme.teal),
                      SizedBox(width: 6),
                      Text('Delivered', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.teal)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppTheme.warning;
      case 'confirmed': return AppTheme.primaryRed;
      case 'preparing': return AppTheme.warning;
      case 'ready': return AppTheme.success;
      case 'delivered': return AppTheme.teal;
      default: return AppTheme.mutedText;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'ready': return 'Ready for Pickup';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}