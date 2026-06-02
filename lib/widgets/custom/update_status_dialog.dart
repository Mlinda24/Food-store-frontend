import 'package:flutter/material.dart';
import '../../config/theme.dart';

class UpdateStatusDialog extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusUpdate;

  const UpdateStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Delivery Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentStatus == 'accepted')
            ListTile(
              leading: const Icon(Icons.restaurant, color: AppTheme.warning),
              title: const Text('Arrived at Restaurant'),
              onTap: () => onStatusUpdate('arrived'),
            ),
          ListTile(
            leading: const Icon(Icons.inventory, color: AppTheme.teal),
            title: const Text('Picked Up'),
            onTap: () => onStatusUpdate('picked_up'),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppTheme.success),
            title: const Text('Delivered'),
            onTap: () => onStatusUpdate('delivered'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ],
    );
  }
}
