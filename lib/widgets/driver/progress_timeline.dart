import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ProgressTimeline extends StatelessWidget {
  final String status;

  const ProgressTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ['Accepted', 'Picked Up', 'Delivered'];
    int currentStep = 0;
    
    if (status == 'accepted') currentStep = 0;
    if (status == 'picked_up') currentStep = 1;
    if (status == 'delivered') currentStep = 2;

    return Row(
      children: steps.asMap().entries.map((entry) {
        int idx = entry.key;
        String step = entry.value;
        bool isCompleted = idx <= currentStep;
        bool isCurrent = idx == currentStep;
        
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.success : AppTheme.cardBackground,
                  border: Border.all(
                    color: isCompleted ? AppTheme.success : AppTheme.mutedText,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: isCompleted ? Colors.white : AppTheme.mutedText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? AppTheme.success : AppTheme.mutedText,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}