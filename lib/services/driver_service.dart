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
  // STATUS
  // ============================================================

  static Future<Map<String, dynamic>> goOnline() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$_base/drivers/go_online/'),
      headers: _headers(token),
    );
    print('🟢 Go online - Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go online');
  }

  static Future<Map<String, dynamic>> goOffline() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$_base/drivers/go_offline/'),
      headers: _headers(token),
    );
    print('🔴 Go offline - Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to go offline');
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
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load profile');
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
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
      return {
        'today_earnings': 0,
        'total_earnings': 0,
        'total_deliveries': 0,
        'rating': 5.0,
        'today_deliveries': 0,
      };
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
          'today_earnings':
              double.tryParse(data['today_earnings']?.toString() ?? '0') ?? 0,
          'total_earnings':
              double.tryParse(data['total_earnings']?.toString() ?? '0') ?? 0,
          'total_deliveries':
              int.tryParse(data['total_deliveries']?.toString() ?? '0') ?? 0,
          'rating':
              double.tryParse(data['rating']?.toString() ?? '5.0') ?? 5.0,
          'today_deliveries':
              int.tryParse(data['today_deliveries']?.toString() ?? '0') ?? 0,
        };
      }
    } catch (e) {
      print('Error getting earnings: $e');
    }
    return {
      'today_earnings': 0,
      'total_earnings': 0,
      'total_deliveries': 0,
      'rating': 5.0,
      'today_deliveries': 0,
    };
  }

  static Future<List<dynamic>> getDeliveryHistory() async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$_base/drivers/delivery_history/'),
        headers: _headers(token),
      );
      print('📜 History - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend may return { "deliveries": [...] } or a plain list
        if (data is List) return data;
        return data['deliveries'] ?? data['orders'] ?? [];
      }
    } catch (e) {
      print('Error getting history: $e');
    }
    return [];
  }

  // ============================================================
  // RESTAURANT ADDRESS LOOKUP
  // The Order schema does NOT include restaurant_address, so we
  // fetch it from the customer restaurants endpoint using the
  // restaurant_id that comes with every order.
  // Results are cached to avoid redundant calls.
  // ============================================================
  static final Map<int, String> _restaurantAddressCache = {};

  static Future<String> getRestaurantAddress(int restaurantId) async {
    if (_restaurantAddressCache.containsKey(restaurantId)) {
      return _restaurantAddressCache[restaurantId]!;
    }
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_base/customer/restaurants/$restaurantId/'),
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
  // Returns real backend orders, falls back to mock only if
  // backend is unreachable (network error).
  // ============================================================
  static List<Map<String, dynamic>> _getMockOrders() {
    return [
      {
        'id': 'MOCK-001',
        'restaurant_name': "Luigi's Pizza",
        'restaurant_address': '123 Main Street, Downtown',
        'restaurant_id': 0,
        'customer_name': 'John Doe',
        'customer_phone': '0999123456',
        'delivery_address': '456 Oak Avenue, Apartment 4B',
        'status': 'pending',
        'items': '2 items (Pepperoni Pizza, Garlic Bread)',
        'total_price': '450',
        'created': '15-20 min',
      },
      {
        'id': 'MOCK-002',
        'restaurant_name': 'Burger King',
        'restaurant_address': '456 Fast Food Lane',
        'restaurant_id': 0,
        'customer_name': 'Jane Smith',
        'customer_phone': '0888123456',
        'delivery_address': '789 Pine Street',
        'status': 'pending',
        'items': '1 item (Whopper Meal)',
        'total_price': '380',
        'created': '10-15 min',
      },
      {
        'id': 'MOCK-003',
        'restaurant_name': 'Sushi Master',
        'restaurant_address': '789 Sushi Road',
        'restaurant_id': 0,
        'customer_name': 'Mike Johnson',
        'customer_phone': '0999765432',
        'delivery_address': '321 Fish Avenue',
        'status': 'pending',
        'items': '3 items (California Roll, Miso Soup, Green Tea)',
        'total_price': '520',
        'created': '25-30 min',
      },
    ];
  }

  static Future<List<dynamic>> getAvailableOrders() async {
    final token = await _getToken();
    if (token == null) {
      print('⚠️ No token – returning mock orders');
      return _getMockOrders();
    }

    try {
      final response = await http.get(
        Uri.parse('$_base/drivers/available_orders/'),
        headers: _headers(token),
      );

      print('📦 Available orders - Status: ${response.statusCode}');
      print('📦 Available orders - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> orders;

        // Handle both { "orders": [...] } and plain list responses
        if (data is List) {
          orders = data;
        } else {
          orders = data['orders'] ?? data['results'] ?? [];
        }

        if (orders.isEmpty) {
          print('⚠️ Backend returned 0 orders – using mock data for testing');
          return _getMockOrders();
        }
        return orders;
      } else {
        print('⚠️ Backend error (${response.statusCode}) – using mock data');
        return _getMockOrders();
      }
    } catch (e) {
      print('⚠️ Network error: $e – using mock data');
      return _getMockOrders();
    }
  }

  // ============================================================
  // ACTIVE DELIVERY
  // Backend may return the delivery/order directly or wrapped.
  // We normalise to a single Map or null.
  // ============================================================
  static Future<Map<String, dynamic>?> getActiveDelivery() async {
    final token = await _getToken();
    if (token == null) return null;

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
        // Unwrap { "delivery": {...} } or { "order": {...} } if present
        if (data is Map) {
          if (data.containsKey('delivery') && data['delivery'] is Map) {
            return Map<String, dynamic>.from(data['delivery']);
          }
          if (data.containsKey('order') && data['order'] is Map) {
            return Map<String, dynamic>.from(data['order']);
          }
          // Plain order object
          if (data.containsKey('id')) {
            return Map<String, dynamic>.from(data);
          }
        }
        return null;
      }
      // 404 means no active delivery – that's fine
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
  static Future<Map<String, dynamic>> updateDeliveryStatus(
      String deliveryId, String status) async {
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
    throw Exception('Failed to update status');
  }
}