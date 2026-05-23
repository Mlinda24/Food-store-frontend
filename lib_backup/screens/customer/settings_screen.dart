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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text(
          'Select Theme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              onTap: () {
                appProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              onTap: () {
                appProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('System Default'),
              onTap: () {
                appProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSwitchDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentRole = authProvider.currentUser?.role ?? UserRole.customer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text(
          'Switch Role',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Customer Option
            Container(
              decoration: BoxDecoration(
                color: currentRole == UserRole.customer
                    ? AppTheme.primaryRed.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person_outline,
                  color: currentRole == UserRole.customer
                      ? AppTheme.primaryRed
                      : (isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText),
                ),
                title: Text(
                  'Customer',
                  style: TextStyle(
                    color: currentRole == UserRole.customer
                        ? AppTheme.primaryRed
                        : (isDark
                            ? AppTheme.darkPrimaryText
                            : AppTheme.lightPrimaryText),
                    fontWeight: currentRole == UserRole.customer
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Order food from restaurants',
                  style: TextStyle(
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText),
                ),
                trailing: currentRole == UserRole.customer
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryRed)
                    : null,
                onTap: () {
                  if (currentRole != UserRole.customer) {
                    Navigator.pop(context);
                    _switchRole(context, UserRole.customer);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            // Restaurant Owner Option
            Container(
              decoration: BoxDecoration(
                color: currentRole == UserRole.restaurant
                    ? AppTheme.primaryRed.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.restaurant_outlined,
                  color: currentRole == UserRole.restaurant
                      ? AppTheme.primaryRed
                      : (isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText),
                ),
                title: Text(
                  'Restaurant Owner',
                  style: TextStyle(
                    color: currentRole == UserRole.restaurant
                        ? AppTheme.primaryRed
                        : (isDark
                            ? AppTheme.darkPrimaryText
                            : AppTheme.lightPrimaryText),
                    fontWeight: currentRole == UserRole.restaurant
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Manage your restaurant and orders',
                  style: TextStyle(
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText),
                ),
                trailing: currentRole == UserRole.restaurant
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryRed)
                    : null,
                onTap: () {
                  if (currentRole != UserRole.restaurant) {
                    Navigator.pop(context);
                    _switchRole(context, UserRole.restaurant);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark
                        ? AppTheme.darkMutedText
                        : AppTheme.lightMutedText)),
          ),
        ],
      ),
    );
  }

  void _switchRole(BuildContext context, UserRole newRole) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentRole = authProvider.currentUser?.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentRole == newRole) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text('Switch Role',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to switch to ${_getRoleName(newRole)}?\n\nYou will be redirected to the ${_getRoleName(newRole)} dashboard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark
                        ? AppTheme.darkMutedText
                        : AppTheme.lightMutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Switch'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.switchRole(newRole);

      String route = newRole == UserRole.restaurant ? '/restaurant' : '/home';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${_getRoleName(newRole)} role'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
        ),
      );

      context.go(route);
    }
  }

  String _getRoleName(UserRole role) {
    return role == UserRole.restaurant ? 'Restaurant Owner' : 'Customer';
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark
                        ? AppTheme.darkMutedText
                        : AppTheme.lightMutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 22, color: iconColor ?? AppTheme.primaryRed),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor ??
                          (isDark
                              ? AppTheme.darkPrimaryText
                              : AppTheme.lightPrimaryText),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkSecondaryText
                            : AppTheme.lightSecondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20,
                color:
                    isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final currentRole = authProvider.currentUser?.role ?? UserRole.customer;
    final currentRoleName =
        currentRole == UserRole.restaurant ? 'Restaurant Owner' : 'Customer';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark
                  ? AppTheme.darkPrimaryText
                  : AppTheme.lightPrimaryText),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Role Card
            GestureDetector(
              onTap: () => _showRoleSwitchDialog(context),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        currentRole == UserRole.restaurant
                            ? Icons.restaurant
                            : Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Role',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8))),
                          const SizedBox(height: 4),
                          Text(currentRoleName,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Switch',
                            style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Account Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                  letterSpacing: 1,
                ),
              ),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'View and edit your profile information',
              onTap: () => context.push('/profile'),
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            _buildSettingsItem(
              context,
              icon: Icons.switch_account_outlined,
              title: 'Switch Role',
              subtitle: currentRole == UserRole.restaurant
                  ? 'Switch to Customer mode'
                  : 'Switch to Restaurant Owner mode',
              onTap: () => _showRoleSwitchDialog(context),
              iconColor: AppTheme.warning,
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            // Preferences Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                  letterSpacing: 1,
                ),
              ),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Theme',
              subtitle: appProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              onTap: () => _showThemeDialog(context),
              iconColor: AppTheme.primaryRed,
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            _buildSettingsItem(
              context,
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English / Chichewa',
              onTap: () {},
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            _buildSettingsItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () => context.push('/notifications'),
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            // Support Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'SUPPORT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                  letterSpacing: 1,
                ),
              ),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help or contact us',
              onTap: () {},
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            _buildSettingsItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),

            const Divider(
                height: 1,
                color: AppTheme.deepCrimson,
                indent: 70,
                endIndent: 16),

            // Account Actions Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'ACCOUNT ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                  letterSpacing: 1,
                ),
              ),
            ),

            _buildSettingsItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () => _showLogoutDialog(context),
              textColor: AppTheme.error,
              iconColor: AppTheme.error,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
