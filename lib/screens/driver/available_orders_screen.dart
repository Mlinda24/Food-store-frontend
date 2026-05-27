import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).refreshAvailableOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final orders = driverProvider.availableOrders;

    return RefreshIndicator(
      onRefresh: () => driverProvider.refreshAvailableOrders(),
      child: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: AppTheme.mutedText),
                  const SizedBox(height: 16),
                  Text(
                    'No available orders',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, driverProvider);
              },
            ),
    );
  }

  Widget _buildOrderCard(order, DriverProvider driverProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'MK${order.earnings.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.customerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 4),
              Text(
                '${order.estimatedTime} min',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.pedal_bike, size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 4),
              Text(
                '${order.distance.toStringAsFixed(1)} km',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    driverProvider.declineOrder(order);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order declined')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await driverProvider.acceptOrder(order.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order accepted!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}