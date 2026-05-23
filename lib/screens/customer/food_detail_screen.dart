import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class FoodDetailScreen extends StatelessWidget {
  final Map<String, dynamic> food;

  const FoodDetailScreen({super.key, required this.food});

  // Get popular meals from the same restaurant
  List<Map<String, dynamic>> _getPopularMealsFromSameRestaurant() {
    // All menu items organized by restaurant
    final restaurantMenus = {
      '1': [ // Sushi Master
        {'id': '101', 'name': 'California Roll', 'description': 'Crab, avocado, cucumber', 'price': 'MK3,500', 'rating': 4.2, 'reviews': 89, 'restaurant': 'Sushi Master', 'restaurantId': '1', 'isPopular': true},
        {'id': '102', 'name': 'Spicy Tuna Roll', 'description': 'Tuna with spicy mayo', 'price': 'MK4,200', 'rating': 4.5, 'reviews': 156, 'restaurant': 'Sushi Master', 'restaurantId': '1', 'isPopular': true},
        {'id': '103', 'name': 'Dragon Roll', 'description': 'Eel, avocado, cucumber', 'price': 'MK5,500', 'rating': 4.7, 'reviews': 234, 'restaurant': 'Sushi Master', 'restaurantId': '1', 'isPopular': true},
        {'id': '105', 'name': 'Tempura Roll', 'description': 'Shrimp tempura with avocado', 'price': 'MK4,800', 'rating': 4.6, 'reviews': 178, 'restaurant': 'Sushi Master', 'restaurantId': '1', 'isPopular': true},
      ],
      '2': [ // Luspernando Food Hub
        {'id': '201', 'name': 'Nsima with Beef', 'description': 'Traditional nsima with beef stew', 'price': 'MK5,000', 'rating': 4.3, 'reviews': 67, 'restaurant': 'Luspernando Food Hub', 'restaurantId': '2', 'isPopular': true},
        {'id': '202', 'name': 'Chambo Fish', 'description': 'Grilled chambo with vegetables', 'price': 'MK7,500', 'rating': 4.6, 'reviews': 123, 'restaurant': 'Luspernando Food Hub', 'restaurantId': '2', 'isPopular': true},
        {'id': '204', 'name': 'Chicken Stew', 'description': 'Tender chicken in rich tomato sauce', 'price': 'MK4,500', 'rating': 4.4, 'reviews': 89, 'restaurant': 'Luspernando Food Hub', 'restaurantId': '2', 'isPopular': true},
      ],
      '3': [ // BossMan
        {'id': '301', 'name': 'Double Cheeseburger', 'description': 'Two beef patties with cheese', 'price': 'MK6,500', 'rating': 4.4, 'reviews': 112, 'restaurant': 'BossMan', 'restaurantId': '3', 'isPopular': true},
        {'id': '302', 'name': 'BBQ Chicken Wings', 'description': 'Grilled wings with BBQ sauce', 'price': 'MK4,500', 'rating': 4.2, 'reviews': 78, 'restaurant': 'BossMan', 'restaurantId': '3', 'isPopular': true},
        {'id': '304', 'name': 'Milkshake', 'description': 'Creamy vanilla milkshake', 'price': 'MK2,500', 'rating': 4.5, 'reviews': 67, 'restaurant': 'BossMan', 'restaurantId': '3', 'isPopular': true},
        {'id': '305', 'name': 'Chicken Burger', 'description': 'Grilled chicken with lettuce', 'price': 'MK4,500', 'rating': 4.3, 'reviews': 89, 'restaurant': 'BossMan', 'restaurantId': '3', 'isPopular': true},
      ],
    };

    final restaurantId = food['restaurantId'].toString();
    final allItems = restaurantMenus[restaurantId] ?? [];
    
    // Filter popular items and exclude the current food item
    return allItems.where((item) => 
      item['isPopular'] == true && 
      item['id'] != food['id']
    ).toList();
  }

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final menuItem = MenuItem(
      id: item['id'],
      restaurantId: item['restaurantId'],
      name: item['name'],
      description: item['description'],
      price: double.parse(item['price'].replaceAll('MK', '').replaceAll(',', '')),
      image: '',
      category: '',
      isAvailable: true,
    );
    cartProvider.addItem(menuItem, restaurantId: item['restaurantId'], restaurantName: item['restaurant']);
    
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popularMeals = _getPopularMealsFromSameRestaurant();
    
    void addCurrentToCart() {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final menuItem = MenuItem(
        id: food['id'],
        restaurantId: food['restaurantId'],
        name: food['name'],
        description: food['description'],
        price: double.parse(food['price'].replaceAll('MK', '').replaceAll(',', '')),
        image: '',
        category: '',
        isAvailable: true,
      );
      cartProvider.addItem(menuItem, restaurantId: food['restaurantId'], restaurantName: food['restaurant']);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food['name']} added to cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.success,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          food['name'],
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                gradient: AppTheme.cardGlowGradient(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 100,
                  color: AppTheme.getMutedTextColor(context),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name and Rating Row - Fixed overflow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          food['name'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: AppTheme.yellow),
                            const SizedBox(width: 2),
                            Text(
                              food['rating'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getPrimaryTextColor(context),
                              ),
                            ),
                            if (food.containsKey('reviews'))
                              Text(
                                ' (${food['reviews']})',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.getSecondaryTextColor(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Restaurant Info
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 16,
                            color: AppTheme.getMutedTextColor(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            food['restaurant'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppTheme.primaryRed,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
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
                  
                  // Popular Items Section
                  if (popularMeals.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Popular from ${food['restaurant']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getPrimaryTextColor(context),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 260,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularMeals.length,
                            itemBuilder: (context, index) {
                              final item = popularMeals[index];
                              return GestureDetector(
                                onTap: () {
                                  _navigateToFoodDetail(context, item);
                                },
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.cardGlowGradient(context),
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
                                        height: 110,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppTheme.getSurfaceColor(context),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.fastfood,
                                            size: 40,
                                            color: AppTheme.getMutedTextColor(context),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Restaurant Name
                                            Text(
                                              item['restaurant'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.getSecondaryTextColor(context),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            // Food Name
                                            Text(
                                              item['name'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.getPrimaryTextColor(context),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Rating and Price Row
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, size: 10, color: AppTheme.yellow),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      item['rating'].toString(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppTheme.getSecondaryTextColor(context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  item['price'],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryRed,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // Add to Cart Button
                                            Container(
                                              width: double.infinity,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: AppTheme.getSurfaceColor(context),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: TextButton(
                                                onPressed: () {
                                                  _addToCart(context, item);
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(0, 28),
                                                ),
                                                child: Text(
                                                  'Add to Cart',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.primaryRed,
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
                      ],
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