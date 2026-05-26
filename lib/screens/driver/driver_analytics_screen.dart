import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/driver_analytics.dart';
import '../../services/mock_analytics_service.dart';
import '../../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final cardColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Earnings Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: textColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadAnalytics();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analytics refreshed!'), backgroundColor: AppTheme.success),
              );
            },
            color: textColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEarningsOverview(isDark, textColor),
            const SizedBox(height: 16),
            _buildPeriodSelector(isDark, textColor, secondaryTextColor),
            const SizedBox(height: 16),
            _buildEarningsChart(isDark, textColor, secondaryTextColor, mutedColor),
            const SizedBox(height: 16),
            _buildPerformanceMetrics(isDark, textColor, secondaryTextColor),
            const SizedBox(height: 16),
            _buildRecentDeliveries(isDark, textColor, secondaryTextColor, mutedColor),
            const SizedBox(height: 16),
            _buildFeeBreakdownExample(isDark, textColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsOverview(bool isDark, Color textColor) {
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

  Widget _buildPeriodSelector(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Week', 'week', isDark, textColor),
          _buildPeriodButton('Month', 'month', isDark, textColor),
          _buildPeriodButton('All Time', 'all', isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period, bool isDark, Color textColor) {
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
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart(bool isDark, Color textColor, Color secondaryTextColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              Row(
                children: [
                  _buildChartTypeButton('Weekly', 0, isDark, textColor),
                  const SizedBox(width: 8),
                  _buildChartTypeButton('Hourly', 1, isDark, textColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _selectedChartIndex == 0 
                ? _buildWeeklyChart(secondaryTextColor) 
                : _buildHourlyChart(secondaryTextColor, mutedColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String label, int index, bool isDark, Color textColor) {
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
          color: isSelected ? AppTheme.primaryRed : (isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(Color secondaryTextColor) {
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
              style: TextStyle(fontSize: 10, color: secondaryTextColor),
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
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart(Color secondaryTextColor, Color mutedColor) {
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
                    style: TextStyle(fontSize: 8, color: secondaryTextColor),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 25,
                  height: heightValue,
                  decoration: BoxDecoration(
                    color: earnings > 0 ? AppTheme.primaryRed : mutedColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$hour:00',
                  style: TextStyle(fontSize: 9, color: secondaryTextColor),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceMetrics(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
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
              _buildMetricCard('Acceptance Rate', '${_analytics.acceptanceRate.toStringAsFixed(1)}%', Icons.check_circle, AppTheme.success, isDark),
              _buildMetricCard('Completion Rate', '${_analytics.completionRate.toStringAsFixed(1)}%', Icons.verified, AppTheme.success, isDark),
              _buildMetricCard('Customer Rating', '${_analytics.averageRating.toStringAsFixed(1)} ★', Icons.star, AppTheme.yellow, isDark),
              _buildMetricCard('Avg Delivery Time', '${_analytics.averageDeliveryTime.toStringAsFixed(0)} min', Icons.timer, AppTheme.warning, isDark),
              _buildMetricCard('Total Distance', '${_analytics.totalDistance.toStringAsFixed(0)} km', Icons.route, AppTheme.primaryRed, isDark),
              _buildMetricCard('Total Deliveries', '${(_analytics.totalEarnings / _analytics.averagePerDelivery).toInt()}', Icons.delivery_dining, Colors.blue, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries(bool isDark, Color textColor, Color secondaryTextColor, Color mutedColor) {
    final deliveries = MockAnalyticsService.getDeliveries().take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Deliveries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
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
                    color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt, size: 20, color: mutedColor),
                ),
                title: Text(
                  delivery.restaurantName,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                subtitle: Text(
                  '${delivery.customerName} • ${_formatDate(delivery.timestamp)}',
                  style: TextStyle(fontSize: 11, color: secondaryTextColor),
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

  Widget _buildFeeBreakdownExample(bool isDark, Color textColor, Color secondaryTextColor) {
    final sampleDelivery = MockAnalyticsService.getDeliveries().first;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Breakdown (Sample Delivery)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Base Fee', sampleDelivery.baseFee, isDark, textColor, secondaryTextColor),
          _buildBreakdownRow('Distance Fee (${sampleDelivery.distance.toStringAsFixed(1)} km)', sampleDelivery.distanceFee, isDark, textColor, secondaryTextColor),
          _buildBreakdownRow('Time Fee (${sampleDelivery.duration} min)', sampleDelivery.timeFee, isDark, textColor, secondaryTextColor),
          if (sampleDelivery.bonus > 0)
            _buildBreakdownRow('Bonus', sampleDelivery.bonus, isDark, textColor, secondaryTextColor, isBonus: true),
          if (sampleDelivery.tip > 0)
            _buildBreakdownRow('Customer Tip', sampleDelivery.tip, isDark, textColor, secondaryTextColor, isTip: true),
          const Divider(height: 24, color: AppTheme.deepCrimson),
          _buildBreakdownRow('TOTAL', sampleDelivery.earnings, isDark, textColor, secondaryTextColor, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, bool isDark, Color textColor, Color secondaryTextColor, {bool isTotal = false, bool isBonus = false, bool isTip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? textColor : secondaryTextColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'MK${amount.toInt()}',
            style: TextStyle(
              color: isBonus ? AppTheme.success : (isTip ? AppTheme.yellow : (isTotal ? AppTheme.primaryRed : textColor)),
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