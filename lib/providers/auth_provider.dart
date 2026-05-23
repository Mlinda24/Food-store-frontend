import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email: email, password: password);
      
      // Parse user data from response
      final userData = response['user'];
      
      UserRole role;
      switch (userData['role']) {
        case 'admin':
          role = UserRole.admin;
          break;
        case 'driver':
          role = UserRole.driver;
          break;
        case 'restaurant':
          role = UserRole.restaurant;
          break;
        default:
          role = UserRole.customer;
      }

      _currentUser = User(
        id: userData['id'].toString(),
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'] ?? '',
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      final response = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      
      // Auto login after registration
      return await login(email, password);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}