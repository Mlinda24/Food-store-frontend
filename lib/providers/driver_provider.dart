import 'package:flutter/material.dart';
import '../models/delivery_request.dart';
import '../services/driver_service.dart';
import '../providers/auth_provider.dart';

// Driver Stats Model
class DriverStats {
  final double todayEarnings;
  final int totalDeliveries;
  final double rating;
  final double totalEarnings;
  final int activeDeliveries;
  final int completedToday;

  DriverStats({
    required this.todayEarnings,
    required this.totalDeliveries,
    required this.rating,
    required this.totalEarnings,
    required this.activeDeliveries,
    required this.completedToday,
  });

  factory DriverStats.fromApi(Map<String, dynamic> data) {
    return DriverStats(
      todayEarnings: double.tryParse(data['today_earnings']?.toString() ?? '0') ?? 0,
      totalDeliveries: data['total_deliveries'] ?? 0,
      rating: double.tryParse(data['rating']?.toString() ?? '5') ?? 5,
      totalEarnings: double.tryParse(data['total_earnings']?.toString() ?? '0') ?? 0,
      activeDeliveries: 0,
      completedToday: data['today_deliveries'] ?? 0,
    );
  }
}

class DriverProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAvailable = false;
  String? _error;
  Map<String, dynamic>? _rawStats;
  List<DeliveryRequest> _availableOrders = [];
  DeliveryRequest? _activeDelivery;
  List<dynamic> _deliveryHistory = [];

  bool get isLoading => _isLoading;
  bool get isAvailable => _isAvailable;
  bool get isOnline => _isAvailable;
  String? get error => _error;
  DriverStats? get stats => _rawStats != null ? DriverStats.fromApi(_rawStats!) : null;
  List<DeliveryRequest> get availableOrders => _availableOrders;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  List<dynamic> get deliveryHistory => _deliveryHistory;

  double get todayEarnings {
    return double.tryParse(_rawStats?['today_earnings']?.toString() ?? '0') ?? 0;
  }

  int get totalDeliveries {
    return _rawStats?['total_deliveries'] ?? 0;
  }

  double get rating {
    return double.tryParse(_rawStats?['rating']?.toString() ?? '5') ?? 5;
  }

  /// Load all driver data in parallel
  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔄 Loading all driver data...');

    try {
      final results = await Future.wait([
        DriverService.getEarningsSummary(),
        DriverService.getAvailableOrders(),
        DriverService.getActiveDelivery(),
        DriverService.getDeliveryHistory(),
      ]);

      print('✅ All data loaded successfully');
      print('📊 Earnings data: ${results[0]}');
      print('📦 Available orders raw: ${results[1]}');
      print('🚚 Active delivery: ${results[2]}');
      print('📜 Delivery history: ${results[3]}');

      _rawStats = results[0] as Map<String, dynamic>;
      
      final availableOrdersData = results[1] as List<dynamic>;
      print('📦 Available orders count from API: ${availableOrdersData.length}');
      
      _availableOrders = availableOrdersData
          .map((order) {
            print('📦 Processing order: $order');
            return DeliveryRequest.fromAvailableOrder(order);
          })
          .toList();
      
      print('📦 Parsed available orders: ${_availableOrders.length}');
      
      final activeDeliveryData = results[2] as Map<String, dynamic>?;
      if (activeDeliveryData != null && activeDeliveryData['has_active_delivery'] == true) {
        _activeDelivery = DeliveryRequest.fromDelivery(activeDeliveryData);
        print('🚚 Active delivery found: ${_activeDelivery?.id}');
      } else if (activeDeliveryData != null && activeDeliveryData.containsKey('order')) {
        _activeDelivery = DeliveryRequest.fromDelivery(activeDeliveryData);
        print('🚚 Active delivery found: ${_activeDelivery?.id}');
      } else {
        _activeDelivery = null;
        print('🚚 No active delivery');
      }
      
      _deliveryHistory = results[3] as List<dynamic>;
      print('📜 Delivery history count: ${_deliveryHistory.length}');

      // Check if driver is online based on profile
      try {
        final profile = await DriverService.getProfile();
        _isAvailable = profile['is_available'] == true || profile['status'] == 'online';
        print('👤 Driver profile loaded - isAvailable: $_isAvailable');
      } catch (e) {
        print('⚠️ Could not load driver profile: $e');
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Load all failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle driver online/offline status
  Future<bool> toggleOnlineStatus(bool isOnline) async {
    print('🔄 Toggling online status to: $isOnline');
    try {
      if (isOnline) {
        await DriverService.goOnline();
        print('✅ Driver is now ONLINE');
      } else {
        await DriverService.goOffline();
        print('✅ Driver is now OFFLINE');
      }
      _isAvailable = isOnline;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Toggle online failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Accept an order by ID
  Future<bool> acceptOrder(String orderId) async {
    print('✅ Accepting order: $orderId');
    try {
      await DriverService.acceptOrder(orderId);
      print('✅ Order accepted successfully');
      await loadAll(); // Refresh all data
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Accept order failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Decline an order
  Future<bool> declineOrder(DeliveryRequest order) async {
    print('❌ Declining order: ${order.id}');
    await refreshAvailableOrders();
    return true;
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    print('🔄 Updating order $orderId to status: $newStatus');
    try {
      await DriverService.updateDeliveryStatus(orderId, newStatus);
      print('✅ Status updated successfully');
      await loadAll(); // Refresh all data
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Update status failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update delivery status (alias)
  Future<bool> updateDeliveryStatus(String deliveryId, String newStatus) async {
    return updateOrderStatus(deliveryId, newStatus);
  }

  /// Refresh available orders only
  Future<void> refreshAvailableOrders() async {
    print('🔄 Refreshing available orders...');
    try {
      final ordersData = await DriverService.getAvailableOrders();
      print('📦 Orders data received: $ordersData');
      print('📦 Orders count from API: ${ordersData.length}');
      
      _availableOrders = ordersData
          .map((order) {
            print('📦 Processing order: ${order['id']} - ${order['restaurant_name']}');
            return DeliveryRequest.fromAvailableOrder(order);
          })
          .toList();
      
      print('📦 Parsed orders in provider: ${_availableOrders.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Refresh available orders failed: $e');
    }
  }

  /// Refresh active delivery only
  Future<void> refreshActiveDelivery() async {
    print('🔄 Refreshing active delivery...');
    try {
      final deliveryData = await DriverService.getActiveDelivery();
      if (deliveryData != null && deliveryData['has_active_delivery'] == true) {
        _activeDelivery = DeliveryRequest.fromDelivery(deliveryData);
        print('🚚 Active delivery found: ${_activeDelivery?.id}');
      } else if (deliveryData != null && deliveryData.containsKey('order')) {
        _activeDelivery = DeliveryRequest.fromDelivery(deliveryData);
        print('🚚 Active delivery found: ${_activeDelivery?.id}');
      } else {
        _activeDelivery = null;
        print('🚚 No active delivery');
      }
      notifyListeners();
    } catch (e) {
      print('❌ Refresh active delivery failed: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset all data (used on logout)
  void reset() {
    print('🔄 Resetting driver provider...');
    _isLoading = false;
    _isAvailable = false;
    _error = null;
    _rawStats = null;
    _availableOrders = [];
    _activeDelivery = null;
    _deliveryHistory = [];
    notifyListeners();
  }
}