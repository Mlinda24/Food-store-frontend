import 'dart:convert';
import 'dart:io';
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
    print('✅ Tokens saved');
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    print('🗑️ Tokens cleared');
  }
  
  Future<dynamic> decodeResponse(http.Response response) async {
    if (response.body.isEmpty) return null;
    try {
      return json.decode(response.body);
    } catch (e) {
      print('Error decoding response: $e');
      return null;
    }
  }
  
  // ========== AUTH ENDPOINTS ==========
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    
    print('Login response status: ${response.statusCode}');
    
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
    
    print('Get current user response: ${response.statusCode}');
    
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
    
    print('Register response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
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
    
    print('Get restaurants response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
  
  Future<Map<String, dynamic>> getRestaurant(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/$id/'),
      headers: await getHeaders(),
    );
    
    print('Get restaurant response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load restaurant: ${response.statusCode}');
    }
  }
  
  // ========== MENU ENDPOINTS ==========
  
  Future<List<dynamic>> getMenuItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu-items/'),
      headers: await getHeaders(),
    );
    
    print('Get menu items response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
  
  Future<List<dynamic>> getAvailableMenuItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/available/'),
      headers: await getHeaders(),
    );
    
    print('Get available menu items response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return getMenuItems();
    }
  }
  
  // ========== MENU ITEM CRUD ENDPOINTS ==========
  
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu-items/'),
      headers: await getHeaders(),
      body: json.encode(itemData),
    );
    
    print('Create menu item response: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create menu item: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> updateMenuItem(String id, Map<String, dynamic> itemData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/menu-items/$id/'),
      headers: await getHeaders(),
      body: json.encode(itemData),
    );
    
    print('Update menu item response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update menu item: ${response.statusCode}');
    }
  }
  
  Future<void> deleteMenuItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/menu-items/$id/'),
      headers: await getHeaders(),
    );
    
    print('Delete menu item response: ${response.statusCode}');
    
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete menu item: ${response.statusCode}');
    }
  }
  
  // ========== CART ENDPOINTS ==========
  
  Future<Map<String, dynamic>> getCart() async {
    final token = await getToken();
    if (token == null) {
      print('No token, returning empty cart');
      return {'items': [], 'total_price': 0};
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/orders/cart/'),
      headers: await getHeaders(),
    );
    
    print('Get cart response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load cart, returning empty cart');
      return {'items': [], 'total_price': 0};
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
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/orders/cart/remove_item/'),
      headers: await getHeaders(),
      body: json.encode({'cart_item_id': cartItemId}),
    );
    
    print('Remove from cart response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      return json.decode(response.body) ?? {};
    } else {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> updateCartItem(int cartItemId, int quantity) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/cart/update_item/'),
      headers: await getHeaders(),
      body: json.encode({
        'cart_item_id': cartItemId,
        'quantity': quantity,
      }),
    );
    
    print('Update cart item response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update cart item: ${response.statusCode}');
    }
  }
  
  Future<void> clearCart() async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/cart/clear_cart/'),
      headers: await getHeaders(),
    );
    
    print('Clear cart response: ${response.statusCode}');
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
    final response = await http.post(
      Uri.parse('$baseUrl/orders/orders/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    
    print('Create order response: ${response.statusCode}');
    print('Create order body: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final errorBody = await decodeResponse(response);
      throw Exception('Invalid order data: ${errorBody?['error'] ?? response.body}');
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
    
    print('Get order response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/orders/$orderId/'),
      headers: await getHeaders(),
      body: json.encode({'status': status}),
    );
    
    print('Update order status response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update order status: ${response.statusCode}');
    }
  }
  
  // ========== RESTAURANT OWNER ENDPOINTS ==========
  
  Future<Map<String, dynamic>> getMyRestaurant() async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/my_restaurant/'),
      headers: await getHeaders(),
    );
    
    print('Get my restaurant response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle both list and object responses
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } else {
      return {};
    }
  }
  
  Future<Map<String, dynamic>> updateMyRestaurant(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/restaurants/my_restaurant/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );
    
    print('Update my restaurant response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update restaurant: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getRestaurantStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/restaurants/stats/'),
      headers: await getHeaders(),
    );
    
    print('Get restaurant stats response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = await decodeResponse(response);
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } else {
      return {};
    }
  }
  
  // ========== RESTAURANT ORDERS ==========
  
  Future<List<dynamic>> getRestaurantOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/orders/'),
      headers: await getHeaders(),
    );
    
    print('Get restaurant orders response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
}