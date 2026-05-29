import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../config/api_config.dart'; 


class AuthProvider extends ChangeNotifier {
  static AuthProvider? _instance;
  static AuthProvider get instance {
    _instance ??= AuthProvider._();
    return _instance!;
  }
  AuthProvider._();
  AuthProvider() {
    _instance = this;
    _loadStoredToken(); // Load token from storage on startup
  }
  static const String _baseUrl = '${ApiConfig.baseUrl}/api';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  User? _currentUser;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _token != null;
  String? get token => _token;
  bool get isInitialized => _isInitialized;

  /// Called by service files to get the current token
  static Future<String?> getToken() async {
    return _instance?._token;
  }

  /// Load stored token from SharedPreferences on app start
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      
      if (_token != null) {
        print('🔐 Loaded stored token');
        // Try to fetch user with stored token
        final success = await _fetchCurrentUser();
        if (!success) {
          // Token might be expired, try to refresh
          final refreshed = await refreshToken();
          if (!refreshed) {
            // Token invalid, clear everything
            await logout();
          }
        }
      }
    } catch (e) {
      print('❌ Error loading stored token: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Save token to SharedPreferences
  Future<void> _saveToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_refreshToken != null) {
        await prefs.setString(_refreshTokenKey, _refreshToken!);
      }
      print('💾 Token saved to storage');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  /// Save user to SharedPreferences
  Future<void> _saveUser() async {
    if (_currentUser != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      } catch (e) {
        print('❌ Error saving user: $e');
      }
    }
  }

  /// POST /api/auth/login/
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 Login attempt for user: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('📡 Login response status: ${response.statusCode}');
      print('📦 Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['access'];
        _refreshToken = data['refresh'];
        
        await _saveToken();
        
        print('✅ Token obtained successfully');
        
        // Fetch user profile
        final userFetched = await _fetchCurrentUser();
        
        if (!userFetched) {
          // If /me/ endpoint fails, create minimal user from login
          print('⚠️ Could not fetch user profile, creating minimal user');
          _createMinimalUser(username);
          await _saveUser();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['detail'] ?? 
                 data['non_field_errors']?[0] ??
                 data['username']?[0] ?? 
                 data['error'] ?? 
                 'Login failed';
        print('❌ Login failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      print('❌ Connection error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// GET /api/auth/me/
  Future<bool> _fetchCurrentUser() async {
    if (_token == null) {
      print('⚠️ No token available for fetching user');
      return false;
    }
    
    print('🔍 Fetching user profile with token...');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('👤 Me endpoint status: ${response.statusCode}');
      print('👤 Me endpoint body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        UserRole role;
        switch (data['role']?.toString().toLowerCase()) {
          case 'driver':
            role = UserRole.driver;
            break;
          case 'restaurant':
            role = UserRole.restaurant;
            break;
          case 'admin':
            role = UserRole.admin;
            break;
          default:
            role = UserRole.customer;
        }

        _currentUser = User(
          id: data['id'].toString(),
          name: data['username'] ?? data['name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          role: role,
          isActive: data['is_active'] ?? true,
          createdAt: DateTime.tryParse(data['date_joined'] ?? '') ?? DateTime.now(),
        );
        
        await _saveUser();
        
        print('✅ User fetched: ${_currentUser?.name} (role: ${_currentUser?.role})');
        return true;
      } else if (response.statusCode == 401) {
        print('⚠️ Token expired or invalid');
        return false;
      } else {
        print('⚠️ Failed to fetch user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception fetching user: $e');
      return false;
    }
  }

  /// Create minimal user when /me/ endpoint is unavailable
  void _createMinimalUser(String username) {
    UserRole role;
    final usernameLower = username.toLowerCase();
    
    if (usernameLower == 'driver') {
      role = UserRole.driver;
    } else if (usernameLower == 'restaurant') {
      role = UserRole.restaurant;
    } else if (usernameLower == 'admin') {
      role = UserRole.admin;
    } else {
      role = UserRole.customer;
    }
    
    _currentUser = User(
      id: username,
      name: username,
      email: '$username@example.com',
      phone: '',
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
    );
    print('✅ Created minimal user: $username (role: $role)');
  }

  /// POST /api/auth/refresh/ - Refresh expired token
  Future<bool> refreshToken() async {
    if (_refreshToken == null) {
      print('⚠️ No refresh token available');
      return false;
    }
    
    print('🔄 Attempting to refresh token...');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': _refreshToken}),
      );

      print('🔄 Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['access'];
        
        // Some backends return a new refresh token as well
        if (data['refresh'] != null) {
          _refreshToken = data['refresh'];
        }
        
        await _saveToken();
        print('✅ Token refreshed successfully');
        
        // Re-fetch user with new token
        await _fetchCurrentUser();
        
        notifyListeners();
        return true;
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  /// POST /api/auth/register/
  Future<bool> register(
    String username,
    String password,
    String email,
    String role,
    String phone,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Register attempt for user: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
          'role': role,
          'phone': phone,
        }),
      );

      print('📝 Register response status: ${response.statusCode}');
      print('📝 Register response body: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Registration successful, auto-logging in...');
        return await login(username, password);
      } else {
        final data = json.decode(response.body);
        _error = _parseErrors(data);
        print('❌ Registration failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      print('❌ Connection error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout - clear all stored data
  Future<void> logout() async {
    print('👋 Logging out user: ${_currentUser?.name ?? 'unknown'}');
    
    _currentUser = null;
    _token = null;
    _refreshToken = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
      print('🗑️ Storage cleared');
    } catch (e) {
      print('❌ Error clearing storage: $e');
    }
    
    notifyListeners();
  }

  /// Check if token is valid and refresh if needed
  Future<bool> validateAndRefreshToken() async {
    if (_token == null) return false;
    
    // Quick check if token might be expired (optional JWT decode)
    // For now, just try to fetch user
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401 && _refreshToken != null) {
        print('⚠️ Token expired, attempting refresh...');
        final refreshed = await refreshToken();
        return refreshed;
      }
      return false;
    } catch (e) {
      print('❌ Token validation error: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseErrors(Map<String, dynamic> data) {
    if (data.containsKey('detail')) return data['detail'];
    final messages = <String>[];
    data.forEach((key, value) {
      if (value is List) {
        messages.add('$key: ${value.join(', ')}');
      } else if (value is String) {
        messages.add('$key: $value');
      } else if (value is Map) {
        messages.add('$key: ${value.values.join(', ')}');
      }
    });
    return messages.join('\n');
  }
}