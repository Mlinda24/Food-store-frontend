import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../models/delivery_request.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final history = driverProvider.deliveryHistory;
    final isLoading = driverProvider.isLoading;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: AppTheme.mutedText),
            const SizedBox(height: 16),
            Text(
              'No delivery history',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed deliveries will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final delivery = history[index];
        
        // Handle both DeliveryRequest objects and Map data
        if (delivery is DeliveryRequest) {
          return _buildDeliveryCardFromModel(delivery, context);
        } else {
          return _buildDeliveryCardFromMap(delivery, context);
        }
      },
    );
  }

  Widget _buildDeliveryCardFromModel(DeliveryRequest delivery, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delivery_dining, size: 25, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #${delivery.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${delivery.estimatedTime} min • ${delivery.distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
                if (delivery.deliveredAt != null)
                  Text(
                    _formatDate(delivery.deliveredAt!),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.mutedText,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MK${delivery.earnings.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(delivery.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  delivery.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(delivery.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCardFromMap(Map<String, dynamic> delivery, BuildContext context) {
    final restaurantName = delivery['restaurant_name'] ?? 
                           delivery['order']?['restaurant_name'] ?? 
                           'Restaurant';
    final orderId = delivery['order_id']?.toString() ?? 
                    delivery['id']?.toString() ?? 
                    delivery['order']?['id']?.toString() ?? 
                    'N/A';
    final earnings = double.tryParse(delivery['total_earning']?.toString() ?? '0') ?? 0;
    final status = delivery['status'] ?? 'completed';
    final distance = double.tryParse(delivery['distance_km']?.toString() ?? '0') ?? 0;
    final estimatedTime = delivery['estimated_time_minutes'] ?? 30;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delivery_dining, size: 25, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #$orderId',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$estimatedTime min • ${distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MK${earnings.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppTheme.success;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      case 'picked_up':
        return AppTheme.warning;
      default:
        return AppTheme.mutedText;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'picked_up':
        return 'Picked Up';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}