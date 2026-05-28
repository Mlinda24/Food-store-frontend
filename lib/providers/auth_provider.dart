import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'cart_provider.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isRestaurant => _currentUser?.role == UserRole.restaurant;
  bool get isCustomer => _currentUser?.role == UserRole.customer;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      if (token != null && token.isNotEmpty) {
        _currentUser = await _apiService.getCurrentUser();
        print('✅ Session restored for: ${_currentUser?.name}');
      } else {
        print('⚠️ No saved session found');
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Session restoration failed: $e');
      _currentUser = null;
      await _apiService.clearTokens();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password,
      {BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.login(username, password);
      _currentUser = await _apiService.getCurrentUser();

      if (context != null && _currentUser != null) {
        try {
          await Provider.of<CartProvider>(context, listen: false).loadCart();
          print('Cart loaded after login');
        } catch (e) {
          print('Error loading cart after login: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(
        username: username,
        email: email,
        password: password,
        role: role.toLowerCase(),
        phone: phone,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout({BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.clearTokens();
      _currentUser = null;

      if (context != null) {
        try {
          await Provider.of<CartProvider>(context, listen: false).clearCart();
          print('Cart cleared after logout');
        } catch (e) {
          print('Error clearing cart after logout: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
      
      // ✅ Navigate to login screen after logout
      if (context != null && context.mounted) {
        // Use a microtask to ensure the widget tree is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            // Navigate to login and clear all history
            context.go('/login');
          }
        });
      }
    } catch (e) {
      print('Error during logout: $e');
      _isLoading = false;
      notifyListeners();
      
      // Even if there's an error, try to navigate to login
      if (context != null && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/login');
          }
        });
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
}