import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/delivery_fee_calculator.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CartItem> _items = [];
  String? _restaurantId;
  String? _restaurantName;
  bool _isLoading = false;
  
  // Delivery fee related fields
  double _calculatedDeliveryFee = 0.0;
  double? _distanceInMeters;
  bool _canDeliver = true;
  String? _deliveryTier;
  double? _restaurantLatitude;
  double? _restaurantLongitude;
  double? _customerLatitude;
  double? _customerLongitude;
  
  // Store the last calculated fee to prevent recalculation
  double _lastCalculatedFee = 0.0;
  String? _lastRestaurantId;

  // ============================================
  // GROUP 1: GETTERS
  // ============================================
  
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
  
  double get deliveryFee => _calculatedDeliveryFee > 0 ? _calculatedDeliveryFee : 2000.0;
  
  double get total => subtotal + deliveryFee;
  
  bool get hasItems => _items.isNotEmpty;
  bool get canDeliver => _canDeliver;
  double? get distanceInMeters => _distanceInMeters;
  String? get deliveryTier => _deliveryTier;
  double? get restaurantLatitude => _restaurantLatitude;
  double? get restaurantLongitude => _restaurantLongitude;

  // ============================================
  // GROUP 2: CART LOADING METHODS
  // ============================================
  
  Future<void> loadCart() async {
    _isLoading = true;
    _safeNotify();
    
    try {
      final data = await _apiService.getCart();
      print('📦 Cart data loaded: $data');
      
      if (data != null && data.containsKey('items') && data['items'] is List) {
        final List<dynamic> itemsData = data['items'];
        print('   Items count: ${itemsData.length}');
        
        _items = itemsData.map((itemData) {
          // Handle two possible response structures
          if (itemData.containsKey('menu_item')) {
            // Nested structure: {menu_item: {...}, quantity: x}
            final menuItem = itemData['menu_item'];
            return CartItem(
              menuItemId: menuItem['id'].toString(),
              name: menuItem['name'] ?? 'Unknown',
              quantity: itemData['quantity'] ?? 1,
              price: (menuItem['price'] is int 
                  ? (menuItem['price'] as int).toDouble() 
                  : double.parse(menuItem['price'].toString())),
              image: menuItem['image'] != null && menuItem['image'].toString().isNotEmpty 
                  ? _apiService.getImageUrl(menuItem['image'].toString())
                  : '',
              restaurantId: menuItem['restaurant']?.toString() ?? '',
              restaurantName: '',
            );
          } else {
            // Flat structure: {menu_item_id: x, menu_item_name: y, quantity: z}
            return CartItem(
              menuItemId: itemData['menu_item_id']?.toString() ?? 
                         itemData['id']?.toString() ?? '',
              name: itemData['menu_item_name']?.toString() ?? 
                    itemData['name']?.toString() ?? 
                    'Unknown',
              quantity: itemData['quantity'] ?? 1,
              price: (itemData['menu_item_price'] != null)
                  ? (itemData['menu_item_price'] is int 
                      ? (itemData['menu_item_price'] as int).toDouble() 
                      : double.parse(itemData['menu_item_price'].toString()))
                  : (itemData['price'] is int 
                      ? (itemData['price'] as int).toDouble() 
                      : double.parse(itemData['price'].toString())),
              image: itemData['image']?.toString() != null && itemData['image'].toString().isNotEmpty
                  ? _apiService.getImageUrl(itemData['image'].toString())
                  : '',
              restaurantId: data['restaurant_id']?.toString() ?? '',
              restaurantName: data['restaurant_name']?.toString() ?? '',
            );
          }
        }).toList();
        
        // Update restaurant info from cart data
        if (data.containsKey('restaurant_id') && data['restaurant_id'] != null) {
          _restaurantId = data['restaurant_id'].toString();
          _restaurantName = data['restaurant_name']?.toString();
          print('   Restaurant ID: $_restaurantId');
          print('   Restaurant Name: $_restaurantName');
        } else if (_items.isNotEmpty) {
          _restaurantId = _items.first.restaurantId;
        }
        
        print('✅ Loaded ${_items.length} items, Subtotal: MK${subtotal.toStringAsFixed(0)}');
        
        if (_restaurantId != null && _restaurantId != _lastRestaurantId) {
          await _loadRestaurantInfo();
        }
      } else {
        print('⚠️ No items in cart or invalid format');
        _items = [];
        _clearRestaurantInfo();
      }
      
      _safeNotify();
    } catch (e) {
      print('❌ Error loading cart: $e');
      _items = [];
      _clearRestaurantInfo();
      _safeNotify();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> _loadRestaurantInfo() async {
    if (_restaurantId == null) return;
    
    if (_lastRestaurantId == _restaurantId && _restaurantLatitude != null) {
      return;
    }
    
    try {
      final restaurant = await _apiService.getRestaurant(_restaurantId!);
      _restaurantName = restaurant['name'] ?? _restaurantName;
      _restaurantLatitude = restaurant['latitude'] != null 
          ? double.parse(restaurant['latitude'].toString()) 
          : null;
      _restaurantLongitude = restaurant['longitude'] != null 
          ? double.parse(restaurant['longitude'].toString()) 
          : null;
      _lastRestaurantId = _restaurantId;
      
      print('📍 Restaurant location loaded: $_restaurantLatitude, $_restaurantLongitude');
      _safeNotify();
    } catch (e) {
      print('⚠️ Error loading restaurant info: $e');
    }
  }

  // ============================================
  // GROUP 3: DELIVERY FEE CALCULATION
  // ============================================
  
  Future<void> calculateDeliveryFeeFromLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      print('⚠️ Could not get customer location');
      _calculatedDeliveryFee = 2000.0;
      _canDeliver = true;
      _safeNotify();
      return;
    }
    
    await calculateDeliveryFee(
      customerLat: position.latitude,
      customerLng: position.longitude,
    );
  }
  
  Future<void> calculateDeliveryFee({
    required double customerLat,
    required double customerLng,
    bool forceRecalc = false,
  }) async {
    _customerLatitude = customerLat;
    _customerLongitude = customerLng;
    
    if (_restaurantLatitude == null || _restaurantLongitude == null) {
      print('⚠️ Restaurant location not available, using default fee');
      _calculatedDeliveryFee = 2000.0;
      _canDeliver = true;
      _deliveryTier = "Standard Delivery";
      _safeNotify();
      return;
    }
    
    try {
      final distanceInMeters = await LocationService.calculateDistanceInMeters(
        _restaurantLatitude!,
        _restaurantLongitude!,
        customerLat,
        customerLng,
      );
      
      _distanceInMeters = distanceInMeters;
      _calculatedDeliveryFee = DeliveryFeeCalculator.calculateFee(distanceInMeters);
      _canDeliver = DeliveryFeeCalculator.canDeliver(distanceInMeters);
      _deliveryTier = DeliveryFeeCalculator.getDeliveryTier(distanceInMeters);
      
      if (_calculatedDeliveryFee < 0) {
        _calculatedDeliveryFee = 9999.0;
        _canDeliver = false;
      }
      
      print('📦 Delivery Calculation Updated:');
      print('   Distance: ${DeliveryFeeCalculator.formatDistance(distanceInMeters)}');
      print('   Fee: MK${_calculatedDeliveryFee.toStringAsFixed(0)}');
      print('   Can Deliver: $_canDeliver');
      print('   Tier: $_deliveryTier');
      
      _lastCalculatedFee = _calculatedDeliveryFee;
      _safeNotify();
    } catch (e) {
      print('⚠️ Error calculating delivery fee: $e');
      _calculatedDeliveryFee = 2000.0;
      _canDeliver = true;
      _safeNotify();
    }
  }
  
  void setDeliveryFeeFromRestaurant({
    required double distanceInMeters,
    required double deliveryFee,
    required bool canDeliver,
    String? tier,
  }) {
    _distanceInMeters = distanceInMeters;
    _calculatedDeliveryFee = deliveryFee;
    _canDeliver = canDeliver;
    _deliveryTier = tier;
    _lastCalculatedFee = deliveryFee;
    print('📦 Delivery fee set from restaurant: MK${deliveryFee.toStringAsFixed(0)}');
    _safeNotify();
  }
  
  void setCalculatedDeliveryFee(double fee) {
    _calculatedDeliveryFee = fee;
    _lastCalculatedFee = fee;
    _safeNotify();
  }
  
  void setDeliveryInfo({
    required double distanceInMeters,
    required double deliveryFee,
    required bool canDeliver,
    String? tier,
  }) {
    _distanceInMeters = distanceInMeters;
    _calculatedDeliveryFee = deliveryFee;
    _canDeliver = canDeliver;
    _deliveryTier = tier;
    _lastCalculatedFee = deliveryFee;
    print('📦 Delivery info set: ${DeliveryFeeCalculator.formatDistance(distanceInMeters)} = MK${deliveryFee.toStringAsFixed(0)}');
    _safeNotify();
  }
  
  void setRestaurantLocation({required double lat, required double lng}) {
    _restaurantLatitude = lat;
    _restaurantLongitude = lng;
    _safeNotify();
  }

  // ============================================
  // GROUP 4: CART ITEM MANAGEMENT
  // ============================================
  
  Future<bool> addItem(MenuItem menuItem, {String? restaurantId, String? restaurantName, int quantity = 1}) async {
    if (_restaurantId != null && _restaurantId != restaurantId && _items.isNotEmpty) {
      await clearCart();
    }
    
    if (_restaurantId == null && restaurantId != null) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
    }
    
    try {
      final result = await _apiService.addToCart(int.parse(menuItem.id), quantity);
      print('✅ Added to cart: ${menuItem.name} x$quantity');
      if (result != null) {
        await loadCart();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding item to cart: $e');
      return false;
    }
  }

  Future<bool> addItemWithQuantity(MenuItem menuItem, int quantity, {String? restaurantId, String? restaurantName}) async {
    return addItem(menuItem, restaurantId: restaurantId, restaurantName: restaurantName, quantity: quantity);
  }

  Future<bool> removeItem(String menuItemId) async {
    try {
      final cartData = await _apiService.getCart();
      final itemsList = cartData['items'] as List;
      final cartItem = itemsList.firstWhere(
        (item) => item['menu_item_id'].toString() == menuItemId,
        orElse: () => null,
      );
      
      if (cartItem != null) {
        final cartItemId = cartItem['id'];
        final result = await _apiService.removeFromCart(cartItemId);
        if (result != null) {
          await loadCart();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error removing item from cart: $e');
      return false;
    }
  }

  Future<bool> updateQuantity(String menuItemId, int quantity) async {
    try {
      final cartData = await _apiService.getCart();
      final itemsList = cartData['items'] as List;
      final cartItem = itemsList.firstWhere(
        (item) => item['menu_item_id'].toString() == menuItemId,
        orElse: () => null,
      );
      
      if (cartItem != null && quantity > 0) {
        final cartItemId = cartItem['id'];
        final result = await _apiService.updateCartItem(cartItemId, quantity);
        if (result != null) {
          await loadCart();
          return true;
        }
      } else if (quantity <= 0) {
        return await removeItem(menuItemId);
      }
      return false;
    } catch (e) {
      print('❌ Error updating quantity: $e');
      return false;
    }
  }

  // ============================================
  // GROUP 5: CART CLEARING METHODS
  // ============================================
  
  Future<void> clearCart() async {
    try {
      await _apiService.clearCart();
      _items = [];
      _clearRestaurantInfo();
      _resetDeliveryInfo();
      print('🗑️ Cart cleared');
      _safeNotify();
    } catch (e) {
      print('❌ Error clearing cart: $e');
      _items = [];
      _clearRestaurantInfo();
      _resetDeliveryInfo();
      _safeNotify();
    }
  }
  
  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
    _restaurantLatitude = null;
    _restaurantLongitude = null;
    _lastRestaurantId = null;
  }
  
  void _resetDeliveryInfo() {
    _calculatedDeliveryFee = 0.0;
    _distanceInMeters = null;
    _canDeliver = true;
    _deliveryTier = null;
    _customerLatitude = null;
    _customerLongitude = null;
    _lastCalculatedFee = 0.0;
  }
  
  // ============================================
  // GROUP 6: LOCAL OPERATIONS
  // ============================================
  
  void updateQuantityLocal(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _safeNotify();
    }
    
    if (_items.isEmpty) {
      _clearRestaurantInfo();
      _resetDeliveryInfo();
    }
  }
  
  // ============================================
  // GROUP 7: ORDER CREATION
  // ============================================
  
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
      tax: 0.0,
      total: total,
      deliveryAddress: deliveryAddress,
      specialInstructions: instructions,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }
  
  // ============================================
  // GROUP 8: UTILITY METHODS
  // ============================================
  
  void _safeNotify() {
    Future.microtask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
  
  void reset() {
    _items = [];
    _restaurantId = null;
    _restaurantName = null;
    _resetDeliveryInfo();
    _safeNotify();
  }
  
  Map<String, dynamic> getDeliverySummary() {
    return {
      'distance': _distanceInMeters,
      'distance_formatted': _distanceInMeters != null 
          ? DeliveryFeeCalculator.formatDistance(_distanceInMeters!) 
          : 'Not calculated',
      'delivery_fee': _calculatedDeliveryFee,
      'delivery_fee_formatted': DeliveryFeeCalculator.formatFee(_calculatedDeliveryFee),
      'can_deliver': _canDeliver,
      'tier': _deliveryTier ?? 'Not calculated',
    };
  }
  
  double getCurrentDeliveryFee() {
    return _calculatedDeliveryFee > 0 ? _calculatedDeliveryFee : 2000.0;
  }
}
