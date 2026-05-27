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

  Future<void> _markOrderAsDelivered() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get the customer's orders
      final orders = await _apiService.getMyOrders();
      
      print('📦 Found ${orders.length} orders');
      
      // Find order that is onTheWay or delivered (ready to be marked as received)
      final activeOrder = orders.firstWhere(
        (order) => order.status == OrderStatus.onTheWay || 
                   order.status == OrderStatus.delivered,
        orElse: () => throw Exception('No active order found'),
      );

      print('✅ Found active order #${activeOrder.id} with status: ${activeOrder.status}');

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppTheme.success),
              const SizedBox(width: 10),
              Text(
                'Confirm Delivery',
                style: TextStyle(
                  color: AppTheme.getPrimaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Have you received your order #${activeOrder.id}?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Not Yet',
                style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Yes, Delivered'),
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

      // Update order status to "delivered"
      await _apiService.updateOrderStatus(activeOrder.id.toString(), 'delivered');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Order #${activeOrder.id} marked as delivered!'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Refresh the page
        context.go('/home');
      }
    } catch (e) {
      print('Error marking order as delivered: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No active orders to mark as delivered'),
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
                const Text(
                  'Fast Delivery Service',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get your favorite food delivered in 30-45 minutes',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
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