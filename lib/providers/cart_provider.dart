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
      _items[existingIndex].quantity += 1;
    } else {
      // Add new item with all required parameters
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        quantity: 1,
        price: menuItem.price,
        image: menuItem.image,
        restaurantId: restaurantId ?? '',
        restaurantName: restaurantName ?? '',
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
        _items[index].quantity = quantity;
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
      selectedOptions: null,
    )).toList();
    
    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      restaurantId: _restaurantId ?? '',
      driverId: null,
      items: orderItems,
      status: OrderStatus.pending,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      total: total,
      deliveryAddress: deliveryAddress,
      specialInstructions: instructions,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }
}