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
                onPressed: () => driverProvider.refresh(),
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
                        _buildEarningsOverview(stats.totalEarnings, stats.todayEarnings, stats.totalDeliveries > 0 ? stats.totalEarnings / stats.totalDeliveries : 0),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(isDark, textColor),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(isDark, totalDeliveries: stats.totalDeliveries, rating: stats.rating),
                        const SizedBox(height: 16),
                        _buildRecentDeliveries(isDark, filtered: history.take(10).toList()),
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
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildPeriodSelector(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground, borderRadius: BorderRadius.circular(30)),
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
          decoration: BoxDecoration(color: isSelected ? AppTheme.primaryRed : Colors.transparent, borderRadius: BorderRadius.circular(30)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(bool isDark, {required int totalDeliveries, required double rating}) {
    final cardBgColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final itemBgColor = isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;

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
              _buildMetricCard('Customer Rating', rating > 0 ? '${rating.toStringAsFixed(1)} ★' : '5.0 ★', Icons.star, AppTheme.yellow, isDark, itemBgColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, bool isDark, Color itemBgColor) {
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: itemBgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              Text(title, style: TextStyle(fontSize: 10, color: AppTheme.secondaryText)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries(bool isDark, {required List filtered}) {
    final cardBgColor = isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
    final textColor = isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;

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
          if (filtered.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('No deliveries in this period', style: TextStyle(color: secondaryTextColor))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.deepCrimson),
              itemBuilder: (context, index) {
                final order = filtered[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: isDark ? AppTheme.darkSecondaryBackground : AppTheme.lightSecondaryBackground, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.receipt, size: 20, color: AppTheme.mutedText)),
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