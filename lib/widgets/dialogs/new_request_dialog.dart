import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/delivery_request.dart';
import '../driver/info_section.dart';

class NewRequestDialog extends StatelessWidget {
  final DeliveryRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const NewRequestDialog({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.getCardBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      title: Row(
        children: [
          Icon(Icons.delivery_dining, color: AppTheme.primaryRed),
          const SizedBox(width: 10),
          const Text('New Delivery Request', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoSection(
            icon: Icons.restaurant,
            title: 'Restaurant',
            subtitle: request.restaurantName,
            address: request.restaurantAddress,
          ),
          const SizedBox(height: 12),
          InfoSection(
            icon: Icons.home,
            title: 'Customer',
            subtitle: request.customerName,
            address: request.deliveryAddress,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getSecondaryBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_money, size: 20, color: AppTheme.primaryRed),
                const SizedBox(width: 8),
                Text('Earnings: MK${request.earnings.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                const Spacer(),
                if (request.distance.isNotEmpty) ...[
                  const Icon(Icons.route, size: 16, color: AppTheme.mutedText),
                  const SizedBox(width: 4),
                  Text(request.distance, style: const TextStyle(color: AppTheme.secondaryText)),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.timer, size: 16, color: AppTheme.mutedText),
                const SizedBox(width: 4),
                Text(request.estimatedTime, style: const TextStyle(color: AppTheme.secondaryText)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onDecline, child: const Text('Decline', style: TextStyle(color: AppTheme.error))),
        ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success), child: const Text('Accept')),
      ],
    );
  }
}