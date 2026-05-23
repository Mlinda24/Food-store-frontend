import 'package:flutter/material.dart';
import '../../config/theme.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.elevatedPanel,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, size: 30, color: Color(0xFF8A8A8A)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant['cuisine'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFFC9C9C9)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFACC15)),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant['rating']} (${restaurant['reviews']})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFC9C9C9)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF8A8A8A)),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['time'],
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8A8A8A)),
          ],
        ),
      ),
    );
  }
}