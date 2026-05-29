import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RestaurantService {
  static const String _base = '${ApiConfig.baseUrl}/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  static Future<List<dynamic>> getRestaurants() async {
    final res = await http.get(
      Uri.parse('$_base/restaurants/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load restaurants');
  }

  static Future<Map<String, dynamic>> getMyRestaurant() async {
    final res = await http.get(
      Uri.parse('$_base/restaurants/my_restaurant/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load restaurant');
  }

  static Future<void> updateMyRestaurant(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$_base/restaurants/my_restaurant/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) throw Exception('Failed to update restaurant');
  }

  static Future<Map<String, dynamic>> getRestaurantStats() async {
    final res = await http.get(
      Uri.parse('$_base/restaurants/stats/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load stats');
  }

  static Future<List<dynamic>> getMenuItems() async {
    final res = await http.get(
      Uri.parse('$_base/menu-items/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load menu items');
  }

  static Future<void> createMenuItem(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_base/menu-items/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode != 201) throw Exception('Failed to create menu item');
  }

  static Future<void> updateMenuItem(dynamic id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$_base/menu-items/$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) throw Exception('Failed to update menu item');
  }

  static Future<void> deleteMenuItem(dynamic id) async {
    final res = await http.delete(
      Uri.parse('$_base/menu-items/$id/'),
      headers: await _headers(),
    );
    if (res.statusCode != 204) throw Exception('Failed to delete menu item');
  }

  static Future<List<dynamic>> searchMenu(String query) async {
    final res = await http.get(
      Uri.parse('$_base/menu-items/?search=$query'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to search menu');
  }
}
