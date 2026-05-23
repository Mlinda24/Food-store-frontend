import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getOrders();
      _orders = _parseOrders(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createOrder(orderData);
      final newOrder = _parseOrder(response);
      _orders.insert(0, newOrder);
      _isLoading = false;
      notifyListeners();
      return newOrder;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  List<Order> _parseOrders(List<dynamic> data) {
    return data.map((item) => _parseOrder(item)).toList();
  }

  Order _parseOrder(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    final items = itemsList.map((item) => OrderItemModel(
      menuItemId: item['menu_item']?.toString() ?? item['menu_item_id']?.toString() ?? '0',
      name: item['menu_item_name'] ?? item['name'] ?? 'Item',
      quantity: item['quantity'] ?? 1,
      price: _parseDouble(item['price']) ?? 0,
    )).toList();

    return Order(
      id: json['id'].toString(),
      userId: json['user']?.toString() ?? '',
      restaurantId: json['restaurant']?.toString() ?? '0',
      driverId: json['driver']?.toString(),
      items: items,
      status: _parseStatus(json['status'] ?? 'pending'),
      subtotal: _parseDouble(json['subtotal']) ?? _calculateSubtotal(items),
      deliveryFee: _parseDouble(json['delivery_fee']) ?? 0,
      tax: _parseDouble(json['tax']) ?? 0,
      total: _parseDouble(json['total_price']) ?? _parseDouble(json['total']) ?? 0,
      deliveryAddress: json['delivery_address'] ?? '',
      specialInstructions: json['note'],
      createdAt: _parseDateTime(json['created']),
      updatedAt: _parseDateTimeNullable(json['updated_at']),
    );
  }

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
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}