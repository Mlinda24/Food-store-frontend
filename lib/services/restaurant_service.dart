import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class RestaurantService {
  static const String _base = 'http://127.0.0.1:8000/api';

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  // ─── Restaurant owner endpoints (/api/owner/) ────────────────────────────

  /// GET /api/owner/restaurants/my_restaurant/
  static Future<Map<String, dynamic>> getMyRestaurant() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/owner/restaurants/my_restaurant/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // Backend returns a list for this endpoint — return first item
      if (body is List && body.isNotEmpty) return body[0];
      if (body is Map<String, dynamic>) return body;
      throw Exception('Unexpected response format');
    }
    throw Exception('Failed to load restaurant (${response.statusCode})');
  }

  /// PATCH /api/owner/restaurants/my_restaurant/
  static Future<Map<String, dynamic>> updateMyRestaurant(
      Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.patch(
      Uri.parse('$_base/owner/restaurants/my_restaurant/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update restaurant (${response.statusCode})');
  }

  /// GET /api/owner/restaurants/stats/
  static Future<Map<String, dynamic>> getRestaurantStats() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/owner/restaurants/stats/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is List && body.isNotEmpty) return body[0];
      if (body is Map<String, dynamic>) return body;
      return {};
    }
    throw Exception('Failed to load stats (${response.statusCode})');
  }

  // ─── Menu item endpoints (/api/owner/menu-items/) ────────────────────────

  /// GET /api/owner/menu-items/
  static Future<List<dynamic>> getMenuItems() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/owner/menu-items/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load menu items (${response.statusCode})');
  }

  /// POST /api/owner/menu-items/
  /// Required: { name, price }
  /// Optional: { description, is_available, category }
  static Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.post(
      Uri.parse('$_base/owner/menu-items/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create menu item (${response.statusCode})');
  }

  /// PATCH /api/owner/menu-items/{id}/
  static Future<Map<String, dynamic>> updateMenuItem(
      int id, Map<String, dynamic> data) async {
    final token = await AuthProvider.getToken();
    final response = await http.patch(
      Uri.parse('$_base/owner/menu-items/$id/'),
      headers: _headers(token ?? ''),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update menu item (${response.statusCode})');
  }

  /// DELETE /api/owner/menu-items/{id}/
  static Future<void> deleteMenuItem(int id) async {
    final token = await AuthProvider.getToken();
    final response = await http.delete(
      Uri.parse('$_base/owner/menu-items/$id/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete menu item (${response.statusCode})');
    }
  }

  // ─── Customer-facing endpoints (/api/customer/) ──────────────────────────

  /// GET /api/customer/restaurants/
  static Future<List<dynamic>> getRestaurants() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/customer/restaurants/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load restaurants (${response.statusCode})');
  }

  /// GET /api/customer/restaurants/{id}/
  static Future<Map<String, dynamic>> getRestaurant(int id) async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/customer/restaurants/$id/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load restaurant (${response.statusCode})');
  }

  /// GET /api/customer/restaurants/{id}/menu/
  static Future<Map<String, dynamic>> getRestaurantMenu(int id) async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/customer/restaurants/$id/menu/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load menu (${response.statusCode})');
  }

  /// GET /api/customer/featured/
  static Future<List<dynamic>> getFeaturedRestaurants() async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/customer/featured/'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load featured restaurants (${response.statusCode})');
  }

  /// GET /api/customer/menu/search/?q=query
  static Future<List<dynamic>> searchMenu(String query) async {
    final token = await AuthProvider.getToken();
    final response = await http.get(
      Uri.parse('$_base/customer/menu/search/?q=$query'),
      headers: _headers(token ?? ''),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Search failed (${response.statusCode})');
  }
}