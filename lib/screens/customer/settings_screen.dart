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
              context.read<AuthProvider>().logout();
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

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    
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
            Icon(Icons.edit, color: AppTheme.primaryRed),
            const SizedBox(width: 10),
            Text('Edit Profile', style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryRed),
                filled: true,
                fillColor: AppTheme.getSurfaceColor(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRed),
                filled: true,
                fillColor: AppTheme.getSurfaceColor(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryRed),
                filled: true,
                fillColor: AppTheme.getSurfaceColor(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement profile update API call
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile update coming soon!'), backgroundColor: AppTheme.success),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Save Changes'),
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
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
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
                  // Avatar
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
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
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
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showEditProfileDialog(context, user!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.getSurfaceColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 12, color: AppTheme.getSecondaryTextColor(context)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Account Section
            _buildSectionHeader(context, 'ACCOUNT', Icons.person_outline),
            _buildSettingsItem(
              context,
              icon: Icons.person_outline,
              title: 'Profile Information',
              subtitle: 'View and edit your personal details',
              onTap: () => _showEditProfileDialog(context, user!),
            ),
            _buildSettingsItem(
              context,
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              subtitle: user?.phone ?? 'Not set',
              onTap: () => _showEditProfileDialog(context, user!),
            ),
            _buildSettingsItem(
              context,
              icon: Icons.email_outlined,
              title: 'Email Address',
              subtitle: user?.email ?? 'Not set',
              onTap: () => _showEditProfileDialog(context, user!),
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
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
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English / Chichewa',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Push notifications, email alerts',
              onTap: () {},
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            // Security Section
            _buildSectionHeader(context, 'SECURITY', Icons.security_outlined),
            _buildSettingsItem(
              context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {},
              iconColor: AppTheme.warning,
            ),
            _buildSettingsItem(
              context,
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Enable fingerprint or face recognition',
              onTap: () {},
              iconColor: AppTheme.teal,
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            // Support Section
            _buildSectionHeader(context, 'SUPPORT', Icons.support_agent_outlined),
            _buildSettingsItem(
              context,
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs, guides, and tutorials',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              subtitle: 'Help us improve your experience',
              onTap: () {},
            ),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0 | Terms & Privacy',
              onTap: () {},
            ),
            
            const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
            
            // Account Actions
            _buildSectionHeader(context, 'ACCOUNT ACTIONS', Icons.warning_amber_outlined),
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
