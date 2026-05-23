import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodDetailScreen({super.key, required this.food});

  // Sample similar items data
  final List<Map<String, dynamic>> _similarItems = const [
    {
      'id': '6',
      'name': 'Cheese Burger',
      'description': 'Juicy beef patty with melted cheese, lettuce, and tomato',
      'price': 'MK3,800',
      'rating': 4.2,
      'reviews': 95,
      'prepTime': '10-15 min',
      'restaurant': 'BossMan',
      'restaurantId': '3',
    },
    {
      'id': '7',
      'name': 'Chicken Caesar Salad',
      'description':
          'Fresh romaine lettuce, grilled chicken, parmesan, and Caesar dressing',
      'price': 'MK4,200',
      'rating': 4.4,
      'reviews': 78,
      'prepTime': '8-12 min',
      'restaurant': 'Luspernando Food Hub',
      'restaurantId': '2',
    },
    {
      'id': '8',
      'name': 'Margherita Pizza',
      'description': 'Fresh mozzarella, tomato sauce, and basil',
      'price': 'MK4,500',
      'rating': 4.6,
      'reviews': 234,
      'prepTime': '15-20 min',
      'restaurant': 'Chef Luigi\'s Kitchen',
      'restaurantId': '4',
    },
  ];

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final menuItem = MenuItem(
      id: item['id'],
      restaurantId: item['restaurantId'],
      name: item['name'],
      description: item['description'],
      price:
          double.parse(item['price'].replaceAll('MK', '').replaceAll(',', '')),
      image: '',
      category: '',
      isAvailable: true,
    );
    cartProvider.addItem(menuItem,
        restaurantId: item['restaurantId'], restaurantName: item['restaurant']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _navigateToFoodDetail(BuildContext context, Map<String, dynamic> item) {
    context.push('/food-detail', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    void addCurrentToCart() {
      final menuItem = MenuItem(
        id: food['id'],
        restaurantId: food['restaurantId'],
        name: food['name'],
        description: food['description'],
        price: double.parse(
            food['price'].replaceAll('MK', '').replaceAll(',', '')),
        image: food['image'] ?? '',
        category: '',
        isAvailable: true,
      );
      cartProvider.addItem(menuItem,
          restaurantId: food['restaurantId'],
          restaurantName: food['restaurant']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food['name']} added to cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.success,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          food['name'],
          style: const TextStyle(
            color: AppTheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: AppTheme.secondaryText,
                    onPressed: () {
                      if (cartProvider.hasItems) {
                        context.go('/checkout');
                      }
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image Placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 100,
                  color: AppTheme.mutedText,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppTheme.yellow),
                            const SizedBox(width: 4),
                            Text(
                              food['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            Text(
                              ' (${food['reviews']})',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Restaurant Info - Clickable
                  GestureDetector(
                    onTap: () {
                      // Navigate to restaurant details
                      context.pop();
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 16,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          food['restaurant'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppTheme.primaryRed,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price and Prep Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          food['price'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: AppTheme.mutedText),
                            const SizedBox(width: 4),
                            Text(
                              food['prepTime'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingredients
                  if (food.containsKey('ingredients'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (food['ingredients'] as List<String>)
                              .map((ingredient) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ingredient,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Add to Cart Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: addCurrentToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // You Might Also Like Section
                  const Text(
                    'You Might Also Like',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarItems.length,
                      itemBuilder: (context, index) {
                        final item = _similarItems[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to the selected food detail
                            _navigateToFoodDetail(context, item);
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.deepCrimson.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Container
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.elevatedPanel,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: AppTheme.mutedText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Restaurant Name
                                      Text(
                                        item['restaurant'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.secondaryText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      // Food Name
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryText,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Rating and Price Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  size: 10,
                                                  color: AppTheme.yellow),
                                              const SizedBox(width: 2),
                                              Text(
                                                item['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.secondaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            item['price'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Add to Cart Button for Similar Item
                                      Container(
                                        width: double.infinity,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            _addToCart(context, item);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 28),
                                          ),
                                          child: const Text(
                                            'Add to Cart',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
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
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
