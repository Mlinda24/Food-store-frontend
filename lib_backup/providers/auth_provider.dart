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

  // Switch user role
  Future<void> switchRole(UserRole newRole) async {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        role: newRole,
        avatar: _currentUser!.avatar,
        isActive: true,
        createdAt: _currentUser!.createdAt,
      );
      notifyListeners();
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