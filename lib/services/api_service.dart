import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String mediaBaseUrl = 'http://127.0.0.1:8000';
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
  
  // ========== AUTH ENDPOINTS ==========
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await saveTokens(data['access'], data['refresh']);
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }
  
  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me/'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User(
        id: data['id'].toString(),
        name: data['username'],
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        role: data['role'] == 'restaurant' ? UserRole.restaurant : UserRole.customer,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Failed to get user');
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone ?? '',
      }),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }
  
  // ========== RESTAURANT ENDPOINTS ==========
  
  Future<List<dynamic>> getRestaurants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }
  }
  
  // ========== MENU ENDPOINTS ==========
  
  Future<List<dynamic>> getMenuItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/available/'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final fallbackResponse = await http.get(
        Uri.parse('$baseUrl/menu-items/'),
        headers: await getHeaders(),
      );
      if (fallbackResponse.statusCode == 200) {
        return json.decode(fallbackResponse.body);
      }
      throw Exception('Failed to load menu items: ${response.statusCode}');
    }
  }
  
  // ========== CART ENDPOINTS ==========
  
  Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/cart/'),
      headers: await getHeaders(),
    );
    
    print('Get cart response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Cart doesn't exist, create one
      return await createCart();
    } else {
      throw Exception('Failed to load cart: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> createCart() async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/cart/'),
      headers: await getHeaders(),
      body: json.encode({}),
    );
    
    print('Create cart response: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create cart: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> addToCart(int menuItemId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/cart/add_item/'),
      headers: await getHeaders(),
      body: json.encode({
        'menu_item_id': menuItemId,
        'quantity': quantity,
      }),
    );
    
    print('Add to cart response: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }
  
  Future<void> clearCart() async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/cart/clear/'),
      headers: await getHeaders(),
    );
    
    print('Clear cart response: ${response.statusCode}');
    
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      throw Exception('Failed to clear cart: ${response.statusCode}');
    }
  }
  
  // ========== ORDER ENDPOINTS ==========
  
  Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/orders/'),
      headers: await getHeaders(),
    );
    
    print('Get orders response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    // First, ensure cart exists and has items
    final cart = await getCart();
    print('Cart data: $cart');
    
    final response = await http.post(
      Uri.parse('$baseUrl/orders/orders/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    
    print('Create order response: ${response.statusCode}');
    print('Create order body: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      // Clear cart after successful order
      await clearCart();
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Invalid order data: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Please login again');
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/orders/$orderId/'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }
}