import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/driver/settings_tile.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final driverName = authProvider.currentUser?.name ?? 'John Driver';
    final driverEmail = authProvider.currentUser?.email ?? 'driver@example.com';
    final driverStats = driverProvider.stats;

    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        backgroundColor: AppTheme.mainBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(context, driverName, driverEmail, driverStats),
            const SizedBox(height: 12),
            _buildPreferencesSection(context, themeProvider),
            const SizedBox(height: 12),
            _buildAccountSection(context),
            const SizedBox(height: 12),
            _buildSupportSection(context),
            const SizedBox(height: 12),
            _buildAboutSection(context),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, String name, String email, driverStats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                          const SizedBox(width: 4),
                          Text(
                            '${driverStats.rating} ★',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delivery_dining, size: 12, color: AppTheme.primaryRed),
                          const SizedBox(width: 4),
                          Text(
                            '${driverStats.totalDeliveries} deliveries',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppTheme.primaryText),
              onPressed: () {
                _showEditProfileDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson, thickness: 0.5),
          
          SettingsTile(
            icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            subtitle: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              activeColor: AppTheme.primaryRed,
              activeTrackColor: AppTheme.primaryRed.withOpacity(0.5),
            ),
            iconColor: themeProvider.isDarkMode ? Colors.purple : Colors.orange,
          ),
          
          SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.straighten,
            title: 'Distance Unit',
            subtitle: 'Kilometers (km)',
            onTap: () {
              _showUnitDialog(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Push notifications, sounds, alerts',
            onTap: () {
              _showNotificationSettings(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson, thickness: 0.5),
          
          SettingsTile(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Add or remove payment methods',
            onTap: () {
              _showComingSoon(context, 'Payment Methods');
            },
          ),
          
          SettingsTile(
            icon: Icons.attach_money,
            title: 'Withdrawal Settings',
            subtitle: 'Bank account, mobile money',
            onTap: () {
              _showComingSoon(context, 'Withdrawal Settings');
            },
          ),
          
          SettingsTile(
            icon: Icons.directions_car,
            title: 'Vehicle Information',
            subtitle: 'Update your vehicle details',
            onTap: () {
              _showComingSoon(context, 'Vehicle Information');
            },
          ),
          
          SettingsTile(
            icon: Icons.assignment,
            title: 'Delivery Preferences',
            subtitle: 'Max distance, order size',
            onTap: () {
              _showComingSoon(context, 'Delivery Preferences');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson, thickness: 0.5),
          
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs, guides, tutorials',
            onTap: () {
              _showComingSoon(context, 'Help Center');
            },
          ),
          
          SettingsTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            subtitle: '24/7 driver support',
            onTap: () {
              _showContactSupport(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.report_problem,
            title: 'Report an Issue',
            subtitle: 'Technical support, delivery problems',
            onTap: () {
              _showReportIssue(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.rate_review,
            title: 'Rate the App',
            subtitle: 'Help us improve',
            onTap: () {
              _rateApp(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson, thickness: 0.5),
          
          SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showVersionInfo(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.security,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              _showComingSoon(context, 'Privacy Policy');
            },
          ),
          
          SettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Driver agreement terms',
            onTap: () {
              _showComingSoon(context, 'Terms of Service');
            },
          ),
          
          SettingsTile(
            icon: Icons.verified_user,
            title: 'License & Permissions',
            subtitle: 'View app permissions',
            onTap: () {
              _showComingSoon(context, 'License & Permissions');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppTheme.primaryRed),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('French'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kilometers (km)'),
              trailing: const Icon(Icons.check, color: AppTheme.primaryRed),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Miles (mi)'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive order alerts'),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryRed,
            ),
            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Play sound for new orders'),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryRed,
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate for new orders'),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryRed,
            ),
          ],
        ),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryRed),
              title: const Text('Call Support'),
              subtitle: const Text('+265 123 456 789'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryRed),
              title: const Text('Email Support'),
              subtitle: const Text('support@foodieexpress.com'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryRed),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe your issue:'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter details here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for rating!')),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Foodie Express Driver',
      applicationVersion: 'Version 1.0.0',
      applicationIcon: const Icon(Icons.delivery_dining, size: 50, color: AppTheme.primaryRed),
      children: const [
        Text('© 2024 Foodie Express. All rights reserved.'),
        SizedBox(height: 8),
        Text('Built with Flutter'),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}