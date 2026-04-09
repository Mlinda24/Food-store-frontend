import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final history = driverProvider.deliveryHistory;

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
                      delivery.estimatedTime,
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
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}