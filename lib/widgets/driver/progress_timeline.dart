import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ProgressTimeline extends StatelessWidget {
  final String status;

  const ProgressTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['driver_assigned', 'driver_arrived', 'picked_up', 'delivered'];
    final currentIndex = steps.indexOf(status.toLowerCase());
    
    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index <= currentIndex;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        if (index > 0) Expanded(child: Divider(color: isCompleted ? AppTheme.primaryRed : AppTheme.mutedText, thickness: 2)),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? AppTheme.primaryRed : AppTheme.mutedText,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : _getStepIcon(steps[index]),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (index < steps.length - 1) Expanded(child: Divider(color: isCompleted ? AppTheme.primaryRed : AppTheme.mutedText, thickness: 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStepLabel(steps[index]),
                    style: TextStyle(fontSize: 10, color: isCompleted ? AppTheme.primaryRed : AppTheme.mutedText),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

 String _getStepLabel(String step) {
  switch (step) {
    case 'driver_assigned': return 'Assigned';  // ✅ was 'accepted'
    case 'driver_arrived': return 'Arrived';
    case 'picked_up': return 'Picked Up';
    case 'delivered': return 'Delivered';
    default: return step;
  }
}

IconData _getStepIcon(String step) {
  switch (step) {
    case 'driver_assigned': return Icons.check_circle;  // ✅ was 'accepted'
    case 'driver_arrived': return Icons.location_on;
    case 'picked_up': return Icons.shopping_bag;
    case 'delivered': return Icons.home;
    default: return Icons.circle;
  }
}
}