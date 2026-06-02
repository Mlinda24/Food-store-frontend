import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/delivery_request.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.local_pizza, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          const Text('New Delivery Request'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Restaurant: ${request.restaurantName}'),
          const SizedBox(height: 8),
          Text('Customer: ${request.customerName}'),
          const SizedBox(height: 8),
          Text('Distance: ${request.distance}'),
          const SizedBox(height: 8),
          Text('Est. Time: ${request.estimatedTime}'),
          const SizedBox(height: 8),
          Text('Earnings: MK${request.earnings.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: onDecline,
            child:
                const Text('Decline', style: TextStyle(color: AppTheme.error))),
        ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Accept')),
      ],
    );
  }
}
