import 'package:flutter/material.dart';
import '../../config/theme.dart';

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
    // Filter available statuses based on current status
    final availableStatuses = _getAvailableStatuses();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cardBackground, AppTheme.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              'Update Delivery Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${_getCurrentStatusLabel()}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            
            // Status Options
            ...availableStatuses.map((status) => _buildStatusOption(status)),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(Map<String, dynamic> status) {
    final isSelected = _selectedStatus == status['value'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status['value'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (status['color'] as Color).withOpacity(0.1)
              : AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? status['color'] as Color
                : AppTheme.mutedText.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              status['icon'],
              color: isSelected ? status['color'] : AppTheme.mutedText,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? status['color'] : AppTheme.primaryText,
                    ),
                  ),
                  Text(
                    status['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: status['color'],
                size: 20,
              ),
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