import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'],
            size: 14,
            color: statusInfo['color'],
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['label'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusInfo['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': 'Pending',
          'color': AppTheme.warning,
          'icon': Icons.pending_actions,
        };
      case 'accepted':
        return {
          'label': 'Accepted',
          'color': AppTheme.success,
          'icon': Icons.check_circle,
        };
      case 'picked_up':
        return {
          'label': 'Out for Delivery',
          'color': AppTheme.primaryRed,
          'icon': Icons.delivery_dining,
        };
      case 'delivered':
        return {
          'label': 'Delivered',
          'color': AppTheme.success,
          'icon': Icons.check_circle_outline,
        };
      default:
        return {
          'label': status,
          'color': AppTheme.mutedText,
          'icon': Icons.circle_outlined,
        };
    }
  }
}