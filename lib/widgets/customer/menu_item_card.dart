import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItem = cartProvider.items.firstWhere(
          (cartItem) => cartItem.menuItemId == item.id,
          orElse: () => CartItem(
            menuItemId: '',
            name: '',
            quantity: 0,
            price: 0,
          ),
        );
        final quantity = cartItem.quantity;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.getElevatedPanelColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fastfood,
                  size: 35,
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MK${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () {
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
                      },
                      icon: Icon(
                        quantity == 0 ? Icons.add_shopping_cart : Icons.add,
                        size: 16,
                        color: AppTheme.primaryRed,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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