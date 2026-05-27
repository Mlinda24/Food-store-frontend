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
  String? _restaurantImageUrl;
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

  // Cache for menu item images
  final Map<String, String> _menuItemImageCache = {};

  // ============================================
  // GROUP 1: GETTERS
  // ============================================
  
  List<CartItem> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  String? get restaurantImageUrl => _restaurantImageUrl;
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

  // Helper method to resolve image URLs (same as home page)
  String _getImageUrl(dynamic image) {
    if (image == null) return '';
    String imageStr = image.toString();
    if (imageStr.isEmpty) return '';
    if (imageStr.startsWith('http')) return imageStr;
    if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
    return 'http://127.0.0.1:8000/media/$imageStr';
  }

  // Fetch restaurant using the same API as home page
  Future<void> _fetchRestaurantDetails(String restaurantId) async {
    print('🔍 Fetching restaurant details for ID: $restaurantId');
    try {
      final restaurant = await _apiService.getRestaurant(restaurantId);
      print('📦 Restaurant data received: $restaurant');
      
      _restaurantName = restaurant['name'] ?? _restaurantName;
      
      // Get image using the same method as home page
      if (restaurant.containsKey('image')) {
        _restaurantImageUrl = _getImageUrl(restaurant['image']);
        print('🏪 Restaurant image URL: $_restaurantImageUrl');
      }
      
      // Get location if available
      if (restaurant.containsKey('latitude')) {
        _restaurantLatitude = double.tryParse(restaurant['latitude'].toString());
      }
      if (restaurant.containsKey('longitude')) {
        _restaurantLongitude = double.tryParse(restaurant['longitude'].toString());
      }
      
      _lastRestaurantId = restaurantId;
      _safeNotify();
    } catch (e) {
      print('⚠️ Error fetching restaurant details: $e');
    }
  }

  // Fetch menu item image using the same API as home page
  Future<String?> _fetchMenuItemImage(String menuItemId, int restaurantId) async {
    // Check cache first
    if (_menuItemImageCache.containsKey(menuItemId)) {
      return _menuItemImageCache[menuItemId];
    }
    
    try {
      // Use the same API that home page uses to get menu items
      final menuItems = await _apiService.getRestaurantMenu(restaurantId);
      
      // Find the menu item with matching ID
      for (var item in menuItems) {
        if (item['id']?.toString() == menuItemId) {
          String? imageUrl;
          
          // Use the same image URL extraction as home page
          if (item['image_url'] != null && item['image_url'].toString().isNotEmpty) {
            imageUrl = item['image_url'].toString();
          } else if (item['image'] != null && item['image'].toString().isNotEmpty) {
            imageUrl = _getImageUrl(item['image']);
          }
          
          if (imageUrl != null && imageUrl.isNotEmpty) {
            _menuItemImageCache[menuItemId] = imageUrl;
            print('📸 Found image for menu item $menuItemId: $imageUrl');
            return imageUrl;
          }
          break;
        }
      }
    } catch (e) {
      print('⚠️ Error fetching image for menu item $menuItemId: $e');
    }
    
    return null;
  }

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
        
        // Get restaurant ID from cart
        if (data.containsKey('restaurant_id') && data['restaurant_id'] != null) {
          _restaurantId = data['restaurant_id'].toString();
          _restaurantName = data['restaurant_name']?.toString();
          print('   Restaurant ID: $_restaurantId');
          print('   Restaurant Name: $_restaurantName');
          
          // Fetch restaurant details (including image) using the same API as home page
          if (_restaurantId != null && _restaurantId != _lastRestaurantId) {
            await _fetchRestaurantDetails(_restaurantId!);
          }
        }
        
        // Load all items with their images
        List<CartItem> loadedItems = [];
        
        for (var itemData in itemsData) {
          String menuItemId = itemData['menu_item_id']?.toString() ?? '';
          String name = itemData['menu_item_name']?.toString() ?? 'Unknown';
          double price = double.parse(itemData['menu_item_price']?.toString() ?? '0');
          int quantity = itemData['quantity'] ?? 1;
          String? imageUrl;
          
          // Try to get image from the same API that home page uses
          if (menuItemId.isNotEmpty && _restaurantId != null) {
            imageUrl = await _fetchMenuItemImage(menuItemId, int.parse(_restaurantId!));
          }
          
          loadedItems.add(CartItem(
            menuItemId: menuItemId,
            name: name,
            quantity: quantity,
            price: price,
            image: imageUrl,
            imageUrl: imageUrl,
            restaurantId: _restaurantId ?? '',
            restaurantName: _restaurantName ?? '',
          ));
        }
        
        _items = loadedItems;
        
        print('✅ Loaded ${_items.length} items, Subtotal: MK${subtotal.toStringAsFixed(0)}');
        print('🏪 Restaurant image: $_restaurantImageUrl');
        
        // Print items with their image URLs for debugging
        for (var item in _items) {
          print('   - ${item.name}: imageUrl=${item.imageUrl}');
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
        (item) => item['menu_item_id']?.toString() == menuItemId,
        orElse: () => null,
      );
      
      if (cartItem != null) {
        final cartItemId = cartItem['id'];
        final result = await _apiService.removeFromCart(cartItemId);
        if (result != null) {
          // Clear cache for this item
          _menuItemImageCache.remove(menuItemId);
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
        (item) => item['menu_item_id']?.toString() == menuItemId,
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
      _menuItemImageCache.clear();
      _clearRestaurantInfo();
      _resetDeliveryInfo();
      print('🗑️ Cart cleared');
      _safeNotify();
    } catch (e) {
      print('❌ Error clearing cart: $e');
      _items = [];
      _menuItemImageCache.clear();
      _clearRestaurantInfo();
      _resetDeliveryInfo();
      _safeNotify();
    }
  }
  
  void _clearRestaurantInfo() {
    _restaurantId = null;
    _restaurantName = null;
    _restaurantImageUrl = null;
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
      restaurantName: _restaurantName,
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
    _menuItemImageCache.clear();
    _restaurantId = null;
    _restaurantName = null;
    _restaurantImageUrl = null;
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