import 'package:flutter/material.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;

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

  void addItem(MenuItem menuItem, {String? restaurantId, String? restaurantName}) {
    // Check if adding from a different restaurant
    if (_restaurantId != null && _restaurantId != restaurantId && _items.isNotEmpty) {
      // Clear cart if different restaurant
      _items.clear();
    }
    
    // Set restaurant info if not set
    if (_restaurantId == null) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
    }
    
    final existingIndex = _items.indexWhere(
      (item) => item.menuItemId == menuItem.id,
    );
    
    if (existingIndex != -1) {
      // Update existing item quantity
      final updatedItem = CartItem(
        menuItemId: _items[existingIndex].menuItemId,
        name: _items[existingIndex].name,
        quantity: _items[existingIndex].quantity + 1,
        price: _items[existingIndex].price,
        image: _items[existingIndex].image,
      );
      _items[existingIndex] = updatedItem;
    } else {
      // Add new item
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        quantity: 1,
        price: menuItem.price,
        image: menuItem.image,
      ));
    }
    
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    if (_items.isEmpty) {
      _clearRestaurantInfo();
    }
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final updatedItem = CartItem(
          menuItemId: _items[index].menuItemId,
          name: _items[index].name,
          quantity: quantity,
          price: _items[index].price,
          image: _items[index].image,
        );
        _items[index] = updatedItem;
      }
      notifyListeners();
    }
    
    if (_items.isEmpty) {
      _clearRestaurantInfo();
    }
  }

  void clearCart() {
    _items.clear();
    _clearRestaurantInfo();
    notifyListeners();
  }
  
  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
  }
  
  // Create order from cart
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