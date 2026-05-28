import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class DeliveryStatusCard extends StatefulWidget {
  const DeliveryStatusCard({super.key});

  @override
  State<DeliveryStatusCard> createState() => _DeliveryStatusCardState();
}

class _DeliveryStatusCardState extends State<DeliveryStatusCard> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  Order? _activeOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveOrder();
  }

  Future<void> _loadActiveOrder() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final orders = await _apiService.getMyOrders();
      print('📦 Loaded ${orders.length} orders');
      
      // Print all orders for debugging
      for (var order in orders) {
        print('   Order #${order.id}: status=${order.status}, items=${order.items.length}');
      }
      
      // Find order that is ready to be delivered (not yet delivered)
      // Check for statuses like: 'pending', 'confirmed', 'preparing', 'ready', 'out_for_delivery'
      Order? foundOrder;
      for (var order in orders) {
        // Don't mark already delivered or cancelled orders
        if (order.status == OrderStatus.delivered || 
            order.status == OrderStatus.cancelled ||
            order.status == OrderStatus.received) {
          continue;
        }
        
        // These are orders that can be marked as delivered
        if (order.status == OrderStatus.onTheWay || 
            order.status == OrderStatus.pickedUp ||
            order.status == OrderStatus.outForDelivery ||
            order.status == OrderStatus.ready) {
          foundOrder = order;
          break;
        }
      }
      
      if (mounted) {
        setState(() {
          _activeOrder = foundOrder;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading active order: $e');
      if (mounted) {
        setState(() {
          _activeOrder = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markOrderAsDelivered() async {
    if (_isProcessing) return;
    
    final orderToDeliver = _activeOrder;
    if (orderToDeliver == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active order found'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });

    try {
      print('✅ Found active order #${orderToDeliver.id} with status: ${orderToDeliver.status}');

      // Get item names for display
      String itemNames = '';
      if (orderToDeliver.items.isNotEmpty) {
        List<String> names = orderToDeliver.items.map((item) => item.name).toList();
        itemNames = names.join(', ');
        if (itemNames.length > 30) {
          itemNames = itemNames.substring(0, 27) + '...';
        }
      }

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          backgroundColor: AppTheme.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppTheme.success),
              SizedBox(width: 10),
              Text('Confirm Delivery'),
            ],
          ),
          content: Text(
            'Have you received your order?\n\nOrder #${orderToDeliver.id}\n$itemNames',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Not Yet',
                style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Yes, Received'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Update order status to "delivered" - this will trigger notification to restaurant
      final result = await _apiService.updateOrderStatus(orderToDeliver.id.toString(), 'delivered');
      print('✅ Update result: $result');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Order #${orderToDeliver.id} marked as delivered! Restaurant owner has been notified.'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        setState(() {
          _activeOrder = null;
          _isProcessing = false;
        });
        
        // Refresh the page to update order status
        context.go('/home');
      }
    } catch (e) {
      print('Error marking order as delivered: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark order as delivered: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _getOrderSummary() {
    if (_activeOrder == null) {
      return 'No active orders';
    }
    
    String itemNames = '';
    if (_activeOrder!.items.isNotEmpty) {
      List<String> names = _activeOrder!.items.map((item) => item.name).toList();
      itemNames = names.join(', ');
      if (itemNames.length > 22) {
        itemNames = itemNames.substring(0, 19) + '...';
      }
    }
    
    return '$itemNames (Order #${_activeOrder!.id})';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.deepCrimson.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delivery_dining, color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Order',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _activeOrder != null ? _getOrderSummary() : 'No active orders',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (_activeOrder != null && !_isLoading)
            GestureDetector(
              onTap: _isProcessing ? null : _markOrderAsDelivered,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isProcessing ? Colors.grey : AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Received',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}