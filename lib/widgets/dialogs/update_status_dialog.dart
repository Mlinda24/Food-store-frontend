import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

class UpdateStatusDialog extends StatefulWidget {
  final String currentStatus;
  final Function(String) onStatusUpdate;

  const UpdateStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusUpdate,
  });

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  String _selectedStatus = '';

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'picked_up',
      'label': 'Picked Up Food',
      'icon': Icons.restaurant,
      'description': 'You have picked up the order from restaurant',
      'color': AppTheme.primaryRed,
    },
    {
      'value': 'delivered',
      'label': 'Delivered to Customer',
      'icon': Icons.home,
      'description': 'Order has been delivered successfully',
      'color': AppTheme.success,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    final availableStatuses = _getAvailableStatuses();
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = theme.isDarkMode;

    final bgColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final subColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final optionBg = isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground;
    final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Delivery Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${_getCurrentStatusLabel()}',
              style: TextStyle(fontSize: 14, color: subColor),
            ),
            const SizedBox(height: 20),
            ...availableStatuses.map((status) => _buildStatusOption(status, optionBg, textColor, mutedColor)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel', style: TextStyle(color: textColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedStatus != widget.currentStatus
                        ? () {
                            widget.onStatusUpdate(_selectedStatus);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(Map<String, dynamic> status, Color optionBg, Color textColor, Color mutedColor) {
    final isSelected = _selectedStatus == status['value'];

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? (status['color'] as Color).withOpacity(0.1) : optionBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? status['color'] as Color : mutedColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(status['icon'], color: isSelected ? status['color'] : mutedColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? status['color'] : textColor,
                    ),
                  ),
                  Text(
                    status['description'],
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: status['color'], size: 20),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableStatuses() {
    if (widget.currentStatus == 'accepted') {
      return _statusOptions.where((s) => s['value'] == 'picked_up').toList();
    } else if (widget.currentStatus == 'picked_up') {
      return _statusOptions.where((s) => s['value'] == 'delivered').toList();
    }
    return [];
  }

  String _getCurrentStatusLabel() {
    if (widget.currentStatus == 'accepted') return 'Accepted';
    if (widget.currentStatus == 'picked_up') return 'Picked Up';
    if (widget.currentStatus == 'delivered') return 'Delivered';
    return widget.currentStatus;
  }
}