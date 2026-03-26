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
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.elevatedPanel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.fastfood, size: 45, color: Color(0xFF8A8A8A)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Color(0xFFFACC15)),
                const SizedBox(width: 4),
                Text(
                  meal['rating'].toString(),
                  style: const TextStyle(fontSize: 11, color: Color(0xFFC9C9C9)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              meal['name'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              meal['description'],
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              meal['price'],
              style: const TextStyle(
                fontSize: 13,
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