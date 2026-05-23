import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
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

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value is double) return value.toInt().toString();
    if (value is String) return int.tryParse(value)?.toString() ?? '0';
    return '0';
  }

  Future<void> _updateOrderStatus(dynamic order, String newStatus, String statusName) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text('Update Order Status'),
        content: Text('Mark order #${order['id']} as $statusName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text('Yes, $statusName'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await provider.updateOrderStatus(order['id'].toString(), newStatus);
      if (success) {
        _loadOrders();
        _showSnackBar('Order #${order['id']} marked as $statusName');
      } else {
        _showSnackBar('Failed to update order status', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);
    final isLoading = provider.isLoadingOrders;
    final allOrders = provider.orders;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeOrders = allOrders.where((o) => 
      o['status'] == 'pending' || o['status'] == 'confirmed' || o['status'] == 'preparing'
    ).toList();
    
    final readyOrders = allOrders.where((o) => o['status'] == 'ready').toList();
    
    final pastOrders = allOrders.where((o) => 
      o['status'] == 'picked_up' || o['status'] == 'delivered' || o['status'] == 'cancelled'
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
                      gradient: isSelected 
                          ? AppTheme.primaryButtonGradient
                          : null,
                      color: isSelected ? null : AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected ? null : Border.all(color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: AppTheme.getMutedTextColor(context)),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedTab orders',
                            style: TextStyle(fontSize: 16, color: AppTheme.getSecondaryTextColor(context)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadOrders();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(context, orders[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final items = order['items'] as List? ?? [];
    final status = order['status'] ?? 'pending';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    DateTime orderTime;
    try {
      orderTime = DateTime.parse(order['created'] ?? DateTime.now().toIso8601String());
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
    String customerAddress = order['delivery_address'] ?? '';
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ORD-${order['id']}',
                    style: TextStyle(fontSize: 10, color: AppTheme.getMutedTextColor(context)),
                  ),
                ],
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 10, color: AppTheme.getMutedTextColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, size: 14, color: AppTheme.getMutedTextColor(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        fontSize: 13, 
                        color: AppTheme.getPrimaryTextColor(context)
                      ),
                    ),
                    Text(
                      customerPhone,
                      style: TextStyle(fontSize: 11, color: AppTheme.getSecondaryTextColor(context)),
                    ),
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
                Icon(Icons.location_on, size: 12, color: AppTheme.getMutedTextColor(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customerAddress,
                    style: TextStyle(fontSize: 11, color: AppTheme.getSecondaryTextColor(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const Divider(height: 16, color: AppTheme.deepCrimson),
          if (items.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatNumber(items.length)} item${items.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 11, color: AppTheme.getSecondaryTextColor(context)),
                ),
                Text(
                  _formatCurrency(order['total_price']),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Status buttons
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(order, 'cancelled', 'Declined'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                    ),
                    child: Text('Decline', style: TextStyle(fontSize: 12, color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order, 'confirmed', 'Confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Accept', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          if (status == 'confirmed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order, 'preparing', 'Preparing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Start Preparing', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          if (status == 'preparing')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateOrderStatus(order, 'ready', 'Ready'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Mark as Ready', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          if (status == 'ready')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(order, 'cancelled', 'Cancelled'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 12, color: AppTheme.error)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order, 'picked_up', 'Picked Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Picked Up', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          if (status == 'picked_up')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _updateOrderStatus(order, 'delivered', 'Delivered'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: AppTheme.success, width: 1.5),
                ),
                child: Text('Mark as Delivered', style: TextStyle(fontSize: 12, color: AppTheme.success)),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'ready': return Colors.teal;
      case 'picked_up': return Colors.indigo;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'preparing': return 'Preparing';
      case 'ready': return 'Ready';
      case 'picked_up': return 'Picked Up';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}
