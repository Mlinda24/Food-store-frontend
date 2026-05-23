import 'package:flutter/material.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Determine role based on email for demo
      UserRole role;
      if (email.contains('admin')) {
        role = UserRole.admin;
      } else if (email.contains('driver')) {
        role = UserRole.driver;
      } else if (email.contains('restaurant')) {
        role = UserRole.restaurant;
      } else {
        role = UserRole.customer;
      }

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email,
        phone: '+1234567890',
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      UserRole userRole;
      switch (role) {
        case 'admin':
          userRole = UserRole.admin;
          break;
        case 'driver':
          userRole = UserRole.driver;
          break;
        case 'restaurant':
          userRole = UserRole.restaurant;
          break;
        default:
          userRole = UserRole.customer;
      }

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        role: userRole,
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}