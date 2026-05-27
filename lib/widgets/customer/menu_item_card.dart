import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';
import '../../config/theme.dart';

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

  String _getImageUrl() {
    if (item.image.isEmpty) return '';
    String imageStr = item.image;
    if (imageStr.startsWith('http')) return imageStr;
    if (imageStr.startsWith('/media/'))
      return 'http://192.168.137.1:8000$imageStr';
    return 'http://192.168.137.1:8000/media/$imageStr';
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      await cartProvider.addItem(
        item,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        quantity: 1,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${item.name} to cart'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = _getImageUrl();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.deepCrimson.withOpacity(0.3),
        ),
      ),
      color: AppTheme.getCardColor(context),
      child: InkWell(
        onTap: () {
          final itemData = {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'price': 'MK${item.price.toStringAsFixed(0)}',
            'price_value': item.price,
            'image': imageUrl,
            'restaurant': restaurantName,
            'restaurantId': restaurantId,
            'category': item.category,
            'is_available': item.isAvailable,
          };
          // context.push('/food-detail', extra: itemData);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with availability overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.cardGlowGradient(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: AppTheme.getMutedTextColor(context),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.cardGlowGradient(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGlowGradient(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              size: 40,
                              color: AppTheme.getMutedTextColor(context),
                            ),
                          ),
                  ),
                  if (!item.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Details — use Expanded + intrinsic height, no fixed stretching
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // FIX: was missing, caused stretch
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getPrimaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 12,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurantName,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // FIX
                          children: [
                            Text(
                              'MK${item.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                            if (item.price > 0)
                              Text(
                                'per serving',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.getMutedTextColor(context),
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: item.isAvailable
                              ? () => _addToCart(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isAvailable
                                ? AppTheme.primaryRed
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                            minimumSize: const Size(90, 36),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_shopping_cart,
                                size: 16,
                                color: item.isAvailable
                                    ? Colors.white
                                    : Colors.grey[300],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: item.isAvailable
                                      ? Colors.white
                                      : Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
