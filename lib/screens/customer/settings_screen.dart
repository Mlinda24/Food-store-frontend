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
        title: Text('Select Theme', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode, color: AppTheme.yellow),
              title: Text('Light Mode', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
              onTap: () {
                appProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: AppTheme.primaryRed),
              title: Text('Dark Mode', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
              onTap: () {
                appProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone, color: AppTheme.teal),
              title: Text('System Default', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Switch Role', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentRole == UserRole.customer ? AppTheme.primaryRed.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.person_outline, color: currentRole == UserRole.customer ? AppTheme.primaryRed : AppTheme.getSecondaryTextColor(context)),
                title: Text('Customer', style: TextStyle(color: currentRole == UserRole.customer ? AppTheme.primaryRed : AppTheme.getPrimaryTextColor(context))),
                subtitle: Text('Order food from restaurants', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                trailing: currentRole == UserRole.customer ? const Icon(Icons.check_circle, color: AppTheme.primaryRed) : null,
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
            Container(
              decoration: BoxDecoration(
                color: currentRole == UserRole.restaurant ? AppTheme.primaryRed.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.restaurant_outlined, color: currentRole == UserRole.restaurant ? AppTheme.primaryRed : AppTheme.getSecondaryTextColor(context)),
                title: Text('Restaurant Owner', style: TextStyle(color: currentRole == UserRole.restaurant ? AppTheme.primaryRed : AppTheme.getPrimaryTextColor(context))),
                subtitle: Text('Manage your restaurant and orders', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                trailing: currentRole == UserRole.restaurant ? const Icon(Icons.check_circle, color: AppTheme.primaryRed) : null,
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
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Switch', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      ),
    );
  }

  void _switchRole(BuildContext context, UserRole newRole) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentRole = authProvider.currentUser?.role;
    
    if (currentRole == newRole) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Confirm Switch', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text(
          'Are you sure you want to switch to ${_getRoleName(newRole)}?\n\nYou will be redirected to the ${_getRoleName(newRole)} dashboard.',
          style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Switch', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      ),
    );

    if (confirm == true) {
      await authProvider.switchRole(newRole);
      String route = newRole == UserRole.restaurant ? '/restaurant' : '/home';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to ${_getRoleName(newRole)} role'), backgroundColor: AppTheme.success, duration: const Duration(seconds: 2)),
      );
      context.go(route);
    }
  }

  String _getRoleName(UserRole role) {
    return role == UserRole.restaurant ? 'Restaurant Owner' : 'Customer';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Logout', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Select Language', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check, color: AppTheme.primaryRed),
              title: Text('English', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.check, color: Colors.transparent),
              title: Text('Chichewa', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor ?? AppTheme.primaryRed),
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
                      color: textColor ?? AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.getMutedTextColor(context),
            ),
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
    final currentRoleName = currentRole == UserRole.restaurant ? 'Restaurant Owner' : 'Customer';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Role Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      currentRole == UserRole.restaurant ? Icons.restaurant : Icons.person,
                      color: AppTheme.primaryRed,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Role',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentRoleName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () => _showRoleSwitchDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Switch',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  color: AppTheme.getMutedTextColor(context),
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
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            _buildSettingsItem(
              context,
              icon: Icons.switch_account_outlined,
              title: 'Switch Role',
              subtitle: currentRole == UserRole.restaurant ? 'Switch to Customer mode' : 'Switch to Restaurant Owner mode',
              onTap: () => _showRoleSwitchDialog(context),
              iconColor: AppTheme.warning,
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            // Preferences Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getMutedTextColor(context),
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
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            _buildSettingsItem(
              context,
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English / Chichewa',
              onTap: () => _showLanguageDialog(context),
            ),
            
            // Support Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'SUPPORT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getMutedTextColor(context),
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

            // Account Actions Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                'ACCOUNT ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getMutedTextColor(context),
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