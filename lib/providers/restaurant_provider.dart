import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/api_service.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MenuItem> _menuItems = [];
  List<RestaurantOrder> _activeOrders = [];
  List<RestaurantOrder> _readyOrders = [];
  List<RestaurantOrder> _pastOrders = [];
  List<dynamic> _orders = [];
  RestaurantStats? _stats;
  bool _isLoading = false;
  bool _isLoadingMenu = false;
  bool _isLoadingOrders = false;
  bool _isRestaurantOpen = true;
  Restaurant? _restaurant;
  String? _error;

  // Location and delivery settings
  double? _restaurantLatitude;
  double? _restaurantLongitude;
  double _baseDeliveryFee = 1000.0;
  double _feePerKm = 1000.0;
  double _freeDeliveryRadius = 0.0;
  double _maxDeliveryRadius = 2500.0;
  Map<String, double> _tierFees = {
    'tier_1': 1000.0,
    'tier_2': 2000.0,
    'tier_3': 3000.0,
    'tier_4': 4000.0,
    'tier_5': 5000.0,
  };

  // ============================================
  // GROUP 1: GETTERS
  // ============================================

  List<MenuItem> get menuItems => _menuItems;
  List<RestaurantOrder> get activeOrders => _activeOrders;
  List<RestaurantOrder> get readyOrders => _readyOrders;
  List<RestaurantOrder> get pastOrders => _pastOrders;
  List<dynamic> get orders => _orders;
  RestaurantStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingMenu => _isLoadingMenu;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isRestaurantOpen => _isRestaurantOpen;
  Restaurant? get restaurant => _restaurant;
  String? get error => _error;

  // Wallet getters
  double get walletBalance => _stats?.walletBalance ?? 0.0;
  double get totalWithdrawn => _stats?.totalWithdrawn ?? 0.0;
  double get totalEarned => _stats?.totalEarned ?? 0.0;

  // Location getters
  double? get restaurantLatitude => _restaurantLatitude;
  double? get restaurantLongitude => _restaurantLongitude;
  bool get hasLocation =>
      _restaurantLatitude != null && _restaurantLongitude != null;

  // Delivery settings getters
  double get baseDeliveryFee => _baseDeliveryFee;
  double get feePerKm => _feePerKm;
  double get freeDeliveryRadius => _freeDeliveryRadius;
  double get maxDeliveryRadius => _maxDeliveryRadius;
  Map<String, double> get tierFees => _tierFees;

  // ============================================
  // GROUP 2: HELPER METHODS
  // ============================================

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _safeNotify() {
    Future.microtask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    _safeNotify();
  }

  // ============================================
  // GROUP 3: RESTAURANT CREATION
  // ============================================

  Future<bool> createRestaurant({
    required String name,
    required String address,
    required String phone,
    String? description,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      Map<String, dynamic> result;

      if (imageFile != null) {
        result = await _apiService.createRestaurantWithImage(
          name: name,
          address: address,
          phone: phone,
          description: description,
          imageFile: imageFile,
        );
      } else {
        result = await _apiService.createRestaurant({
          'name': name,
          'address': address,
          'phone': phone,
          'description': description ?? '',
        });
      }

      if (result.isNotEmpty) {
        _restaurant = Restaurant(
          id: result['id']?.toString() ?? '',
          name: result['name']?.toString() ?? name,
          description: result['description']?.toString() ?? description ?? '',
          image: result['image']?.toString() ?? '',
          address: result['address']?.toString() ?? address,
          phone: result['phone']?.toString() ?? phone,
          rating: _toDouble(result['rating']),
          deliveryTime: _toInt(result['delivery_time']),
          deliveryFee: _toDouble(result['delivery_fee']),
          minOrderAmount: _toDouble(result['min_order_amount']),
          categories: ['All'],
          isOpen: result['is_open'] ?? true,
        );

        _isLoading = false;
        _safeNotify();
        return true;
      }

      _isLoading = false;
      _safeNotify();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ Error creating restaurant: $e');
      return false;
    }
  }

  // ============================================
  // GROUP 4: RESTAURANT DATA LOADING
  // ============================================

  Future<void> loadRestaurantData() async {
    _isLoading = true;
    _safeNotify();

    try {
      await Future.wait([
        loadRestaurantInfo(),
        loadMenuItems(),
        loadStats(),
        loadRestaurantOrders(),
      ]);
    } catch (e) {
      _error = e.toString();
      print('Error loading restaurant data: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> loadRestaurantInfo() async {
    try {
      final restaurantData = await _apiService.getMyRestaurant();
      print('📦 Restaurant data: $restaurantData');

      if (restaurantData.isNotEmpty) {
        List<String> categoryList = [];
        if (restaurantData['categories'] != null) {
          final categories = restaurantData['categories'];
          if (categories is List) {
            for (var cat in categories) {
              if (cat is String) {
                categoryList.add(cat);
              } else if (cat is Map) {
                if (cat['name'] != null) {
                  categoryList.add(cat['name'].toString());
                }
              }
            }
          }
        }
        if (categoryList.isEmpty) {
          categoryList = ['All'];
        }

        if (restaurantData['latitude'] != null) {
          _restaurantLatitude = _toDouble(restaurantData['latitude']);
          _restaurantLongitude = _toDouble(restaurantData['longitude']);
          print(
              '📍 Restaurant location: $_restaurantLatitude, $_restaurantLongitude');
        }

        _baseDeliveryFee =
            _toDouble(restaurantData['base_delivery_fee'] ?? 1000.0);
        _feePerKm = _toDouble(restaurantData['fee_per_km'] ?? 1000.0);
        _freeDeliveryRadius =
            _toDouble(restaurantData['free_delivery_radius'] ?? 0.0);
        _maxDeliveryRadius =
            _toDouble(restaurantData['max_delivery_radius'] ?? 2500.0);

        _tierFees = {
          'tier_1': _toDouble(restaurantData['tier_1_fee'] ?? 1000.0),
          'tier_2': _toDouble(restaurantData['tier_2_fee'] ?? 2000.0),
          'tier_3': _toDouble(restaurantData['tier_3_fee'] ?? 3000.0),
          'tier_4': _toDouble(restaurantData['tier_4_fee'] ?? 4000.0),
          'tier_5': _toDouble(restaurantData['tier_5_fee'] ?? 5000.0),
        };

        _restaurant = Restaurant(
          id: restaurantData['id']?.toString() ?? '',
          name: restaurantData['name']?.toString() ?? '',
          description: restaurantData['description']?.toString() ?? '',
          image: restaurantData['image']?.toString() ?? '',
          address: restaurantData['address']?.toString() ?? '',
          phone: restaurantData['phone']?.toString() ?? '',
          rating: _toDouble(restaurantData['rating']),
          deliveryTime: _toInt(restaurantData['delivery_time']),
          deliveryFee: _toDouble(restaurantData['delivery_fee']),
          minOrderAmount: _toDouble(restaurantData['min_order_amount']),
          categories: categoryList,
          isOpen: restaurantData['is_open'] ?? true,
        );
        _isRestaurantOpen = _restaurant?.isOpen ?? true;
        print('✅ Restaurant loaded: ${_restaurant?.name}');
      }
      _safeNotify();
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading restaurant info: $e');
    }
  }

  Future<void> loadMenuItems() async {
    _isLoadingMenu = true;
    _safeNotify();

    try {
      print('🍽️ Loading restaurant menu items...');

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/owner/menu-items/'),
        headers: await _apiService.getHeaders(),
      );

      print('   Menu items response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> itemsData = [];
        if (data is List) {
          itemsData = data;
        } else if (data is Map && data.containsKey('results')) {
          itemsData = data['results'];
        } else if (data is Map && data.containsKey('items')) {
          itemsData = data['items'];
        }

        print('   Found ${itemsData.length} menu items');

        _menuItems = itemsData
            .map((item) => MenuItem(
                  id: item['id']?.toString() ?? '',
                  restaurantId: item['restaurant']?.toString() ?? '',
                  name: item['name']?.toString() ?? '',
                  description: item['description']?.toString() ?? '',
                  price: _toDouble(item['price']),
                  image: item['image']?.toString() ?? '',
                  imageUrl: item['image_url']?.toString() ?? '',
                  category: item['category_name']?.toString() ??
                      item['category']?.toString() ??
                      'General',
                  isAvailable: item['is_available'] ?? true,
                ))
            .toList();

        print('✅ Loaded ${_menuItems.length} menu items into provider');
      } else if (response.statusCode == 401) {
        print('⚠️ Token expired, attempting refresh...');
        await _apiService.refreshToken();
        await loadMenuItems();
        return;
      } else {
        print('❌ Failed to load menu items: ${response.statusCode}');
        _menuItems = [];
      }

      _isLoadingMenu = false;
      _safeNotify();
    } catch (e) {
      print('❌ Error loading menu items: $e');
      _error = e.toString();
      _menuItems = [];
      _isLoadingMenu = false;
      _safeNotify();
    }
  }

  Future<void> loadStats() async {
  try {
    final statsData = await _apiService.getRestaurantStats();
    _stats = RestaurantStats(
      todayEarnings: _toDouble(statsData['todayEarnings']),
      todayOrders: _toInt(statsData['todayOrders']),
      totalEarnings: _toDouble(statsData['totalEarnings']),
      totalOrders: _toInt(statsData['totalOrders']),
      averageRating: _toDouble(statsData['averageRating']),
      activeOrders: _toInt(statsData['activeOrders']),
      monthlyEarnings: _toDouble(statsData['monthlyEarnings']),
      monthlyOrders: _toInt(statsData['monthlyOrders']),
      walletBalance: _toDouble(statsData['walletBalance']),
      totalWithdrawn: _toDouble(statsData['totalWithdrawn']),
      totalEarned: _toDouble(statsData['totalEarned']),
    );
    print('✅ Stats loaded: ${_stats?.todayOrders} orders today');
    _safeNotify();
  } catch (e) {
    print('⚠️ Error loading stats: $e');
    _stats = RestaurantStats(
      todayEarnings: 0, todayOrders: 0, totalEarnings: 0,
      totalOrders: 0, averageRating: 0, activeOrders: 0,
      monthlyEarnings: 0, monthlyOrders: 0, walletBalance: 0,
      totalWithdrawn: 0, totalEarned: 0,
    );
    _safeNotify();
  }
}
  Future<void> loadWalletBalance() async {
    try {
      final walletData = await _apiService.getWalletBalance();
      if (_stats != null) {
        _stats = RestaurantStats(
          todayEarnings: _stats!.todayEarnings,
          todayOrders: _stats!.todayOrders,
          totalEarnings: _stats!.totalEarnings,
          totalOrders: _stats!.totalOrders,
          averageRating: _stats!.averageRating,
          activeOrders: _stats!.activeOrders,
          monthlyEarnings: _stats!.monthlyEarnings,
          monthlyOrders: _stats!.monthlyOrders,
          walletBalance: _toDouble(walletData['balance']),
          totalWithdrawn: _toDouble(walletData['total_withdrawn']),
          totalEarned: _stats!.totalEarned,
        );
        _safeNotify();
      }
      print('💰 Wallet balance updated: MK${walletData['balance']}');
    } catch (e) {
      print('Error loading wallet balance: $e');
    }
  }

  // ============================================
  // GROUP 5: RESTAURANT ORDERS
  // ============================================

  Future<void> loadRestaurantOrders() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 Loading restaurant orders...');
    _isLoadingOrders = true;
    _safeNotify();

    try {
      final allOrders = await _apiService.getRestaurantOrders();
      print('📦 Raw orders from API: ${allOrders.length}');

      _orders = allOrders;

      final List<RestaurantOrder> allRestaurantOrders = [];

      for (var order in _orders) {
        final itemsList = order['items'] as List? ?? [];
        final orderItems = itemsList.map((item) {
          final price = _toDouble(item['price'] ??
              item['total_price'] ??
              item['menu_item_price'] ??
              0);
          final quantity = _toInt(item['quantity']);
          final name = item['menu_item_name']?.toString() ??
              item['name']?.toString() ??
              'Menu Item';
          return OrderItemModel(
            menuItemId: item['menu_item']?.toString() ??
                item['menu_item_id']?.toString() ??
                '',
            name: name,
            quantity: quantity,
            price: price,
          );
        }).toList();

        String customerName = 'Customer';
        String customerPhone = 'No phone';

        if (order['customer_name'] != null &&
            order['customer_name'].toString().isNotEmpty) {
          customerName = order['customer_name'].toString();
        } else if (order['customer'] != null) {
          if (order['customer'] is Map) {
            final customerMap = order['customer'] as Map;
            customerName = customerMap['username']?.toString() ?? 'Customer';
            customerPhone = customerMap['phone']?.toString() ?? 'No phone';
          } else {
            customerName = 'Customer #${order['customer']}';
          }
        }

        if (order['customer_phone'] != null &&
            order['customer_phone'].toString().isNotEmpty) {
          customerPhone = order['customer_phone'].toString();
        }

        DateTime orderTime;
        try {
          orderTime = DateTime.parse(
              order['created']?.toString() ?? DateTime.now().toIso8601String());
        } catch (e) {
          orderTime = DateTime.now();
        }

        final statusStr = order['status']?.toString() ?? 'pending';

        allRestaurantOrders.add(RestaurantOrder(
          id: order['id'].toString(),
          customerName: customerName,
          customerPhone: customerPhone,
          customerAddress: order['delivery_address']?.toString() ?? '',
          items: orderItems,
          status: _getOrderStatus(statusStr),
          total: _toDouble(order['total_price']),
          orderTime: orderTime,
          specialInstructions: order['note']?.toString(),
          estimatedPrepTime: _toInt(order['estimated_prep_time']),
        ));
      }

      _activeOrders = allRestaurantOrders
    .where((o) =>
        o.status == OrderStatus.pending ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.preparing ||
        o.status == OrderStatus.ready ||
        o.status == OrderStatus.driverAssigned) // ADD
    .toList();

      _readyOrders = allRestaurantOrders
          .where((o) => o.status == OrderStatus.ready)
          .toList();

      _pastOrders = allRestaurantOrders
          .where((o) =>
              o.status == OrderStatus.delivered ||
              o.status == OrderStatus.cancelled ||
              o.status == OrderStatus.pickedUp)
          .toList();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ Orders Summary:');
      print('   Total: ${allRestaurantOrders.length}');
      print('   Active: ${_activeOrders.length}');
      print('   Ready: ${_readyOrders.length}');
      print('   Past: ${_pastOrders.length}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      _isLoadingOrders = false;
      _safeNotify();
    } catch (e) {
      _error = e.toString();
      _isLoadingOrders = false;
      _safeNotify();
      print('❌ Error loading orders: $e');
    }
  }

  OrderStatus _getOrderStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending': return OrderStatus.pending;
    case 'confirmed': return OrderStatus.confirmed;
    case 'preparing': return OrderStatus.preparing;
    case 'ready': return OrderStatus.ready;
    case 'driver_assigned': return OrderStatus.driverAssigned; // ADD
    case 'picked_up': return OrderStatus.pickedUp;
    case 'delivered': return OrderStatus.delivered;
    case 'cancelled': return OrderStatus.cancelled;
    default: return OrderStatus.pending;
  }
}

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      print('📝 Updating order $orderId to status: $status');
      final result = await _apiService.updateOrderStatus(orderId, status);

      if (result != null &&
          (result['success'] == true || result['status'] == status)) {
        await loadRestaurantOrders();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  // ============================================
  // GROUP 6: RESTAURANT MANAGEMENT
  // ============================================

  Future<bool> updateMyRestaurant(Map<String, dynamic> data) async {
    _isLoading = true;
    _safeNotify();

    try {
      final result = await _apiService.updateMyRestaurant(data);
      await loadRestaurantInfo();
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating restaurant: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> updateRestaurantLocation({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      final result = await _apiService.updateRestaurantLocation(
        restaurantId: _restaurant!.id,
        latitude: latitude,
        longitude: longitude,
      );

      _restaurantLatitude = latitude;
      _restaurantLongitude = longitude;

      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating restaurant location: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> updateDeliverySettings({
    double? baseDeliveryFee,
    double? feePerKm,
    double? freeDeliveryRadius,
    double? maxDeliveryRadius,
    double? tier1Fee,
    double? tier2Fee,
    double? tier3Fee,
    double? tier4Fee,
    double? tier5Fee,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      final data = <String, dynamic>{};
      if (baseDeliveryFee != null) data['base_delivery_fee'] = baseDeliveryFee;
      if (feePerKm != null) data['fee_per_km'] = feePerKm;
      if (freeDeliveryRadius != null)
        data['free_delivery_radius'] = freeDeliveryRadius;
      if (maxDeliveryRadius != null)
        data['max_delivery_radius'] = maxDeliveryRadius;
      if (tier1Fee != null) data['tier_1_fee'] = tier1Fee;
      if (tier2Fee != null) data['tier_2_fee'] = tier2Fee;
      if (tier3Fee != null) data['tier_3_fee'] = tier3Fee;
      if (tier4Fee != null) data['tier_4_fee'] = tier4Fee;
      if (tier5Fee != null) data['tier_5_fee'] = tier5Fee;

      final result = await _apiService.updateMyRestaurant(data);
      await loadRestaurantInfo();
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating delivery settings: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> toggleRestaurantStatus(bool isOpen) async {
    try {
      await _apiService.updateMyRestaurant({'is_open': isOpen});
      _isRestaurantOpen = isOpen;
      if (_restaurant != null) {
        _restaurant = Restaurant(
          id: _restaurant!.id,
          name: _restaurant!.name,
          description: _restaurant!.description,
          image: _restaurant!.image,
          address: _restaurant!.address,
          phone: _restaurant!.phone,
          rating: _restaurant!.rating,
          deliveryTime: _restaurant!.deliveryTime,
          deliveryFee: _restaurant!.deliveryFee,
          minOrderAmount: _restaurant!.minOrderAmount,
          categories: _restaurant!.categories,
          isOpen: isOpen,
        );
      }
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error toggling restaurant status: $e');
      return false;
    }
  }

  // ============================================
  // GROUP 7: WITHDRAWAL
  // ============================================

  Future<bool> requestWithdraw({
    required double amount,
    required String phone,
    required String provider,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      print('💰 Requesting withdrawal:');
      print('   Amount: MK$amount');
      print('   Phone: $phone');
      print('   Provider: $provider');

      final result = await _apiService.requestWithdrawal(
        amount: amount,
        phoneNumber: phone,
        provider: provider,
      );

      print('✅ Withdrawal request submitted: $result');

      await loadStats();

      _isLoading = false;
      _safeNotify();
      return result['success'] == true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ Withdrawal error: $e');
      return false;
    }
  }

  Future<void> refreshWallet() async {
    await loadStats();
    await loadWalletBalance();
  }

  // ============================================
  // GROUP 8: MENU ITEM MANAGEMENT
  // ============================================

  Future<bool> addMenuItemWithImage({
    required String name,
    required String description,
    required double price,
    required String category,
    required XFile imageFile,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      print('📤 Adding menu item with image file');
      final result = await _apiService.createMenuItemWithImage(
        name: name,
        description: description,
        price: price,
        category: category,
        imageFile: imageFile,
      );
      print('✅ Success: $result');
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> addMenuItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    _safeNotify();

    try {
      print('📤 Adding menu item: $itemData');
      final result = await _apiService.createMenuItem(itemData);
      print('✅ Success: $result');
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> updateMenuItem(
      String itemId, Map<String, dynamic> itemData) async {
    _isLoading = true;
    _safeNotify();

    try {
      await _apiService.updateMenuItem(itemId, itemData);
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating menu item: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> toggleMenuItemAvailability(
      String menuItemId, bool isAvailable) async {
    _isLoading = true;
    _safeNotify();

    try {
      print(
          '🔄 Toggling menu item $menuItemId to ${isAvailable ? "Available" : "Unavailable"}');

      final updateData = {
        'is_available': isAvailable,
      };

      await _apiService.updateMenuItem(menuItemId, updateData);
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error toggling menu item availability: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> deleteMenuItem(String menuItemId) async {
    _isLoading = true;
    _safeNotify();

    try {
      await _apiService.deleteMenuItem(menuItemId);
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting menu item: $e');
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // ============================================
  // GROUP 9: UTILITY METHODS
  // ============================================

  void clearError() {
    _error = null;
    _safeNotify();
  }

  void reset() {
    _menuItems = [];
    _activeOrders = [];
    _readyOrders = [];
    _pastOrders = [];
    _orders = [];
    _stats = null;
    _isLoading = false;
    _isLoadingMenu = false;
    _isLoadingOrders = false;
    _isRestaurantOpen = true;
    _restaurant = null;
    _error = null;
    _restaurantLatitude = null;
    _restaurantLongitude = null;
    _safeNotify();
  }
}
