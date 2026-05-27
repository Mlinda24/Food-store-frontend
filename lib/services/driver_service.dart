import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class DriverService {
  static const String _base = 'http://127.0.0.1:8000/api';

  static Future<String?> _getToken() async {
    final token = await AuthProvider.getToken();
    if (token == null) {
      print('❌ No token available in DriverService');
    } else {
      print('✅ Token available: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }
    return token;
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // EARNINGS & STATS
  // ============================================================

  /// Get earnings summary for driver
  static Future<Map<String, dynamic>> getEarningsSummary() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_base/drivers/earnings_summary/'),
      headers: _headers(token),
    );

    print('📊 Earnings summary - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode == 404) {
      return {
        'today_earnings': 0,
        'week_earnings': 0,
        'month_earnings': 0,
        'total_earnings': 0,
        'total_deliveries': 0,
        'today_deliveries': 0,
        'rating': 5.0,
      };
    } else {
      throw Exception('Failed to load earnings (${response.statusCode})');
    }
  }

  /// Get delivery history
  static Future<List<dynamic>> getDeliveryHistory() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_base/drivers/delivery_history/'),
      headers: _headers(token),
    );

    print('📜 Delivery history - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['deliveries'] ?? [];
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      return [];
    }
  }

  // ============================================================
  // ORDERS
  // ============================================================

  /// Get available orders for pickup
  static Future<List<dynamic>> getAvailableOrders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_base/drivers/available_orders/'),
      headers: _headers(token),
    );

    print('📦 Available orders - Status: ${response.statusCode}');
    print('📦 Available orders - Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📦 Parsed data - count: ${data['count']}, orders: ${data['orders']?.length ?? 0}');
      return data['orders'] ?? [];
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      print('⚠️ Failed to load available orders: ${response.statusCode}');
      return [];
    }
  }

  /// Get current active delivery
  static Future<Map<String, dynamic>?> getActiveDelivery() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_base/drivers/active_delivery/'),
      headers: _headers(token),
    );

    print('🚚 Active delivery - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      return null;
    }
  }

  /// Accept an order
  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/accept_order/'),
      headers: _headers(token),
      body: json.encode({'order_id': orderId}),
    );

    print('✅ Accept order - Status: ${response.statusCode}');
    print('✅ Accept order - Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to accept order');
    }
  }

  /// Update delivery status (arrived, picked_up, delivered)
  static Future<Map<String, dynamic>> updateDeliveryStatus(String deliveryId, String status) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/update_delivery_status/'),
      headers: _headers(token),
      body: json.encode({
        'delivery_id': deliveryId,
        'status': status,
      }),
    );

    print('🔄 Update delivery status - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update status');
    }
  }

  /// Cancel a delivery
  static Future<Map<String, dynamic>> cancelDelivery(String deliveryId, {String reason = ''}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/cancel_delivery/'),
      headers: _headers(token),
      body: json.encode({
        'delivery_id': deliveryId,
        'reason': reason,
      }),
    );

    print('❌ Cancel delivery - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to cancel delivery');
    }
  }

  // ============================================================
  // STATUS MANAGEMENT
  // ============================================================

  /// Go online (become available for deliveries)
  static Future<Map<String, dynamic>> goOnline() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/go_online/'),
      headers: _headers(token),
    );

    print('🟢 Go online - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to go online');
    }
  }

  /// Go offline (stop receiving new orders)
  static Future<Map<String, dynamic>> goOffline() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/go_offline/'),
      headers: _headers(token),
    );

    print('🔴 Go offline - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to go offline');
    }
  }

  /// Update driver status (online/offline/busy/break)
  static Future<Map<String, dynamic>> updateStatus(String status) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.patch(
      Uri.parse('$_base/drivers/update_status/'),
      headers: _headers(token),
      body: json.encode({'status': status}),
    );

    print('📝 Update status - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update status');
    }
  }

  // ============================================================
  // PROFILE MANAGEMENT
  // ============================================================

  /// Get driver profile
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_base/drivers/profile/'),
      headers: _headers(token),
    );

    print('👤 Get profile - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Driver profile not found. Please complete registration.');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Update driver profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.patch(
      Uri.parse('$_base/drivers/update_profile/'),
      headers: _headers(token),
      body: json.encode(data),
    );

    print('✏️ Update profile - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update profile');
    }
  }

  // ============================================================
  // LOCATION MANAGEMENT
  // ============================================================

  /// Update driver's current location
  static Future<Map<String, dynamic>> updateLocation(double latitude, double longitude) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/update_location/'),
      headers: _headers(token),
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    print('📍 Update location - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update location');
    }
  }

  // ============================================================
  // RATING
  // ============================================================

  /// Rate a customer after delivery
  static Future<Map<String, dynamic>> rateCustomer(String deliveryId, int rating, {String feedback = ''}) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/rate_customer/'),
      headers: _headers(token),
      body: json.encode({
        'delivery_id': deliveryId,
        'rating': rating,
        'feedback': feedback,
      }),
    );

    print('⭐ Rate customer - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to submit rating');
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Apply as a driver (convert existing user to driver)
  static Future<Map<String, dynamic>> applyAsDriver({
    required String phoneNumber,
    required String vehicleType,
    required String vehicleRegistration,
    required String licenseNumber,
    required DateTime licenseExpiryDate,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_base/drivers/apply_as_driver/'),
      headers: _headers(token),
      body: json.encode({
        'phone_number': phoneNumber,
        'vehicle_type': vehicleType,
        'vehicle_registration': vehicleRegistration,
        'license_number': licenseNumber,
        'license_expiry_date': licenseExpiryDate.toIso8601String().split('T')[0],
      }),
    );

    print('📝 Apply as driver - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to apply as driver');
    }
  }

  /// Check if driver profile exists
  static Future<bool> hasDriverProfile() async {
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}