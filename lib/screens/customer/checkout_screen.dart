import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';

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
  String _selectedPaymentMethod = 'Cash on Delivery';

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'PayChangu',
    'Airtel Money',
    'TNM Mpamba',
    'Mpamba',
  ];

  Map<String, Map<String, dynamic>> get _paymentIcons => {
    'Cash on Delivery': {'icon': Icons.money, 'color': AppTheme.success},
    'PayChangu': {'icon': Icons.qr_code, 'color': AppTheme.primaryRed},
    'Airtel Money': {'icon': Icons.phone_android, 'color': AppTheme.warning},
    'TNM Mpamba': {'icon': Icons.phone_iphone, 'color': AppTheme.teal},
    'Mpamba': {'icon': Icons.phone_iphone, 'color': AppTheme.teal},
  };

  @override
  void initState() {
    super.initState();
    _initializeInstructionControllers();
    _loadUserPhoneNumber();
  }

  void _initializeInstructionControllers() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    for (var item in cartProvider.items) {
      _itemInstructions[item.menuItemId] = TextEditingController();
    }
  }

  void _loadUserPhoneNumber() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedPhoneNumber = authProvider.currentUser?.phone ?? '';
    
    // If no registered number, automatically switch to "different number" mode
    if (_selectedPhoneNumber.isEmpty) {
      _useNewPhone = true;
    }
  }

  @override
  void dispose() {
    _streetNumberController.dispose();
    _houseNumberController.dispose();
    _floorNumberController.dispose();
    for (var controller in _itemInstructions.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValidPhoneNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanNumber.length == 10 && cleanNumber.startsWith('0');
  }

  String _getDeliveryAddress() {
    return '${_streetNumberController.text}, ${_houseNumberController.text}${_floorNumberController.text.isNotEmpty ? ', Floor ${_floorNumberController.text}' : ''}';
  }

  // If different number is selected but empty, fallback to registered number
  String _getPhoneNumber() {
    if (_useNewPhone && _newPhoneNumber.trim().isNotEmpty) {
      return _newPhoneNumber.trim();
    }
    return _selectedPhoneNumber;
  }

  bool _validateFields() {
    if (_streetNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter street name/number')),
      );
      return false;
    }
    
    if (_houseNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter house/apartment number')),
      );
      return false;
    }
    
    final phoneNumber = _getPhoneNumber();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a phone number in your profile or enter a different number')),
      );
      return false;
    }
    
    if (!_isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number starting with 0')),
      );
      return false;
    }
    
    return true;
  }

  Future<void> _showPaymentDetailsDialog() async {
    if (!_validateFields()) {
      return;
    }

    final subtotal = context.read<CartProvider>().subtotal;
    final discount = 0.0;
    final deliveryFee = 2.99;
    final total = subtotal + deliveryFee - discount;
    final phoneNumber = _getPhoneNumber();
    final deliveryAddress = _getDeliveryAddress();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryRed),
            const SizedBox(width: 8),
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryRed.withOpacity(0.1), AppTheme.deepCrimson.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_paymentIcons[_selectedPaymentMethod]?['icon'] ?? Icons.payment, 
                         color: _paymentIcons[_selectedPaymentMethod]?['color'] ?? AppTheme.primaryRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                          Text(
                            _selectedPaymentMethod,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Order Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                        Text('MK${subtotal.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee:', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                        Text('MK${deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                        Text('MK${discount.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'MK${total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Delivery Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delivery_dining, size: 18, color: AppTheme.primaryRed),
                        const SizedBox(width: 8),
                        const Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            deliveryAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Payment Instructions based on method
              if (_selectedPaymentMethod != 'Cash on Delivery')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppTheme.warning),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Instructions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPaymentInstructions(),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Warning message
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.primaryRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please confirm your order details before proceeding',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Edit Details', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmOrderDialog(total);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Proceed to Pay'),
          ),
        ],
      ),
    );
  }

  String _getPaymentInstructions() {
    switch (_selectedPaymentMethod) {
      case 'PayChangu':
        return 'You will be redirected to PayChangu payment gateway to complete your payment securely.';
      case 'Airtel Money':
        return 'A payment request will be sent to your Airtel Money account. Please check your phone and enter your PIN to complete the payment.';
      case 'TNM Mpamba':
        return 'A payment request will be sent to your Mpamba account. Please check your phone and enter your PIN to complete the payment.';
      default:
        return '';
    }
  }

  Future<void> _showConfirmOrderDialog(double total) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirm Order',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 50, color: AppTheme.primaryRed),
            const SizedBox(height: 16),
            Text(
              'Total Amount: MK${total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Payment Method: $_selectedPaymentMethod',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryRed),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order will be confirmed shortly',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _placeOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      context.go('/login');
      return;
    }

    final deliveryAddress = _getDeliveryAddress();
    
    final order = cartProvider.createOrder(
      authProvider.currentUser!.id,
      deliveryAddress,
      null,
    );

    final placedOrder = await orderProvider.placeOrder(order);
    
    setState(() {
      _isLoading = false;
    });

    if (placedOrder != null && mounted) {
      cartProvider.clearCart();
      
      if (_selectedPaymentMethod != 'Cash on Delivery') {
        _showPaymentProcessingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go('/my-orders');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showPaymentProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryRed),
            const SizedBox(width: 8),
            const Text('Processing Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing your payment via $_selectedPaymentMethod...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getPaymentInstructions(),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showPaymentSuccessDialog();
      }
    });
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            const SizedBox(width: 8),
            const Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 60, color: AppTheme.success),
            const SizedBox(height: 16),
            const Text(
              'Your order has been placed successfully!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Payment of amount via $_selectedPaymentMethod has been processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/my-orders');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
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
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 180,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
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
        final discount = 0.0;
        final deliveryFee = 2.99;
        final total = subtotal + deliveryFee - discount;

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
                // Order Items Section
                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    final instructionController = _itemInstructions[item.menuItemId] ?? TextEditingController();
                    if (!_itemInstructions.containsKey(item.menuItemId)) {
                      _itemInstructions[item.menuItemId] = instructionController;
                    }
                    
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
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.fastfood, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quantity: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                      ),
                                    ),
                                    Text(
                                      'MK${item.price.toStringAsFixed(0)} each',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'MK${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
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
                
                // Phone Number Section - Modified to show optional message
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _useNewPhone,
                        onChanged: (value) {
                          setState(() {
                            _useNewPhone = false;
                          });
                        },
                        title: const Text('Use registered number'),
                        subtitle: Text(_selectedPhoneNumber.isNotEmpty ? _selectedPhoneNumber : 'No number registered'),
                        activeColor: AppTheme.primaryRed,
                      ),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _useNewPhone,
                        onChanged: (value) {
                          setState(() {
                            _useNewPhone = true;
                          });
                        },
                        title: const Text('Use a different number'),
                        activeColor: AppTheme.primaryRed,
                      ),
                      if (_useNewPhone)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: (value) {
                              _newPhoneNumber = value;
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number (10 digits) - Optional',
                              helperText: 'Leave empty to use your registered number',
                              prefixIcon: Icon(Icons.phone, color: AppTheme.primaryRed),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Delivery Address Section
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _streetNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Street Name/Number',
                            prefixIcon: Icon(Icons.streetview),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _houseNumberController,
                          decoration: const InputDecoration(
                            labelText: 'House/Apartment Number',
                            prefixIcon: Icon(Icons.home),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _floorNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Floor (Optional)',
                            prefixIcon: Icon(Icons.elevator),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Payment Method Section
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: _paymentMethods.map((method) {
                      final iconData = _paymentIcons[method]?['icon'] as IconData? ?? Icons.payment;
                      final iconColor = _paymentIcons[method]?['color'] as Color? ?? AppTheme.primaryRed;
                      return RadioListTile<String>(
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        title: Text(method),
                        secondary: Icon(iconData, color: iconColor),
                        activeColor: AppTheme.primaryRed,
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${subtotal.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${discount.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        ],
                      ),
                      const Divider(height: 24, color: AppTheme.deepCrimson),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'MK${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showPaymentDetailsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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