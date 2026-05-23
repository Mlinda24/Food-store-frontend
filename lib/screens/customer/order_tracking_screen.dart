import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../config/theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order? order;

  const OrderTrackingScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    // Create a default order if none is provided
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

    final List<OrderStatus> statusFlow = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.pickedUp,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    int getCurrentStep() {
      final index = statusFlow.indexOf(displayOrder.status);
      return index >= 0 ? index : 0;
    }

    String getStatusText(OrderStatus status) {
      switch (status) {
        case OrderStatus.pending:
          return 'Order Placed';
        case OrderStatus.confirmed:
          return 'Confirmed';
        case OrderStatus.preparing:
          return 'Preparing';
        case OrderStatus.ready:
          return 'Ready for Pickup';
        case OrderStatus.pickedUp:
          return 'Picked Up';
        case OrderStatus.onTheWay:
          return 'On The Way';
        case OrderStatus.delivered:
          return 'Delivered';
        default:
          return 'Pending';
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: AppTheme.mainBackground,
        foregroundColor: AppTheme.primaryText,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardBackground,
            child: Column(
              children: [
                Text(
                  'Order #${displayOrder.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MK${displayOrder.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: statusFlow.length,
              itemBuilder: (context, index) {
                final status = statusFlow[index];
                final isCompleted = statusFlow.indexOf(status) <= getCurrentStep();
                final isCurrent = statusFlow.indexOf(status) == getCurrentStep();
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.success
                          : AppTheme.secondaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: isCompleted ? Colors.white : AppTheme.mutedText,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    getStatusText(status),
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? AppTheme.primaryText : AppTheme.secondaryText,
                    ),
                  ),
                  trailing: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.kitchen;
      case OrderStatus.ready:
        return Icons.done_all;
      case OrderStatus.pickedUp:
        return Icons.local_shipping;
      case OrderStatus.onTheWay:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.home;
      default:
        return Icons.pending;
    }
  }
}