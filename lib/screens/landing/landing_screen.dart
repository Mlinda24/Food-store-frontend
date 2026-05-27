import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // Appetising meals with food images and ratings
  final List<Map<String, dynamic>> _featuredMeals = const [
    {
      'id': '1',
      'name': 'Grilled Chambo',
      'rating': 4.9,
      'imageUrl': 'https://images.pexels.com/photos/462039/pexels-photo-462039.jpeg?w=400',
    },
    {
      'id': '2',
      'name': 'Nsima with Beef',
      'rating': 4.8,
      'imageUrl': 'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?w=400',
    },
    {
      'id': '3',
      'name': 'Spicy Chicken Wings',
      'rating': 4.7,
      'imageUrl': 'https://images.pexels.com/photos/60616/fried-chicken-chicken-fried-crunchy-60616.jpeg?w=400',
    },
    {
      'id': '4',
      'name': 'Zitumbuwa',
      'rating': 4.6,
      'imageUrl': 'https://images.pexels.com/photos/1092747/pexels-photo-1092747.jpeg?w=400',
    },
    {
      'id': '5',
      'name': 'Beef Burger',
      'rating': 4.5,
      'imageUrl': 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?w=400',
    },
    {
      'id': '6',
      'name': 'Grilled Chicken',
      'rating': 4.8,
      'imageUrl': 'https://images.pexels.com/photos/616353/pexels-photo-616353.jpeg?w=400',
    },
    {
      'id': '7',
      'name': 'Fish and Chips',
      'rating': 4.3,
      'imageUrl': 'https://images.pexels.com/photos/699953/pexels-photo-699953.jpeg?w=400',
    },
    {
      'id': '8',
      'name': 'Chicken Curry',
      'rating': 4.7,
      'imageUrl': 'https://images.pexels.com/photos/5639293/pexels-photo-5639293.jpeg?w=400',
    },
    {
      'id': '9',
      'name': 'Margherita Pizza',
      'rating': 4.6,
      'imageUrl': 'https://images.pexels.com/photos/803290/pexels-photo-803290.jpeg?w=400',
    },
    {
      'id': '10',
      'name': 'Vegetable Pasta',
      'rating': 4.4,
      'imageUrl': 'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Login Button only
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Login Button
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        minimumSize: const Size(80, 40),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Meals Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _featuredMeals.length,
                itemBuilder: (context, index) {
                  final meal = _featuredMeals[index];
                  return _buildMealCard(context, meal);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final String name = (meal['name'] ?? 'Unknown').toString();
    final double rating = (meal['rating'] ?? 0.0) as double;
    final String imageUrl = (meal['imageUrl'] ?? '').toString();
    
    return GestureDetector(
      onTap: () => context.push('/food-detail', extra: meal),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                            size: 50,
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                        size: 50,
                        color: AppTheme.primaryRed.withOpacity(0.5),
                      ),
                    ),
            ),
            // Meal Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${(rating * 20).toInt()}+ reviews)',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.getMutedTextColor(context),
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
    );
  }
}