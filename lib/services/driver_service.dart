import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class DriverService {
  static const String _base = 'http://127.0.0.1:8000/api';

  static Future<String?> _getToken() async {
    return await AuthProvider.getToken();
  }

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ============================================================
  // STATUS - Using update_status endpoint (PATCH)
  // ============================================================

  static Future<Map<String, dynamic>> goOnline() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final response = await http.patch(
      Uri.parse('$_base/drivers/update_status/'),
      headers: _headers(token),
      body: json.encode({'status': 'online', 'is_available': true}),
    );
    
    print('🟢 Go online - Status: ${response.statusCode}');
    print('🟢 Go online - Response: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go online: ${response.body}');
  }

  static Future<Map<String, dynamic>> goOffline() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    final response = await http.patch(
      Uri.parse('$_base/drivers/update_status/'),
      headers: _headers(token),
      body: json.encode({'status': 'offline', 'is_available': false}),
    );
    
    print('🔴 Go offline - Status: ${response.statusCode}');
    print('🔴 Go offline - Response: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go offline: ${response.body}');
  }

  static Future<Map<String, dynamic>> getDriverStatus() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    
    // Try to get status from profile or driver endpoint
    final response = await http.get(
      Uri.parse('$_base/drivers/profile/'),
      headers: _headers(token),
    );
    
    print('📊 Get status - Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'is_available': data['is_available'] ?? false,
        'status': data['status'] ?? 'offline',
        'role': 'driver',
        'is_verified': data['is_verified'] ?? true
      };
    }
    return {'is_available': false, 'status': 'offline'};
  }

  // ============================================================
  // PROFILE & EARNINGS
  // ============================================================

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$_base/drivers/profile/'),
      headers: _headers(token),
    );
    print('👤 Get profile - Status: ${response.statusCode}');
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load profile');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.patch(
      Uri.parse('$_base/drivers/update_profile/'),
      headers: _headers(token),
      body: json.encode(data),
    );
    if (response.statusCode == 200) return json.decode(response.body);
    final error = json.decode(response.body);
    throw Exception(error['error'] ?? 'Failed to update profile');
  }

  static Future<Map<String, dynamic>> getEarningsSummary() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    try {
      final response = await http.get(
        Uri.parse('$_base/drivers/earnings_summary/'),
        headers: _headers(token),
      );
      print('💰 Earnings - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'today_earnings': double.tryParse(data['today_earnings']?.toString() ?? '0') ?? 0,
          'total_earnings': double.tryParse(data['total_earnings']?.toString() ?? '0') ?? 0,
          'total_deliveries': int.tryParse(data['total_deliveries']?.toString() ?? '0') ?? 0,
          'average_rating': double.tryParse(data['average_rating']?.toString() ?? '5.0') ?? 5.0,
          'today_deliveries': int.tryParse(data['today_deliveries']?.toString() ?? '0') ?? 0,
        };
      }
    } catch (e) {
      print('Error getting earnings: $e');
    }
    throw Exception('Failed to load earnings');
  }

  static Future<List<dynamic>> getDeliveryHistory() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    try {
      final response = await http.get(
        Uri.parse('$_base/drivers/delivery_history/'),
        headers: _headers(token),
      );
      print('📜 History - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        return data['deliveries'] ?? data['orders'] ?? [];
      }
    } catch (e) {
      print('Error getting history: $e');
    }
    throw Exception('Failed to load delivery history');
  }

  // ============================================================
  // RESTAURANT ADDRESS LOOKUP
  // ============================================================
  static final Map<String, String> _restaurantAddressCache = {};

  static Future<String> getRestaurantAddress(String restaurantId) async {
    if (_restaurantAddressCache.containsKey(restaurantId)) {
      return _restaurantAddressCache[restaurantId]!;
    }
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_base/restaurants/$restaurantId/'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address']?.toString() ?? 'Address not available';
        _restaurantAddressCache[restaurantId] = address;
        return address;
      }
    } catch (e) {
      print('⚠️ Could not fetch restaurant address for $restaurantId: $e');
    }
    return 'Address not available';
  }

  // ============================================================
  // AVAILABLE ORDERS
  // ============================================================
  static Future<List<dynamic>> getAvailableOrders() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_base/drivers/available_orders/'),
      headers: _headers(token),
    );

    print('📦 Available orders - Status: ${response.statusCode}');
    print('📦 Available orders - Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> orders;
      if (data is List) {
        orders = data;
      } else {
        orders = data['orders'] ?? data['results'] ?? [];
      }
      return orders;
    }
    throw Exception('Failed to load available orders: ${response.body}');
  }

  // ============================================================
  // ACTIVE DELIVERY
  // ============================================================
  static Future<Map<String, dynamic>?> getActiveDelivery() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await http.get(
        Uri.parse('$_base/drivers/active_delivery/'),
        headers: _headers(token),
      );

      print('🚚 Active delivery - Status: ${response.statusCode}');
      print('🚚 Active delivery - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data == null) return null;
        if (data is Map) {
          if (data.containsKey('has_active_delivery') && data['has_active_delivery'] == false) {
            return null;
          }
          if (data.containsKey('delivery') && data['delivery'] is Map) {
            return Map<String, dynamic>.from(data['delivery']);
          }
          if (data.containsKey('order') && data['order'] is Map) {
            return Map<String, dynamic>.from(data['order']);
          }
          if (data.containsKey('id')) {
            return Map<String, dynamic>.from(data);
          }
        }
        return null;
      }
      if (response.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      print('Error getting active delivery: $e');
      return null;
    }
  }

  // ============================================================
  // ACCEPT ORDER
  // ============================================================
  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_base/drivers/accept_order/'),
      headers: _headers(token),
      body: json.encode({'order_id': orderId}),
    );

    print('✅ Accept order - Status: ${response.statusCode}');
    print('✅ Accept order - Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    final body = response.body;
    throw Exception('Failed to accept order: $body');
  }

  // ============================================================
  // UPDATE DELIVERY STATUS
  // ============================================================
  static Future<Map<String, dynamic>> updateDeliveryStatus(String deliveryId, String status) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_base/drivers/update_delivery_status/'),
      headers: _headers(token),
      body: json.encode({'delivery_id': deliveryId, 'status': status}),
    );

    print('🔄 Update status - Status: ${response.statusCode}');
    print('🔄 Update status - Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update status: ${response.body}');
  }
}