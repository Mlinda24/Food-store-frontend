import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  /// Ensures any image path (relative or absolute) becomes a full http URL.
  String _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('/media/')) return 'http://127.0.0.1:8000$raw';
    if (raw.startsWith('/')) return 'http://127.0.0.1:8000$raw';
    return 'http://127.0.0.1:8000/media/$raw';
  }

  void _updateQuantity(BuildContext context, CartItem item, int newQuantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (newQuantity <= 0) {
      _showRemoveConfirmation(context, item);
    } else {
      cartProvider.updateQuantity(item.menuItemId, newQuantity);
    }
  }

  void _showRemoveConfirmation(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Remove Item',
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Remove ${item.name} from cart?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false)
                  .removeItem(item.menuItemId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed from cart'),
                  backgroundColor: AppTheme.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Clear Cart',
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Remove all items from your cart?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: AppTheme.warning),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantImage(BuildContext context, CartProvider cartProvider) {
    final imageUrl = cartProvider.restaurantImageUrl;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryButtonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryButtonGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cartProvider.restaurantName![0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryButtonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            cartProvider.restaurantName![0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildItemImage(BuildContext context, CartItem item, bool isDark) {
    // Try multiple sources for the image URL
    String imageUrl = '';
    
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      imageUrl = item.imageUrl!;
      print('🖼️ Using item.imageUrl: $imageUrl');
    } else if (item.image != null && item.image!.isNotEmpty) {
      imageUrl = _resolveImageUrl(item.image);
      print('🖼️ Using item.image resolved: $imageUrl');
    } else {
      print('⚠️ No image URL for item: ${item.name}');
    }
    
    final placeholder = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryButtonGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.fastfood,
          size: 28,
          color: Colors.white),
    );

    if (imageUrl.isEmpty) {
      return placeholder;
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, _) => placeholder,
        errorWidget: (context, url, error) {
          print('❌ Failed to load image: $url');
          return placeholder;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Debug: Print all cart items with their image URLs
        print('📋 Cart has ${cartProvider.items.length} items:');
        for (var item in cartProvider.items) {
          print('   - ${item.name}: imageUrl=${item.imageUrl}, image=${item.image}');
        }
        
        // ── Empty state ──────────────────────────────────────────────────────
        if (!cartProvider.hasItems) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            appBar: AppBar(
              title: const Text('My Cart'),
              backgroundColor: AppTheme.getBackgroundColor(context),
              foregroundColor: AppTheme.getPrimaryTextColor(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: AppTheme.getPrimaryTextColor(context)),
                onPressed: () => context.go('/home'),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.getMutedTextColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items from restaurants to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getMutedTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Browse Restaurants'),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Cart with items ──────────────────────────────────────────────────
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          appBar: AppBar(
            title: const Text('My Cart'),
            backgroundColor: AppTheme.getBackgroundColor(context),
            foregroundColor: AppTheme.getPrimaryTextColor(context),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: AppTheme.getPrimaryTextColor(context)),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () => _clearCart(context),
                tooltip: 'Clear Cart',
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Restaurant info banner with image ─────────────────────────
              if (cartProvider.restaurantName != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      // Restaurant image
                      _buildRestaurantImage(context, cartProvider),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartProvider.restaurantName!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getPrimaryTextColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Delivery: MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSecondaryTextColor(context),
                              ),
                            ),
                            if (!cartProvider.canDeliver)
                              Text(
                                'Outside delivery zone',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Items list ───────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGlowGradient(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          // Item image
                          _buildItemImage(context, item, isDark),
                          const SizedBox(width: 12),
                          // Item details - reduced font size to prevent overflow
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getPrimaryTextColor(context),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MK${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quantity controls
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                      context, item, item.quantity - 1),
                                  icon: const Icon(Icons.remove, size: 16),
                                  color: AppTheme.primaryRed,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getPrimaryTextColor(context),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                      context, item, item.quantity + 1),
                                  icon: const Icon(Icons.add, size: 16),
                                  color: AppTheme.primaryRed,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            onPressed: () => _showRemoveConfirmation(context, item),
                            icon: Icon(Icons.delete_outline,
                                size: 18, color: AppTheme.error),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Order summary + checkout ─────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cartProvider.itemCount})',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          'MK${cartProvider.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Fee',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          'MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    if (!cartProvider.canDeliver)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                size: 14, color: AppTheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Delivery not available',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                        Text(
                          'MK${cartProvider.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cartProvider.canDeliver
                            ? () => context.push('/checkout')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cartProvider.canDeliver
                              ? AppTheme.primaryRed
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          cartProvider.canDeliver
                              ? 'Proceed to Checkout'
                              : 'Delivery Not Available',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
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