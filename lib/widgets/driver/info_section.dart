import 'package:flutter/material.dart';
import '../../config/theme.dart';

class InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String address;

  const InfoSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryText)),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(address, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}