import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/order_provider.dart';
import '../../utils/theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order? order;

  const OrderTrackingScreen({super.key, this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _order;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _order = widget.order!;
      _isLoading = false;
    }
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _refreshOrder();
        _startPeriodicRefresh();
      }
    });
  }

  Future<void> _refreshOrder() async {
    if (_order.id.isEmpty) return;
    
    if (!_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
    }
    
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final updatedOrder = await orderProvider.getOrder(_order.id);
      
      if (updatedOrder != null && mounted) {
        final oldStatus = _order.status;
        final newStatus = updatedOrder.status;
        
        setState(() {
          _order = updatedOrder;
          _isRefreshing = false;
          _isLoading = false;
          _refreshCount++;
        });
        
        if (oldStatus != newStatus) {
          _showStatusNotification(newStatus);
        }
        
        print('🔄 Order refreshed #${_order.id}: Status = ${_getStatusText(newStatus)}');
      } else {
        setState(() {
          _isRefreshing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error refreshing order: $e');
      setState(() {
        _isRefreshing = false;
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showStatusNotification(OrderStatus status) {
    String message = '';
    Color color = AppTheme.success;
    
    switch (status) {
      case OrderStatus.confirmed:
        message = '✅ Your order has been confirmed!';
        color = AppTheme.success;
        break;
      case OrderStatus.preparing:
        message = '🍳 Your order is being prepared!';
        color = AppTheme.warning;
        break;
      case OrderStatus.ready:
        message = '🛵 Your order is ready for pickup!';
        color = AppTheme.teal;
        break;
      case OrderStatus.pickedUp:
        message = '🚚 The delivery person has picked up your order and is on the way!';
        color = AppTheme.orange;
        break;
      case OrderStatus.delivered:
        message = '🎉 Your order has been delivered! Enjoy your meal!';
        color = AppTheme.success;
        break;
      case OrderStatus.cancelled:
        message = '❌ Your order has been cancelled.';
        color = AppTheme.error;
        break;
      default:
        return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<OrderStep> _getOrderSteps() {
    return [
      OrderStep(OrderStatus.pending, 'Order Placed', Icons.pending_actions, 0),
      OrderStep(OrderStatus.confirmed, 'Confirmed', Icons.check_circle_outline, 1),
      OrderStep(OrderStatus.preparing, 'Preparing', Icons.kitchen, 2),
      OrderStep(OrderStatus.ready, 'Ready for Pickup', Icons.shopping_bag, 3),
      OrderStep(OrderStatus.pickedUp, 'Picked Up', Icons.motorcycle, 4),
      OrderStep(OrderStatus.delivered, 'Delivered', Icons.celebration, 5),
    ];
  }

  int _getCurrentStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.pickedUp:
        return 4;
      case OrderStatus.delivered:
        return 5;
      default:
        return 0;
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
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Processing';
    }
  }

  String _getDetailedStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been received and is waiting for confirmation from the restaurant.';
      case OrderStatus.confirmed:
        return 'Great! Your order has been confirmed. The restaurant is preparing your meal.';
      case OrderStatus.preparing:
        return 'The chef is cooking your delicious meal. It will be ready soon!';
      case OrderStatus.ready:
        return 'Your order is ready for pickup by the delivery partner.';
      case OrderStatus.pickedUp:
        return 'The delivery person has picked up your order and is on the way!';
      case OrderStatus.delivered:
        return 'Order delivered successfully! Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled. Please contact support.';
      default:
        return 'Your order is being processed.';
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
      case OrderStatus.delivered:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.pickedUp:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _order.status;
    final statusSteps = _getOrderSteps();
    final currentStepIndex = _getCurrentStepIndex(currentStatus);

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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, color: AppTheme.primaryText),
                onPressed: _isRefreshing ? null : _refreshOrder,
              ),
              if (_refreshCount > 0 && !_isRefreshing)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading order',
                          style: TextStyle(color: AppTheme.error),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.access_time, size: 12, color: AppTheme.secondaryText),
                            const SizedBox(width: 4),
                            Text(
                              'Updated just now',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryRed.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${_order.id.length > 6 ? _order.id.substring(_order.id.length - 6) : _order.id}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(currentStatus)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(currentStatus),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(currentStatus),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total: MK${_order.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Placed on: ${_formatDate(_order.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              if (_order.deliveryAddress.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Delivery: ${_order.deliveryAddress}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Order Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: statusSteps.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final step = statusSteps[index];
                              final isCompleted = index < currentStepIndex;
                              final isActive = index == currentStepIndex;

                              Color stepColor;
                              if (isCompleted) {
                                stepColor = AppTheme.success;
                              } else if (isActive) {
                                stepColor = AppTheme.primaryRed;
                              } else {
                                stepColor = AppTheme.secondaryText
                                    .withOpacity(0.4);
                              }

                              return Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: stepColor.withOpacity(0.2),
                                      border: Border.all(
                                        color: stepColor,
                                        width: 2,
                                      ),
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
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryRed.withOpacity(0.1),
                                AppTheme.primaryRed.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryRed.withOpacity(0.3),
                            ),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                      _getDetailedStatusMessage(currentStatus),
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

                        const SizedBox(height: 24),

                        if (_order.items.isNotEmpty) ...[
                          const Text(
                            'Order Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryRed.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: _order.items.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.quantity}x ${item.name}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.primaryText,
                                        ),
                                      ),
                                      Text(
                                        'MK${(item.price * item.quantity).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

class OrderStep {
  final OrderStatus status;
  final String label;
  final IconData icon;
  final int statusIndex;

  OrderStep(this.status, this.label, this.icon, this.statusIndex);
}