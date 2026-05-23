import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../utils/theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order? order;

  const OrderTrackingScreen({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final Order displayOrder = order ??
        Order(
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

    final currentStatus = displayOrder.status;
    final statusSteps = _getOrderSteps();

    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: AppTheme.mainBackground,
        foregroundColor: AppTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Total: MK${displayOrder.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on: ${_formatDate(displayOrder.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Progress timeline
            const Text(
              'Order Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal scrollable timeline
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statusSteps.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final step = statusSteps[index];
                  final isCompleted = step.statusIndex < _getCurrentStepIndex(currentStatus);
                  final isActive = step.statusIndex == _getCurrentStepIndex(currentStatus);

                  Color stepColor;
                  if (isCompleted) {
                    stepColor = AppTheme.success;
                  } else if (isActive) {
                    stepColor = AppTheme.primaryRed;
                  } else {
                    stepColor = AppTheme.secondaryText.withOpacity(0.4);
                  }

                  return Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stepColor.withOpacity(0.2),
                          border: Border.all(color: stepColor, width: 2),
                        ),
                        child: Icon(
                          step.icon,
                          color: stepColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 80,
                        child: Text(
                          step.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: stepColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Current status message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRed.withOpacity(0.1), AppTheme.primaryRed.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(currentStatus),
                    size: 32,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status: ${_getStatusText(currentStatus)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStatusMessage(currentStatus),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Timeline steps (without Preparing and On The Way)
  List<OrderStep> _getOrderSteps() {
    return [
      OrderStep(OrderStatus.pending, 'Pending', Icons.pending_actions, 0),
      OrderStep(OrderStatus.confirmed, 'Confirmed', Icons.check_circle_outline, 1),
      OrderStep(OrderStatus.ready, 'Ready', Icons.shopping_bag, 2),
      OrderStep(OrderStatus.pickedUp, 'Picked Up', Icons.motorcycle, 3),
      OrderStep(OrderStatus.delivered, 'Delivered', Icons.home, 4),
    ];
  }

  // Map each status to its index in the timeline
  int _getCurrentStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 1; // Treat Preparing same as Confirmed
      case OrderStatus.ready:
        return 2;
      case OrderStatus.pickedUp:
        return 3;
      case OrderStatus.onTheWay:
        return 3; // Treat On The Way same as Picked Up
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.kitchen;
      case OrderStatus.ready:
        return Icons.shopping_bag;
      case OrderStatus.pickedUp:
        return Icons.motorcycle;
      case OrderStatus.onTheWay:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been received and is waiting for confirmation.';
      case OrderStatus.confirmed:
        return 'Great! Your order has been confirmed. The restaurant is preparing your meal.';
      case OrderStatus.preparing:
        return 'The chef is cooking your delicious meal. It will be ready soon!';
      case OrderStatus.ready:
        return 'Your order is ready for pickup by the delivery partner.';
      case OrderStatus.pickedUp:
        return 'The delivery person has picked up your order and is on the way.';
      case OrderStatus.onTheWay:
        return 'Your food is almost there! Get ready to enjoy.';
      case OrderStatus.delivered:
        return 'Order delivered successfully! Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled. Please contact support.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Helper model for steps
class OrderStep {
  final OrderStatus status;
  final String label;
  final IconData icon;
  final int statusIndex;

  OrderStep(this.status, this.label, this.icon, this.statusIndex);
}