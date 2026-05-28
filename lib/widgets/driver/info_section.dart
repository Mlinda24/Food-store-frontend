import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';

class InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String address;
  final String? phone;

  const InfoSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.address,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedTextColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: AppTheme.primaryRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: mutedTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              if (phone != null) ...[
                const SizedBox(height: 2),
                Text(
                  '📞 $phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}