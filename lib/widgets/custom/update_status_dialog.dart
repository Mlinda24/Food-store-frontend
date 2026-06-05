import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

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
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;
    final bg = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final subColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

    return AlertDialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Update Status', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current: ${_label(currentStatus)}',
              style: TextStyle(fontSize: 12, color: subColor)),
          const SizedBox(height: 12),

          // Step 1: driver_assigned → driver_arrived
          if (currentStatus == 'driver_assigned')
            _option(context, Icons.restaurant, 'Arrived at Restaurant',
                AppTheme.warning, 'driver_arrived'),

          // Step 2: driver_arrived → picked_up
          if (currentStatus == 'driver_arrived')
            _option(context, Icons.inventory, 'Picked Up Food',
                AppTheme.teal, 'picked_up'),

          // Step 3: picked_up → delivered
          if (currentStatus == 'picked_up')
            _option(context, Icons.home, 'Mark as Delivered',
                AppTheme.success, 'delivered'),

          if (!['driver_assigned', 'driver_arrived', 'picked_up']
              .contains(currentStatus))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No further updates available.',
                  style: TextStyle(color: subColor)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: subColor)),
        ),
      ],
    );
  }

  Widget _option(BuildContext context, IconData icon, String label,
      Color color, String status) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.pop(context);
        onStatusUpdate(status);
      },
    );
  }

  String _label(String s) => {
    'driver_assigned': 'Assigned',
    'driver_arrived': 'Arrived at Restaurant',
    'picked_up': 'Picked Up',
    'delivered': 'Delivered',
  }[s] ?? s;
}