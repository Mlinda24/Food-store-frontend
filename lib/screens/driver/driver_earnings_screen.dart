import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:foodie_express_mobile/services/driver_services.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  Map<String, dynamic>? _earnings;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Both calls in parallel
      final results = await Future.wait([
        DriverService.getEarningsSummary(),
        DriverService.getDeliveryHistory(),
      ]);

      final earningsData = results[0] as Map<String, dynamic>;
      // History returns { count, deliveries: [...] }
      final historyData = results[1] as Map<String, dynamic>;

      setState(() {
        _earnings = earningsData;
        _history = (historyData['deliveries'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }
    if (_error != null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
        const SizedBox(height: 16),
        Text('Failed to load earnings',
            style: TextStyle(color: AppTheme.secondaryText)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            _loadData();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
          child: const Text('Retry'),
        ),
      ]));
    }

    // Backend field names from earnings_summary view:
    final totalEarnings =
        double.tryParse(_earnings?['total_earnings']?.toString() ?? '0') ?? 0;
    final todayEarnings =
        double.tryParse(_earnings?['today_earnings']?.toString() ?? '0') ?? 0;
    final weekEarnings =
        double.tryParse(_earnings?['week_earnings']?.toString() ?? '0') ?? 0;
    final monthEarnings =
        double.tryParse(_earnings?['month_earnings']?.toString() ?? '0') ?? 0;
    // Backend was fixed: returns 'rating' (was 'average_rating')
    final rating =
        double.tryParse(_earnings?['rating']?.toString() ?? '0') ?? 0;
    final totalDeliveries = _earnings?['total_deliveries'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Total Earnings Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Text('Total Earnings',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('MK${totalEarnings.toInt()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text('$rating Rating',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 16),
                const Icon(Icons.delivery_dining,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text('$totalDeliveries Deliveries',
                    style: const TextStyle(color: Colors.white70)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          const Text('Earnings Breakdown',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText)),
          const SizedBox(height: 12),

          _buildBreakdownItem(
              title: 'Today\'s Earnings',
              amount: todayEarnings,
              icon: Icons.today,
              color: AppTheme.primaryRed),
          _buildBreakdownItem(
              title: 'This Week',
              amount: weekEarnings,
              icon: Icons.calendar_view_week,
              color: AppTheme.warning),
          _buildBreakdownItem(
              title: 'This Month',
              amount: monthEarnings,
              icon: Icons.calendar_month,
              color: AppTheme.success),

          const SizedBox(height: 24),
          const Text('Recent Transactions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText)),
          const SizedBox(height: 12),

          if (_history.isEmpty)
            Center(
                child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No delivery history yet',
                  style: TextStyle(color: AppTheme.secondaryText)),
            ))
          else
            // DeliveryAssignment fields: id, total_earning, assigned_at, restaurant_name
            ..._history.take(10).map((delivery) {
              final id = delivery['id']?.toString() ?? '-';
              // Backend field: total_earning (not 'earnings')
              final earning = double.tryParse(
                      delivery['total_earning']?.toString() ?? '0') ??
                  0;
              // Backend field: assigned_at (not 'created')
              final dateStr =
                  delivery['assigned_at'] ?? delivery['delivered_at'];
              final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
              final label = date != null ? _formatDate(date) : 'Unknown date';

              return _buildTransactionItem(id, earning.toInt(), label,
                  restaurantName: delivery['restaurant_name']);
            }),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inDays == 0)
      return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildBreakdownItem(
      {required String title,
      required double amount,
      required IconData icon,
      required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient as Gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: AppTheme.primaryText))),
        Text('MK${amount.toInt()}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildTransactionItem(String id, int amount, String date,
      {String? restaurantName}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt, size: 20, color: AppTheme.mutedText)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery #$id',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          if (restaurantName != null)
            Text(restaurantName,
                style: TextStyle(fontSize: 11, color: AppTheme.mutedText)),
          Text(date,
              style: TextStyle(fontSize: 11, color: AppTheme.secondaryText)),
        ])),
        Text('MK$amount',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed)),
      ]),
    );
  }
}
