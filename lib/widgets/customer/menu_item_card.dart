import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String restaurantId;
  final String restaurantName;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = item.image.isNotEmpty ? item.image : '';
    final isAvailable = item.isAvailable;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItem = cartProvider.items.firstWhere(
          (cartItem) => cartItem.menuItemId == item.id,
          orElse: () => CartItem(
            menuItemId: '',
            name: '',
            quantity: 0,
            price: 0,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
          ),
        );
        final quantity = cartItem.quantity;

        return Opacity(
          opacity: isAvailable ? 1.0 : 0.6,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGlowGradient(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAvailable 
                    ? AppTheme.deepCrimson.withOpacity(0.3)
                    : AppTheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 70,
                            height: 70,
                            color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 70,
                            height: 70,
                            color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                            child: Icon(
                              Icons.fastfood,
                              size: 30,
                              color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                            ),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                          child: Icon(
                            Icons.fastfood,
                            size: 30,
                            color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                              ),
                            ),
                          ),
                          if (!isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Unavailable',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MK${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity Controls
                if (isAvailable)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        if (quantity > 0)
                          IconButton(
                            onPressed: () {
                              cartProvider.updateQuantity(item.id, quantity - 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} removed from cart'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppTheme.warning,
                                ),
                              );
                            },
                            icon: const Icon(Icons.remove, size: 16, color: AppTheme.primaryRed),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (quantity > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () {
                            if (isAvailable) {
                              cartProvider.addItem(
                                item,
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppTheme.success,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            quantity == 0 ? Icons.add_shopping_cart : Icons.add,
                            size: 16,
                            color: isAvailable ? AppTheme.primaryRed : AppTheme.mutedText,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: AppTheme.error),
                        const SizedBox(width: 6),
                        Text(
                          'Not Available',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}