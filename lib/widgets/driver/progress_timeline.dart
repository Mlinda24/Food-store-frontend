import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

class ProgressTimeline extends StatelessWidget {
  final String status;

  const ProgressTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final steps = ['Accepted', 'Picked Up', 'Delivered'];
    int currentStep = 0;
    
    if (status == 'accepted') currentStep = 0;
    if (status == 'picked_up') currentStep = 1;
    if (status == 'delivered') currentStep = 2;

    final completedColor = AppTheme.success;
    final inactiveColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    final textColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

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
                  color: isCompleted ? completedColor : inactiveColor.withOpacity(0.3),
                  border: Border.all(
                    color: isCompleted ? completedColor : inactiveColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: isCompleted ? Colors.white : inactiveColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? completedColor : textColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}