import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/theme_provider.dart';

class DriverAnalyticsScreen extends StatefulWidget {
  const DriverAnalyticsScreen({super.key});

  @override
  State<DriverAnalyticsScreen> createState() => _DriverAnalyticsScreenState();
}

class _DriverAnalyticsScreenState extends State<DriverAnalyticsScreen> {
  String _selectedPeriod = 'week';
  int _selectedChartIndex = 0;

  Map<String, double> _buildWeeklyBreakdown(List history) {
    final breakdown = {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0,
      'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    for (final order in history) {
      if (order.status != 'delivered') continue;
      final date = _parseDate(order.estimatedTime);
      if (date == null || date.isBefore(weekAgo)) continue;
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = days[date.weekday - 1];
      breakdown[dayName] = (breakdown[dayName] ?? 0) + order.earnings;
    }
    return breakdown;
  }

  Map<int, double> _buildHourlyBreakdown(List history) {
    final breakdown = <int, double>{};
    for (final order in history) {
      if (order.status != 'delivered') continue;
      final date = _parseDate(order.estimatedTime);
      if (date == null) continue;
      breakdown[date.hour] = (breakdown[date.hour] ?? 0) + order.earnings;
    }
    return breakdown;
  }

  DateTime? _parseDate(String raw) {
    return DateTime.tryParse(raw);
  }

  List _filteredHistory(List history) {
    final now = DateTime.now();
    return history.where((o) {
      if (o.status != 'delivered') return false;
      final date = _parseDate(o.estimatedTime);
      if (date == null) return true;
      switch (_selectedPeriod) {
        case 'week': return date.isAfter(now.subtract(const Duration(days: 7)));
        case 'month': return date.isAfter(now.subtract(const Duration(days: 30)));
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final driverProvider = Provider.of<DriverProvider>(context);
        final stats = driverProvider.stats;
        final history = driverProvider.deliveryHistory.where((d) => d.status == 'delivered').toList();

        final isDark = theme.isDarkMode;
        final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
        final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
        final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
        final mutedColor = isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;
        final cardBgColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
        final itemBgColor = isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground;

        final weeklyBreakdown = _buildWeeklyBreakdown(history);
        final hourlyBreakdown = _buildHourlyBreakdown(history);
        final filtered = _filteredHistory(history);
        final totalEarnings = stats.totalEarnings;
        final todayEarnings = stats.todayEarnings;
        final totalDeliveries = stats.totalDeliveries;
        final rating = stats.rating;
        final avgPerDelivery = totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0.0;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text('Earnings Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context), color: textColor),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  driverProvider.refresh();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Refreshing analytics...'),
                    backgroundColor: AppTheme.success,
                  ));
                },
                color: textColor,
              ),
            ],
          ),
          body: driverProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: driverProvider.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildEarningsOverview(totalEarnings, todayEarnings, avgPerDelivery),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(isDark, textColor),
                        const SizedBox(height: 16),
                        _buildEarningsChart(isDark, textColor, secondaryTextColor, mutedColor, cardBgColor,
                            weeklyBreakdown: weeklyBreakdown, hourlyBreakdown: hourlyBreakdown),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(isDark, textColor, secondaryTextColor, cardBgColor, itemBgColor,
                            totalDeliveries: totalDeliveries, rating: rating),
                        const SizedBox(height: 16),
                        _buildRecentDeliveries(isDark, textColor, secondaryTextColor, mutedColor, cardBgColor, itemBgColor,
                            filtered: filtered),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEarningsOverview(double total, double today, double avg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('MK${total.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('Today', 'MK${today.toInt()}'),
              _buildOverviewItem('Avg / Delivery', 'MK${avg.toInt()}'),
            ],
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

  Widget _buildPeriodSelector(bool isDark, Color textColor) {
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
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRed : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart(
    bool isDark, Color textColor, Color secondaryTextColor, Color mutedColor, Color cardBgColor, {
    required Map<String, double> weeklyBreakdown,
    required Map<int, double> hourlyBreakdown,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Earnings Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
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
                ? _buildWeeklyChart(secondaryTextColor, weeklyBreakdown)
                : _buildHourlyChart(secondaryTextColor, mutedColor, hourlyBreakdown),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String label, int index, bool isDark, Color textColor) {
    final isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : (isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontSize: 12)),
      ),
    );
  }

  Widget _buildWeeklyChart(Color secondaryTextColor, Map<String, double> weeklyBreakdown) {
    final hasData = weeklyBreakdown.values.any((v) => v > 0);
    if (!hasData) return Center(child: Text('No data for this week', style: TextStyle(color: secondaryTextColor)));
    final maxVal = weeklyBreakdown.values.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weeklyBreakdown.entries.map((entry) {
        final barHeight = maxVal > 0 ? (entry.value / maxVal) * 150 : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('MK${entry.value.toInt()}', style: TextStyle(fontSize: 9, color: secondaryTextColor)),
            const SizedBox(height: 4),
            Container(width: 35, height: barHeight, decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 4),
            Text(entry.key, style: TextStyle(fontSize: 12, color: secondaryTextColor)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart(Color secondaryTextColor, Color mutedColor, Map<int, double> hourlyBreakdown) {
    if (hourlyBreakdown.isEmpty) return Center(child: Text('No hourly data available', style: TextStyle(color: secondaryTextColor)));
    final maxVal = hourlyBreakdown.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (hour) {
          final earnings = hourlyBreakdown[hour] ?? 0;
          final barHeight = earnings > 0 && maxVal > 0 ? (earnings / maxVal) * 150 : 5.0;
          return Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (earnings > 0) Text('MK${earnings.toInt()}', style: TextStyle(fontSize: 8, color: secondaryTextColor)),
                const SizedBox(height: 4),
                Container(width: 25, height: barHeight, decoration: BoxDecoration(color: earnings > 0 ? AppTheme.primaryRed : mutedColor.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                Text('$hour:00', style: TextStyle(fontSize: 9, color: secondaryTextColor)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPerformanceMetrics(
    bool isDark, Color textColor, Color secondaryTextColor, Color cardBgColor, Color itemBgColor, {
    required int totalDeliveries,
    required double rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard('Total Deliveries', '$totalDeliveries', Icons.delivery_dining, Colors.blue, isDark, itemBgColor),
              _buildMetricCard('Customer Rating', rating > 0 ? '${rating.toStringAsFixed(1)} ★' : '—', Icons.star, AppTheme.yellow, isDark, itemBgColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, bool isDark, Color itemBgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: itemBgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText)),
                Text(title, style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries(
    bool isDark, Color textColor, Color secondaryTextColor, Color mutedColor, Color cardBgColor, Color itemBgColor, {
    required List filtered,
  }) {
    final items = filtered.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Deliveries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text('No deliveries in this period', style: TextStyle(color: secondaryTextColor))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.deepCrimson),
              itemBuilder: (context, index) {
                final order = items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: itemBgColor, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.receipt, size: 20, color: mutedColor),
                  ),
                  title: Text(order.restaurantName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  subtitle: Text(order.customerName, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                  trailing: Text('MK${order.earnings.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                );
              },
            ),
        ],
      ),
    );
  }
}