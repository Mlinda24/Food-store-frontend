import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  final String? selectedRole;
  
  const RegistrationScreen({super.key, this.selectedRole});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _selectedRole = 'customer';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  final ApiService _apiService = ApiService();

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Customer',
      'value': 'customer',
      'description': 'Order from the best restaurants nearby',
      'icon': Icons.person_outline,
    },
    {
      'title': 'Restaurant Owner',
      'value': 'restaurant',
      'description': 'List your menu and grow your business',
      'icon': Icons.restaurant_outlined,
    },
    {
      'title': 'Delivery Driver',
      'value': 'driver',
      'description': 'Deliver food and earn on your schedule',
      'icon': Icons.delivery_dining_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedRole != null) {
      _selectedRole = widget.selectedRole!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    
    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    
    if (!_isValidPhone(_phoneController.text.trim())) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.register(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
      );
      
      print('Registration successful: $result');
      _showSuccess('Account created successfully! Please login.');
      
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/login');
      });
      
    } catch (e) {
      print('Registration error: $e');
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanPhone.length == 10 && cleanPhone.startsWith('0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Text
              Text(
                'Join Us',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 32),
              
              // Role Selection Title
              Text(
                'SELECT YOUR ROLE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getMutedTextColor(context),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              
              // Role Cards
              ..._roles.map((role) => _buildRoleCard(
                title: role['title'],
                value: role['value'],
                description: role['description'],
                icon: role['icon'],
                isSelected: _selectedRole == role['value'],
                onTap: () {
                  setState(() {
                    _selectedRole = role['value'];
                  });
                },
              )),
              
              const SizedBox(height: 24),
              
              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'John Doe',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'john@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '0999 000 000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '********',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.getMutedTextColor(context),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: '********',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.getMutedTextColor(context),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? AppTheme.primaryButtonGradient 
              : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], 
                  begin: Alignment.topLeft, 
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryRed 
                : AppTheme.deepCrimson.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppTheme.primaryRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getPrimaryTextColor(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppTheme.getMutedTextColor(context),
            ),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.getMutedTextColor(context)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppTheme.getSurfaceColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}