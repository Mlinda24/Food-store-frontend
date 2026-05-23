import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../config/theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order? order;

  const OrderTrackingScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final Order displayOrder = order ?? Order(
      id: 'ORD-001',
      userId: 'user1',
      restaurantId: 'rest1',
      items: [],
      status: OrderStatus.pending,
      subtotal: 0,
      deliveryFee: 0,
      tax: 0,
      total: 0,
      deliveryAddress: '',
      createdAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: AppTheme.mainBackground,
        foregroundColor: AppTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => context.pop(), // Navigate back to previous page
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              size: 80,
              color: AppTheme.primaryRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Order #${displayOrder.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_getStatusText(displayOrder.status)}',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: MK${displayOrder.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
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
}