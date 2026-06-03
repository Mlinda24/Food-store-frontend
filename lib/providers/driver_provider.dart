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

  Future<void> refresh() async {
    await loadAvailableOrders();
    await loadActiveDelivery();
    await loadDeliveryHistory();
    await loadEarningsSummary();
    await loadDriverStatus();
    notifyListeners();
  }

  Future<void> loadDriverStatus() async {
    try {
      final profile = await _apiService.getDriverProfile();
      if (profile.containsKey('status')) {
        _isOnline = profile['status'] == 'online';
        print('🟢 Loaded driver status: ${_isOnline ? "ONLINE" : "OFFLINE"}');
        notifyListeners();
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
      notifyListeners();
    } catch (e) {
      print('Error loading available orders: $e');
      _errorMessage = 'Failed to load available orders';
    }
  }

  Future<void> loadDeliveryHistory() async {
    try {
      final data = await _apiService.getDeliveryHistory();
      final deliveries = data['deliveries'] as List? ?? [];
      _deliveryHistory =
          deliveries.map((json) => DeliveryRequest.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading delivery history: $e');
    }
  }

  Future<void> loadActiveDelivery() async {
    try {
      final data = await _apiService.getActiveDelivery();
      if (data.isNotEmpty && data['id'] != null) {
        _activeDelivery = DeliveryRequest.fromJson(data);
      } else {
        _activeDelivery = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading active delivery: $e');
      _activeDelivery = null;
    }
  }

  Future<void> loadEarningsSummary() async {
    try {
      final data = await _apiService.getEarningsSummary();
      _stats = DriverStats.fromJson(data);
      notifyListeners();
    } catch (e) {
      print('Error loading earnings: $e');
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
    print('🔄 Toggle clicked: ${value ? "ON" : "OFF"}');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // REMOVED: await _apiService.ensureDriverProfile(); - This method doesn't exist

      final status = value ? 'online' : 'offline';
      print('📡 Sending status to API: $status');

      final response = await _apiService.updateDriverStatus(status);
      print('✅ Status updated successfully on server');
      print('📦 Server response: $response');

      // Update local state based on server response
      if (response.containsKey('status')) {
        _isOnline = response['status'] == 'online';
      } else {
        _isOnline = value;
      }

      print('🟢 Driver is now ${_isOnline ? "ONLINE" : "OFFLINE"}');

      if (_isOnline) {
        await loadAvailableOrders();
      } else {
        _availableOrders.clear();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Failed to update status: $e');
      _errorMessage = 'Failed to update status. Please check your connection.';
      _isLoading = false;
      notifyListeners();

      throw Exception('Failed to update status. Please check your connection.');
    }
  }

  Future<void> acceptOrder(DeliveryRequest order) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.acceptDelivery(order.id);
      _availableOrders.removeWhere((o) => o.id == order.id);
      _activeDelivery = order;
      _acceptedHistory.add(order);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error accepting order: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> declineOrder(DeliveryRequest order) async {
    try {
      await _apiService.declineDelivery(order.id);
      _availableOrders.removeWhere((o) => o.id == order.id);
      _declinedOrders.add(order);
      notifyListeners();
    } catch (e) {
      print('Error declining order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();

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
        } else {
          _activeDelivery = updatedOrder;
        }

        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error updating order status: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshAvailableOrders() async {
    await loadAvailableOrders();
  }

  void consumePendingOrder() {
    _pendingOrder = null;
    notifyListeners();
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
    notifyListeners();
  }
}
