import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    print('🔐 Attempting login with username: $username');
    final success = await authProvider.login(username, password);

    if (success && mounted) {
      final user = authProvider.currentUser;
      print('✅ Login successful! User role: ${user?.role}');
      
      if (user != null) {
        if (user.role == UserRole.admin) {
          print('➡️ Navigating to admin dashboard');
          context.go('/admin');
        } else if (user.role == UserRole.driver) {
          print('➡️ Navigating to driver dashboard');
          context.go('/driver');
        } else if (user.role == UserRole.restaurant) {
          print('➡️ Navigating to restaurant dashboard');
          context.go('/restaurant');
        } else {
          print('➡️ Navigating to customer home');
          context.go('/home');
        }
      } else {
        print('⚠️ User object is null after successful login!');
        // Fallback - try to determine role from username
        if (username.toLowerCase() == 'driver') {
          context.go('/driver');
        } else if (username.toLowerCase() == 'admin') {
          context.go('/admin');
        } else if (username.toLowerCase() == 'restaurant') {
          context.go('/restaurant');
        } else {
          context.go('/home');
        }
      }
    } else if (mounted) {
      print('❌ Login failed: ${authProvider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo Container
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to Foodie Express',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Username Field
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: AppTheme.primaryText),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: AppTheme.secondaryText),
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.mutedText),
                  filled: true,
                  fillColor: AppTheme.secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppTheme.primaryText),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: AppTheme.secondaryText),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.mutedText),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.mutedText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppTheme.secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password feature coming soon!')),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Login Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoading) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }
                      return const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Demo Credentials Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGlowGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.deepCrimson.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Demo Credentials:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDemoCredential('Customer', 'customer'),
                    _buildDemoCredential('Admin', 'admin'),
                    _buildDemoCredential('Restaurant', 'restaurant'),
                    _buildDemoCredential('Driver', 'driver'),
                    const SizedBox(height: 4),
                    const Text(
                      'Password for all: password123',
                      style: TextStyle(
                        color: AppTheme.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/role-selection');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredential(String role, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$role: ',
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 12,
            ),
          ),
          Text(
            username,
            style: const TextStyle(
              color: AppTheme.primaryRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}