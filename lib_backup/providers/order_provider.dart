import 'package:flutter/material.dart';
import '../models/models.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    
    _orders = [
      Order(
        id: 'ORD-001',
        userId: userId,
        restaurantId: '1',
        items: [
          OrderItemModel(menuItemId: '1', name: 'Margherita Pizza', quantity: 2, price: 4500),
        ],
        status: OrderStatus.delivered,
        subtotal: 9000,
        deliveryFee: 2.99,
        tax: 900,
        total: 9902.99,
        deliveryAddress: '123 Main St, Downtown',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD-002',
        userId: userId,
        restaurantId: '2',
        items: [
          OrderItemModel(menuItemId: '3', name: 'Cheeseburger', quantity: 1, price: 3800),
        ],
        status: OrderStatus.onTheWay,
        subtotal: 3800,
        deliveryFee: 2.99,
        tax: 380,
        total: 4182.99,
        deliveryAddress: '456 Oak Ave',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> placeOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    
    final newOrder = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
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
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
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
  }
}