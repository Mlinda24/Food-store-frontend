import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final stats = driverProvider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total Earnings Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MK${stats.totalEarnings.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.rating} Rating',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.delivery_dining, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.totalDeliveries} Deliveries',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Earnings Breakdown
          const Text(
            'Earnings Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildBreakdownItem(
            title: 'Today\'s Earnings',
            amount: stats.todayEarnings,
            icon: Icons.today,
            color: AppTheme.primaryRed,
          ),
          _buildBreakdownItem(
            title: 'This Week',
            amount: stats.todayEarnings * 7,
            icon: Icons.calendar_view_week,  // FIXED: Changed from Icons.week to Icons.calendar_view_week
            color: AppTheme.warning,
          ),
          _buildBreakdownItem(
            title: 'This Month',
            amount: stats.todayEarnings * 30,
            icon: Icons.calendar_month,
            color: AppTheme.success,
          ),
          
          const SizedBox(height: 24),
          
          // Recent Transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildTransactionItem('ORD-001', 450, 'Today, 12:30 PM'),
          _buildTransactionItem('ORD-002', 380, 'Today, 11:15 AM'),
          _buildTransactionItem('ORD-003', 520, 'Yesterday, 2:00 PM'),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Text(
            'MK${amount.toInt()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String orderId, int amount, String date) {
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
            child: Icon(Icons.receipt, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'MK$amount',
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