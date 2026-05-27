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
    if (raw.startsWith('/media/')) return 'http://192.168.137.1:8000$raw';
    if (raw.startsWith('/')) return 'http://192.168.137.1:8000$raw';
    return 'http://192.168.137.1:8000/media/$raw';
  }

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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Remove Item',
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Are you sure you want to remove ${item.name}?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    TextStyle(color: AppTheme.getSecondaryTextColor(context))),
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
        content: Text('Are you sure you want to clear your entire cart?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    TextStyle(color: AppTheme.getSecondaryTextColor(context))),
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

  Widget _buildItemImage(BuildContext context, String? rawImage, bool isDark) {
    final url = _resolveImageUrl(rawImage);
    final placeholder = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.fastfood,
          size: 28,
          color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
    );

    if (url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          width: 60,
          height: 60,
          color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, _, __) => placeholder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // ── Empty state ──────────────────────────────────────────────────────
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
                    color: isDark
                        ? AppTheme.darkMutedText
                        : AppTheme.lightMutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items from restaurants to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkMutedText
                          : AppTheme.lightMutedText,
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

        // ── Cart with items ──────────────────────────────────────────────────
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
              // ── Restaurant info banner ───────────────────────────────────
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
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurface
                              : AppTheme.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.restaurant,
                            color: isDark
                                ? AppTheme.darkMutedText
                                : AppTheme.lightMutedText),
                      ),
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
                                color: isDark
                                    ? AppTheme.darkPrimaryText
                                    : AppTheme.lightPrimaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Delivery: MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.darkSecondaryText
                                    : AppTheme.lightSecondaryText,
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
                          _buildItemImage(context, item.image, isDark),
                          const SizedBox(width: 12),
                          // Item details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkPrimaryText
                                        : AppTheme.lightPrimaryText,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'MK${item.price.toStringAsFixed(0)} each',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppTheme.getSecondaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quantity controls
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSurface
                                  : AppTheme.lightBackground,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                      context, item, item.quantity - 1),
                                  icon: const Icon(Icons.remove, size: 18),
                                  color: AppTheme.primaryRed,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkPrimaryText
                                        : AppTheme.lightPrimaryText,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                      context, item, item.quantity + 1),
                                  icon: const Icon(Icons.add, size: 18),
                                  color: AppTheme.primaryRed,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            onPressed: () => _removeItem(context, item),
                            icon: Icon(Icons.delete_outline,
                                size: 20, color: AppTheme.error),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cartProvider.itemCount} items)',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : AppTheme.lightSecondaryText,
                          ),
                        ),
                        Text(
                          'MK${cartProvider.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : AppTheme.lightSecondaryText,
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
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : AppTheme.lightSecondaryText,
                          ),
                        ),
                        Text(
                          'MK${cartProvider.deliveryFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppTheme.darkSecondaryText
                                : AppTheme.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    if (!cartProvider.canDeliver)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                size: 16, color: AppTheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Delivery not available to your location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkPrimaryText
                                : AppTheme.lightPrimaryText,
                          ),
                        ),
                        Text(
                          'MK${cartProvider.total.toStringAsFixed(0)}',
                          style: const TextStyle(
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
                        onPressed: cartProvider.canDeliver
                            ? () => context.go('/checkout')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cartProvider.canDeliver
                              ? AppTheme.primaryRed
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          cartProvider.canDeliver
                              ? 'Proceed to Checkout'
                              : 'Delivery Not Available',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
