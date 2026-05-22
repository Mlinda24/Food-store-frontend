import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/driver_analytics.dart';
import '../../services/mock_analytics_service.dart';

class DriverAnalyticsScreen extends StatefulWidget {
  const DriverAnalyticsScreen({super.key});

  @override
  State<DriverAnalyticsScreen> createState() => _DriverAnalyticsScreenState();
}

class _DriverAnalyticsScreenState extends State<DriverAnalyticsScreen> {
  late DriverAnalyticsData _analytics;
  String _selectedPeriod = 'week';
  int _selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    _analytics = MockAnalyticsService.getAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text(
          'Earnings Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        backgroundColor: AppTheme.mainBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryText),
            onPressed: () {
              setState(() {
                _loadAnalytics();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics refreshed!'), backgroundColor: AppTheme.success),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEarningsOverview(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildEarningsChart(),
            const SizedBox(height: 16),
            _buildPerformanceMetrics(),
            const SizedBox(height: 16),
            _buildRecentDeliveries(),
            const SizedBox(height: 16),
            _buildFeeBreakdownExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'MK${_analytics.totalEarnings.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('Today', 'MK${_analytics.todayEarnings.toInt()}'),
              _buildOverviewItem('This Week', 'MK${_analytics.weeklyEarnings.toInt()}'),
              _buildOverviewItem('This Month', 'MK${_analytics.monthlyEarnings.toInt()}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Avg. MK${_analytics.averagePerDelivery.toInt()} per delivery',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Week', 'week'),
          _buildPeriodButton('Month', 'month'),
          _buildPeriodButton('All Time', 'all'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.secondaryText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Container(
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
              const Text(
                'Earnings Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
              ),
              Row(
                children: [
                  _buildChartTypeButton('Weekly', 0),
                  const SizedBox(width: 8),
                  _buildChartTypeButton('Hourly', 1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _selectedChartIndex == 0 ? _buildWeeklyChart() : _buildHourlyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String label, int index) {
    final isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.secondaryText,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final maxEarnings = _analytics.weeklyBreakdown.values.reduce((a, b) => a > b ? a : b);
    if (maxEarnings == 0) return const Center(child: Text('No data available'));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _analytics.weeklyBreakdown.entries.map((entry) {
        final heightValue = (entry.value / maxEarnings) * 150;
        return Column(
          children: [
            Text(
              'MK${entry.value.toInt()}',
              style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText),
            ),
            const SizedBox(height: 4),
            Container(
              width: 35,
              height: heightValue,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart() {
    if (_analytics.hourlyBreakdown.isEmpty) {
      return const Center(child: Text('No hourly data available'));
    }
    
    final maxEarnings = _analytics.hourlyBreakdown.values.reduce((a, b) => a > b ? a : b);
    final hours = List.generate(24, (i) => i);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hours.map((hour) {
          final earnings = _analytics.hourlyBreakdown[hour] ?? 0;
          final heightValue = earnings > 0 ? (earnings / maxEarnings) * 150 : 5.0;
          
          return Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                if (earnings > 0)
                  Text(
                    'MK${earnings.toInt()}',
                    style: const TextStyle(fontSize: 8, color: AppTheme.secondaryText),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 25,
                  height: heightValue,
                  decoration: BoxDecoration(
                    color: earnings > 0 ? AppTheme.primaryRed : AppTheme.mutedText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$hour:00',
                  style: const TextStyle(fontSize: 9, color: AppTheme.secondaryText),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard(
                'Acceptance Rate',
                '${_analytics.acceptanceRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                AppTheme.success,
              ),
              _buildMetricCard(
                'Completion Rate',
                '${_analytics.completionRate.toStringAsFixed(1)}%',
                Icons.verified,
                AppTheme.success,
              ),
              _buildMetricCard(
                'Customer Rating',
                '${_analytics.averageRating.toStringAsFixed(1)} ★',
                Icons.star,
                AppTheme.yellow,
              ),
              _buildMetricCard(
                'Avg Delivery Time',
                '${_analytics.averageDeliveryTime.toStringAsFixed(0)} min',
                Icons.timer,
                AppTheme.warning,
              ),
              _buildMetricCard(
                'Total Distance',
                '${_analytics.totalDistance.toStringAsFixed(0)} km',
                Icons.route,
                AppTheme.primaryRed,
              ),
              _buildMetricCard(
                'Total Deliveries',
                '${(_analytics.totalEarnings / _analytics.averagePerDelivery).toInt()}',
                Icons.delivery_dining,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: AppTheme.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries() {
    final deliveries = MockAnalyticsService.getDeliveries().take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Deliveries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deliveries.length,
            separatorBuilder: (_, __) => const Divider(color: AppTheme.deepCrimson),
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt, size: 20, color: AppTheme.mutedText),
                ),
                title: Text(
                  delivery.restaurantName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                ),
                subtitle: Text(
                  '${delivery.customerName} • ${_formatDate(delivery.timestamp)}',
                  style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MK${delivery.earnings.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                    ),
                    if (delivery.tip > 0)
                      Text(
                        '+ MK${delivery.tip.toInt()} tip',
                        style: const TextStyle(fontSize: 10, color: AppTheme.success),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdownExample() {
    final sampleDelivery = MockAnalyticsService.getDeliveries().first;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Breakdown (Sample Delivery)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Base Fee', sampleDelivery.baseFee),
          _buildBreakdownRow('Distance Fee (${sampleDelivery.distance.toStringAsFixed(1)} km)', sampleDelivery.distanceFee),
          _buildBreakdownRow('Time Fee (${sampleDelivery.duration} min)', sampleDelivery.timeFee),
          if (sampleDelivery.bonus > 0)
            _buildBreakdownRow('Bonus', sampleDelivery.bonus, isBonus: true),
          if (sampleDelivery.tip > 0)
            _buildBreakdownRow('Customer Tip', sampleDelivery.tip, isTip: true),
          const Divider(height: 24, color: AppTheme.deepCrimson),
          _buildBreakdownRow('TOTAL', sampleDelivery.earnings, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, {bool isTotal = false, bool isBonus = false, bool isTip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppTheme.primaryText : AppTheme.secondaryText,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'MK${amount.toInt()}',
            style: TextStyle(
              color: isBonus ? AppTheme.success : (isTip ? AppTheme.yellow : (isTotal ? AppTheme.primaryRed : AppTheme.primaryText)),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.day == now.day - 1 && date.month == now.month) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}