import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

class ScheduleItem extends StatelessWidget {
  final String orderId;
  final String restaurant;
  final String customer;
  final String time;
  final String status;
  final VoidCallback? onTap;

  const ScheduleItem({
    super.key,
    required this.orderId,
    required this.restaurant,
    required this.customer,
    required this.time,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground;
    final iconBgColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedTextColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.restaurant, size: 20, color: mutedTextColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Order #$orderId • $customer',
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(status),
                ),
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.chevron_right, size: 20, color: AppTheme.mutedText),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ready for Pickup':
        return AppTheme.success;
      case 'Preparing':
        return AppTheme.warning;
      case 'Out for Delivery':
        return AppTheme.primaryRed;
      case 'Available':
        return AppTheme.primaryRed;
      default:
        return AppTheme.mutedText;
    }
  }
}