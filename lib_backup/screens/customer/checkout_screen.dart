import 'package:flutter/material.dart';
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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

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

    final order = cartProvider.createOrder(
      authProvider.currentUser!.id,
      _addressController.text,
      _instructionsController.text.isEmpty ? null : _instructionsController.text,
    );

    final placedOrder = await orderProvider.placeOrder(order);
    
    setState(() {
      _isLoading = false;
    });

    if (placedOrder != null && mounted) {
      cartProvider.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go('/my-orders');
    }
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
                onPressed: () => context.pop(),
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

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
            foregroundColor: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.restaurant, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartProvider.restaurantName ?? 'Restaurant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Delivery: MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cart Items
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: Row(
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
                    );
                  },
                ),
                
                const Divider(
                  height: 32,
                  color: AppTheme.deepCrimson,
                ),
                
                // Phone Number Field
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    hintStyle: TextStyle(color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                    prefixIcon: Icon(Icons.phone_outlined, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Delivery Address
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                  decoration: InputDecoration(
                    hintText: 'Enter your delivery address',
                    hintStyle: TextStyle(color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                    prefixIcon: Icon(Icons.location_on_outlined, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                    ),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                // Special Instructions
                const Text(
                  'Special Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _instructionsController,
                  style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                  decoration: InputDecoration(
                    hintText: 'Any special requests?',
                    hintStyle: TextStyle(color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
                    ),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 24),
                
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${cartProvider.subtotal.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee:', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${cartProvider.deliveryFee.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax (10%):', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                          Text('MK${cartProvider.tax.toStringAsFixed(0)}', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
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
                            'MK${cartProvider.total.toStringAsFixed(0)}',
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
                Center(
                  child: Container(
                    width: 160,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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