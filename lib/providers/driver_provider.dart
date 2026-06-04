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

  // ============================================
  // AUTO REFRESH
  // ============================================

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

  // ============================================
  // LOAD METHODS
  // ============================================

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
      if (profile.containsKey('status')) {
        final wasOnline = _isOnline;
        _isOnline = profile['status'] == 'online';

        if (_isOnline && !wasOnline) {
          _startAutoRefresh();
        } else if (!_isOnline && wasOnline) {
          _stopAutoRefresh();
        }

        if (_mounted) notifyListeners();
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

  // ============================================
  // ONLINE STATUS
  // ============================================

  Future<void> toggleOnlineStatus(bool value) async {
    print('🔄 Toggle clicked: ${value ? "ON" : "OFF"}');

    _isLoading = true;
    _errorMessage = null;
    if (_mounted) notifyListeners();

    try {
      final statusStr = value ? 'online' : 'offline';
      print('📡 Sending status to API: $statusStr');

      final response = await _apiService.updateDriverStatus(statusStr);
      print('✅ Status updated successfully on server');

      if (response.containsKey('status')) {
        _isOnline = response['status'] == 'online';
      } else {
        _isOnline = value;
      }

      print('🟢 Driver is now ${_isOnline ? "ONLINE" : "OFFLINE"}');

      if (_isOnline) {
        await loadAvailableOrders();
        await loadActiveDelivery();
        _startAutoRefresh();
      } else {
        _availableOrders.clear();
        _activeDelivery = null;
        _stopAutoRefresh();
      }

      _isLoading = false;
      if (_mounted) notifyListeners();
    } catch (e) {
      print('❌ Failed to update status: $e');
      _errorMessage = 'Failed to update status. Please check your connection.';
      _isLoading = false;
      if (_mounted) notifyListeners();
      throw Exception('Failed to update status. Please check your connection.');
    }
  }

  // ============================================
  // ORDER ACTIONS
  // ============================================

  Future<void> acceptOrder(DeliveryRequest order) async {
    try {
      _isLoading = true;
      if (_mounted) notifyListeners();

      await _apiService.acceptDelivery(order.id);

      _availableOrders.removeWhere((o) => o.id == order.id);

      // Create updated order with 'accepted' status
      final acceptedOrder = DeliveryRequest(
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
        status: 'accepted',
        assignedAt: DateTime.now(),
        deliveredAt: null,
      );

      _activeDelivery = acceptedOrder;
      _acceptedHistory.add(acceptedOrder);

      _isLoading = false;
      if (_mounted) notifyListeners();

      print('✅ Order ${order.id} accepted successfully');
    } catch (e) {
      print('Error accepting order: $e');
      _isLoading = false;
      if (_mounted) notifyListeners();
      rethrow;
    }
  }

  Future<void> declineOrder(DeliveryRequest order) async {
    try {
      await _apiService.declineDelivery(order.id);
      _availableOrders.removeWhere((o) => o.id == order.id);
      _declinedOrders.add(order);
      if (_mounted) notifyListeners();
      print('📝 Order ${order.id} declined');
    } catch (e) {
      print('Error declining order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      if (_mounted) notifyListeners();

      await _apiService.updateDeliveryStatus(orderId, status);

      if (_activeDelivery != null && _activeDelivery!.id == orderId) {
        final updatedOrder = DeliveryRequest(
          id: _activeDelivery!.id,
          restaurantName: _activeDelivery!.restaurantName,
          restaurantAddress: _activeDelivery!.restaurantAddress,
          customerName: _activeDelivery!.customerName,
          customerPhone: _activeDelivery!.customerPhone,
          deliveryAddress: _activeDelivery!.deliveryAddress,
          items: _activeDelivery!.items,
          earnings: _activeDelivery!.earnings,
          distance: _activeDelivery!.distance,
          estimatedTime: _activeDelivery!.estimatedTime,
          status: status,
          assignedAt: _activeDelivery!.assignedAt,
          deliveredAt: status == 'delivered'
              ? DateTime.now()
              : _activeDelivery!.deliveredAt,
        );

        if (status == 'delivered') {
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

      print('✅ Order $orderId status updated to $status');
    } catch (e) {
      print('Error updating order status: $e');
      _isLoading = false;
      if (_mounted) notifyListeners();
      rethrow;
    }
  }

  // ============================================
  // UTILITY
  // ============================================

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
