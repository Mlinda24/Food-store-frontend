import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get driver profile
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drivers/profile/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  // Update driver profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/drivers/update_profile/'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update profile');
  }

  // Get available orders
  static Future<List<dynamic>> getAvailableOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drivers/available_orders/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // Accept an order
  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/drivers/accept_order/'),
      headers: await _getHeaders(),
      body: json.encode({'order_id': orderId}),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to accept order');
  }

  // Decline an order
  static Future<void> declineOrder(String orderId) async {
    await http.post(
      Uri.parse('$_baseUrl/drivers/decline_order/'),
      headers: await _getHeaders(),
      body: json.encode({'order_id': orderId}),
    );
  }

  // Update order status (arrived, picked_up, delivered)
  static Future<Map<String, dynamic>> updateDeliveryStatus({required String orderId, required String status}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/drivers/update_delivery_status/'),
      headers: await _getHeaders(),
      body: json.encode({
        'order_id': orderId,
        'status': status,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update order status');
  }

  // Cancel delivery
  static Future<void> cancelDelivery(String orderId) async {
    await http.post(
      Uri.parse('$_baseUrl/drivers/cancel_delivery/'),
      headers: await _getHeaders(),
      body: json.encode({'order_id': orderId}),
    );
  }

  // Update driver location
  static Future<void> updateLocation(double lat, double lng) async {
    await http.post(
      Uri.parse('$_baseUrl/drivers/update_location/'),
      headers: await _getHeaders(),
      body: json.encode({
        'latitude': lat,
        'longitude': lng,
      }),
    );
  }

  // Go online
  static Future<Map<String, dynamic>> goOnline() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/drivers/go_online/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go online');
  }

  // Go offline
  static Future<Map<String, dynamic>> goOffline() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/drivers/go_offline/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go offline');
  }

  // Get active delivery
  static Future<Map<String, dynamic>> getActiveDelivery() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drivers/active_delivery/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  // Get delivery history
  static Future<Map<String, dynamic>> getDeliveryHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drivers/delivery_history/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'deliveries': []};
  }

  // Get earnings summary
  static Future<Map<String, dynamic>> getEarningsSummary() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/drivers/earnings_summary/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {
      'total_earnings': 0,
      'today_earnings': 0,
      'week_earnings': 0,
      'month_earnings': 0,
      'total_deliveries': 0,
      'rating': 0,
    };
  }
}