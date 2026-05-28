import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../utils/delivery_fee_calculator.dart';
import '../payment/paychangu_webview_screen.dart';
import '../../providers/restaurant_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _streetNumberController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _floorNumberController = TextEditingController();
  final Map<String, TextEditingController> _itemInstructions = {};
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  bool _isPlacingOrder = false;
  bool _isCreatingOrder = false;
  Order? _pendingOrder;

  // Delivery
  Position? _currentLocation;
  bool _isLoadingLocation = true;
  double? _calculatedDeliveryFee;
  double? _distanceInMeters;
  bool _canDeliver = true;
  String? _deliveryTier;
  String? _locationError;

  final ApiService _apiService = ApiService();
  late final PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _paymentProvider = PaymentProvider();
    _loadCart();
    _getUserLocation();
  }

  @override
  void dispose() {
    _streetNumberController.dispose();
    _houseNumberController.dispose();
    _floorNumberController.dispose();
    for (var controller in _itemInstructions.values) {
      controller.dispose();
    }
    _paymentProvider.dispose();
    super.dispose();
  }

  // ─── Location ────────────────────────────────────────────────

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() => _currentLocation = location);
        await _calculateDeliveryFee();
      } else {
        setState(() => _locationError = 'Unable to get your location');
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() =>
          _locationError = 'Please enable location to calculate delivery fee');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _calculateDeliveryFee() async {
    if (_currentLocation == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final items = cartProvider.items;
    if (items.isEmpty) return;

    final restaurantId = items.first.restaurantId;

    try {
      final restaurantData = await _apiService.getRestaurant(restaurantId);

      final restaurantLat = restaurantData['latitude'] != null
          ? double.parse(restaurantData['latitude'].toString())
          : null;
      final restaurantLng = restaurantData['longitude'] != null
          ? double.parse(restaurantData['longitude'].toString())
          : null;

      if (restaurantLat != null && restaurantLng != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          restaurantLat,
          restaurantLng,
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        final fee = DeliveryFeeCalculator.calculateFee(distanceInMeters);
        final canDeliver = DeliveryFeeCalculator.canDeliver(distanceInMeters);
        final tier = DeliveryFeeCalculator.getDeliveryTier(distanceInMeters);

        setState(() {
          _distanceInMeters = distanceInMeters;
          _calculatedDeliveryFee = fee > 0 ? fee : 2000.0;
          _canDeliver = canDeliver;
          _deliveryTier = tier;
        });

        cartProvider.setCalculatedDeliveryFee(_calculatedDeliveryFee!);
        cartProvider.setDeliveryInfo(
          distanceInMeters: distanceInMeters,
          deliveryFee: _calculatedDeliveryFee!,
          canDeliver: canDeliver,
          tier: tier,
        );
      } else {
        setState(() {
          _calculatedDeliveryFee = cartProvider.deliveryFee;
          _canDeliver = true;
        });
      }
    } catch (e) {
      print('Error calculating delivery fee: $e');
      setState(() {
        _locationError = 'Could not calculate delivery fee';
        _calculatedDeliveryFee = cartProvider.deliveryFee;
      });
    }
  }

  // ─── Cart ─────────────────────────────────────────────────────

  Future<void> _loadCart() async {
    await context.read<CartProvider>().loadCart();
    _initializeInstructionControllers();

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.deliveryFee > 0 && cartProvider.deliveryFee != 2000.0) {
      setState(() {
        _calculatedDeliveryFee = cartProvider.deliveryFee;
        _distanceInMeters = cartProvider.distanceInMeters;
        _canDeliver = cartProvider.canDeliver;
        _deliveryTier = cartProvider.deliveryTier;
      });
    }
  }

  void _initializeInstructionControllers() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _itemInstructions.clear();
    for (var item in cartProvider.items) {
      if (!_itemInstructions.containsKey(item.menuItemId)) {
        _itemInstructions[item.menuItemId] = TextEditingController();
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _getDeliveryAddress() {
    final street = _streetNumberController.text.trim();
    final house = _houseNumberController.text.trim();
    final floor = _floorNumberController.text.trim();
    if (street.isEmpty && house.isEmpty) return '';
    return floor.isNotEmpty
        ? '$street, $house, Floor $floor'
        : '$street, $house';
  }

  bool _validateFields() {
    if (_streetNumberController.text.trim().isEmpty) {
      _showError('Please enter street name/number');
      return false;
    }
    if (_houseNumberController.text.trim().isEmpty) {
      _showError('Please enter house/apartment number');
      return false;
    }
    if (!_canDeliver) {
      _showError(
          'Sorry, we do not deliver to your location. Maximum delivery radius is 2.5 km.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  // ─── Payment Flow (Order Created FIRST, THEN Payment) ──────────────

  Future<void> _startPayment() async {
    if (_isProcessingPayment || _isPlacingOrder || _isCreatingOrder) {
      print('⏳ Payment already in progress, ignoring duplicate call');
      return;
    }

    final cartProvider = context.read<CartProvider>();

    if (cartProvider.items.isEmpty) {
      _showError('Your cart is empty. Please add items first.');
      return;
    }

    if (!_validateFields()) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // STEP 1: CREATE ORDER FIRST
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📝 STEP 1: Creating order...');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final deliveryAddress = _getDeliveryAddress();

      final Map<String, String> instructions = {};
      _itemInstructions.forEach((key, controller) {
        if (controller.text.isNotEmpty) instructions[key] = controller.text;
      });

      final instructionsText = instructions.isNotEmpty
          ? 'Item Instructions: ${instructions.entries.map((e) => 'Item ${e.key}: ${e.value}').join('; ')}'
          : '';

      final restaurantId = cartProvider.items.first.restaurantId;

      final orderData = {
        'restaurant_id': int.parse(restaurantId),
        'delivery_address': deliveryAddress,
        'note': instructionsText,
        'latitude': _currentLocation?.latitude,
        'longitude': _currentLocation?.longitude,
      };

      print('📤 Order data: $orderData');

      final orderProvider = context.read<OrderProvider>();
      final placedOrder = await orderProvider.placeOrder(orderData);

      if (placedOrder == null) {
        throw Exception('Failed to create order');
      }

      final orderId = placedOrder.id;
      print('✅ Order created with ID: $orderId');

      // STEP 2: INITIATE PAYMENT WITH REAL ORDER ID
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💳 STEP 2: Initiating real payment for order: $orderId');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final total = cartProvider.subtotal +
          (_calculatedDeliveryFee ?? cartProvider.deliveryFee);

      // Real PayChangu payment with real order ID
      final result = await _paymentProvider.initiateSimplePayment(
        amount: total,
        orderId: orderId, // Use REAL order ID, not 'temp'
      );

      final checkoutUrl = result['checkout_url'] as String?;
      final paymentReference = result['reference'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('Payment service did not return a checkout URL');
      }

      setState(() => _isProcessingPayment = false);

      // Open PayChangu checkout page in WebView
      final webViewResult =
          await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => PaychanguWebViewScreen(
            checkoutUrl: checkoutUrl,
            reference: paymentReference ?? '',
            amount: total,
            orderId: orderId, // Pass order ID for wallet sync
          ),
        ),
      );

      if (webViewResult == null || webViewResult['status'] == 'cancelled') {
        _showError('Payment was cancelled. Order #$orderId is pending.');
        context.go('/my-orders');
        return;
      }

      if (webViewResult['status'] == 'submitted') {
        setState(() => _isProcessingPayment = true);
        final ref =
            webViewResult['reference'] as String? ?? paymentReference ?? '';
        final orderIdForSync = webViewResult['order_id'] as String? ?? orderId;

        // Poll for payment confirmation
        bool paymentConfirmed = await _pollPaymentStatus(ref);

        // If polling fails, try manual confirmation
        if (!paymentConfirmed) {
          print('⚠️ Polling failed, trying manual confirmation...');
          try {
            final manualResult =
                await _apiService.manualConfirmPayment(orderIdForSync);
            paymentConfirmed = manualResult['status'] == 'completed';
            if (paymentConfirmed) {
              print('✅ Manual confirmation successful');
              // Sync wallet after manual confirmation
              await _syncWalletAfterPayment(orderIdForSync);
            }
          } catch (e) {
            print('❌ Manual confirmation failed: $e');
          }
        }

        setState(() => _isProcessingPayment = false);

        if (paymentConfirmed) {
          // Update order status to confirmed
          await _apiService.updateOrderStatus(orderIdForSync, 'confirmed');
          await _completeOrder(orderIdForSync);
        } else {
          _showError(
              'Payment verification failed. Order #$orderIdForSync is pending.');
          context.go('/my-orders');
        }
      } else if (webViewResult['status'] == 'failed') {
        _showError('Payment failed. Order #$orderId is pending.');
        context.go('/my-orders');
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      _showError('Error: ${e.toString()}');
      print('❌ Error: $e');
    }
  }

  Future<bool> _pollPaymentStatus(String reference) async {
    print('🔄 Polling payment status for reference: $reference');
    for (int attempt = 1; attempt <= 10; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      try {
        final statusData =
            await _paymentProvider.getPaymentStatusByReference(reference);
        final status = statusData?['status'] as String?;
        final distributed =
            statusData?['distributed_to_wallets'] as bool? ?? false;

        print(
            '🔄 Poll attempt $attempt: status=$status, distributed=$distributed');

        if (status == 'completed') {
          print('✅ Payment confirmed!');
          return true;
        }
        if (status == 'failed') {
          print('❌ Payment failed');
          return false;
        }
      } catch (e) {
        print('Poll attempt $attempt error: $e');
      }
    }
    return false;
  }

  Future<void> _syncWalletAfterPayment(String orderId) async {
    try {
      print('🔄 Syncing wallet for order: $orderId');
      final result = await _apiService.checkAndUpdateWallet(orderId);
      if (result['updated'] == true || result['already_updated'] == true) {
        print(
            '✅ Wallet synced successfully! Balance: ${result['wallet_balance']}');
      } else {
        print('⚠️ Wallet sync returned: ${result['message']}');
      }
    } catch (e) {
      print('❌ Wallet sync failed: $e');
    }
  }

  Future<void> _completeOrder(String orderId) async {
    // Clear cart AFTER successful payment
    final cartProvider = context.read<CartProvider>();
    await cartProvider.clearCart();

    // Refresh wallet balance in restaurant provider if available
    try {
      final restaurantProvider =
          Provider.of<RestaurantProvider>(context, listen: false);
      await restaurantProvider.loadStats();
      await restaurantProvider.loadRestaurantData();
    } catch (e) {
      print('⚠️ Could not refresh restaurant data: $e');
    }

    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadUnreadCount();

    _showSuccess('Order placed successfully!');

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go('/order-tracking', extra: {'order_id': orderId});
        }
      });
    }
  }

  // ─── UI Widgets ───────────────────────────────────────────────

  Widget _buildDeliveryInfoCard() {
    final cartProvider = Provider.of<CartProvider>(context);
    final deliveryFee = _calculatedDeliveryFee ?? cartProvider.deliveryFee;
    final distance = _distanceInMeters ?? cartProvider.distanceInMeters;
    final canDeliver = _canDeliver && cartProvider.canDeliver;
    final tier = _deliveryTier ?? cartProvider.deliveryTier;

    if (_isLoadingLocation) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Calculating delivery fee...'),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warning),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: AppTheme.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location Required',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_locationError!, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            TextButton(onPressed: _getUserLocation, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (!canDeliver) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Outside Delivery Zone',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.error)),
                  const SizedBox(height: 4),
                  Text('Maximum delivery radius is 2.5 km',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryTextColor(context))),
                  if (distance != null)
                    Text(
                        'Your distance: ${DeliveryFeeCalculator.formatDistance(distance)}',
                        style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining, color: AppTheme.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Available',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (distance != null)
                  Text(
                      'Distance: ${DeliveryFeeCalculator.formatDistance(distance)}'
                      '${tier != null ? " - $tier" : ""}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryTextColor(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'MK${deliveryFee.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed),
              ),
              if (tier != null)
                Text(tier,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.getSecondaryTextColor(context))),
            ],
          ),
        ],
      ),
    );
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoading) {
          return Scaffold(
            backgroundColor:
                isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            appBar: AppBar(
              title: const Text('Checkout'),
              backgroundColor:
                  isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              foregroundColor:
                  isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark
                        ? AppTheme.darkPrimaryText
                        : AppTheme.lightPrimaryText),
                onPressed: _goBack,
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!cartProvider.hasItems) {
          return Scaffold(
            backgroundColor:
                isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            appBar: AppBar(
              title: const Text('My Cart'),
              backgroundColor:
                  isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              foregroundColor:
                  isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark
                        ? AppTheme.darkPrimaryText
                        : AppTheme.lightPrimaryText),
                onPressed: _goBack,
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80,
                      color: isDark
                          ? AppTheme.darkMutedText
                          : AppTheme.lightMutedText),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? AppTheme.darkSecondaryText
                              : AppTheme.lightSecondaryText)),
                  const SizedBox(height: 24),
                  Container(
                    width: 180,
                    height: 44,
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(22)),
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text('Browse Restaurants'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final subtotal = cartProvider.subtotal;
        final deliveryFee = _calculatedDeliveryFee ?? cartProvider.deliveryFee;
        final total = subtotal + (deliveryFee > 0 ? deliveryFee : 0);

        return Scaffold(
          backgroundColor:
              isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor:
                isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            foregroundColor:
                isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark
                      ? AppTheme.darkPrimaryText
                      : AppTheme.lightPrimaryText),
              onPressed: _goBack,
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryInfoCard(),
                    const Text('Order Items',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        if (!_itemInstructions.containsKey(item.menuItemId)) {
                          _itemInstructions[item.menuItemId] =
                              TextEditingController();
                        }
                        final instructionController =
                            _itemInstructions[item.menuItemId]!;
                        // Use ApiService to get the correct image URL
                        final imageUrl = _apiService.getImageUrl(item.image);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGlowGradient(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.deepCrimson.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            placeholder: (ctx, url) =>
                                                Container(
                                              width: 50,
                                              height: 50,
                                              color: isDark
                                                  ? AppTheme.darkSurface
                                                  : AppTheme.lightBackground,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2)),
                                            ),
                                            errorWidget: (ctx, url, error) =>
                                                Container(
                                              width: 50,
                                              height: 50,
                                              color: isDark
                                                  ? AppTheme.darkSurface
                                                  : AppTheme.lightBackground,
                                              child: const Icon(Icons.fastfood,
                                                  size: 25, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: isDark
                                                ? AppTheme.darkSurface
                                                : AppTheme.lightBackground,
                                            child: const Icon(Icons.fastfood,
                                                size: 25, color: Colors.grey),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppTheme.darkPrimaryText
                                                    : AppTheme
                                                        .lightPrimaryText),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('Qty: ${item.quantity}',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppTheme.darkSecondaryText
                                                    : AppTheme
                                                        .lightSecondaryText)),
                                        Text(
                                            'MK${item.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: isDark
                                                    ? AppTheme.darkMutedText
                                                    : AppTheme.lightMutedText)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                      'MK${(item.price * item.quantity).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRed)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkSurface
                                      : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.deepCrimson
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_note,
                                        size: 16, color: AppTheme.primaryRed),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: instructionController,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppTheme.darkPrimaryText
                                                : AppTheme.lightPrimaryText),
                                        decoration: InputDecoration(
                                          hintText: 'Special instructions...',
                                          hintStyle: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppTheme.darkMutedText
                                                  : AppTheme.lightMutedText),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text('Delivery Address',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Card(
                      color: AppTheme.getCardColor(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: AppTheme.deepCrimson.withOpacity(0.3))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                                controller: _streetNumberController,
                                decoration: const InputDecoration(
                                    labelText: 'Street Name/Number',
                                    prefixIcon: Icon(Icons.streetview),
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(
                                controller: _houseNumberController,
                                decoration: const InputDecoration(
                                    labelText: 'House/Apartment Number',
                                    prefixIcon: Icon(Icons.home),
                                    border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(
                                controller: _floorNumberController,
                                decoration: const InputDecoration(
                                    labelText: 'Floor (Optional)',
                                    prefixIcon: Icon(Icons.elevator),
                                    border: OutlineInputBorder())),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order summary card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGlowGradient(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal:',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkSecondaryText
                                            : AppTheme.lightSecondaryText)),
                                Text('MK${subtotal.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkSecondaryText
                                            : AppTheme.lightSecondaryText)),
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Fee:',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkSecondaryText
                                            : AppTheme.lightSecondaryText)),
                                Text('MK${deliveryFee.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkSecondaryText
                                            : AppTheme.lightSecondaryText)),
                              ]),
                          const Divider(
                              height: 24, color: AppTheme.deepCrimson),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text('MK${total.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.primaryRed)),
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place order button - Creates order first, then payment
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading ||
                                !_canDeliver ||
                                _isProcessingPayment ||
                                _isPlacingOrder ||
                                _isCreatingOrder)
                            ? null
                            : _startPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: (_isLoading ||
                                _isProcessingPayment ||
                                _isCreatingOrder)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Proceed to Payment',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Payment processing overlay
              if (_isProcessingPayment || _isCreatingOrder)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                                color: AppTheme.primaryRed),
                            const SizedBox(height: 16),
                            Text(
                              _isCreatingOrder
                                  ? 'Creating your order...'
                                  : _isProcessingPayment
                                      ? 'Processing Payment...'
                                      : 'Please wait...',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please wait',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.darkSecondaryText
                                      : AppTheme.lightSecondaryText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
