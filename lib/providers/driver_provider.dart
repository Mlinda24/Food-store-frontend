import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/delivery_request.dart';

class DriverStats {
  final double totalEarnings;
  final double todayEarnings;
  final int totalDeliveries;
  final double rating;

  DriverStats({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.totalDeliveries,
    required this.rating,
  });

  factory DriverStats.empty() {
    return DriverStats(
      totalEarnings: 0,
      todayEarnings: 0,
      totalDeliveries: 0,
      rating: 5.0,
    );
  }

  factory DriverStats.fromJson(Map<String, dynamic> json) {
    return DriverStats(
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      todayEarnings: (json['today_earnings'] ?? 0).toDouble(),
      totalDeliveries: json['total_deliveries'] ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
    );
  }
}

class DriverProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _refreshTimer;
  bool _mounted = true;

  List<DeliveryRequest> _availableOrders = [];
  List<DeliveryRequest> _deliveryHistory = [];
  List<DeliveryRequest> _acceptedHistory = [];
  List<DeliveryRequest> _declinedOrders = [];
  DeliveryRequest? _activeDelivery;
  DeliveryRequest? _pendingOrder;
  bool _isLoading = false;
  bool _isOnline = false;
  DriverStats _stats = DriverStats.empty();
  String? _errorMessage;

  List<DeliveryRequest> get availableOrders => _availableOrders;
  List<DeliveryRequest> get deliveryHistory => _deliveryHistory;
  List<DeliveryRequest> get acceptedHistory => _acceptedHistory;
  List<DeliveryRequest> get declinedOrders => _declinedOrders;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  DeliveryRequest? get pendingOrder => _pendingOrder;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  DriverStats get stats => _stats;
  String? get errorMessage => _errorMessage;

  void setMounted(bool mounted) {
    _mounted = mounted;
  }

  @override
  void dispose() {
    _mounted = false;
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOnline && _mounted) {
        print('🔄 Auto-refresh: loading available orders...');
        loadAvailableOrders();
        loadActiveDelivery();
      }
    });
    print('🔄 Auto-refresh started (every 10s)');
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('⏹️ Auto-refresh stopped');
  }

  Future<void> refresh() async {
    await loadAvailableOrders();
    await loadActiveDelivery();
    await loadDeliveryHistory();
    await loadEarningsSummary();
    await loadDriverStatus();
    if (_mounted) notifyListeners();
  }

  Future<void> loadDriverStatus() async {
    try {
      final profile = await _apiService.getDriverProfile();
      print('📱 Driver profile response: $profile');

      if (profile.containsKey('status')) {
        final wasOnline = _isOnline;
        _isOnline = profile['status'] == 'online' || profile['status'] == 'busy';
        print('🟢 Server says driver is: ${profile['status']}');
        print('🟢 Local state updated to: ${_isOnline ? "ONLINE" : "OFFLINE"}');

        if (_isOnline && !wasOnline) {
          _startAutoRefresh();
          await loadAvailableOrders();
          await loadActiveDelivery();
        } else if (!_isOnline && wasOnline) {
          _stopAutoRefresh();
          _availableOrders.clear();
          _activeDelivery = null;
        }

        if (_mounted) notifyListeners();
      } else {
        print('⚠️ No status field in profile: $profile');
      }
    } catch (e) {
      print('Error loading driver status: $e');
    }
  }

  Future<void> loadAvailableOrders() async {
    try {
      final data = await _apiService.getAvailableOrders();
      _availableOrders =
          data.map((json) => DeliveryRequest.fromJson(json)).toList();
      print('📦 Available orders loaded: ${_availableOrders.length}');
      if (_mounted) notifyListeners();
    } catch (e) {
      print('Error loading available orders: $e');
      _errorMessage = 'Failed to load available orders';
      if (_mounted) notifyListeners();
    }
  }

  Future<void> loadDeliveryHistory() async {
    try {
      final data = await _apiService.getDeliveryHistory();
      final deliveries = data['deliveries'] as List? ?? [];
      _deliveryHistory =
          deliveries.map((json) => DeliveryRequest.fromJson(json)).toList();
      if (_mounted) notifyListeners();
    } catch (e) {
      print('Error loading delivery history: $e');
    }
  }

  Future<void> loadActiveDelivery() async {
    try {
      final data = await _apiService.getActiveDelivery();
      if (data.isNotEmpty && data['id'] != null) {
        _activeDelivery = DeliveryRequest.fromJson(data);
        print(
            '✅ Active delivery found: ${_activeDelivery!.id} - status: ${_activeDelivery!.status}');
      } else {
        _activeDelivery = null;
      }
      if (_mounted) notifyListeners();
    } catch (e) {
      print('Error loading active delivery: $e');
      _activeDelivery = null;
    }
  }

  Future<void> loadEarningsSummary() async {
    try {
      final data = await _apiService.getEarningsSummary();
      _stats = DriverStats.fromJson(data);
      if (_mounted) notifyListeners();
    } catch (e) {
      print('Error loading earnings: $e');
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
  print('🔄 Toggle clicked: ${value ? "ON" : "OFF"}');
  _isLoading = true;
  if (_mounted) notifyListeners();

  try {
    final statusStr = value ? 'online' : 'offline';
    final response = await _apiService.updateDriverStatus(statusStr);
    
    // ADD THESE:
    print('🔍 FULL RESPONSE: $response');
    print('🔍 RESPONSE TYPE: ${response.runtimeType}');
    print('🔍 KEYS: ${response.keys.toList()}');
    print('🔍 STATUS VALUE: ${response['status']}');
    print('🔍 IS ONLINE CHECK: ${response['status'] == 'online'}');

    if (response.containsKey('status')) {
      _isOnline = response['status'] == 'online';
    } else {
      _isOnline = value; // fallback
    }
    
    print('🟢 _isOnline is now: $_isOnline');
    
    _isLoading = false;
    if (_mounted) notifyListeners();
  } catch (e) {
    print('❌ FULL ERROR: $e');
    _isLoading = false;
    if (_mounted) notifyListeners();
  }
}

  Future<void> acceptOrder(DeliveryRequest order) async {
    try {
      _isLoading = true;
      if (_mounted) notifyListeners();

      print('📝 Accepting order ID: ${order.id}');
      final response = await _apiService.acceptDelivery(order.id);
      print('✅ Accept response: $response');

      if (response['success'] == true) {
        _availableOrders.removeWhere((o) => o.id == order.id);

        final acceptedOrder = DeliveryRequest(
          id: order.id,
          deliveryId: response['id']?.toString() ?? '',
          restaurantName: order.restaurantName,
          restaurantAddress: order.restaurantAddress,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          deliveryAddress: order.deliveryAddress,
          items: order.items,
          earnings: order.earnings,
          distance: order.distance,
          estimatedTime: order.estimatedTime,
          status: 'driver_assigned',
          assignedAt: DateTime.now(),
          deliveredAt: null,
        );

        _activeDelivery = acceptedOrder;
        _acceptedHistory.add(acceptedOrder);

        // Refresh driver status (should become 'busy')
        await loadDriverStatus();

        print('✅ Order ${order.id} accepted successfully');
      } else {
        throw Exception('Accept failed: ${response['error']}');
      }

      _isLoading = false;
      if (_mounted) notifyListeners();
    } catch (e) {
      print('Error accepting order: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      if (_mounted) notifyListeners();
      rethrow;
    }
  }

  Future<void> declineOrder(DeliveryRequest order) async {
  try {
    await _apiService.declineDelivery(order.id);
    _availableOrders.removeWhere((o) => o.id == order.id);
    
    // Create a copy with status set to 'declined'
    final declinedOrder = DeliveryRequest(
      id: order.id,
      restaurantName: order.restaurantName,
      restaurantAddress: order.restaurantAddress,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      deliveryAddress: order.deliveryAddress,
      items: order.items,
      earnings: order.earnings,
      distance: order.distance,
      estimatedTime: order.estimatedTime,
      status: 'declined',  // SET STATUS HERE
      assignedAt: order.assignedAt,
      deliveredAt: null,
    );
    
    _declinedOrders.add(declinedOrder);
    if (_mounted) notifyListeners();
    print('📝 Order ${order.id} declined');
  } catch (e) {
    print('Error declining order: $e');
  }
}

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
  try {
    _isLoading = true;
    if (_mounted) notifyListeners();

    // Use deliveryId (DeliveryAssignment ID), not order ID
    final deliveryId = _activeDelivery?.deliveryId;
    if (deliveryId == null || deliveryId.isEmpty) {
      throw Exception('No active delivery ID found');
    }

    await _apiService.updateDeliveryStatus(deliveryId, newStatus);

    if (_activeDelivery != null && _activeDelivery!.id == orderId) {
      final updatedOrder = DeliveryRequest(
        id: _activeDelivery!.id,
        deliveryId: _activeDelivery!.deliveryId,  // KEEP deliveryId
        restaurantName: _activeDelivery!.restaurantName,
        restaurantAddress: _activeDelivery!.restaurantAddress,
        customerName: _activeDelivery!.customerName,
        customerPhone: _activeDelivery!.customerPhone,
        deliveryAddress: _activeDelivery!.deliveryAddress,
        items: _activeDelivery!.items,
        earnings: _activeDelivery!.earnings,
        distance: _activeDelivery!.distance,
        estimatedTime: _activeDelivery!.estimatedTime,
        status: newStatus,
        assignedAt: _activeDelivery!.assignedAt,
        deliveredAt: newStatus == 'delivered' ? DateTime.now() : _activeDelivery!.deliveredAt,
      );

      if (newStatus == 'delivered') {
        _deliveryHistory.insert(0, updatedOrder);
        _activeDelivery = null;
        await loadDriverStatus();
        await loadEarningsSummary();
      } else {
        _activeDelivery = updatedOrder;
      }

      if (_mounted) notifyListeners();
    }

    _isLoading = false;
    if (_mounted) notifyListeners();
    print('✅ Order $orderId status updated to $newStatus');
  } catch (e) {
    print('Error updating order status: $e');
    _isLoading = false;
    if (_mounted) notifyListeners();
    rethrow;
  }
}

  Future<void> refreshAvailableOrders() async {
    await loadAvailableOrders();
  }

  void consumePendingOrder() {
    _pendingOrder = null;
    if (_mounted) notifyListeners();
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _apiService.updateDriverLocation(latitude, longitude);
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_mounted) notifyListeners();
  }
}
