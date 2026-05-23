import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  bool _isLoading = false;

  List<CartItem> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  bool get isLoading => _isLoading;
  
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

  // Load cart from backend
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final data = await _apiService.getCart();
      print('Cart data loaded: $data');
      
      // Parse cart items from the response
      if (data['items'] != null && data['items'] is List) {
        final List<dynamic> itemsData = data['items'];
        _items = itemsData.map((itemData) {
          final menuItem = itemData['menu_item'];
          return CartItem(
            menuItemId: menuItem['id'].toString(),
            name: menuItem['name'],
            quantity: itemData['quantity'],
            price: double.parse(menuItem['price'].toString()),
            image: menuItem['image'] != null && menuItem['image'].toString().isNotEmpty 
                ? '${ApiService.mediaBaseUrl}${menuItem['image']}' 
                : '',
            restaurantId: menuItem['restaurant'].toString(),
            restaurantName: '',
          );
        }).toList();
        
        // Set restaurant info from first item
        if (_items.isNotEmpty) {
          _restaurantId = _items.first.restaurantId;
          await _loadRestaurantName();
        } else {
          _clearRestaurantInfo();
        }
      } else {
        _items = [];
        _clearRestaurantInfo();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
      _items = [];
      _clearRestaurantInfo();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load restaurant name from backend
  Future<void> _loadRestaurantName() async {
    if (_restaurantId == null) return;
    
    try {
      final restaurant = await _apiService.getRestaurant(_restaurantId!);
      _restaurantName = restaurant['name'];
      notifyListeners();
    } catch (e) {
      print('Error loading restaurant name: $e');
    }
  }

  // Add item to cart (with API call)
  Future<bool> addItem(MenuItem menuItem, {String? restaurantId, String? restaurantName, int quantity = 1}) async {
    // Check if adding from a different restaurant
    if (_restaurantId != null && _restaurantId != restaurantId && _items.isNotEmpty) {
      await clearCart();
    }
    
    if (_restaurantId == null) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
    }
    
    try {
      final result = await _apiService.addToCart(int.parse(menuItem.id), quantity);
      if (result != null) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding item to cart: $e');
      return false;
    }
  }

  Future<bool> addItemWithQuantity(MenuItem menuItem, int quantity, {String? restaurantId, String? restaurantName}) async {
    return addItem(menuItem, restaurantId: restaurantId, restaurantName: restaurantName, quantity: quantity);
  }

  Future<bool> removeItem(String menuItemId) async {
    try {
      final result = await _apiService.removeFromCart(int.parse(menuItemId));
      if (result != null) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing item from cart: $e');
      return false;
    }
  }

  Future<bool> updateQuantity(String menuItemId, int quantity) async {
    try {
      final result = await _apiService.updateCartItem(int.parse(menuItemId), quantity);
      if (result != null) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiService.clearCart();
      _items = [];
      _clearRestaurantInfo();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      _items = [];
      _clearRestaurantInfo();
      notifyListeners();
    }
  }
  
  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
  }
  
  void updateQuantityLocal(String menuItemId, int quantity) {
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