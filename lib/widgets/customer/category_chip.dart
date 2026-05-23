import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.primaryButton
              : null,
          color: isSelected ? null : (isDark ? AppTheme.darkSurface : AppTheme.lightBackground),
          borderRadius: BorderRadius.circular(30),
          border: isSelected
              ? null
              : Border.all(color: (isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText).withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}