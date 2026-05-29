import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../config/api_config.dart'; 

class OrderService {
  static const String _base = '${ApiConfig.baseUrl}/api';

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  /// GET /api/orders/orders/
  static Future<List<dynamic>> getOrders() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/orders/orders/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load orders (${response.statusCode})');
  }

  /// GET /api/orders/orders/{id}/
  static Future<Map<String, dynamic>> getOrderDetails(int id) async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/orders/orders/$id/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load order details (${response.statusCode})');
  }

  /// POST /api/orders/orders/
  /// Required: { restaurant_id, delivery_address, note? }
  static Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.post(
      Uri.parse('$_base/orders/orders/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create order (${response.statusCode})');
  }

  /// PATCH /api/orders/orders/{id}/update_status/
  /// status options: pending, confirmed, preparing, ready,
  ///                 picked_up, delivered, cancelled
  static Future<Map<String, dynamic>> updateOrderStatus(
      int id, String status) async {
    final token = await AuthProvider.getToken();
    final response = await http.patch(
      Uri.parse('$_base/orders/orders/$id/update_status/'),
      headers: _headers(token ?? ''),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update order status (${response.statusCode})');
  }

  /// DELETE /api/orders/orders/{id}/
  static Future<void> deleteOrder(int id) async {
    final token = await AuthProvider.getToken();
    final response = await http.delete(
      Uri.parse('$_base/orders/orders/$id/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete order (${response.statusCode})');
    }
  }

  // ─── Cart ───────────────────────────────────────────────

  /// GET /api/orders/cart/
  static Future<Map<String, dynamic>> getCart() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/orders/cart/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load cart (${response.statusCode})');
  }

  /// POST /api/orders/cart/add_item/
  static Future<Map<String, dynamic>> addCartItem(
      Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.post(
      Uri.parse('$_base/orders/cart/add_item/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to add item to cart (${response.statusCode})');
  }

  /// PATCH /api/orders/cart/update_item/
  static Future<Map<String, dynamic>> updateCartItem(
      Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.patch(
      Uri.parse('$_base/orders/cart/update_item/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update cart item (${response.statusCode})');
  }

  /// DELETE /api/orders/cart/remove_item/
  static Future<void> removeCartItem(Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final request = http.Request(
      'DELETE',
      Uri.parse('$_base/orders/cart/remove_item/'),
    );
    request.headers.addAll(_headers(token ?? ''));
    request.body = json.encode(data);
    final streamed = await request.send();
    if (streamed.statusCode != 204) {
      throw Exception('Failed to remove cart item (${streamed.statusCode})');
    }
  }

  /// POST /api/orders/cart/clear_cart/
  static Future<void> clearCart() async {
    final token = await AuthProvider.getToken();
    await http.post(
      Uri.parse('$_base/orders/cart/clear_cart/'),
      headers: _headers(token ?? ''),
    );
  }
}