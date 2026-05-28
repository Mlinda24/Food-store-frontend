import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';
  
  final List<String> _languages = ['English', 'Chichewa'];
  
  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _deliveryFeeController.dispose();
    _minOrderController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRestaurantData() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.loadRestaurantInfo();
    
    final restaurant = provider.restaurant;
    if (restaurant != null) {
      _nameController.text = restaurant.name;
      _phoneController.text = restaurant.phone;
      _addressController.text = restaurant.address;
      _descriptionController.text = restaurant.description;
      _deliveryFeeController.text = restaurant.deliveryFee.toString();
      _minOrderController.text = restaurant.minOrderAmount.toString();
      _deliveryTimeController.text = restaurant.deliveryTime.toString();
      
      setState(() {});
    }
  }
  
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    
    final success = await provider.updateMyRestaurant({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'description': _descriptionController.text.trim(),
      'delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 0,
      'min_order_amount': double.tryParse(_minOrderController.text) ?? 0,
      'delivery_time': int.tryParse(_deliveryTimeController.text) ?? 30,
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }
  
  Future<void> _showLogoutDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logging out...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      await authProvider.logout(context: context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Restaurant Profile'),
        backgroundColor: AppTheme.getBackgroundColor(context),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Edit'),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryButtonGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryRed.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      TextButton(
                        onPressed: () {},
                        child: const Text('Change Logo'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Restaurant Information', Icons.restaurant),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _nameController,
                label: 'Restaurant Name',
                icon: Icons.restaurant,
                enabled: _isEditing,
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                enabled: _isEditing,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                enabled: _isEditing,
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Delivery Settings', Icons.delivery_dining),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _deliveryFeeController,
                label: 'Delivery Fee (MK)',
                icon: Icons.motorcycle,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _minOrderController,
                label: 'Minimum Order Amount (MK)',
                icon: Icons.attach_money,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              
              _buildTextField(
                controller: _deliveryTimeController,
                label: 'Est. Delivery Time (minutes)',
                icon: Icons.access_time,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Notifications', Icons.notifications),
              const SizedBox(height: 12),
              
              _buildToggleCard(
                title: 'Push Notifications',
                subtitle: 'Receive real-time alerts on your device',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              const SizedBox(height: 8),
              
              _buildToggleCard(
                title: 'Email Notifications',
                subtitle: 'Receive order updates via email',
                value: _emailNotifications,
                onChanged: (value) => setState(() => _emailNotifications = value),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Appearance', Icons.brightness_6),
              const SizedBox(height: 12),
              
              _buildThemeSelector(context, appProvider),
              const SizedBox(height: 12),
              
              _buildDropdownField(
                label: 'Language',
                icon: Icons.language,
                value: _selectedLanguage,
                items: _languages,
                enabled: true,
                onChanged: (value) => setState(() => _selectedLanguage = value!),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Account', Icons.account_circle),
              const SizedBox(height: 12),
              
              _buildSettingsTile(
                title: 'Logout',
                icon: Icons.logout,
                iconColor: AppTheme.error,
                textColor: AppTheme.error,
                onTap: _showLogoutDialog,
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Support', Icons.help_outline),
              const SizedBox(height: 12),
              
              _buildSettingsTile(
                title: 'App Version',
                icon: Icons.info_outline,
                trailing: const Text('1.0.0', style: TextStyle(fontSize: 14)),
                onTap: () {},
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeSelector(BuildContext context, AppProvider appProvider) {
    return Card(
      color: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Theme'),
        subtitle: Text(_getThemeText(appProvider.themeMode)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(context, appProvider),
      ),
    );
  }
  
  void _showThemeDialog(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text('Select Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              trailing: appProvider.themeMode == ThemeMode.light ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                appProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: appProvider.themeMode == ThemeMode.dark ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                appProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest),
              title: const Text('System Default'),
              trailing: appProvider.themeMode == ThemeMode.system ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                appProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
  
  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light Mode';
      case ThemeMode.dark: return 'Dark Mode';
      case ThemeMode.system: return 'System Default';
      default: return 'System Default';
    }
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRed),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getPrimaryTextColor(context))),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.getMutedTextColor(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: enabled ? null : AppTheme.getSurfaceColor(context).withOpacity(0.5),
      ),
      validator: (value) {
        if (enabled && (value == null || value.trim().isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.getMutedTextColor(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
  
  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Card(
      color: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        subtitle: Text(subtitle, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? AppTheme.primaryRed,
        inactiveThumbColor: inactiveColor ?? Colors.grey,
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return Card(
      color: AppTheme.getCardColor(context),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.getMutedTextColor(context)),
        title: Text(title, style: TextStyle(color: textColor ?? AppTheme.getPrimaryTextColor(context))),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}