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
    final List<Map<String, dynamic>> statuses = [
      {'status': 'accepted', 'label': 'Accept Order', 'icon': Icons.check_circle, 'color': Colors.blue},
      {'status': 'driver_arrived', 'label': 'Arrived at Restaurant', 'icon': Icons.location_on, 'color': Colors.orange},
      {'status': 'picked_up', 'label': 'Picked Up Order', 'icon': Icons.shopping_bag, 'color': Colors.purple},
      {'status': 'delivered', 'label': 'Delivered to Customer', 'icon': Icons.home, 'color': AppTheme.success},
    ];

    final currentIndex = statuses.indexWhere((s) => s['status'] == currentStatus);
    final availableStatuses = currentIndex >= 0 ? statuses.sublist(currentIndex + 1) : [];

    return AlertDialog(
      backgroundColor: AppTheme.getCardBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      title: const Text('Update Delivery Status', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableStatuses.map((status) {
          return ListTile(
            leading: Icon(status['icon'], color: status['color']),
            title: Text(status['label']),
            onTap: () {
              Navigator.pop(context);
              onStatusUpdate(status['status']);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}