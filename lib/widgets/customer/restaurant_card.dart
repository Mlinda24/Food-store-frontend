import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.restaurant, size: 30, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText)),
                  const SizedBox(height: 4),
                  Text(restaurant['cuisine'], style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                      const SizedBox(width: 4),
                      Text('${restaurant['rating']} (${restaurant['reviews']})', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                      const SizedBox(width: 4),
                      Text(restaurant['time'], style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
          ],
        ),
      ),
    );
  }
}