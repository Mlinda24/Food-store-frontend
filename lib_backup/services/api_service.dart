import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use local Django backend URL
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _addAuthHeader() async {
    final token = await getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ============= AUTH ENDPOINTS =============

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, 
  }) async {
    try {
      final response = await _dio.post('/auth/register/', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      
      if (response.data['token'] != null) {
        await saveToken(response.data['token']);
      }
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============= RESTAURANT ENDPOINTS =============

  Future<List<dynamic>> getRestaurants() async {
    try {
      final response = await _dio.get('/restaurants/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createRestaurant({
    required String name,
    required String description,
    required String address,
    required List<String> categories,
    required double deliveryFee,
    required double minOrderAmount,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/restaurants/', data: {
        'name': name,
        'description': description,
        'address': address,
        'categories': categories,
        'delivery_fee': deliveryFee,
        'min_order_amount': minOrderAmount,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addMenuItem({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    required String category,
    required bool isAvailable,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/restaurants/menu/', data: {
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'is_available': isAvailable,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============= CART ENDPOINTS =============

  Future<Map<String, dynamic>> getCart() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/orders/cart/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required String menuItemId,
    required int quantity,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/orders/cart/add/', data: {
        'menu_item_id': menuItemId,
        'quantity': quantity,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> placeOrder({
    required String deliveryAddress,
    required String phoneNumber,
    String? specialInstructions,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/orders/', data: {
        'delivery_address': deliveryAddress,
        'phone_number': phoneNumber,
        'special_instructions': specialInstructions,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/orders/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.patch('/orders/$orderId/update_status/', data: {
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============= ERROR HANDLER =============

  dynamic _handleError(DioException error) {
    if (error.response != null) {
      // Server returned an error response
      final data = error.response?.data;
      if (data is Map) {
        return data['error'] ?? data['message'] ?? 'Server error: ${error.response?.statusCode}';
      }
      return 'Server error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else if (error.type == DioExceptionType.cancel) {
      return 'Request was cancelled.';
    } else {
      return 'Something went wrong: ${error.message}';
    }
  }
}