import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ScheduleItem extends StatelessWidget {
  final String orderId;
  final String restaurant;
  final String customer;
  final String time;
  final String status;
  final VoidCallback onTap;

  const ScheduleItem({
    super.key,
    required this.orderId,
    required this.restaurant,
    required this.customer,
    required this.time,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                  const SizedBox(height: 2),
                  Text(customer, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Available' ? AppTheme.success.withOpacity(0.15) : AppTheme.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status, style: TextStyle(fontSize: 10, color: status == 'Available' ? AppTheme.success : AppTheme.warning)),
            ),
          ],
        ),
      ),
    );
  }
}