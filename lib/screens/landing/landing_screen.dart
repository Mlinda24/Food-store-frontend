import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // Appetising meals with food images (ratings removed)
  final List<Map<String, dynamic>> _featuredMeals = const [
    {
      'id': '3',
      'name': 'Spicy Chicken Wings',
      'imageUrl':
          'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg?w=400',
    },
    {
      'id': '5',
      'name': 'Beef Burger',
      'imageUrl':
          'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?w=400',
    },
    {
      'id': '6',
      'name': 'Grilled Chicken',
      'imageUrl':
          'https://images.pexels.com/photos/616353/pexels-photo-616353.jpeg?w=400',
    },
    {
      'id': '7',
      'name': 'Fish and Chips',
      'imageUrl':
          'https://images.pexels.com/photos/699953/pexels-photo-699953.jpeg?w=400',
    },
    {
      'id': '9',
      'name': 'Margherita Pizza',
      'imageUrl':
          'https://images.pexels.com/photos/803290/pexels-photo-803290.jpeg?w=400',
    },
    {
      'id': '10',
      'name': 'Vegetable Pasta',
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
                      ' Hungry? We\'ve Got This! ',
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
                            context, '24/7 Service', Icons.access_time),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Meals Grid (Scrollable and clickable - leads to login)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate dynamic card height based on screen width
                  final cardWidth = (constraints.maxWidth - 24) /
                      2; // 2 columns with 12 spacing
                  final imageHeight =
                      cardWidth * 0.9; // Make image proportional

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisExtent:
                          imageHeight + 50, // Image height + text area
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _featuredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _featuredMeals[index];
                      return _buildMealCard(context, meal);
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
    final String imageUrl = (meal['imageUrl'] ?? '').toString();

    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
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
          mainAxisSize: MainAxisSize.min, // Important: Prevents extra space
          children: [
            // Meal Image - Fixed height relative to card
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
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
                          height: 140,
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
                      height: 140,
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
            // Meal Details - Fixed padding
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
