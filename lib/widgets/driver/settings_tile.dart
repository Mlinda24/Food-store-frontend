import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryRed).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppTheme.primaryRed),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppTheme.mutedText),
      onTap: onTap,
    );
  }
}