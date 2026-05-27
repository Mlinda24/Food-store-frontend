import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showThemeDialog(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.palette_outlined, color: AppTheme.primaryRed, size: 20),
            const SizedBox(width: 8),
            Text('Select Theme', style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, Icons.light_mode, 'Light Mode', AppTheme.yellow, () {
              appProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            }),
            const SizedBox(height: 6),
            _buildThemeOption(context, Icons.dark_mode, 'Dark Mode', AppTheme.primaryRed, () {
              appProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            }),
            const SizedBox(height: 6),
            _buildThemeOption(context, Icons.smartphone, 'System Default', AppTheme.teal, () {
              appProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppTheme.getMutedTextColor(context), size: 18),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppTheme.error, size: 20),
            const SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logging out...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await authProvider.logout(context: context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? AppTheme.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor ?? AppTheme.getPrimaryTextColor(context))),
                  if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.getSecondaryTextColor(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: AppTheme.getMutedTextColor(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final user = authProvider.currentUser;
    final currentRole = user?.role ?? UserRole.customer;
    final currentRoleName = currentRole == UserRole.restaurant ? 'Restaurant Owner' : 'Customer';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context), size: 22),
          onPressed: () => _goBack(context),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGlowGradient(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name?.split('@')[0] ?? 'User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentRole == UserRole.restaurant ? Icons.restaurant : Icons.person,
                                size: 10,
                                color: AppTheme.primaryRed,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                currentRoleName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Preferences Section
            _buildSectionHeader(context, 'PREFERENCES', Icons.settings_outlined),
            _buildSettingsItem(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Theme',
              subtitle: appProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              onTap: () => _showThemeDialog(context),
            ),
            _buildSettingsItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'View your notifications',
              onTap: () => context.push('/notifications'),
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 60, endIndent: 14),
            
            // Support Section
            _buildSectionHeader(context, 'SUPPORT', Icons.support_agent_outlined),
            _buildSettingsItem(
              context,
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs and support',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 60, endIndent: 14),
            
            // Account Actions
            _buildSectionHeader(context, 'ACCOUNT', Icons.account_circle_outlined),
            _buildSettingsItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () => _showLogoutDialog(context),
              iconColor: AppTheme.error,
              textColor: AppTheme.error,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text('About Foodie Express', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            const Text('A food delivery app connecting you with the best restaurants in your area.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text('© 2026 Foodie Express. All rights reserved.', style: TextStyle(fontSize: 11, color: AppTheme.getSecondaryTextColor(context))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(fontSize: 13, color: AppTheme.getSecondaryTextColor(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryRed),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.getMutedTextColor(context), letterSpacing: 0.8)),
        ],
      ),
    );
  }
}