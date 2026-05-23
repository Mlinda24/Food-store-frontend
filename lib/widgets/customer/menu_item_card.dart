import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  String _getImageUrl() {
    if (item.image.isEmpty) return '';
    String imageStr = item.image;
    if (imageStr.startsWith('http')) return imageStr;
    if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
    return 'http://127.0.0.1:8000/media/$imageStr';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    
    print('🎨 Building MenuItemCard for: ${item.name}');
    print('   Image URL: $imageUrl');
    print('   Price: ${item.price}');
    print('   Available: ${item.isAvailable}');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Image load error: $error');
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, size: 40),
                    ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MK${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      if (item.isAvailable)
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return IconButton(
                              onPressed: () async {
                                print('🛒 Adding to cart: ${item.name}');
                                await cartProvider.addItem(
                                  item,
                                  restaurantId: restaurantId,
                                  restaurantName: restaurantName,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${item.name} to cart'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              color: Colors.red,
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}