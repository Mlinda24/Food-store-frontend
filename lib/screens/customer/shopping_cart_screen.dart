import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  void _updateQuantity(BuildContext context, CartItem item, int newQuantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (newQuantity <= 0) {
      cartProvider.removeItem(item.menuItemId);
    } else {
      cartProvider.updateQuantity(item.menuItemId, newQuantity);
    }
  }

  void _removeItem(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Remove Item', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Are you sure you want to remove ${item.name}?', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              cartProvider.removeItem(item.menuItemId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed from cart'),
                  backgroundColor: AppTheme.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Remove'),
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
                  const SizedBox(height: 8),
                  Text(
                    'Add items from restaurants to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 200,
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

        // Group items by restaurant using restaurantName from CartItem
        final Map<String, List<CartItem>> groupedItems = {};
        for (var item in cartProvider.items) {
          final restaurantKey = item.restaurantId;
          if (!groupedItems.containsKey(restaurantKey)) {
            groupedItems[restaurantKey] = [];
          }
          groupedItems[restaurantKey]!.add(item);
        }

        // Calculate total without tax
        final totalWithoutTax = cartProvider.subtotal + cartProvider.deliveryFee;

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
          body: Column(
            children: [
              // Cart Items Grouped by Restaurant
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedItems.keys.length,
                  itemBuilder: (context, restaurantIndex) {
                    final restaurantId = groupedItems.keys.elementAt(restaurantIndex);
                    final restaurantItems = groupedItems[restaurantId]!;
                    final restaurantName = restaurantItems.first.restaurantName;
                    
                    // Calculate restaurant subtotal
                    final restaurantSubtotal = restaurantItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGlowGradient(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.restaurant, color: AppTheme.primaryRed, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurantName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.getPrimaryTextColor(context),
                                      ),
                                    ),
                                    Text(
                                      '${restaurantItems.length} items • MK${restaurantSubtotal.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Items from this restaurant
                        ...restaurantItems.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGlowGradient(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  size: 30,
                                  color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'MK${item.price.toStringAsFixed(0)} each',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _updateQuantity(context, item, item.quantity - 1),
                                      icon: const Icon(Icons.remove, size: 18),
                                      color: AppTheme.primaryRed,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _updateQuantity(context, item, item.quantity + 1),
                                      icon: const Icon(Icons.add, size: 18),
                                      color: AppTheme.primaryRed,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _removeItem(context, item),
                                icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                              ),
                            ],
                          ),
                        )).toList(),
                        
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              
              // Order Summary (without tax)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cartProvider.itemCount} items)',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                          ),
                        ),
                        Text(
                          'MK${cartProvider.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Fee',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                          ),
                        ),
                        Text(
                          'MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    // Tax row removed
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                          ),
                        ),
                        Text(
                          'MK${totalWithoutTax.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}