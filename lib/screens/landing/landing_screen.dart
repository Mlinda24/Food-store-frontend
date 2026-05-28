import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // Appetising meals with food images and ratings (Grilled Chambo and Nsima with Beef removed)
  final List<Map<String, dynamic>> _featuredMeals = const [
    {
      'id': '3',
      'name': 'Spicy Chicken Wings',
      'rating': 4.7,
      'imageUrl':
          'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg?w=400',
    },
    {
      'id': '5',
      'name': 'Beef Burger',
      'rating': 4.5,
      'imageUrl':
          'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?w=400',
    },
    {
      'id': '6',
      'name': 'Grilled Chicken',
      'rating': 4.8,
      'imageUrl':
          'https://images.pexels.com/photos/616353/pexels-photo-616353.jpeg?w=400',
    },
    {
      'id': '7',
      'name': 'Fish and Chips',
      'rating': 4.3,
      'imageUrl':
          'https://images.pexels.com/photos/699953/pexels-photo-699953.jpeg?w=400',
    },
    {
      'id': '9',
      'name': 'Margherita Pizza',
      'rating': 4.6,
      'imageUrl':
          'https://images.pexels.com/photos/803290/pexels-photo-803290.jpeg?w=400',
    },
    {
      'id': '10',
      'name': 'Vegetable Pasta',
      'rating': 4.4,
      'imageUrl':
          'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Login Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Section (Not Clickable)
                  IgnorePointer(
                    ignoring: true,
                    child: Row(
                      children: [
                        // Logo Image
                        Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryButtonGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        // Brand Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delicious meals at your door',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        minimumSize: const Size(70, 36),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Hero Section - Catchy words (Not Clickable but visible)
            IgnorePointer(
              ignoring: true,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGlowGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      ' Hungry? We\'ve Got This',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order from the best restaurants in town',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureChip(
                            context, 'Fast Delivery', Icons.delivery_dining),
                        _buildFeatureChip(
                            context, 'Best Prices', Icons.money_off),
                        _buildFeatureChip(
                            context, '12/7 Service', Icons.access_time),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Meals Grid (Scrollable but not clickable)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _featuredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _featuredMeals[index];
                      return IgnorePointer(
                        ignoring: true,
                        child: _buildMealCard(context, meal),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: AppTheme.primaryRed),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final String name = (meal['name'] ?? 'Unknown').toString();
    final double rating = (meal['rating'] ?? 0.0) as double;
    final String imageUrl = (meal['imageUrl'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.fastfood,
                          size: 40,
                          color: AppTheme.primaryRed.withOpacity(0.5),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                      color: AppTheme.primaryRed.withOpacity(0.5),
                    ),
                  ),
          ),
          // Meal Details
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '(${(rating * 20).toInt()})',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
