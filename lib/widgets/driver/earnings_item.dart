import 'package:flutter/material.dart';
import '../../config/theme.dart';

class EarningsItem extends StatelessWidget {
  final int index;

  const EarningsItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final earnings = [
      {'order': 'ORD-001', 'amount': 'MK450', 'time': '12:30 PM', 'restaurant': 'Luigi\'s Pizza'},
      {'order': 'ORD-002', 'amount': 'MK380', 'time': '11:15 AM', 'restaurant': 'Burger King'},
      {'order': 'ORD-003', 'amount': 'MK520', 'time': '10:00 AM', 'restaurant': 'Sushi Master'},
    ];
    final earning = earnings[index];

    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning['restaurant']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ${earning['order']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
                Text(
                  earning['time']!,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            earning['amount']!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}