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
      rating: _d(data['rating'], fallback: 5.0),
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

  // The single source of truth for available orders.
  List<DeliveryRequest> _availableOrders = [];

  // History: contains BOTH completed AND declined orders.
  List<DeliveryRequest> _deliveryHistory = [];

  // Declined orders tracked separately so the history screen can filter.
  List<DeliveryRequest> _declinedOrders = [];

  // ── NEW ─────────────────────────────────────────────────────────────────────
  // All orders that were ever accepted in this session (including the current
  // active one). This lets the dashboard schedule show full details for every
  // accepted order, not just the one currently active.
  List<DeliveryRequest> _acceptedHistory = [];

  // In-session earnings accumulated during this session.
  double _sessionEarnings = 0;
  int _sessionDeliveries = 0;

  DriverStats _stats = DriverStats.empty();

  // Set by provider after go-online; consumed by UI to show popup once.
  DeliveryRequest? _pendingOrder;

  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DeliveryRequest? get activeDelivery => _activeDelivery;
  List<DeliveryRequest> get availableOrders =>
      List.unmodifiable(_availableOrders);

  /// All history entries (completed + declined), newest first.
  List<DeliveryRequest> get deliveryHistory =>
      List.unmodifiable(_deliveryHistory);

  /// Only declined orders – used by history screen filter.
  List<DeliveryRequest> get declinedOrders =>
      List.unmodifiable(_declinedOrders);

  /// Only completed (delivered) orders – used by history screen filter.
  List<DeliveryRequest> get completedOrders => List.unmodifiable(
      _deliveryHistory.where((d) => d.status == 'delivered').toList());

  /// Every order accepted this session, including the current active one.
  /// Used by the dashboard schedule to show tappable detail for all accepted
  /// orders, even after a second/third order becomes active.
  List<DeliveryRequest> get acceptedHistory =>
      List.unmodifiable(_acceptedHistory);

  DriverStats get stats => _stats;
  DeliveryRequest? get pendingOrder => _pendingOrder;

  double get sessionEarnings => _sessionEarnings;

  DriverProvider() {
    _loadInitialData();
  }

  // ============================================================
  // INITIAL LOAD
  // ============================================================
  Future<void> _loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final earningsData = await DriverService.getEarningsSummary();
      _stats = DriverStats.fromEarnings(earningsData);

      final historyData = await DriverService.getDeliveryHistory();
      _deliveryHistory = await _parseOrdersWithAddress(historyData);
    } catch (e) {
      print('Error loading initial data: $e');
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // ONLINE / OFFLINE
  // ============================================================
  Future<void> toggleOnlineStatus(bool status) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (status) {
        print('🟢 Going online...');
        await DriverService.goOnline();
        _isOnline = true;

        await _refreshAvailableOrders();
        await _restoreActiveDelivery();
        _updatePendingOrder();
      } else {
        print('🔴 Going offline...');
        await DriverService.goOffline();
        _isOnline = false;
        _availableOrders = [];
        _pendingOrder = null;
      }
    } catch (e) {
      print('❌ Toggle online error: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // AVAILABLE ORDERS
  // ============================================================
  Future<void> _refreshAvailableOrders() async {
    try {
      final raw = await DriverService.getAvailableOrders();
      print('📦 Raw orders: $raw');
      _availableOrders = await _parseOrdersWithAddress(raw);
      print('📦 Parsed ${_availableOrders.length} orders');
      notifyListeners();
    } catch (e) {
      print('❌ Error refreshing orders: $e');
    }
  }

  Future<void> refreshAvailableOrders() async {
    await _refreshAvailableOrders();
    _updatePendingOrder();
  }

  // ============================================================
  // RESTORE ACTIVE DELIVERY
  // ============================================================
  Future<void> _restoreActiveDelivery() async {
    try {
      final data = await DriverService.getActiveDelivery();
      if (data == null) return;

      final restored = await _parseOrderWithAddress(data);
      if (restored == null) return;

      const inProgress = {
        'accepted',
        'driver_assigned',
        'driver_arrived',
        'picked_up',
        'on_the_way',
      };

      if (inProgress.contains(restored.status)) {
        _activeDelivery = restored;
        _availableOrders.removeWhere((o) => o.id == restored.id);

        // Add to acceptedHistory if not already present (app restart case).
        if (!_acceptedHistory.any((o) => o.id == restored.id)) {
          _acceptedHistory.insert(0, restored);
        }

        print('🚚 Restored active delivery: ${restored.id} (${restored.status})');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error restoring active delivery: $e');
    }
  }

  // ============================================================
  // PENDING ORDER POPUP LOGIC
  // ============================================================
  void _updatePendingOrder() {
    if (_isOnline && _activeDelivery == null && _availableOrders.isNotEmpty) {
      _pendingOrder = _availableOrders.first;
      print(
          '🔔 pendingOrder → ${_pendingOrder!.id} – ${_pendingOrder!.restaurantName}');
    } else {
      _pendingOrder = null;
    }
    notifyListeners();
  }

  void consumePendingOrder() {
    _pendingOrder = null;
  }

  // ============================================================
  // ACCEPT ORDER
  // ============================================================
  Future<void> acceptOrder(DeliveryRequest order) async {
    _isLoading = true;
    _pendingOrder = null;
    notifyListeners();

    try {
      print('✅ Accepting order: ${order.id}');

      if (!order.id.startsWith('MOCK')) {
        await DriverService.acceptOrder(order.id);
      } else {
        print('ℹ️ Mock order – skipping backend accept');
      }

      _availableOrders.removeWhere((o) => o.id == order.id);
      final accepted = order.copyWith(status: 'accepted');
      _activeDelivery = accepted;

      // ── NEW: record in acceptedHistory so schedule can show it ────────────
      _acceptedHistory.insert(0, accepted);

      _stats = DriverStats(
        todayEarnings: _stats.todayEarnings,
        totalDeliveries: _stats.totalDeliveries,
        rating: _stats.rating,
        totalEarnings: _stats.totalEarnings,
        activeDeliveries: _stats.activeDeliveries + 1,
        completedToday: _stats.completedToday,
      );

      print(
          '✅ Active delivery set: ${_activeDelivery!.restaurantName} → ${_activeDelivery!.deliveryAddress}');
    } catch (e) {
      print('❌ Error accepting order: $e');
      _error = e.toString();
      if (!_availableOrders.any((o) => o.id == order.id)) {
        _availableOrders.insert(0, order);
      }
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // DECLINE ORDER
  // ============================================================
  void declineOrder(DeliveryRequest order) {
    _pendingOrder = null;
    _availableOrders.removeWhere((o) => o.id == order.id);

    final declined = order.copyWith(status: 'declined');
    _declinedOrders.insert(0, declined);
    _deliveryHistory.insert(0, declined);

    print('🚫 Order declined and saved to history: ${order.id}');
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _updatePendingOrder();
    });
  }

  // ============================================================
  // UPDATE DELIVERY STATUS
  // ============================================================
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_activeDelivery == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!orderId.startsWith('MOCK')) {
        await DriverService.updateDeliveryStatus(orderId, newStatus);
      } else {
        print('ℹ️ Mock order – skipping backend status update');
      }

      _activeDelivery = _activeDelivery!.copyWith(status: newStatus);

      // ── NEW: keep acceptedHistory entry in sync with the latest status ────
      final idx = _acceptedHistory.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _acceptedHistory[idx] = _activeDelivery!;
      }

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
        print(
            '💰 Delivery complete. Session earnings: MK${_sessionEarnings.toInt()}');
      }

      print('✅ Status updated to: $newStatus');
    } catch (e) {
      print('❌ Error updating status: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================
  Future<void> refresh() async {
    await _loadInitialData();
    if (_isOnline) {
      await _refreshAvailableOrders();
      await _restoreActiveDelivery();
      _updatePendingOrder();
    }
  }

  List<DeliveryRequest> getActiveDeliveries() =>
      _activeDelivery != null ? [_activeDelivery!] : [];

  // ============================================================
  // PARSING HELPERS
  // ============================================================
  Future<List<DeliveryRequest>> _parseOrdersWithAddress(
      List<dynamic> orders) async {
    final List<DeliveryRequest> result = [];
    for (final raw in orders) {
      final parsed = await _parseOrderWithAddress(raw as Map<String, dynamic>);
      if (parsed != null) result.add(parsed);
    }
    return result;
  }

  Future<DeliveryRequest?> _parseOrderWithAddress(
      Map<String, dynamic> raw) async {
    try {
      print('📦 Parsing order: $raw');

      String restaurantAddress =
          raw['restaurant_address']?.toString() ?? '';

      if (restaurantAddress.isEmpty) {
        final restaurantId =
            _parseInt(raw['restaurant_id'] ?? raw['restaurant']);
        if (restaurantId != null && restaurantId > 0) {
          restaurantAddress =
              await DriverService.getRestaurantAddress(restaurantId);
        } else {
          restaurantAddress = 'Address not available';
        }
      }

      final itemsRaw = raw['items'];
      String itemsLabel;
      if (itemsRaw is List && itemsRaw.isNotEmpty) {
        final count = itemsRaw.length;
        final names = itemsRaw
            .take(2)
            .map((i) =>
                i['menu_item_name']?.toString() ??
                i['display_name']?.toString() ??
                '')
            .where((n) => n.isNotEmpty)
            .join(', ');
        itemsLabel = count == 1
            ? '1 item ($names)'
            : '$count items ($names${count > 2 ? '…' : ''})';
      } else if (itemsRaw is String) {
        itemsLabel = itemsRaw;
      } else {
        itemsLabel = '1 item';
      }

      final earnings = _parseDouble(
        raw['delivery_fee'] ?? raw['earnings'] ?? raw['total_price'],
      );

      final createdRaw = raw['created']?.toString();
      String estimatedTime = '30 min';
      if (createdRaw != null && createdRaw.contains('T')) {
        try {
          final created = DateTime.parse(createdRaw);
          final age = DateTime.now().difference(created);
          estimatedTime = age.inMinutes < 60
              ? '~${age.inMinutes} min ago'
              : '~${age.inHours}h ago';
        } catch (_) {}
      } else if (createdRaw != null && createdRaw.isNotEmpty) {
        estimatedTime = createdRaw;
      }

      return DeliveryRequest(
        id: (raw['id'] ?? raw['order_id']).toString(),
        restaurantName:
            raw['restaurant_name']?.toString() ?? 'Unknown Restaurant',
        restaurantAddress: restaurantAddress,
        customerName:
            raw['customer_name']?.toString() ?? 'Unknown Customer',
        customerPhone: raw['customer_phone']?.toString(),
        deliveryAddress:
            raw['delivery_address']?.toString() ?? 'Address not available',
        status: raw['status']?.toString() ?? 'pending',
        items: itemsLabel,
        distance: raw['distance']?.toString() ?? '',
        earnings: earnings,
        estimatedTime: estimatedTime,
      );
    } catch (e) {
      print('❌ Error parsing order: $e\nRaw: $raw');
      return null;
    }
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}