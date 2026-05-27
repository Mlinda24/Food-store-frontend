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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.palette_outlined, color: AppTheme.primaryRed),
            const SizedBox(width: 10),
            Text('Select Theme', style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, Icons.light_mode, 'Light Mode', AppTheme.yellow, () {
              appProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            }),
            _buildThemeOption(context, Icons.dark_mode, 'Dark Mode', AppTheme.primaryRed, () {
              appProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            }),
            _buildThemeOption(context, Icons.smartphone, 'System Default', AppTheme.teal, () {
              appProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontSize: 16)),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppTheme.getMutedTextColor(context)),
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppTheme.error),
            const SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout(context: context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _goBack(BuildContext context) {
    // FIXED: Properly handle back navigation with go_router
    // Use canPop() to check if there's anything to pop first
    if (context.canPop()) {
      context.pop();
    } else {
      // If nothing to pop, navigate to home screen
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor ?? AppTheme.primaryRed),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? AppTheme.getPrimaryTextColor(context))),
                  if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.getMutedTextColor(context)),
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
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => _goBack(context),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card - from /api/auth/me/
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGlowGradient(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name?.split('@')[0] ?? 'User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                currentRole == UserRole.restaurant ? Icons.restaurant : Icons.person,
                                size: 12,
                                color: AppTheme.primaryRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentRoleName,
                                style: TextStyle(
                                  fontSize: 10,
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
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
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
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
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
            
            const SizedBox(height: 30),
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text('About Foodie Express'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('A food delivery app connecting you with the best restaurants in your area.'),
            const SizedBox(height: 8),
            Text('© 2026 Foodie Express. All rights reserved.', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getMutedTextColor(context), letterSpacing: 1)),
        ],
      ),
    );
  }
}