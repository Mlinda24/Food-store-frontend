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
  
  String _selectedPhoneNumber = '';
  String _newPhoneNumber = '';
  bool _useNewPhone = false;
  
  // Payment related variables
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash_on_delivery;
  String _mpambaNumber = '';
  String _airtelNumber = '';
  bool _isProcessingPayment = false;
  
  // Delivery related variables
  Position? _currentLocation;
  bool _isLoadingLocation = true;
  bool _locationChecked = false;
  double? _calculatedDeliveryFee;
  double? _distanceInMeters;
  bool _canDeliver = true;
  String? _deliveryTier;
  String? _locationError;
  
  final ApiService _apiService = ApiService();
  
  // ✅ Create PaymentProvider locally
  late final PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _paymentProvider = PaymentProvider(); // Initialize locally
    _loadCart();
    _loadUserPhoneNumber();
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
    _paymentProvider.dispose(); // Dispose to avoid memory leaks
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        await _calculateDeliveryFee();
      } else {
        setState(() {
          _locationError = 'Unable to get your location';
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationError = 'Please enable location to calculate delivery fee';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
        _locationChecked = true;
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
        final distanceInMeters = await Geolocator.distanceBetween(
          restaurantLat, restaurantLng,
          _currentLocation!.latitude, _currentLocation!.longitude,
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
        
        print('✅ Checkout delivery fee calculated: MK${_calculatedDeliveryFee!.toStringAsFixed(0)} for ${DeliveryFeeCalculator.formatDistance(distanceInMeters)}');
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
      print('✅ Using delivery fee from CartProvider: MK${_calculatedDeliveryFee!.toStringAsFixed(0)}');
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

  void _loadUserPhoneNumber() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedPhoneNumber = authProvider.currentUser?.phone ?? '';
    
    if (_selectedPhoneNumber.isEmpty) {
      _useNewPhone = true;
    }
  }

  bool _isValidPhoneNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanNumber.length == 10 && cleanNumber.startsWith('0');
  }

  String _getDeliveryAddress() {
    final street = _streetNumberController.text.trim();
    final house = _houseNumberController.text.trim();
    final floor = _floorNumberController.text.trim();
    
    if (street.isEmpty && house.isEmpty) return '';
    if (floor.isNotEmpty) {
      return '$street, $house, Floor $floor';
    }
    return '$street, $house';
  }

  String _getPhoneNumber() {
    if (_useNewPhone && _newPhoneNumber.trim().isNotEmpty) {
      return _newPhoneNumber.trim();
    }
    return _selectedPhoneNumber;
  }

  String _getPaymentPhoneNumber() {
    if (_selectedPaymentMethod == PaymentMethod.mpamba) {
      return _mpambaNumber;
    } else if (_selectedPaymentMethod == PaymentMethod.airtel_money) {
      return _airtelNumber;
    }
    return '';
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
    
    final phoneNumber = _getPhoneNumber();
    if (phoneNumber.isEmpty) {
      _showError('Please register a phone number in your profile or enter a different number');
      return false;
    }
    
    if (!_isValidPhoneNumber(phoneNumber)) {
      _showError('Please enter a valid 10-digit phone number starting with 0');
      return false;
    }
    
    if (_selectedPaymentMethod != PaymentMethod.cash_on_delivery) {
      final paymentPhone = _getPaymentPhoneNumber();
      if (paymentPhone.isEmpty) {
        _showError('Please enter your mobile money phone number');
        return false;
      }
      if (!_isValidPhoneNumber(paymentPhone)) {
        _showError('Please enter a valid 10-digit phone number starting with 0');
        return false;
      }
    }
    
    if (!_canDeliver) {
      _showError('Sorry, we do not deliver to your location. Maximum delivery radius is 2.5 km.');
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

  // ✅ FIXED: Use local _paymentProvider instead of context.read
  Future<void> _processPaymentAndPlaceOrder(Order order) async {
    if (_selectedPaymentMethod == PaymentMethod.cash_on_delivery) {
      await _completeOrder(order.id);
      return;
    }
    
    final paymentPhone = _getPaymentPhoneNumber();
    if (paymentPhone.isEmpty) {
      _showError('Please enter your mobile money phone number');
      return;
    }
    
    setState(() {
      _isProcessingPayment = true;
    });
    
    try {
      // Use local payment provider instance
      final result = await _paymentProvider.initiatePayment(
        amount: order.total,
        phoneNumber: paymentPhone,
        orderId: order.id,
        method: _selectedPaymentMethod,
      );
      
      if (result['status'] == 'success' || result['transaction_id'] != null) {
        final transactionId = result['transaction_id'] ?? result['id'].toString();
        
        if (mounted) {
          await _showPaymentProcessingDialog(transactionId);
        }
        
        final isPaid = await _checkPaymentStatus(transactionId);
        
        if (isPaid) {
          await _completeOrder(order.id);
        } else {
          _showError('Payment failed. Please try again or choose Cash on Delivery.');
        }
      } else {
        _showError('Payment initiation failed. Please try again.');
      }
    } catch (e) {
      _showError('Payment error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _showPaymentProcessingDialog(String transactionId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            Text(
              'Processing Payment...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your phone for the payment prompt',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Transaction: $transactionId',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getMutedTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkPaymentStatus(String transactionId) async {
    // Use local payment provider instance
    for (int i = 0; i < 15; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      
      final isPaid = await _paymentProvider.verifyPayment(transactionId);
      if (isPaid) {
        if (mounted) {
          Navigator.pop(context);
        }
        return true;
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
    return false;
  }

  Future<void> _completeOrder(String orderId) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.clearCart();
    
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadUnreadCount();
    
    _showSuccess('Order placed successfully!');
    
    if (mounted) {
      context.go('/order-tracking', extra: {'order_id': orderId});
    }
  }

  Future<void> _placeOrder() async {
    if (!_validateFields()) {
      return;
    }

    final cartProvider = context.read<CartProvider>();
    
    print('Cart items before order: ${cartProvider.items.map((i) => i.name).toList()}');
    
    if (cartProvider.items.isEmpty) {
      _showError('Your cart is empty. Please add items first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      _showError('Please login first');
      context.go('/login');
      return;
    }

    final deliveryAddress = _getDeliveryAddress();
    final phoneNumber = _getPhoneNumber();
    
    final Map<String, String> instructions = {};
    _itemInstructions.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        instructions[key] = controller.text;
      }
    });
    
    final instructionsText = instructions.isNotEmpty 
        ? 'Item Instructions: ${instructions.entries.map((e) => 'Item ${e.key}: ${e.value}').join('; ')}'
        : '';
    
    final restaurantId = cartProvider.items.first.restaurantId;
    
    final orderData = {
      'restaurant_id': int.parse(restaurantId),
      'delivery_address': deliveryAddress,
      'note': 'Phone: $phoneNumber. Payment: ${_selectedPaymentMethod.displayName}. $instructionsText',
      'latitude': _currentLocation?.latitude,
      'longitude': _currentLocation?.longitude,
      'payment_method': _selectedPaymentMethod.value,
    };
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 Placing Order');
    print('   Order Data: $orderData');
    print('   Restaurant ID: $restaurantId');
    print('   Delivery Fee: MK${(_calculatedDeliveryFee ?? cartProvider.deliveryFee).toStringAsFixed(0)}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final placedOrder = await orderProvider.placeOrder(orderData);
      
      setState(() {
        _isLoading = false;
      });

      if (placedOrder != null && mounted) {
        await _processPaymentAndPlaceOrder(placedOrder);
      } else if (mounted) {
        _showError('Failed to place order. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error placing order: $e');
      print('❌ Order placement error: $e');
    }
  }

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
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
            Icon(Icons.location_off, color: AppTheme.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location Required', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.warning, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Outside Delivery Zone', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error)),
                  const SizedBox(height: 4),
                  Text('Maximum delivery radius is 2.5 km', style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context))),
                  if (distance != null)
                    Text('Your distance: ${DeliveryFeeCalculator.formatDistance(distance)}', style: const TextStyle(fontSize: 11)),
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
          Icon(Icons.delivery_dining, color: AppTheme.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Available', style: TextStyle(fontWeight: FontWeight.bold)),
                if (distance != null)
                  Text('Distance: ${DeliveryFeeCalculator.formatDistance(distance)}${tier != null ? " - $tier" : ""}',
                      style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('MK${deliveryFee.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
              if (tier != null) Text(tier, style: TextStyle(fontSize: 10, color: AppTheme.getSecondaryTextColor(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          color: AppTheme.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.cash_on_delivery,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                title: const Text('Cash on Delivery'),
                subtitle: const Text('Pay when you receive your order'),
                activeColor: AppTheme.primaryRed,
              ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.mpamba,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                title: const Text('Mpamba'),
                subtitle: const Text('Pay using Mpamba mobile money'),
                activeColor: AppTheme.primaryRed,
              ),
              if (_selectedPaymentMethod == PaymentMethod.mpamba)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) => _mpambaNumber = value,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mpamba Phone Number',
                      hintText: '0XXX XXX XXX',
                      prefixIcon: Icon(Icons.phone_android, color: AppTheme.primaryRed),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.airtel_money,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                title: const Text('Airtel Money'),
                subtitle: const Text('Pay using Airtel Money'),
                activeColor: AppTheme.primaryRed,
              ),
              if (_selectedPaymentMethod == PaymentMethod.airtel_money)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) => _airtelNumber = value,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Airtel Money Phone Number',
                      hintText: '0XXX XXX XXX',
                      prefixIcon: Icon(Icons.phone_iphone, color: AppTheme.primaryRed),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isLoading) {
          return Scaffold(
            backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            appBar: AppBar(
              title: const Text('Checkout'),
              backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              foregroundColor: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        
        if (!cartProvider.hasItems) {
          return Scaffold(
            backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            appBar: AppBar(
              title: const Text('My Cart'),
              backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              foregroundColor: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                  const SizedBox(height: 24),
                  Container(
                    width: 180,
                    height: 44,
                    decoration: BoxDecoration(gradient: AppTheme.primaryButtonGradient, borderRadius: BorderRadius.circular(22)),
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
          backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            foregroundColor: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeliveryInfoCard(),
                _buildPaymentSection(),
                const SizedBox(height: 24),
                const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    if (!_itemInstructions.containsKey(item.menuItemId)) {
                      _itemInstructions[item.menuItemId] = TextEditingController();
                    }
                    final instructionController = _itemInstructions[item.menuItemId]!;
                    final imageUrl = item.image ?? '';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGlowGradient(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
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
                                        placeholder: (context, url) => Container(
                                          width: 50,
                                          height: 50,
                                          color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          width: 50,
                                          height: 50,
                                          color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                          child: Icon(Icons.fastfood, size: 25, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                        child: Icon(Icons.fastfood, size: 25, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('Qty: ${item.quantity}', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                                    Text('MK${item.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('MK${(item.price * item.quantity).toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_note, size: 16, color: AppTheme.primaryRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: instructionController,
                                    style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                                    decoration: InputDecoration(
                                      hintText: 'Special instructions...',
                                      hintStyle: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
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
                const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3))),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _useNewPhone,
                        onChanged: (value) => setState(() => _useNewPhone = false),
                        title: const Text('Use registered number'),
                        subtitle: Text(_selectedPhoneNumber.isNotEmpty ? _selectedPhoneNumber : 'No number registered'),
                        activeColor: AppTheme.primaryRed,
                      ),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _useNewPhone,
                        onChanged: (value) => setState(() => _useNewPhone = true),
                        title: const Text('Use a different number'),
                        activeColor: AppTheme.primaryRed,
                      ),
                      if (_useNewPhone)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: (value) => _newPhoneNumber = value,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number (10 digits)',
                              prefixIcon: Icon(Icons.phone, color: AppTheme.primaryRed),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(controller: _streetNumberController, decoration: const InputDecoration(labelText: 'Street Name/Number', prefixIcon: Icon(Icons.streetview), border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: _houseNumberController, decoration: const InputDecoration(labelText: 'House/Apartment Number', prefixIcon: Icon(Icons.home), border: OutlineInputBorder())),
                        const SizedBox(height: 12),
                        TextField(controller: _floorNumberController, decoration: const InputDecoration(labelText: 'Floor (Optional)', prefixIcon: Icon(Icons.elevator), border: OutlineInputBorder())),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: AppTheme.cardGlowGradient(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3))),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Subtotal:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        Text('MK${subtotal.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                      ]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Delivery Fee:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        Text('MK${deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                      ]),
                      const Divider(height: 24, color: AppTheme.deepCrimson),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('MK${total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryRed)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_canDeliver || _isProcessingPayment) ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: (_isLoading || _isProcessingPayment)
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}