import 'package:flutter/material.dart';
import '../models/delivery_request.dart';
import '../services/driver_service.dart';

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

  factory DriverStats.empty() => DriverStats(
        todayEarnings: 0,
        totalDeliveries: 0,
        rating: 0,
        totalEarnings: 0,
        activeDeliveries: 0,
        completedToday: 0,
      );

  factory DriverStats.fromEarnings(Map<String, dynamic>? data) {
    if (data == null) return DriverStats.empty();
    return DriverStats(
      todayEarnings: _d(data['today_earnings']),
      totalDeliveries: _i(data['total_deliveries']),
      rating: _d(data['average_rating'], fallback: 5.0),
      totalEarnings: _d(data['total_earnings']),
      activeDeliveries: 0,
      completedToday: _i(data['today_deliveries']),
    );
  }

  static double _d(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class DriverProvider extends ChangeNotifier {
  bool _isOnline = false;
  bool _isLoading = false;
  String? _error;
  DeliveryRequest? _activeDelivery;
  List<DeliveryRequest> _availableOrders = [];
  List<DeliveryRequest> _deliveryHistory = [];
  List<DeliveryRequest> _declinedOrders = [];
  List<DeliveryRequest> _acceptedHistory = [];
  double _sessionEarnings = 0;
  int _sessionDeliveries = 0;
  DriverStats _stats = DriverStats.empty();
  DeliveryRequest? _pendingOrder;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  List<DeliveryRequest> get availableOrders => List.unmodifiable(_availableOrders);
  List<DeliveryRequest> get deliveryHistory => List.unmodifiable(_deliveryHistory);
  List<DeliveryRequest> get declinedOrders => List.unmodifiable(_declinedOrders);
  List<DeliveryRequest> get completedOrders => List.unmodifiable(_deliveryHistory.where((d) => d.status == 'delivered').toList());
  List<DeliveryRequest> get acceptedHistory => List.unmodifiable(_acceptedHistory);
  DriverStats get stats => _stats;
  DeliveryRequest? get pendingOrder => _pendingOrder;
  double get sessionEarnings => _sessionEarnings;

  DriverProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final earningsData = await DriverService.getEarningsSummary();
      _stats = DriverStats.fromEarnings(earningsData);
      final historyData = await DriverService.getDeliveryHistory();
      _deliveryHistory = await _parseOrdersWithAddress(historyData);
      await _restoreActiveDelivery();
    } catch (e) {
      print('Error loading initial data: $e');
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleOnlineStatus(bool status) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (status) {
        await DriverService.goOnline();
        _isOnline = true;
        await _refreshAvailableOrders();
        await _restoreActiveDelivery();
        _updatePendingOrder();
      } else {
        await DriverService.goOffline();
        _isOnline = false;
        _availableOrders = [];
        _pendingOrder = null;
      }
    } catch (e) {
      print('Toggle online error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStatus() async {
    try {
      final status = await DriverService.getDriverStatus();
      _isOnline = status['is_available'] ?? false;
      notifyListeners();
    } catch (e) {
      print('Error refreshing status: $e');
    }
  }

  Future<void> _refreshAvailableOrders() async {
    if (!_isOnline) return;
    try {
      final raw = await DriverService.getAvailableOrders();
      _availableOrders = await _parseOrdersWithAddress(raw);
      notifyListeners();
    } catch (e) {
      print('Error refreshing orders: $e');
    }
  }

  Future<void> refreshAvailableOrders() async {
    await _refreshAvailableOrders();
    _updatePendingOrder();
  }

  Future<void> _restoreActiveDelivery() async {
    try {
      final data = await DriverService.getActiveDelivery();
      if (data == null || data['has_active_delivery'] == false) {
        _activeDelivery = null;
        return;
      }
      final deliveryData = data['delivery'] ?? data;
      final restored = await _parseOrderWithAddress(deliveryData);
      if (restored != null) {
        const inProgress = {'accepted', 'assigned', 'driver_assigned', 'driver_arrived', 'arrived', 'picked_up', 'on_the_way'};
        if (inProgress.contains(restored.status)) {
          _activeDelivery = restored;
          _availableOrders.removeWhere((o) => o.id == restored.id);
          if (!_acceptedHistory.any((o) => o.id == restored.id)) {
            _acceptedHistory.insert(0, restored);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error restoring active delivery: $e');
    }
  }

  void _updatePendingOrder() {
    if (_isOnline && _activeDelivery == null && _availableOrders.isNotEmpty) {
      _pendingOrder = _availableOrders.first;
    } else {
      _pendingOrder = null;
    }
    notifyListeners();
  }

  void consumePendingOrder() {
    _pendingOrder = null;
    notifyListeners();
  }

  Future<void> acceptOrder(DeliveryRequest order) async {
    _isLoading = true;
    _pendingOrder = null;
    notifyListeners();

    try {
      if (!order.id.startsWith('MOCK')) {
        await DriverService.acceptOrder(order.id);
      }
      _availableOrders.removeWhere((o) => o.id == order.id);
      final accepted = order.copyWith(status: 'accepted');
      _activeDelivery = accepted;
      _acceptedHistory.insert(0, accepted);
    } catch (e) {
      print('Error accepting order: $e');
      _error = e.toString();
      if (!_availableOrders.any((o) => o.id == order.id)) {
        _availableOrders.insert(0, order);
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void declineOrder(DeliveryRequest order) {
    _pendingOrder = null;
    _availableOrders.removeWhere((o) => o.id == order.id);
    final declined = order.copyWith(status: 'declined');
    _declinedOrders.insert(0, declined);
    _deliveryHistory.insert(0, declined);
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () => _updatePendingOrder());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_activeDelivery == null || _activeDelivery!.id != orderId) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!orderId.startsWith('MOCK')) {
        await DriverService.updateDeliveryStatus(orderId, newStatus);
      }
      _activeDelivery = _activeDelivery!.copyWith(status: newStatus);
      
      final idx = _acceptedHistory.indexWhere((o) => o.id == orderId);
      if (idx != -1) _acceptedHistory[idx] = _activeDelivery!;

      if (newStatus == 'delivered') {
        final earned = _activeDelivery!.earnings;
        _sessionEarnings += earned;
        _sessionDeliveries += 1;
        _stats = DriverStats(
          todayEarnings: _stats.todayEarnings + earned,
          totalDeliveries: _stats.totalDeliveries + 1,
          rating: _stats.rating,
          totalEarnings: _stats.totalEarnings + earned,
          activeDeliveries: (_stats.activeDeliveries - 1).clamp(0, 9999),
          completedToday: _stats.completedToday + 1,
        );
        _deliveryHistory.insert(0, _activeDelivery!);
        _activeDelivery = null;
        _updatePendingOrder();
      }
    } catch (e) {
      print('Error updating status: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      await refreshStatus();
      await _loadInitialData();
      if (_isOnline) {
        await _refreshAvailableOrders();
        await _restoreActiveDelivery();
        _updatePendingOrder();
      }
    } catch (e) {
      print('Error during refresh: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DeliveryRequest>> _parseOrdersWithAddress(List<dynamic> orders) async {
    final List<DeliveryRequest> result = [];
    for (final raw in orders) {
      final parsed = await _parseOrderWithAddress(raw as Map<String, dynamic>);
      if (parsed != null) result.add(parsed);
    }
    return result;
  }

  Future<DeliveryRequest?> _parseOrderWithAddress(Map<String, dynamic> raw) async {
    try {
      String restaurantAddress = raw['restaurant_address']?.toString() ?? '';
      if (restaurantAddress.isEmpty) {
        final restaurantId = raw['restaurant_id'] ?? raw['restaurant'];
        if (restaurantId != null && restaurantId.toString().isNotEmpty) {
          restaurantAddress = await DriverService.getRestaurantAddress(restaurantId.toString());
        }
      }
      return DeliveryRequest(
        id: (raw['id'] ?? raw['order_id'] ?? raw['delivery_id']).toString(),
        restaurantName: raw['restaurant_name']?.toString() ?? 'Unknown Restaurant',
        restaurantAddress: restaurantAddress,
        customerName: raw['customer_name']?.toString() ?? 'Unknown Customer',
        customerPhone: raw['customer_phone']?.toString(),
        deliveryAddress: raw['delivery_address']?.toString() ?? 'Address not available',
        status: raw['status']?.toString() ?? 'pending',
        items: 'Items',
        distance: raw['distance_km']?.toString() ?? '',
        earnings: _parseDouble(raw['delivery_fee'] ?? raw['earnings'] ?? raw['total_price'] ?? raw['estimated_earning']),
        estimatedTime: '30 min',
      );
    } catch (e) {
      print('Error parsing order: $e');
      return null;
    }
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}