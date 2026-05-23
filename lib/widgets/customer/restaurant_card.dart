import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = restaurant['image'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGlowGradient(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.deepCrimson.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightBackground,
                        child: const Icon(Icons.restaurant,
                            size: 30, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightBackground,
                        child: const Icon(Icons.restaurant,
                            size: 30, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: isDark
                          ? AppTheme.darkSurface
                          : AppTheme.lightBackground,
                      child: const Icon(Icons.restaurant,
                          size: 30, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'] ?? 'Restaurant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkPrimaryText
                          : AppTheme.lightPrimaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppTheme.yellow),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['rating']?.toString() ?? '4.5',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkPrimaryText
                              : AppTheme.lightPrimaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 12, color: AppTheme.mutedText),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          restaurant['time'] ?? '20-30 min',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkMutedText
                                : AppTheme.lightMutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: (restaurant['is_open'] ?? true)
                              ? AppTheme.success
                              : AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (restaurant['is_open'] ?? true) ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 10,
                          color: (restaurant['is_open'] ?? true)
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant['cuisine'] ?? 'Various Cuisines',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.darkSecondaryText
                          : AppTheme.lightSecondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.mutedText, size: 20),
          ],
        ),
      ),
    );
  }
}
