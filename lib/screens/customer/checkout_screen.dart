import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadUserPhoneNumber();
  }

  Future<void> _loadCart() async {
    await context.read<CartProvider>().loadCart();
    _initializeInstructionControllers();
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

  String _getPhoneNumber() {
    if (_useNewPhone && _newPhoneNumber.trim().isNotEmpty) {
      return _newPhoneNumber.trim();
    }
    return _selectedPhoneNumber;
  }

  bool _validateFields() {
    if (_streetNumberController.text.isEmpty) {
      _showError('Please enter street name/number');
      return false;
    }
    
    if (_houseNumberController.text.isEmpty) {
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

  Future<void> _placeOrder() async {
    if (!_validateFields()) {
      return;
    }

    final cartProvider = context.read<CartProvider>();
    
    // Debug: Check cart contents
    print('Cart items count before order: ${cartProvider.items.length}');
    print('Cart items: ${cartProvider.items.map((i) => i.name).toList()}');
    
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
    
    // Collect special instructions for each item
    final Map<String, String> instructions = {};
    _itemInstructions.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        instructions[key] = controller.text;
      }
    });
    
    final instructionsText = instructions.isNotEmpty 
        ? 'Item Instructions: ${instructions.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'
        : '';
    
    // IMPORTANT: Only send delivery_address and note
    // The backend automatically gets restaurant from cart items
    final orderData = {
      'delivery_address': deliveryAddress,
      'note': 'Phone: $phoneNumber. $instructionsText',
    };
    
    print('Order data being sent: $orderData');

    try {
      final placedOrder = await orderProvider.placeOrder(orderData);
      
      setState(() {
        _isLoading = false;
      });

      if (placedOrder != null && mounted) {
        await cartProvider.clearCart();
        _showSuccess('Order placed successfully!');
        
        // Show order confirmation dialog
        _showOrderConfirmationDialog(placedOrder);
      } else if (mounted) {
        _showError('Failed to place order. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error placing order: $e');
      print('Order placement error: $e');
    }
  }

  void _showOrderConfirmationDialog(Order order) {
    showDialog(
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
            Icon(Icons.check_circle, color: AppTheme.success),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 60, color: AppTheme.success),
            const SizedBox(height: 16),
            Text(
              'Order #${order.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Amount: MK${order.total.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppTheme.primaryRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.deliveryAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppTheme.primaryRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estimated delivery: 30-45 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can track your order status in "My Orders"',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Continue Shopping', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/my-orders');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('View Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
        // Show loading indicator while cart is loading
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
        final deliveryFee = cartProvider.deliveryFee;
        final total = cartProvider.total;

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
                              // Item Image
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
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
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
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                                      ),
                                    ),
                                    Text(
                                      'MK${item.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'MK${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
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
                
                // Contact Information Section
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
                              hintText: 'Enter phone number (10 digits)',
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
                    onPressed: _isLoading ? null : _placeOrder,
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