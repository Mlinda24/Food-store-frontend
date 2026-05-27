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
  static const String baseUrl = 'http://192.168.137.1:8000';
  static const String mediaBaseUrl = 'http://192.168.137.1:8000';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ============================================
  // GROUP 1: TOKEN MANAGEMENT
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
    return {
      'Content-Type': 'multipart/form-data',
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

  Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      print('🔄 Refresh token status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveTokens(data['access'], refreshToken);
        return true;
      }
    } catch (e) {
      print('Token refresh error: $e');
    }

    return false;
  }

  // ============================================
  // GROUP 2: AUTH ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
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
      Uri.parse('$baseUrl/api/auth/me/'),
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
        role: data['role'] == 'restaurant'
            ? UserRole.restaurant
            : UserRole.customer,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await getCurrentUser();
      }
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Failed to get user: ${response.statusCode}');
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
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone ?? '',
      }),
    );

    print('Register response status: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      String errorMessage = 'Registration failed: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map) {
          final errors = <String>[];
          errorData.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errors.add('$key: ${value.join(', ')}');
            } else if (value is String) {
              errors.add('$key: $value');
            } else if (value is Map) {
              value.forEach((subKey, subValue) {
                errors.add('$key.$subKey: ${subValue.join(', ')}');
              });
            }
          });
          if (errors.isNotEmpty) {
            errorMessage = errors.join('\n');
          }
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // ============================================
  // GROUP 3: CUSTOMER RESTAURANT ENDPOINTS
  // ============================================

  Future<List<dynamic>> getRestaurants() async {
    final token = await getToken();
    if (token == null) {
      print('❌ No token found, please login first');
      return [];
    }

    final url = '$baseUrl/api/customer/restaurants/';
    print('📡 Fetching restaurants from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    print('Get restaurants response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Found ${data.length} restaurants');
      return data;
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return getRestaurants();
      return [];
    } else {
      print('❌ Error getting restaurants: ${response.statusCode}');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRestaurant(String id) async {
    final url = '$baseUrl/api/customer/restaurants/$id/';
    print('📡 Fetching restaurant details from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    print('Get restaurant response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Restaurant loaded: ${data['name']}');
      return data;
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return getRestaurant(id);
      return {};
    } else {
      print('❌ Failed to load restaurant: ${response.statusCode}');
      return {};
    }
  }

  Future<Map<String, dynamic>> getRestaurantDeliveryInfo(
      String restaurantId, double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/customer/restaurants/$restaurantId/delivery-info/?lat=$lat&lng=$lng'),
      headers: await getHeaders(),
    );

    print('Delivery info response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'can_deliver': true, 'delivery_fee': 2000.0};
    }
  }

  Future<List<dynamic>> getFeaturedRestaurants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/featured/'),
      headers: await getHeaders(),
    );

    print('Get featured restaurants response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return getFeaturedRestaurants();
      return [];
    } else {
      return [];
    }
  }

  // ============================================
  // GROUP 4: CUSTOMER MENU ENDPOINTS
  // ============================================

  Future<List<dynamic>> getRestaurantMenu(int restaurantId) async {
    final token = await getToken();
    if (token == null) {
      print('❌ No token found, please login first');
      return [];
    }

    final url = '$baseUrl/api/customer/restaurants/$restaurantId/menu/';
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🍽️ FETCHING MENU');
    print('   Restaurant ID: $restaurantId');
    print('   URL: $url');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS! Raw data type: ${data.runtimeType}');

        List<dynamic> menuItems = [];

        if (data.containsKey('menu') && data['menu'] is List) {
          final menuList = data['menu'] as List;
          for (var menuCategory in menuList) {
            if (menuCategory.containsKey('items') &&
                menuCategory['items'] is List) {
              final items = menuCategory['items'] as List;
              menuItems.addAll(items);
              print(
                  '✅ Found ${items.length} items in category: ${menuCategory['category_name'] ?? 'Uncategorized'}');
            }
          }
        }

        if (menuItems.isEmpty &&
            data.containsKey('restaurant') &&
            data['restaurant'].containsKey('menu_items')) {
          menuItems = data['restaurant']['menu_items'] as List;
          print('✅ Found ${menuItems.length} items in restaurant.menu_items');
        }

        if (menuItems.isEmpty && data.containsKey('menu_items')) {
          menuItems = data['menu_items'] as List;
          print('✅ Found ${menuItems.length} items in direct menu_items');
        }

        print('📊 Total menu items extracted: ${menuItems.length}');
        if (menuItems.isNotEmpty) {
          print(
              '📋 First item: ${menuItems[0]['name']} - MK${menuItems[0]['price']}');
        }

        return menuItems;
      } else if (response.statusCode == 401) {
        print('⚠️ Token expired, attempting refresh...');
        final refreshed = await refreshToken();
        if (refreshed) return getRestaurantMenu(restaurantId);
        return [];
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching menu: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMenuItems({int? restaurantId}) async {
    if (restaurantId != null) {
      return getRestaurantMenu(restaurantId);
    }

    print('🌐 Fetching menu items from ALL restaurants...');
    final restaurants = await getRestaurants();

    if (restaurants.isEmpty) {
      print('⚠️ No restaurants found, returning empty menu list');
      return [];
    }

    final List<dynamic> allItems = [];

    for (var restaurant in restaurants) {
      try {
        final dynamic rawId = restaurant['id'];
        if (rawId == null) continue;

        final int parsedId = rawId is int ? rawId : int.parse(rawId.toString());
        final String restaurantName =
            restaurant['name']?.toString() ?? 'Restaurant';

        print('📡 Fetching menu for: $restaurantName (ID: $parsedId)');

        final items = await getRestaurantMenu(parsedId);

        for (var item in items) {
          final enriched = Map<String, dynamic>.from(item as Map);
          enriched['restaurant'] ??= parsedId;
          enriched['restaurant_name'] ??= restaurantName;
          allItems.add(enriched);
        }

        print('   ✅ Added ${items.length} items from $restaurantName');
      } catch (e) {
        print('❌ Error fetching menu for restaurant ${restaurant['id']}: $e');
      }
    }

    print('🎉 Total menu items across all restaurants: ${allItems.length}');
    return allItems;
  }

  Future<List<dynamic>> searchMenu(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/menu/search/?q=$query'),
      headers: await getHeaders(),
    );

    print('Search menu response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Found ${data.length} items matching "$query"');
      return data;
    } else {
      return [];
    }
  }

  // ============================================
  // GROUP 5: RESTAURANT OWNER ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> createRestaurant(
      Map<String, dynamic> data) async {
    print('🏪 Creating restaurant with data: $data');

    final response = await http.post(
      Uri.parse('$baseUrl/api/owner/restaurants/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );

    print('Create restaurant response: ${response.statusCode}');
    print('Create restaurant body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? error.toString());
    } else {
      throw Exception('Failed to create restaurant: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createRestaurantWithImage({
    required String name,
    required String address,
    required String phone,
    String? description,
    required File imageFile,
  }) async {
    print('🏪 Creating restaurant with image upload');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/owner/restaurants/'),
    );

    final token = await getToken();
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['address'] = address;
    request.fields['phone'] = phone;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    request.fields['is_open'] = 'true';

    final bytes = await imageFile.readAsBytes();
    final fileName = path.basename(imageFile.path);

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    print('Create restaurant response: ${response.statusCode}');
    print('Create restaurant body: ${responseBody.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(responseBody.body);
    } else {
      throw Exception('Failed to create restaurant: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMyRestaurant() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/owner/restaurants/my_restaurant/'),
      headers: await getHeaders(),
    );

    print('Get my restaurant response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> updateMyRestaurant(
      Map<String, dynamic> data) async {
    print('📝 Updating my restaurant with data: $data');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/owner/restaurants/my_restaurant/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );

    print('Update my restaurant response: ${response.statusCode}');
    print('Update my restaurant body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update restaurant: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateRestaurantLocation({
    required String restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    final data = {
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/api/owner/restaurants/$restaurantId/'),
      headers: await getHeaders(),
      body: json.encode(data),
    );

    print('Update restaurant location response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to update restaurant location: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getRestaurantOrders() async {
    try {
      final myRestaurant = await getMyRestaurant();
      final restaurantId = myRestaurant['id']?.toString();

      print('🏪 Getting orders for restaurant ID: $restaurantId');

      if (restaurantId == null) {
        print('⚠️ No restaurant found for this user');
        return [];
      }

      List<dynamic> allOrders = [];

      final allOrdersResponse = await http.get(
        Uri.parse('$baseUrl/api/orders/orders/'),
        headers: await getHeaders(),
      );

      if (allOrdersResponse.statusCode == 200) {
        final data = json.decode(allOrdersResponse.body);
        List<dynamic> orders = [];

        if (data is List) {
          orders = data;
        } else if (data is Map && data.containsKey('results')) {
          orders = data['results'];
        } else if (data is Map && data.containsKey('orders')) {
          orders = data['orders'];
        }

        for (var order in orders) {
          final orderRestaurantId = order['restaurant']?.toString() ??
              order['restaurant_id']?.toString();
          if (orderRestaurantId == restaurantId) {
            allOrders.add(order);
          }
        }
        print(
            '✅ Found ${allOrders.length} orders for restaurant after filtering');
      } else {
        print('⚠️ Failed to get orders: ${allOrdersResponse.statusCode}');
      }

      return allOrders;
    } catch (e) {
      print('❌ Error in getRestaurantOrders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRestaurantStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/owner/restaurants/stats/'),
      headers: await getHeaders(),
    );

    print('Get restaurant stats response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = await decodeResponse(response);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {
        'walletBalance': 0.0,
        'totalEarned': 0.0,
        'totalWithdrawn': 0.0,
        'todayEarnings': 0.0,
        'todayOrders': 0,
        'monthlyEarnings': 0.0,
        'monthlyOrders': 0,
        'totalEarnings': 0.0,
        'totalOrders': 0,
        'activeOrders': 0,
        'averageRating': 0.0,
      };
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> getRestaurantWalletBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/restaurants/wallet_balance/'),
      headers: await getHeaders(),
    );

    print('Get wallet balance response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get wallet balance');
    }
  }

  Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> itemData) async {
    print('➕ Create menu item');

    final myRestaurant = await getMyRestaurant();
    final restaurantId = myRestaurant['id']?.toString();

    if (restaurantId == null) {
      throw Exception(
          'No restaurant found for this user. Please register a restaurant first.');
    }

    final dataWithRestaurant = Map<String, dynamic>.from(itemData);
    dataWithRestaurant['restaurant'] = int.parse(restaurantId);

    final response = await http.post(
      Uri.parse('$baseUrl/api/owner/menu-items/'),
      headers: await getHeaders(),
      body: json.encode(dataWithRestaurant),
    );

    print('Create menu item response: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      return data is Map<String, dynamic> ? data : {'success': true};
    } else {
      throw Exception('Failed to create menu item: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createMenuItemWithImage({
    required String name,
    required String description,
    required double price,
    required String category,
    required XFile imageFile,
  }) async {
    print('📸 Creating menu item with image upload');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/owner/menu-items/'),
    );

    final token = await getToken();
    request.headers['Authorization'] = 'Bearer $token';

    final myRestaurant = await getMyRestaurant();
    final restaurantId = myRestaurant['id']?.toString();

    if (restaurantId == null) {
      throw Exception('No restaurant found for this user');
    }

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['category'] = category;
    request.fields['restaurant'] = restaurantId;

    final bytes = await imageFile.readAsBytes();
    final fileName = path.basename(imageFile.path);

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    print('Create menu item response: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(responseBody.body);
    } else {
      throw Exception('Failed to create menu item: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateMenuItem(
      String id, Map<String, dynamic> itemData) async {
    print('✏️ Update menu item');
    print('   ID: $id');
    print('   Data to update: $itemData');

    final cleanedData = Map<String, dynamic>.from(itemData);

    cleanedData.remove('id');
    cleanedData.remove('restaurant');
    cleanedData.remove('restaurant_id');
    cleanedData.remove('restaurant_name');
    cleanedData.remove('created');
    cleanedData.remove('category_name');

    if (cleanedData.containsKey('is_available')) {
      cleanedData['is_available'] = cleanedData['is_available'] == true;
    }

    if (cleanedData.containsKey('category') &&
        cleanedData['category'] == null) {
      cleanedData['category'] = null;
    }

    print('   Cleaned data: $cleanedData');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/owner/menu-items/$id/'),
      headers: await getHeaders(),
      body: json.encode(cleanedData),
    );

    print('Update response status: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      print('✅ Menu item updated successfully');
      return data is Map<String, dynamic> ? data : {'success': true};
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      print('❌ Validation errors: $error');
      throw Exception('Validation error: ${error.toString()}');
    } else {
      throw Exception('Failed to update menu item: ${response.statusCode}');
    }
  }

  Future<void> deleteMenuItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/owner/menu-items/$id/'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete menu item: ${response.statusCode}');
    }
  }

  // ============================================
  // GROUP 6: CART ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getCart() async {
    final token = await getToken();
    if (token == null) {
      print('❌ No token, returning empty cart');
      return {'items': [], 'total_price': 0, 'total_items': 0};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/cart/'),
      headers: await getHeaders(),
    );

    print('Get cart response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Cart loaded successfully');
      print('   Items in cart: ${data['items']?.length ?? 0}');
      print('   Total price: ${data['total_price']}');
      return data;
    } else if (response.statusCode == 401) {
      print('⚠️ Token expired, refreshing...');
      final refreshed = await refreshToken();
      if (refreshed) return getCart();
      return {'items': [], 'total_price': 0, 'total_items': 0};
    } else {
      print('❌ Failed to load cart: ${response.statusCode}');
      return {'items': [], 'total_price': 0, 'total_items': 0};
    }
  }

  Future<Map<String, dynamic>> addToCart(int menuItemId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/cart/add_item/'),
      headers: await getHeaders(),
      body: json.encode({
        'menu_item_id': menuItemId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> removeFromCart(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/orders/cart/remove_item/'),
      headers: await getHeaders(),
      body: json.encode({'cart_item_id': cartItemId}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return {};
    } else {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateCartItem(
      int cartItemId, int quantity) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/orders/cart/update_item/'),
      headers: await getHeaders(),
      body: json.encode({
        'cart_item_id': cartItemId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update cart item: ${response.statusCode}');
    }
  }

  Future<void> clearCart() async {
    await http.post(
      Uri.parse('$baseUrl/api/orders/cart/clear_cart/'),
      headers: await getHeaders(),
    );
  }

  // ============================================
  // GROUP 7: ORDER ENDPOINTS
  // ============================================

  Future<List<dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/orders/'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('results')) {
        return data['results'];
      }
      return [];
    } else {
      return [];
    }
  }

  // Get my orders (for customer)
  Future<List<Order>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/my_orders/'),
      headers: await getHeaders(),
    );

    print('Get my orders response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> ordersData = data is List ? data : (data['results'] ?? []);

      return ordersData.map((json) => Order.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return getMyOrders();
      return [];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    print('📝 Creating order');
    print('📤 Order data: $orderData');

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/orders/'),
      headers: await getHeaders(),
      body: json.encode(orderData),
    );

    print('Create order response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      print('❌ Validation errors: $error');
      throw Exception(error['error'] ?? error.toString());
    } else {
      throw Exception('Failed to create order: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders/orders/$orderId/'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load order: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String status) async {
    print('🔄 Updating order #$orderId status to: $status');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/orders/orders/$orderId/update_status/'),
      headers: await getHeaders(),
      body: json.encode({'status': status}),
    );

    print('Update order status response: ${response.statusCode}');
    print('Update order status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return updateOrderStatus(orderId, status);
      throw Exception('Session expired. Please login again.');
    } else {
      throw Exception('Failed to update order status: ${response.statusCode}');
    }
  }

  // Customer marks order as delivered/received
  Future<Map<String, dynamic>> markOrderAsDelivered(String orderId) async {
    return updateOrderStatus(orderId, 'delivered');
  }

  // ============================================
  // GROUP 8: PAYMENT ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String orderId,
    required PaymentMethod method,
  }) async {
    print('💳 Initiating payment:');
    print('   Order ID: $orderId');
    print('   Method: ${method.value}');
    print('   Phone: $phoneNumber');
    print('   Amount (for reference): MK$amount');

    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/initiate/'),
      headers: await getHeaders(),
      body: json.encode({
        'order_id': orderId,
        'method': method.value,
        'phone_number': phoneNumber,
      }),
    );

    print('💳 Initiate payment response: ${response.statusCode}');
    print('💳 Initiate payment body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {};
      try {
        error = json.decode(response.body);
      } catch (_) {}
      throw Exception(error['error'] ??
          'Payment initiation failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> initiateSimplePayment({
    required double amount,
    required String orderId,
  }) async {
    print('💳 Initiating simple payment:');
    print('   Order ID: $orderId');
    print('   Amount: MK$amount');

    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/initiate_simple/'),
      headers: await getHeaders(),
      body: json.encode({
        'order_id': orderId,
      }),
    );

    print('💳 Initiate payment response: ${response.statusCode}');
    print('💳 Initiate payment body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {};
      try {
        error = json.decode(response.body);
      } catch (_) {}
      throw Exception(error['error'] ??
          'Payment initiation failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> initiatePayChanguPayment({
    required double amount,
    required String orderId,
  }) async {
    print('💳 Initiating PayChangu payment (simplified):');
    print('   Order ID: $orderId');
    print('   Amount: MK$amount');

    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/initiate/'),
      headers: await getHeaders(),
      body: json.encode({
        'order_id': orderId,
        'method': 'paychangu',
        'phone_number': '',
      }),
    );

    print('💳 Initiate payment response: ${response.statusCode}');
    print('💳 Initiate payment body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {};
      try {
        error = json.decode(response.body);
      } catch (_) {}
      throw Exception(error['error'] ??
          'Payment initiation failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/payments/$transactionId/status/'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify payment: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatusByReference(
      String reference) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/api/payments/status_by_reference/?reference=$reference'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get payment status: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getMyPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/payments/my_payments/'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data is List ? data : [];
    } else {
      return [];
    }
  }

  // ============================================
  // GROUP 9: WITHDRAWAL & WALLET ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String phoneNumber,
    required String provider,
  }) async {
    print('💰 Requesting withdrawal:');
    print('   Amount: MK$amount');
    print('   Phone: $phoneNumber');
    print('   Provider: $provider');

    final response = await http.post(
      Uri.parse('$baseUrl/api/restaurants/withdraw/'),
      headers: await getHeaders(),
      body: json.encode({
        'amount': amount.toString(),
        'phone_number': phoneNumber,
        'provider': provider,
      }),
    );

    print('Withdrawal response status: ${response.statusCode}');
    print('Withdrawal response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {};
      try {
        error = json.decode(response.body);
      } catch (_) {}
      throw Exception(
          error['error'] ?? 'Withdrawal failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/restaurants/wallet_balance/'),
      headers: await getHeaders(),
    );

    print('Get wallet balance response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return {'balance': 0.0, 'total_earned': 0.0, 'total_withdrawn': 0.0};
    } else {
      throw Exception('Failed to get wallet balance');
    }
  }

  Future<Map<String, dynamic>> getWalletTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/restaurants/wallet/'),
      headers: await getHeaders(),
    );

    print('Get wallet transactions response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get wallet transactions');
    }
  }

  // ============================================
  // GROUP 10: NOTIFICATION ENDPOINTS
  // ============================================

  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/notifications/'),
      headers: await getHeaders(),
    );

    print('📬 Get notifications response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        print('✅ Found ${data.length} notifications');
        return data;
      } else if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        print('✅ Found ${results.length} notifications (paginated)');
        return results;
      }
      return [];
    }
    return [];
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/notifications/unread_count/'),
      headers: await getHeaders(),
    );

    print('📬 Unread count response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['unread_count'] ?? 0;
    }
    return 0;
  }

  Future<Map<String, dynamic>> markNotificationRead(
      String notificationId) async {
    final response = await http.patch(
      Uri.parse(
          '$baseUrl/api/notifications/notifications/$notificationId/mark_read/'),
      headers: await getHeaders(),
    );

    print('📬 Mark read response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to mark notification as read');
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/notifications/mark_all_read/'),
      headers: await getHeaders(),
    );

    print('📬 Mark all read response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to mark all as read');
  }

  Future<void> deleteNotification(String notificationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications/notifications/$notificationId/'),
      headers: await getHeaders(),
    );

    print('📬 Delete notification response: ${response.statusCode}');

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  // ============================================
  // GROUP 11: UTILITY METHODS
  // ============================================

  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$mediaBaseUrl$imagePath';
  }
}
