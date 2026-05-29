import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'picked_up':
        color = Colors.purple;
        label = 'Picked Up';
        break;
      case 'driver_arrived':
        color = Colors.orange;
        label = 'Arrived';
        break;
      case 'delivered':
        color = AppTheme.success;
        label = 'Delivered';
        break;
      case 'declined':
        color = AppTheme.error;
        label = 'Declined';
        break;
      default:
        color = AppTheme.warning;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}