import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  final ApiService _apiService = ApiService();

  List<CartItem> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  
  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  double get deliveryFee => 2.99;
  double get tax => subtotal * 0.1;
  double get total => subtotal + deliveryFee + tax;
  
  bool get hasItems => _items.isNotEmpty;

  // Load cart from API
  Future<void> loadCart() async {
    try {
      final response = await _apiService.getCart();
      if (response['items'] != null) {
        _items = (response['items'] as List).map((item) => CartItem(
          menuItemId: item['menu_item_id'].toString(),
          name: item['name'],
          quantity: item['quantity'],
          price: (item['price'] as num).toDouble(),
        )).toList();
        _restaurantId = response['restaurant_id']?.toString();
        _restaurantName = response['restaurant_name'];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  void addItem(MenuItem menuItem, {String? restaurantId, String? restaurantName}) async {
    // Check if adding from a different restaurant
    if (_restaurantId != null && _restaurantId != restaurantId && _items.isNotEmpty) {
      _items.clear();
    }
    
    if (_restaurantId == null) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
    }
    
    final existingIndex = _items.indexWhere(
      (item) => item.menuItemId == menuItem.id,
    );
    
    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        quantity: 1,
        price: menuItem.price,
      ));
    }
    
    // Sync with API
    try {
      await _apiService.addToCart(
        menuItemId: menuItem.id,
        quantity: 1,
      );
    } catch (e) {
      print('Error adding to cart: $e');
    }
    
    notifyListeners();
  }

  void removeItem(String menuItemId) async {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    if (_items.isEmpty) {
      _clearRestaurantInfo();
    }
    
    // Sync with API (set quantity to 0)
    try {
      await _apiService.addToCart(
        menuItemId: menuItemId,
        quantity: 0,
      );
    } catch (e) {
      print('Error removing from cart: $e');
    }
    
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) async {
    final index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
    
    if (_items.isEmpty) {
      _clearRestaurantInfo();
    }
    
    // Sync with API
    try {
      await _apiService.addToCart(
        menuItemId: menuItemId,
        quantity: quantity,
      );
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  void clearCart() async {
    // Clear all items by setting quantity to 0
    for (var item in _items) {
      try {
        await _apiService.addToCart(
          menuItemId: item.menuItemId,
          quantity: 0,
        );
      } catch (e) {
        print('Error clearing cart: $e');
      }
    }
    
    _items.clear();
    _clearRestaurantInfo();
    notifyListeners();
  }
  
  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
  }
  
  Order createOrder(String userId, String deliveryAddress, String? instructions) {
    final orderItems = _items.map((item) => OrderItemModel(
      menuItemId: item.menuItemId,
      name: item.name,
      quantity: item.quantity,
      price: item.price,
    )).toList();
    
    return Order(
      id: '',
      userId: userId,
      restaurantId: _restaurantId!,
      items: orderItems,
      status: OrderStatus.pending,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      deliveryAddress: deliveryAddress,
      specialInstructions: instructions,
      createdAt: DateTime.now(),
    );
  }
}