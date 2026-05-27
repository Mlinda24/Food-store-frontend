import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isLoadingOrder = false;
  bool _isPlacingOrder = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingOrder => _isLoadingOrder;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  // ============================================
  // ORDER FETCHING METHODS
  // ============================================

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final data = await _apiService.getOrders();
      _orders = _parseOrders(data);
    } catch (e) {
      _error = e.toString();
      print('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<Order?> getOrder(String orderId) async {
    _isLoadingOrder = true;
    _error = null;
    _safeNotify();

    try {
      final response = await _apiService.getOrder(orderId);
      final order = _parseOrder(response);
      _isLoadingOrder = false;
      _safeNotify();
      return order;
    } catch (e) {
      _error = e.toString();
      _isLoadingOrder = false;
      _safeNotify();
      return null;
    }
  }

  // ============================================
  // ORDER CREATION
  // ============================================

  Future<Order?> placeOrder(Map<String, dynamic> orderData) async {
    if (_isPlacingOrder) {
      print('⏳ Order already in progress, ignoring duplicate call');
      return null;
    }

    _isPlacingOrder = true;
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final cleanedData = Map<String, dynamic>.from(orderData);
      cleanedData.remove('restaurantId');
      cleanedData.remove('items');

      print('📤 Placing order with cleaned data: $cleanedData');

      final response = await _apiService.createOrder(cleanedData);

      if (response != null && response['id'] != null) {
        final newOrder = _parseOrder(response);
        _orders.insert(0, newOrder);
        _isLoading = false;
        _isPlacingOrder = false;
        _safeNotify();
        print('✅ Order created successfully: #${newOrder.id}');
        return newOrder;
      }

      _isLoading = false;
      _isPlacingOrder = false;
      _safeNotify();
      return null;
    } catch (e) {
      _error = e.toString();
      print('❌ Error placing order: $e');
      _isLoading = false;
      _isPlacingOrder = false;
      _safeNotify();
      return null;
    }
  }

  // ============================================
  // ORDER STATUS UPDATE
  // ============================================

  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _safeNotify();

    try {
      await _apiService.updateOrderStatus(orderId, status);

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = Order(
          id: _orders[index].id,
          userId: _orders[index].userId,
          restaurantId: _orders[index].restaurantId,
          driverId: _orders[index].driverId,
          items: _orders[index].items,
          status: _parseStatus(status),
          subtotal: _orders[index].subtotal,
          deliveryFee: _orders[index].deliveryFee,
          tax: _orders[index].tax,
          total: _orders[index].total,
          deliveryAddress: _orders[index].deliveryAddress,
          specialInstructions: _orders[index].specialInstructions,
          createdAt: _orders[index].createdAt,
          updatedAt: DateTime.now(),
        );
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating order status: $e');
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  // ============================================
  // PARSING METHODS
  // ============================================

  List<Order> _parseOrders(List<dynamic> data) {
    if (data == null || data.isEmpty) return [];
    return data.map((item) => _parseOrder(item)).toList();
  }

  Order _parseOrder(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];

    String customerName = json['customer_name'] ?? 'Customer';
    String customerPhone = json['customer_phone'] ?? 'No phone';

    if (customerName == 'Customer' && json['customer'] != null) {
      if (json['customer'] is Map) {
        customerName = json['customer']['username'] ?? 'Customer';
        customerPhone = json['customer']['phone'] ?? 'No phone';
      }
    }

    final items = itemsList
        .map((item) => OrderItemModel(
              menuItemId: item['menu_item']?.toString() ??
                  item['menu_item_id']?.toString() ??
                  '0',
              name: item['menu_item_name'] ?? item['name'] ?? 'Item',
              quantity: item['quantity'] is int
                  ? item['quantity']
                  : (item['quantity'] ?? 1),
              price: _parseDouble(item['price']) ??
                  _parseDouble(item['menu_item_price']) ??
                  0,
            ))
        .toList();

    return Order(
      id: json['id'].toString(),
      userId: json['customer']?.toString() ?? json['user']?.toString() ?? '',
      restaurantId: json['restaurant']?.toString() ??
          json['restaurant_id']?.toString() ??
          '0',
      driverId: json['driver']?.toString(),
      items: items,
      status: _parseStatus(json['status'] ?? 'pending'),
      subtotal: _parseDouble(json['subtotal']) ?? _calculateSubtotal(items),
      deliveryFee: _parseDouble(json['delivery_fee']) ?? 2000.0,
      tax: _parseDouble(json['tax']) ?? 0,
      total: _parseDouble(json['total_price']) ??
          _parseDouble(json['total']) ??
          _calculateSubtotal(items) + 2000.0,
      deliveryAddress: json['delivery_address'] ?? '',
      specialInstructions: json['note'],
      createdAt: _parseDateTime(json['created']),
      updatedAt: _parseDateTimeNullable(json['updated_at']),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double _calculateSubtotal(List<OrderItemModel> items) {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  void _safeNotify() {
    Future.microtask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void clearError() {
    _error = null;
    _safeNotify();
  }

  void clearOrders() {
    _orders = [];
    _safeNotify();
  }

  void resetPlacingOrder() {
    _isPlacingOrder = false;
    _safeNotify();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> get pendingOrders {
    return _orders
        .where((order) => order.status == OrderStatus.pending)
        .toList();
  }

  List<Order> get activeOrders {
    return _orders
        .where((order) =>
            order.status == OrderStatus.pending ||
            order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.preparing)
        .toList();
  }

  List<Order> get completedOrders {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .toList();
  }

  List<Order> get cancelledOrders {
    return _orders
        .where((order) => order.status == OrderStatus.cancelled)
        .toList();
  }
}