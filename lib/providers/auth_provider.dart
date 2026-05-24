import 'package:flutter/material.dart';
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

  // ✅ Constructor - checks for existing session when app starts
  AuthProvider() {
    checkAuthStatus();
  }

  // ✅ Check if user is already logged in (restores session)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, try to get user info
        _currentUser = await _apiService.getCurrentUser();
        print('✅ Session restored for: ${_currentUser?.name}');
      } else {
        print('⚠️ No saved session found');
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Session restoration failed: $e');
      _currentUser = null;
      // Clear invalid tokens
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

      // Load cart after successful login
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

    await _apiService.clearTokens();
    _currentUser = null;

    // Clear cart after logout
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
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }
}