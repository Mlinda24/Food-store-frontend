import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../widgets/driver/settings_tile.dart';

// Model for a Withdrawal Account - FIXED with non-final properties
class WithdrawalAccount {
  String id;
  String method; // 'airtel' or 'tnm'
  String accountNumber;
  String holderName;
  bool isDefault;

  WithdrawalAccount({
    required this.id,
    required this.method,
    required this.accountNumber,
    required this.holderName,
    this.isDefault = false,
  });
}

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  List<WithdrawalAccount> _withdrawalAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadWithdrawalAccounts();
  }

  // Load saved accounts (mock data for demo)
  void _loadWithdrawalAccounts() {
    _withdrawalAccounts = [
      WithdrawalAccount(
        id: '1',
        method: 'airtel',
        accountNumber: '0999 123 456',
        holderName: 'John Driver',
        isDefault: true,
      ),
    ];
    setState(() {});
  }

  void _addWithdrawalAccount() {
    _showAccountDialog();
  }

  void _editWithdrawalAccount(WithdrawalAccount account) {
    _showAccountDialog(account: account);
  }

  void _deleteWithdrawalAccount(WithdrawalAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text('Are you sure you want to remove ${account.method.toUpperCase()} account ${account.accountNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _withdrawalAccounts.removeWhere((acc) => acc.id == account.id);
                if (account.isDefault && _withdrawalAccounts.isNotEmpty) {
                  _withdrawalAccounts.first.isDefault = true;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account removed'), backgroundColor: AppTheme.error),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _setDefaultAccount(WithdrawalAccount selectedAccount) {
    setState(() {
      for (var acc in _withdrawalAccounts) {
        acc.isDefault = (acc.id == selectedAccount.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Default withdrawal account updated to ${selectedAccount.method.toUpperCase()}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showAccountDialog({WithdrawalAccount? account}) {
    final isEditing = account != null;
    final nameController = TextEditingController(text: account?.holderName ?? '');
    final phoneController = TextEditingController(text: account?.accountNumber ?? '');
    String selectedMethod = account?.method ?? 'airtel';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Withdrawal Account' : 'Add Withdrawal Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Method Selection
                Row(
                  children: [
                    _buildMethodOption(
                      method: 'airtel',
                      label: 'Airtel Money',
                      icon: Icons.phone_android,
                      selectedMethod: selectedMethod,
                      onTap: () => setStateDialog(() => selectedMethod = 'airtel'),
                    ),
                    const SizedBox(width: 16),
                    _buildMethodOption(
                      method: 'tnm',
                      label: 'TNM Mpamba',
                      icon: Icons.phone_iphone,
                      selectedMethod: selectedMethod,
                      onTap: () => setStateDialog(() => selectedMethod = 'tnm'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.primaryText),
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'Full name on the account',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTheme.primaryText),
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'e.g., 0999 123 456',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields'), backgroundColor: AppTheme.error),
                    );
                    return;
                  }
                  setState(() {
                    if (isEditing) {
                      // Update existing account
                      account!.holderName = nameController.text;
                      account!.accountNumber = phoneController.text;
                      account!.method = selectedMethod;
                    } else {
                      // Add new account
                      _withdrawalAccounts.add(WithdrawalAccount(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        method: selectedMethod,
                        accountNumber: phoneController.text,
                        holderName: nameController.text,
                        isDefault: _withdrawalAccounts.isEmpty,
                      ));
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Save Changes' : 'Add Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMethodOption({
    required String method,
    required String label,
    required IconData icon,
    required String selectedMethod,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRed.withOpacity(0.2) : AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryRed : AppTheme.mutedText.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: isSelected ? AppTheme.primaryRed : AppTheme.mutedText),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);
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
            _buildWithdrawalSection(context),
            const SizedBox(height: 12),
            _buildPreferencesSection(context),
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
                    _buildBadge(Icons.star, '${driverStats.rating} ★', AppTheme.success),
                    const SizedBox(width: 8),
                    _buildBadge(Icons.delivery_dining, '${driverStats.totalDeliveries} deliveries', AppTheme.primaryRed),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryText),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              'WITHDRAWAL ACCOUNTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          if (_withdrawalAccounts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No withdrawal accounts added. Tap + to add one.',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              ),
            ),
          
          ..._withdrawalAccounts.map((account) => _buildAccountTile(account)),
          
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _addWithdrawalAccount,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Withdrawal Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryBackground,
                foregroundColor: AppTheme.primaryRed,
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(WithdrawalAccount account) {
    return Dismissible(
      key: Key(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Account'),
            content: Text('Remove ${account.method.toUpperCase()} account ending with ${account.accountNumber.substring(account.accountNumber.length - 4)}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: AppTheme.error))),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteWithdrawalAccount(account),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon based on method
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  account.method == 'airtel' ? Icons.phone_android : Icons.phone_iphone,
                  size: 28,
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.method.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.accountNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.holderName,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            if (account.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.success,
                  ),
                ),
              ),
            if (!account.isDefault)
              TextButton(
                onPressed: () => _setDefaultAccount(account),
                child: const Text(
                  'Set Default',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryText),
              onPressed: () => _editWithdrawalAccount(account),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(context),
          ),
          SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Push notifications, sounds, alerts',
            onTap: () => _showNotificationSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SUPPORT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs, guides, tutorials',
            onTap: () => _showComingSoon(context, 'Help Center'),
          ),
          SettingsTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            subtitle: '24/7 driver support',
            onTap: () => _showContactSupport(context),
          ),
          SettingsTile(
            icon: Icons.report_problem,
            title: 'Report an Issue',
            subtitle: 'Technical support, delivery problems',
            onTap: () => _showReportIssue(context),
          ),
          SettingsTile(
            icon: Icons.rate_review,
            title: 'Rate the App',
            subtitle: 'Help us improve',
            onTap: () => _rateApp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: 'Version 1.0.0',
            onTap: () => _showVersionInfo(context),
          ),
          SettingsTile(
            icon: Icons.security,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => _showComingSoon(context, 'Privacy Policy'),
          ),
          SettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Driver agreement terms',
            onTap: () => _showComingSoon(context, 'Terms of Service'),
          ),
          SettingsTile(
            icon: Icons.verified_user,
            title: 'License & Permissions',
            subtitle: 'View app permissions',
            onTap: () => _showComingSoon(context, 'License & Permissions'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(context),
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
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
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
              title: const Text('Chichewa'),
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
              context.go('/login');
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