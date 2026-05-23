import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getMyOrders();
      
      _orders = (response as List).map((orderData) => Order(
        id: orderData['id'].toString(),
        userId: userId,
        restaurantId: orderData['restaurant_id'].toString(),
        items: (orderData['items'] as List).map((item) => OrderItemModel(
          menuItemId: item['menu_item_id'].toString(),
          name: item['name'],
          quantity: item['quantity'],
          price: (item['price'] as num).toDouble(),
        )).toList(),
        status: _mapStatus(orderData['status']),
        subtotal: (orderData['subtotal'] as num).toDouble(),
        deliveryFee: (orderData['delivery_fee'] as num).toDouble(),
        tax: (orderData['tax'] as num).toDouble(),
        total: (orderData['total'] as num).toDouble(),
        deliveryAddress: orderData['delivery_address'],
        specialInstructions: orderData['special_instructions'],
        createdAt: DateTime.parse(orderData['created_at']),
      )).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.placeOrder(
        deliveryAddress: order.deliveryAddress,
        phoneNumber: '', // You'll need to add phone to order model
        specialInstructions: order.specialInstructions,
      );
      
      final newOrder = Order(
        id: response['id'].toString(),
        userId: order.userId,
        restaurantId: order.restaurantId,
        items: order.items,
        status: OrderStatus.pending,
        subtotal: order.subtotal,
        deliveryFee: order.deliveryFee,
        tax: order.tax,
        total: order.total,
        deliveryAddress: order.deliveryAddress,
        specialInstructions: order.specialInstructions,
        createdAt: DateTime.now(),
      );
      
      _orders.insert(0, newOrder);
      _isLoading = false;
      notifyListeners();
      
      return newOrder;
    } catch (e) {
      print('Error placing order: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _apiService.updateOrderStatus(
        orderId: orderId,
        status: status.toString().split('.').last,
      );
      
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = Order(
          id: _orders[index].id,
          userId: _orders[index].userId,
          restaurantId: _orders[index].restaurantId,
          driverId: _orders[index].driverId,
          items: _orders[index].items,
          status: status,
          subtotal: _orders[index].subtotal,
          deliveryFee: _orders[index].deliveryFee,
          tax: _orders[index].tax,
          total: _orders[index].total,
          deliveryAddress: _orders[index].deliveryAddress,
          specialInstructions: _orders[index].specialInstructions,
          createdAt: _orders[index].createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  OrderStatus _mapStatus(String status) {
    switch (status) {
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
}