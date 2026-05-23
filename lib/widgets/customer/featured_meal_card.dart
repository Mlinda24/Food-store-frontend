import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class FeaturedMealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onTap;

  const FeaturedMealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.deepCrimson.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 50,
                  color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Restaurant Name
            Text(
              meal['restaurant'],
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Food Name
            Text(
              meal['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText,
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
                    const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                    const SizedBox(width: 2),
                    Text(
                      meal['rating'].toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
                Text(
                  meal['price'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}