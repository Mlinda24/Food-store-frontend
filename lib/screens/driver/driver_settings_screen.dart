import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/driver/settings_tile.dart';

// Model for a Withdrawal Account
class WithdrawalAccount {
  String id;
  String method;
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
  
  // Profile Data
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _driverName = 'John Driver';
  String _driverEmail = 'driver@example.com';
  String _driverPhone = '0999123456';
  
  // Verification Status
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  
  // Vehicle Information
  String _selectedVehicleType = 'Car';
  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Scooter', 'Bicycle'];
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  bool _hasVehicleInfo = false;
  bool _showVehicleForm = false;
  
  // Password Change
  bool _showPasswordChange = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWithdrawalAccounts();
    _loadProfileData();
    _loadVehicleData();
  }

  void _loadWithdrawalAccounts() {
    _withdrawalAccounts = [
      WithdrawalAccount(
        id: '1',
        method: 'airtel',
        accountNumber: '0999123456',
        holderName: 'John Driver',
        isDefault: true,
      ),
    ];
    setState(() {});
  }

  void _loadProfileData() {
    _driverName = 'John Driver';
    _driverEmail = 'driver@example.com';
    _driverPhone = '0999123456';
  }

  void _loadVehicleData() {
    _vehicleModelController.text = 'Toyota Corolla';
    _vehiclePlateController.text = 'MN 1234';
    _hasVehicleInfo = true;
  }

  void _saveVehicleInfo() {
    if (_vehicleModelController.text.isEmpty || _vehiclePlateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all vehicle fields'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _hasVehicleInfo = true;
      _showVehicleForm = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vehicle information saved successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _editVehicleInfo() {
    setState(() {
      _showVehicleForm = true;
    });
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Car':
        return Icons.directions_car;
      case 'Motorcycle':
        return Icons.motorcycle;
      case 'Scooter':
        return Icons.electric_scooter;
      case 'Bicycle':
        return Icons.pedal_bike;
      default:
        return Icons.directions_car;
    }
  }

  String? _validatePhoneNumber(String method, String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanedNumber.isEmpty) {
      return 'Phone number is required';
    }
    
    if (cleanedNumber.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    
    if (method == 'airtel') {
      if (!cleanedNumber.startsWith('09')) {
        return 'Airtel number must start with 09';
      }
    } else if (method == 'tnm') {
      if (!cleanedNumber.startsWith('08')) {
        return 'TNM number must start with 08';
      }
    }
    
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image'), backgroundColor: AppTheme.error),
      );
    }
  }

  void _showImagePickerOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({required IconData icon, required String label, required VoidCallback onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText, fontSize: 12)),
        ],
      ),
    );
  }

  void _verifyEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We sent a 6-digit code to your email:'),
            const SizedBox(height: 8),
            Text(_driverEmail, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => 
                SizedBox(
                  width: 45,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(color: AppTheme.primaryText),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isEmailVerified = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email verified successfully!'), backgroundColor: AppTheme.success),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _verifyPhone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We sent a 6-digit code to your phone:'),
            const SizedBox(height: 8),
            Text(_driverPhone, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => 
                SizedBox(
                  width: 45,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(color: AppTheme.primaryText),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPhoneVerified = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone verified successfully!'), backgroundColor: AppTheme.success),
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _driverName);
    final emailController = TextEditingController(text: _driverEmail);
    final phoneController = TextEditingController(text: _driverPhone);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: const TextStyle(color: AppTheme.primaryText),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: AppTheme.primaryText),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_android),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _driverName = nameController.text;
                _driverEmail = emailController.text;
                _driverPhone = phoneController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.success),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all password fields'), backgroundColor: AppTheme.error),
      );
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match'), backgroundColor: AppTheme.error),
      );
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: AppTheme.error),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully!'), backgroundColor: AppTheme.success),
    );
    
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _showPasswordChange = false;
    });
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
        content: Text('Are you sure you want to remove ${account.method.toUpperCase()} account ${_formatPhoneNumber(account.accountNumber)}?'),
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
                const SnackBar(content: Text('Account removed successfully'), backgroundColor: AppTheme.error),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatPhoneNumber(String number) {
    if (number.length == 10) {
      return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
    }
    return number;
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
    String? phoneError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          final isDark = themeProvider.isDarkMode;
          
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
            title: Text(isEditing ? 'Edit Withdrawal Account' : 'Add Withdrawal Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildMethodOption(
                      method: 'airtel',
                      label: 'Airtel Money',
                      icon: Icons.phone_android,
                      selectedMethod: selectedMethod,
                      onTap: () {
                        setStateDialog(() {
                          selectedMethod = 'airtel';
                          phoneError = null;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildMethodOption(
                      method: 'tnm',
                      label: 'TNM Mpamba',
                      icon: Icons.phone_iphone,
                      selectedMethod: selectedMethod,
                      onTap: () {
                        setStateDialog(() {
                          selectedMethod = 'tnm';
                          phoneError = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                  decoration: InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'Full name on the account',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                  onChanged: (value) {
                    setStateDialog(() {
                      phoneError = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: selectedMethod == 'airtel' ? 'e.g., 0999123456' : 'e.g., 0888123456',
                    prefixIcon: Icon(selectedMethod == 'airtel' ? Icons.phone_android : Icons.phone_iphone),
                    errorText: phoneError,
                    helperText: 'Must be exactly 10 digits',
                    helperStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  String cleanedNumber = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  String? validationError = _validatePhoneNumber(selectedMethod, cleanedNumber);
                  
                  if (validationError != null) {
                    setStateDialog(() {
                      phoneError = validationError;
                    });
                    return;
                  }
                  
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter account holder name'), backgroundColor: AppTheme.error),
                    );
                    return;
                  }
                  
                  setState(() {
                    if (isEditing) {
                      account!.holderName = nameController.text;
                      account!.accountNumber = cleanedNumber;
                      account!.method = selectedMethod;
                    } else {
                      _withdrawalAccounts.add(WithdrawalAccount(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        method: selectedMethod,
                        accountNumber: cleanedNumber,
                        holderName: nameController.text,
                        isDefault: _withdrawalAccounts.isEmpty,
                      ));
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Account updated successfully' : 'Account added successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final isSelected = selectedMethod == method;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRed.withOpacity(0.2) : (isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryRed : (isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText).withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: isSelected ? AppTheme.primaryRed : (isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? (isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText) : (isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
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
    final driverProvider = Provider.of<DriverProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final todayEarnings = driverProvider.stats.todayEarnings;
    final totalDeliveries = driverProvider.stats.totalDeliveries;
    final rating = driverProvider.stats.rating;
    
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final cardColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: textColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(todayEarnings, totalDeliveries, rating),
            const SizedBox(height: 16),
            _buildVerificationCard(),
            const SizedBox(height: 16),
            _buildVehicleCard(),
            const SizedBox(height: 16),
            _buildWithdrawalCard(),
            const SizedBox(height: 16),
            _buildSecurityCard(),
            const SizedBox(height: 16),
            _buildPreferencesCard(themeProvider),
            const SizedBox(height: 16),
            _buildSupportCard(),
            const SizedBox(height: 16),
            _buildAboutCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE CARD ====================
  Widget _buildProfileCard(double todayEarnings, int totalDeliveries, double rating) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _driverName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryRed),
                              onPressed: _showEditProfileDialog,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: mutedColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _driverEmail,
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone_android, size: 14, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(
                            _driverPhone,
                            style: TextStyle(fontSize: 12, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.attach_money, 'MK${todayEarnings.toInt()}', 'Today'),
                _buildDivider(),
                _buildStatItem(Icons.delivery_dining, '$totalDeliveries', 'Deliveries'),
                _buildDivider(),
                _buildStatItem(Icons.star, '$rating ★', 'Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRed),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppTheme.deepCrimson.withOpacity(0.3),
    );
  }

  // ==================== VERIFICATION CARD ====================
  Widget _buildVerificationCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'VERIFICATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEmailVerified ? AppTheme.success.withOpacity(0.2) : AppTheme.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.email_outlined, size: 20, color: _isEmailVerified ? AppTheme.success : AppTheme.warning),
            ),
            title: const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(_isEmailVerified ? 'Verified' : 'Verify your email', style: TextStyle(color: secondaryTextColor)),
            trailing: _isEmailVerified
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Verified', style: TextStyle(fontSize: 11, color: AppTheme.success)),
                  )
                : TextButton(
                    onPressed: _verifyEmail,
                    child: const Text('Verify', style: TextStyle(color: AppTheme.primaryRed)),
                  ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isPhoneVerified ? AppTheme.success.withOpacity(0.2) : AppTheme.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.phone_android, size: 20, color: _isPhoneVerified ? AppTheme.success : AppTheme.warning),
            ),
            title: const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(_isPhoneVerified ? 'Verified' : 'Verify your phone', style: TextStyle(color: secondaryTextColor)),
            trailing: _isPhoneVerified
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Verified', style: TextStyle(fontSize: 11, color: AppTheme.success)),
                  )
                : TextButton(
                    onPressed: _verifyPhone,
                    child: const Text('Verify', style: TextStyle(color: AppTheme.primaryRed)),
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== VEHICLE CARD ====================
  Widget _buildVehicleCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'VEHICLE INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          if (!_showVehicleForm && _hasVehicleInfo)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getVehicleIcon(_selectedVehicleType),
                      size: 28,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVehicleType,
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _vehicleModelController.text,
                          style: TextStyle(fontSize: 12, color: secondaryTextColor),
                        ),
                        Text(
                          _vehiclePlateController.text,
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryRed),
                    onPressed: _editVehicleInfo,
                  ),
                ],
              ),
            ),
          
          if (_showVehicleForm)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedVehicleType,
                    dropdownColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: _vehicleTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _vehicleModelController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Model',
                      hintText: 'e.g., Toyota Corolla',
                      prefixIcon: Icon(Icons.model_training),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _vehiclePlateController,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      hintText: 'e.g., MN 1234',
                      prefixIcon: Icon(Icons.local_police),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showVehicleForm = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.deepCrimson),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveVehicleInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Save Vehicle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          if (!_showVehicleForm && !_hasVehicleInfo)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.directions_car, size: 48, color: mutedColor),
                    const SizedBox(height: 8),
                    Text(
                      'No vehicle information added',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showVehicleForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Add Vehicle'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== WITHDRAWAL CARD ====================
  Widget _buildWithdrawalCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          if (_withdrawalAccounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 48, color: mutedColor),
                    const SizedBox(height: 8),
                    Text(
                      'No withdrawal accounts',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                    Text(
                      'Tap + to add one',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ),
          
          ..._withdrawalAccounts.map((account) => Dismissible(
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
                  content: Text('Remove ${account.method.toUpperCase()} account ${_formatPhoneNumber(account.accountNumber)}?'),
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
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatPhoneNumber(account.accountNumber),
                          style: TextStyle(fontSize: 12, color: secondaryTextColor),
                        ),
                        Text(
                          account.holderName,
                          style: TextStyle(fontSize: 11, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  if (account.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Default', style: TextStyle(fontSize: 10, color: AppTheme.success)),
                    ),
                  if (!account.isDefault)
                    TextButton(
                      onPressed: () => _setDefaultAccount(account),
                      child: const Text('Set Default', style: TextStyle(fontSize: 12)),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editWithdrawalAccount(account),
                    color: textColor,
                  ),
                ],
              ),
            ),
          )),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _addWithdrawalAccount,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Withdrawal Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
                foregroundColor: AppTheme.primaryRed,
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECURITY CARD ====================
  Widget _buildSecurityCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SECURITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_outline, size: 20, color: AppTheme.warning),
            ),
            title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Update your account password', style: TextStyle(color: secondaryTextColor)),
            trailing: IconButton(
              icon: Icon(_showPasswordChange ? Icons.expand_less : Icons.expand_more, color: secondaryTextColor),
              onPressed: () {
                setState(() {
                  _showPasswordChange = !_showPasswordChange;
                });
              },
            ),
          ),
          
          if (_showPasswordChange)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_open),
                      helperText: 'Minimum 6 characters',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== PREFERENCES CARD ====================
  Widget _buildPreferencesCard(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          // Theme Toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                    ? Colors.purple.withOpacity(0.2) 
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 20,
                color: themeProvider.isDarkMode ? Colors.purple : Colors.orange,
              ),
            ),
            title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(color: secondaryTextColor),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              activeColor: AppTheme.primaryRed,
            ),
          ),
          
          // Language Selection
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.language, size: 20, color: AppTheme.primaryRed),
            ),
            title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('English / Chichewa', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showLanguageDialog(context),
          ),
          
          // Notification Settings
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications, size: 20, color: AppTheme.success),
            ),
            title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Push notifications, sounds, alerts', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showNotificationSettings(context),
          ),
        ],
      ),
    );
  }

  // ==================== SUPPORT CARD ====================
  Widget _buildSupportCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'SUPPORT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline, size: 20, color: Colors.blue),
            ),
            title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('FAQs, guides, tutorials', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showComingSoon(context, 'Help Center'),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.support_agent, size: 20, color: Colors.green),
            ),
            title: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('24/7 driver support', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showContactSupport(context),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.report_problem, size: 20, color: Colors.orange),
            ),
            title: const Text('Report an Issue', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Technical support, delivery problems', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showReportIssue(context),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rate_review, size: 20, color: AppTheme.yellow),
            ),
            title: const Text('Rate the App', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Help us improve', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _rateApp(context),
          ),
        ],
      ),
    );
  }

  // ==================== ABOUT CARD ====================
  Widget _buildAboutCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.deepCrimson),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryRed),
            ),
            title: const Text('App Version', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Version 1.0.0', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showVersionInfo(context),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.security, size: 20, color: Colors.purple),
            ),
            title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('How we handle your data', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showComingSoon(context, 'Privacy Policy'),
          ),
          
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description, size: 20, color: Colors.teal),
            ),
            title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Driver agreement terms', style: TextStyle(color: secondaryTextColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showComingSoon(context, 'Terms of Service'),
          ),
        ],
      ),
    );
  }

  // ==================== LOGOUT BUTTON ====================
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // ==================== DIALOGS ====================
  void _showLanguageDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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