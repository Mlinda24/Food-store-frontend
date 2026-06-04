import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cross_file/cross_file.dart';
import '../models/models.dart';
import '../models/payment_model.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // ============================================
  // ENVIRONMENT CONFIGURATION
  // ============================================
  static const bool useLocalDev = false;

  static const String prodBaseUrl =
      'https://food-store-backend-4eo6.onrender.com';
  static const String prodMediaBaseUrl =
      'https://food-store-backend-4eo6.onrender.com';

  static const String localBaseUrl = 'http://192.168.137.1:8000';
  static const String localMediaBaseUrl = 'http://192.168.137.1:8000';

  static const String _cloudinaryBaseUrl =
      'https://res.cloudinary.com/dvtfdu0yq/image/upload';

  static String get baseUrl => useLocalDev ? localBaseUrl : prodBaseUrl;
  static String get mediaBaseUrl =>
      useLocalDev ? localMediaBaseUrl : prodMediaBaseUrl;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ============================================
  // STATIC UTILITY METHODS
  // ============================================

  static String getImageUrlStatic(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    String raw = imagePath.trim();
    if (raw.startsWith('https://res.cloudinary.com')) return raw;
    if (useLocalDev) {
      if (raw.startsWith('http')) {
        return raw
            .replaceAll('127.0.0.1', '192.168.137.1')
            .replaceAll('localhost', '192.168.137.1')
            .replaceAll('10.0.2.2', '192.168.137.1');
      }
      if (raw.startsWith('/media/')) return '$localMediaBaseUrl$raw';
      if (raw.startsWith('/')) return '$localMediaBaseUrl$raw';
      return '$localMediaBaseUrl/media/$raw';
    }
    String cleaned = raw;
    if (cleaned.startsWith('/media/')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('media/')) cleaned = cleaned.substring(6);
    if (cleaned.startsWith('/')) cleaned = cleaned.substring(1);
    if (cleaned.contains('.'))
      cleaned = cleaned.substring(0, cleaned.lastIndexOf('.'));
    return '$_cloudinaryBaseUrl/v1/$cleaned';
  }

  static String cleanImageUrlStatic(String? imagePath) =>
      getImageUrlStatic(imagePath);

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> getMultipartHeaders() async {
    final token = await getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
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
      return null;
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveTokens(data['access'], refreshToken);
        return true;
      }
    } catch (e) {}
    return false;
  }

  // ============================================
  // HTTP METHODS
  // ============================================

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: await getHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return get(endpoint);
      throw Exception('Unauthorized');
    } else {
      throw Exception('GET failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String reference) async {
    try {
      return await get(
          '/api/payments/status_by_reference/?reference=$reference');
    } catch (e) {
      return {'status': 'pending'};
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic>? data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: await getHeaders(),
      body: data != null ? json.encode(data) : null,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return post(endpoint, data);
      throw Exception('Unauthorized');
    } else {
      throw Exception('POST failed: ${response.statusCode}');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic>? data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.patch(
      url,
      headers: await getHeaders(),
      body: data != null ? json.encode(data) : null,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return patch(endpoint, data);
      throw Exception('Unauthorized');
    } else {
      throw Exception('PATCH failed: ${response.statusCode}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: await getHeaders());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return delete(endpoint);
      throw Exception('Unauthorized');
    } else {
      throw Exception('DELETE failed: ${response.statusCode}');
    }
  }

  // ============================================
  // AUTH ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login/');
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      await saveTokens(data['access'], data['refresh']);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me/'),
      headers: await getHeaders(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User(
        id: data['id'].toString(),
        name: data['username'],
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        role: data['role'] == 'restaurant'
            ? UserRole.restaurant
            : data['role'] == 'driver'
                ? UserRole.driver
                : UserRole.customer,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return await getCurrentUser();
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      final response = await post('/api/auth/register/', {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'phone_number': phone,
      });
      return {
        'success': true,
        'tokens': {
          'access': response['access'],
          'refresh': response['refresh'],
        },
        'user': response['user'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============================================
  // CUSTOMER RESTAURANT ENDPOINTS
  // ============================================

  Future<List<dynamic>> getRestaurants() async {
    try {
      return await get('/api/customer/restaurants/');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getRestaurant(String id) async {
    return await get('/api/customer/restaurants/$id/');
  }

  Future<List<dynamic>> getRestaurantMenu(int restaurantId) async {
    try {
      final data = await get('/api/customer/restaurants/$restaurantId/menu/');
      List<dynamic> menuItems = [];
      if (data.containsKey('menu') && data['menu'] is List) {
        for (var category in data['menu']) {
          if (category.containsKey('items') && category['items'] is List) {
            menuItems.addAll(category['items']);
          }
        }
      }
      return menuItems;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMenuItems({int? restaurantId}) async {
    if (restaurantId != null) return getRestaurantMenu(restaurantId);
    final restaurants = await getRestaurants();
    final List<dynamic> allItems = [];
    for (var restaurant in restaurants) {
      final items = await getRestaurantMenu(restaurant['id']);
      allItems.addAll(items);
    }
    return allItems;
  }

  // ============================================
  // RESTAURANT OWNER ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getMyRestaurant() async {
    try {
      return await get('/api/owner/restaurants/my_restaurant/');
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getRestaurantStats() async {
    try {
      return await get('/api/owner/restaurants/stats/');
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String phoneNumber,
    required String provider,
  }) async {
    return await post('/api/restaurants/withdraw/', {
      'amount': amount.toString(),
      'phone_number': phoneNumber,
      'provider': provider,
    });
  }

  Future<Map<String, dynamic>> createRestaurantWithImage({
    required String name,
    required String address,
    required String phone,
    String? description,
    required File imageFile,
  }) async {
    return await post('/api/owner/restaurants/', {
      'name': name,
      'address': address,
      'phone': phone,
      'description': description ?? '',
      'is_open': true,
    });
  }

  Future<Map<String, dynamic>> createRestaurant(
      Map<String, dynamic> data) async {
    return await post('/api/owner/restaurants/', data);
  }

  Future<List<dynamic>> getRestaurantOrders() async {
    final response = await get('/api/orders/');
    return response is List ? response : [];
  }

  Future<Map<String, dynamic>> updateMyRestaurant(
      Map<String, dynamic> data) async {
    return await patch('/api/owner/restaurants/my_restaurant/', data);
  }

  Future<Map<String, dynamic>> updateRestaurantLocation({
    required String restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    return await patch('/api/owner/restaurants/$restaurantId/', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> createMenuItemWithImage({
    required String name,
    required String description,
    required double price,
    required String category,
    required XFile imageFile,
  }) async {
    return await post('/api/owner/menu-items/', {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'is_available': true,
    });
  }

  Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> itemData) async {
    return await post('/api/owner/menu-items/', itemData);
  }

  Future<Map<String, dynamic>> updateMenuItem(
      String id, Map<String, dynamic> itemData) async {
    return await patch('/api/owner/menu-items/$id/', itemData);
  }

  Future<void> deleteMenuItem(String id) async {
    await delete('/api/owner/menu-items/$id/');
  }

  // ============================================
  // CART ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getCart() async {
    try {
      return await get('/api/cart/');
    } catch (e) {
      return {'items': [], 'total_price': 0};
    }
  }

  Future<Map<String, dynamic>> addToCart(int menuItemId, int quantity) async {
    return await post('/api/cart/add_item/', {
      'menu_item_id': menuItemId,
      'quantity': quantity,
    });
  }

  Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    return await delete('/api/cart/remove_item/?cart_item_id=$cartItemId');
  }

  Future<Map<String, dynamic>> updateCartItem(
      int cartItemId, int quantity) async {
    return await patch('/api/cart/update_item/', {
      'cart_item_id': cartItemId,
      'quantity': quantity,
    });
  }

  Future<void> clearCart() async {
    await post('/api/cart/clear_cart/', null);
  }

  // ============================================
  // ORDER ENDPOINTS
  // ============================================

  Future<List<dynamic>> getOrders() async {
    try {
      final response = await get('/api/orders/');
      if (response is List) return response as List<dynamic>;
      if (response.containsKey('results')) return response['results'];
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await get('/api/my_orders/');
      List<dynamic> ordersData =
          response is List ? response : (response['results'] ?? []);
      return ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    return await get('/api/orders/$orderId/');
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    return await post('/api/orders/', orderData);
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    return await patch(
        '/api/orders/$orderId/update_status/', {'status': status});
  }

  // ============================================
  // PAYMENT ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await get('/wallet/balance/');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {
        'balance': 0.0,
        'available_balance': 0.0,
        'pending_balance': 0.0,
        'currency': 'USD'
      };
    } catch (e) {
      print('Error getting wallet balance: $e');
      return {
        'balance': 0.0,
        'available_balance': 0.0,
        'pending_balance': 0.0,
        'currency': 'USD'
      };
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String orderId,
    required PaymentMethod method,
  }) async {
    return await post('/api/payments/initiate/', {
      'order_id': int.tryParse(orderId) ?? orderId,
      'method': method.value,
      'phone_number': phoneNumber,
    });
  }

  Future<Map<String, dynamic>> initiateSimplePayment({
    required double amount,
    required String orderId,
  }) async {
    print('💳 initiateSimplePayment: amount=$amount, orderId=$orderId');
    final response = await post('/api/payments/initiate_simple/', {
      'order_id': int.tryParse(orderId) ?? orderId,
    });
    print('📦 initiateSimplePayment response: $response');
    return response;
  }

  Future<Map<String, dynamic>> initiatePayChanguPayment({
    required double amount,
    required String orderId,
  }) async {
    return await post('/api/payments/initiate/', {
      'order_id': int.tryParse(orderId) ?? orderId,
      'method': 'paychangu',
      'phone_number': '',
    });
  }

  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    return await get('/api/payments/$transactionId/status/');
  }

  Future<Map<String, dynamic>> manualConfirmPayment(String orderId) async {
    return await post('/api/payments/test_confirm_payment/', {
      'order_id': int.parse(orderId),
    });
  }

  Future<Map<String, dynamic>> checkAndUpdateWallet(String orderId) async {
    return await get(
        '/api/payments/check_and_update_wallet/?order_id=$orderId');
  }

  Future<Map<String, dynamic>> syncPayment(String orderId) async {
    try {
      print('🔄 Syncing payment for order: $orderId');
      final result = await post('/api/payments/sync_payment/', {
        'order_id': int.tryParse(orderId) ?? orderId,
      });
      print('📦 Sync result: $result');
      return result;
    } catch (e) {
      print('❌ syncPayment error: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPaymentStatusByReference(
      String reference) async {
    return await get('/api/payments/status_by_reference/?reference=$reference');
  }

  Future<List<dynamic>> getMyPayments() async {
    final response = await get('/api/payments/my_payments/');
    return response is List ? response : [];
  }

  // ============================================
  // DRIVER API ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getDriverProfile() async {
    return await get('/api/drivers/drivers/profile/');
  }

  Future<Map<String, dynamic>> updateDriverProfile(
      Map<String, dynamic> data) async {
    return await patch('/api/drivers/drivers/update_profile/', data);
  }

  Future<Map<String, dynamic>> updateDriverStatus(String status) async {
    print('📡 Updating driver status to: $status');
    try {
      final response = await patch(
          '/api/drivers/drivers/profile_status/', {'status': status});
      print('✅ Driver status updated successfully');
      return response;
    } catch (e) {
      print('❌ Failed to update driver status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateDriverLocation(
      double latitude, double longitude) async {
    return await post('/api/drivers/drivers/location_update/', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<List<dynamic>> getAvailableOrders() async {
    final response = await get('/api/drivers/deliveries/available/');
    return response is List ? response : [];
  }

  Future<List<dynamic>> getMyDeliveries() async {
    final response = await get('/api/drivers/deliveries/my/');
    return response is List ? response : [];
  }

  Future<Map<String, dynamic>> getActiveDelivery() async {
    try {
      final response = await get('/api/drivers/deliveries/active/');
      if (response is Map && response.isNotEmpty) {
        return response as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> acceptDelivery(String deliveryId) async {
    return await post('/api/drivers/deliveries/$deliveryId/accept/', null);
  }

  Future<Map<String, dynamic>> declineDelivery(String deliveryId) async {
    return await post('/api/drivers/deliveries/$deliveryId/decline/', null);
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(
      String deliveryId, String status) async {
    return await patch(
        '/api/drivers/deliveries/$deliveryId/status/', {'status': status});
  }

  Future<Map<String, dynamic>> getEarningsSummary() async {
    return await get('/api/drivers/drivers/earnings/');
  }

  Future<Map<String, dynamic>> getDeliveryHistory() async {
    return await get('/api/drivers/drivers/delivery_history/');
  }

  // ============================================
  // NOTIFICATION ENDPOINTS
  // ============================================

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await get('/api/notifications/notifications/');
      if (response is List) return response as List<dynamic>;
      if (response.containsKey('results')) return response['results'];
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response =
          await get('/api/notifications/notifications/unread_count/');
      return response['unread_count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(
      String notificationId) async {
    return await patch(
        '/api/notifications/notifications/$notificationId/mark_read/', null);
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    return await post('/api/notifications/notifications/mark_all_read/', null);
  }

  Future<void> deleteNotification(String notificationId) async {
    await delete('/api/notifications/notifications/$notificationId/');
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  String cleanImageUrl(String? imagePath) => getImageUrlStatic(imagePath);
  String getImageUrl(String? imagePath) => getImageUrlStatic(imagePath);
}
