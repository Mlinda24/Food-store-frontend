import 'package:flutter/material.dart';
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
  bool _isLoadingOrders = false;
  bool _isRestaurantOpen = true;
  Restaurant? _restaurant;
  String? _error;

  List<MenuItem> get menuItems => _menuItems;
  List<RestaurantOrder> get activeOrders => _activeOrders;
  List<RestaurantOrder> get readyOrders => _readyOrders;
  List<RestaurantOrder> get pastOrders => _pastOrders;
  List<dynamic> get orders => _orders;
  RestaurantStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isRestaurantOpen => _isRestaurantOpen;
  Restaurant? get restaurant => _restaurant;
  String? get error => _error;

  // Helper methods for safe type conversion
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

  Future<void> loadRestaurantData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        loadRestaurantInfo(),
        loadMenuItems(),
        loadStats(),
      ]);
    } catch (e) {
      _error = e.toString();
      print('Error loading restaurant data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRestaurantOrders() async {
    _isLoadingOrders = true;
    notifyListeners();
    
    try {
      final allOrders = await _apiService.getRestaurantOrders();
      final restaurantId = _restaurant?.id;
      
      _orders = allOrders.where((order) => 
        order['restaurant'].toString() == restaurantId?.toString()
      ).toList();
      
      final List<RestaurantOrder> allRestaurantOrders = [];
      
      for (var order in _orders) {
        final itemsList = order['items'] as List? ?? [];
        final orderItems = itemsList.map((item) => OrderItemModel(
          menuItemId: item['menu_item'].toString(),
          name: item['menu_item_name'] ?? '',
          quantity: _toInt(item['quantity']),
          price: _toDouble(item['price']),
        )).toList();
        
        allRestaurantOrders.add(RestaurantOrder(
          id: order['id'].toString(),
          customerName: order['customer']?['username'] ?? 'Customer',
          customerPhone: order['customer']?['phone'] ?? '',
          customerAddress: order['delivery_address'] ?? '',
          items: orderItems,
          status: _getOrderStatus(order['status'] ?? 'pending'),
          total: _toDouble(order['total_price']),
          orderTime: DateTime.tryParse(order['created'] ?? '') ?? DateTime.now(),
          specialInstructions: order['note'],
          estimatedPrepTime: _toInt(order['estimated_prep_time']),
        ));
      }
      
      _activeOrders = allRestaurantOrders.where((o) => 
        o.status == OrderStatus.pending || 
        o.status == OrderStatus.confirmed || 
        o.status == OrderStatus.preparing
      ).toList();
      
      _readyOrders = allRestaurantOrders.where((o) => 
        o.status == OrderStatus.ready
      ).toList();
      
      _pastOrders = allRestaurantOrders.where((o) => 
        o.status == OrderStatus.delivered || 
        o.status == OrderStatus.cancelled
      ).toList();
      
      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoadingOrders = false;
      notifyListeners();
      print('Error loading orders: $e');
    }
  }

  OrderStatus _getOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  Future<void> loadRestaurantInfo() async {
    try {
      final restaurantData = await _apiService.getMyRestaurant();
      _restaurant = Restaurant(
        id: restaurantData['id'].toString(),
        name: restaurantData['name'] ?? '',
        description: restaurantData['description'] ?? '',
        image: restaurantData['image'] ?? '',
        address: restaurantData['address'] ?? '',
        rating: _toDouble(restaurantData['rating']),
        deliveryTime: _toInt(restaurantData['delivery_time']),
        deliveryFee: _toDouble(restaurantData['delivery_fee']),
        minOrderAmount: _toDouble(restaurantData['min_order_amount']),
        phone: restaurantData['phone'] ?? '',
        categories: restaurantData['categories'] != null 
            ? List<String>.from(restaurantData['categories']) 
            : ['All'],
        isOpen: restaurantData['is_open'] ?? true,
      );
      _isRestaurantOpen = _restaurant?.isOpen ?? true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error loading restaurant info: $e');
    }
  }

  Future<void> loadMenuItems() async {
    try {
      final itemsData = await _apiService.getMenuItems();
      _menuItems = itemsData.map((item) => MenuItem(
        id: item['id'].toString(),
        restaurantId: item['restaurant'].toString(),
        name: item['name'] ?? '',
        description: item['description'] ?? '',
        price: _toDouble(item['price']),
        image: item['image'] ?? '',
        category: item['category']?.toString() ?? 'General',
        isAvailable: item['is_available'] ?? true,
      )).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error loading menu items: $e');
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
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error loading stats: $e');
      _stats = RestaurantStats(
        todayEarnings: 0,
        todayOrders: 0,
        totalEarnings: 0,
        totalOrders: 0,
        averageRating: 0,
        activeOrders: 0,
        monthlyEarnings: 0,
        monthlyOrders: 0,
      );
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _apiService.updateOrderStatus(orderId, status);
      await loadRestaurantOrders();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating order status: $e');
      return false;
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
          rating: _restaurant!.rating,
          deliveryTime: _restaurant!.deliveryTime,
          deliveryFee: _restaurant!.deliveryFee,
          minOrderAmount: _restaurant!.minOrderAmount,
          phone: _restaurant!.phone,
          categories: _restaurant!.categories,
          isOpen: isOpen,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error toggling restaurant status: $e');
      return false;
    }
  }

  Future<bool> addMenuItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _apiService.createMenuItem(itemData);
      await loadMenuItems();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error adding menu item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMenuItem(String itemId, Map<String, dynamic> itemData) async {
    _isLoading = true;
    notifyListeners();
    
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
      notifyListeners();
    }
  }

  Future<bool> deleteMenuItem(String menuItemId) async {
    _isLoading = true;
    notifyListeners();
    
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
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}