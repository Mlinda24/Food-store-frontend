import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrders(authProvider.currentUser!.id);
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warning;
      case OrderStatus.confirmed:
        return AppTheme.primaryRed;
      case OrderStatus.preparing:
        return AppTheme.warning;
      case OrderStatus.ready:
        return AppTheme.teal;
      case OrderStatus.pickedUp:
        return AppTheme.orange;
      case OrderStatus.onTheWay:
        return AppTheme.teal;
      case OrderStatus.delivered:
        return AppTheme.success;
      case OrderStatus.cancelled:
        return AppTheme.error;
    }
  }

  // Build a detailed item row (no instructions field)
  Widget _buildItemRow(OrderItemModel item, bool isDark) {
    final itemTotal = item.price * item.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.fastfood,
              size: 20,
              color: AppTheme.primaryRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity} x MK${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'MK${itemTotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        foregroundColor: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your order history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 200,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryButtonGradient,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('Browse Restaurants'),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGlowGradient(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.deepCrimson.withOpacity(0.3),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.go('/order-tracking', extra: order);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Order #${order.id.substring(order.id.length - 6)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getStatusText(order.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(order.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Restaurant placeholder (no restaurantName field)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 16,
                                        color: AppTheme.primaryRed,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Foodie Express',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Items Section - Detailed List (no instructions)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ordered Items',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...order.items.map((item) => _buildItemRow(item, isDark)),
                                      const Divider(height: 16),
                                      // Subtotal and total
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Subtotal',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                            ),
                                          ),
                                          Text(
                                            'MK${order.items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Delivery Fee',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                            ),
                                          ),
                                          Text(
                                            'MK2.99',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                            ),
                                          ),
                                          Text(
                                            'MK${order.total.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Delivery Address (if available)
                                if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.darkSurface.withOpacity(0.5) : AppTheme.lightBackground.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: AppTheme.primaryRed),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            order.deliveryAddress!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 12),
                                
                                // Order Date
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} • ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // View Details / Track Order Button
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryButtonGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/order-tracking', extra: order);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Track Order',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}