import 'package:flutter/material.dart';
import '../../config/theme.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
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
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
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