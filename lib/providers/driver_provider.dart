import 'package:flutter/material.dart';
import '../models/delivery_request.dart';
import '../services/driver_service.dart';

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
  List<DeliveryRequest> _availableOrders = [];
  List<DeliveryRequest> _deliveryHistory = [];
  List<DeliveryRequest> _acceptedHistory = [];
  List<DeliveryRequest> _declinedOrders = [];
  DeliveryRequest? _activeDelivery;
  DeliveryRequest? _pendingOrder;
  bool _isLoading = false;
  bool _isOnline = false;
  DriverStats _stats = DriverStats.empty();

  List<DeliveryRequest> get availableOrders => _availableOrders;
  List<DeliveryRequest> get deliveryHistory => _deliveryHistory;
  List<DeliveryRequest> get acceptedHistory => _acceptedHistory;
  List<DeliveryRequest> get declinedOrders => _declinedOrders;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  DeliveryRequest? get pendingOrder => _pendingOrder;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  DriverStats get stats => _stats;

  Future<void> refresh() async {
    await loadAvailableOrders();
    await loadActiveDelivery();
    await loadDeliveryHistory();
    await loadEarningsSummary();
    notifyListeners();
  }

  Future<void> loadAvailableOrders() async {
    try {
      final data = await DriverService.getAvailableOrders();
      _availableOrders = data.map((json) => DeliveryRequest.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading available orders: $e');
    }
  }

  Future<void> loadDeliveryHistory() async {
    try {
      final data = await DriverService.getDeliveryHistory();
      final deliveries = data['deliveries'] as List? ?? [];
      _deliveryHistory = deliveries.map((json) => DeliveryRequest.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading delivery history: $e');
    }
  }

  Future<void> loadActiveDelivery() async {
    try {
      final data = await DriverService.getActiveDelivery();
      if (data.isNotEmpty) {
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
      final data = await DriverService.getEarningsSummary();
      _stats = DriverStats.fromJson(data);
      notifyListeners();
    } catch (e) {
      print('Error loading earnings: $e');
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
    _isOnline = value;
    notifyListeners();
    
    try {
      if (value) {
        await DriverService.goOnline();
        await loadAvailableOrders();
      } else {
        await DriverService.goOffline();
      }
    } catch (e) {
      _isOnline = !value;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptOrder(DeliveryRequest order) async {
    try {
      await DriverService.acceptOrder(order.id);
      _availableOrders.removeWhere((o) => o.id == order.id);
      _activeDelivery = order;
      _acceptedHistory.add(order);
      notifyListeners();
    } catch (e) {
      print('Error accepting order: $e');
      rethrow;
    }
  }

  Future<void> declineOrder(DeliveryRequest order) async {
    try {
      await DriverService.declineOrder(order.id);
      _availableOrders.removeWhere((o) => o.id == order.id);
      _declinedOrders.add(order);
      notifyListeners();
    } catch (e) {
      print('Error declining order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await DriverService.updateDeliveryStatus(orderId: orderId, status: status);
      
      if (_activeDelivery != null && _activeDelivery!.id == orderId) {
        final updatedOrder = DeliveryRequest(
          id: _activeDelivery!.id,
          restaurantName: _activeDelivery!.restaurantName,
          restaurantAddress: _activeDelivery!.restaurantAddress,
          customerName: _activeDelivery!.customerName,
          customerPhone: _activeDelivery!.customerPhone,
          deliveryAddress: _activeDelivery!.deliveryAddress,
          earnings: _activeDelivery!.earnings,
          distance: _activeDelivery!.distance,
          estimatedTime: _activeDelivery!.estimatedTime,
          items: _activeDelivery!.items,
          status: status,
        );
        
        if (status == 'delivered') {
          _deliveryHistory.insert(0, updatedOrder);
          _activeDelivery = null;
        } else {
          _activeDelivery = updatedOrder;
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order status: $e');
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
}