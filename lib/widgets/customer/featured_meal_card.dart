import 'package:flutter/material.dart';
import '../../config/theme.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, // Reduced from 150
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container - Reduced height
            Container(
              height: 100, // Reduced from 110
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.elevatedPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.fastfood,
                  size: 35, // Reduced from 45
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            // Rating Row
            Row(
              children: [
                const Icon(Icons.star, size: 10, color: Color(0xFFFACC15)), // Reduced from 12
                const SizedBox(width: 2),
                Text(
                  meal['rating'].toString(),
                  style: const TextStyle(
                    fontSize: 10, // Reduced from 11
                    color: Color(0xFFC9C9C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3), // Reduced from 4
            // Name
            Text(
              meal['name'],
              style: const TextStyle(
                fontSize: 12, // Reduced from 13
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Description
            Text(
              meal['description'],
              style: const TextStyle(
                fontSize: 9, // Reduced from 10
                color: Color(0xFF8A8A8A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              meal['price'],
              style: const TextStyle(
                fontSize: 12, // Reduced from 13
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF2E2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
