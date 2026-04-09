import 'package:flutter/material.dart';
import '../models/delivery_request.dart';

class DriverProvider extends ChangeNotifier {
  bool _isOnline = false;
  DeliveryRequest? _activeDelivery;
  List<DeliveryRequest> _availableOrders = [];
  List<DeliveryRequest> _deliveryHistory = [];
  DriverStats _stats = DriverStats(
    todayEarnings: 2450,
    totalDeliveries: 342,
    rating: 4.8,
    totalEarnings: 45800,
    activeDeliveries: 0,
    completedToday: 5,
  );

  bool get isOnline => _isOnline;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  List<DeliveryRequest> get availableOrders => _availableOrders;
  List<DeliveryRequest> get deliveryHistory => _deliveryHistory;
  DriverStats get stats => _stats;

  DriverProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _availableOrders = [
      DeliveryRequest(
        id: 'ORD-001',
        restaurantName: 'Luigi\'s Pizza',
        restaurantAddress: '123 Main St',
        customerName: 'John Doe',
        deliveryAddress: '456 Oak Ave, Apartment 4B',
        status: 'pending',
        items: '2 items (Pepperoni Pizza, Garlic Bread)',
        distance: '1.2 km',
        earnings: 450,
        estimatedTime: '12:30 PM',
      ),
      DeliveryRequest(
        id: 'ORD-002',
        restaurantName: 'Burger King',
        restaurantAddress: '456 Fast Food Ln',
        customerName: 'Jane Smith',
        deliveryAddress: '789 Pine St',
        status: 'pending',
        items: '1 item (Whopper Meal)',
        distance: '0.8 km',
        earnings: 380,
        estimatedTime: '1:15 PM',
      ),
      DeliveryRequest(
        id: 'ORD-003',
        restaurantName: 'Sushi Master',
        restaurantAddress: '789 Sushi Rd',
        customerName: 'Mike Johnson',
        deliveryAddress: '321 Fish Ave',
        status: 'pending',
        items: '3 items (California Roll, Miso Soup, Green Tea)',
        distance: '2.5 km',
        earnings: 520,
        estimatedTime: '2:00 PM',
      ),
    ];

    _deliveryHistory = [
      DeliveryRequest(
        id: 'ORD-004',
        restaurantName: 'Tasty Bites',
        restaurantAddress: '111 Food St',
        customerName: 'Sarah Wilson',
        deliveryAddress: '222 Home Ave',
        status: 'delivered',
        items: '2 items',
        distance: '1.5 km',
        earnings: 410,
        estimatedTime: 'Yesterday, 12:45 PM',
      ),
      DeliveryRequest(
        id: 'ORD-005',
        restaurantName: 'Flame Grill',
        restaurantAddress: '333 Grill Rd',
        customerName: 'Tom Brown',
        deliveryAddress: '444 Flame Ct',
        status: 'delivered',
        items: '3 items',
        distance: '2.0 km',
        earnings: 490,
        estimatedTime: 'Yesterday, 6:30 PM',
      ),
    ];
  }

  void toggleOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
    
    if (_isOnline) {
      // Simulate incoming request after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_isOnline && _activeDelivery == null && _availableOrders.isNotEmpty) {
          notifyListeners();
        }
      });
    }
  }

  void acceptOrder(DeliveryRequest order) {
    final updatedOrder = order.copyWith(status: 'accepted');
    _activeDelivery = updatedOrder;
    _availableOrders.removeWhere((o) => o.id == order.id);
    _stats = DriverStats(
      todayEarnings: _stats.todayEarnings,
      totalDeliveries: _stats.totalDeliveries,
      rating: _stats.rating,
      totalEarnings: _stats.totalEarnings,
      activeDeliveries: _stats.activeDeliveries + 1,
      completedToday: _stats.completedToday,
    );
    notifyListeners();
  }

  void updateOrderStatus(String newStatus) {
    if (_activeDelivery != null) {
      _activeDelivery = _activeDelivery!.copyWith(status: newStatus);
      
      if (newStatus == 'delivered') {
        _stats = DriverStats(
          todayEarnings: _stats.todayEarnings + _activeDelivery!.earnings,
          totalDeliveries: _stats.totalDeliveries + 1,
          rating: _stats.rating,
          totalEarnings: _stats.totalEarnings + _activeDelivery!.earnings,
          activeDeliveries: _stats.activeDeliveries - 1,
          completedToday: _stats.completedToday + 1,
        );
        
        _deliveryHistory.insert(0, _activeDelivery!);
        _activeDelivery = null;
      }
      
      notifyListeners();
    }
  }

  void declineOrder(DeliveryRequest order) {
    _availableOrders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  List<DeliveryRequest> getActiveDeliveries() {
    return _activeDelivery != null ? [_activeDelivery!] : [];
  }
}