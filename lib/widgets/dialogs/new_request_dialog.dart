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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cardBackground, AppTheme.secondaryBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                size: 32,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'New Delivery Request!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Order #${request.id}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.store, request.restaurantName),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on, request.restaurantAddress),
                  const Divider(),
                  _infoRow(Icons.person, request.customerName),
                  const SizedBox(height: 8),
                  _infoRow(Icons.home, request.deliveryAddress),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.fastfood, size: 16, color: AppTheme.mutedText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.items.isNotEmpty ? request.items : 'Items will be shown',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: AppTheme.mutedText),
                      const SizedBox(width: 8),
                      Text(
                        '${request.estimatedTime} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.attach_money, size: 16, color: AppTheme.primaryRed),
                      const SizedBox(width: 4),
                      Text(
                        'MK${request.earnings.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isNotEmpty ? text : 'Not provided',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}