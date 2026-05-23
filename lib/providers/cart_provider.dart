import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  
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

  CartProvider() {
    _loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_items');
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(cartJson);
        _items = decoded.map((item) => CartItem(
          menuItemId: item['menuItemId'],
          name: item['name'],
          quantity: item['quantity'],
          price: (item['price'] as num).toDouble(),
          image: item['image'],
          restaurantId: item['restaurantId'] ?? '',
          restaurantName: item['restaurantName'] ?? '',
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> cartData = _items.map((item) => ({
        'menuItemId': item.menuItemId,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'image': item.image,
        'restaurantId': item.restaurantId,
        'restaurantName': item.restaurantName,
      })).toList();
      
      await prefs.setString('cart_items', json.encode(cartData));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  void addItem(MenuItem menuItem, {String? restaurantId, String? restaurantName}) {
    // Check if item already exists in cart
    final existingIndex = _items.indexWhere(
      (item) => item.menuItemId == menuItem.id,
    );
    
    if (existingIndex != -1) {
      // Update existing item quantity
      final existingItem = _items[existingIndex];
      final updatedItem = CartItem(
        menuItemId: existingItem.menuItemId,
        name: existingItem.name,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
        image: existingItem.image,
        restaurantId: existingItem.restaurantId,
        restaurantName: existingItem.restaurantName,
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
        restaurantId: restaurantId ?? '',
        restaurantName: restaurantName ?? '',
      ));
    }
    
    _saveCart();
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final existingItem = _items[index];
        final updatedItem = CartItem(
          menuItemId: existingItem.menuItemId,
          name: existingItem.name,
          quantity: quantity,
          price: existingItem.price,
          image: existingItem.image,
          restaurantId: existingItem.restaurantId,
          restaurantName: existingItem.restaurantName,
        );
        _items[index] = updatedItem;
      }
      notifyListeners();
    }
    _saveCart();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
  
  Order createOrder(String userId, String deliveryAddress, String? instructions) {
    final orderItems = _items.map((item) => OrderItemModel(
      menuItemId: item.menuItemId,
      name: item.name,
      quantity: item.quantity,
      price: item.price,
    )).toList();
    
    // For multiple restaurants, we'll use a placeholder
    final firstRestaurantId = _items.isNotEmpty ? _items.first.restaurantId : '';
    
    return Order(
      id: '',
      userId: userId,
      restaurantId: firstRestaurantId,
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