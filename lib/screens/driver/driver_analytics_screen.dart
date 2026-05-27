import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/driver_service.dart';

class DriverAnalyticsScreen extends StatefulWidget {
  const DriverAnalyticsScreen({super.key});

  @override
  State<DriverAnalyticsScreen> createState() => _DriverAnalyticsScreenState();
}

class _DriverAnalyticsScreenState extends State<DriverAnalyticsScreen> {
  String _selectedPeriod = 'week';
  int _selectedChartIndex = 0;

  bool _isLoading = true;
  String? _error;

  // Data from API
  Map<String, dynamic> _earningsSummary = {};
  List<dynamic> _deliveryHistory = [];

  // Computed chart data from history
  Map<String, double> _weeklyBreakdown = {
    'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
  };
  Map<int, double> _hourlyBreakdown = {};

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
      final results = await Future.wait([
        DriverService.getEarningsSummary(),
        DriverService.getDeliveryHistory(),
      ]);
      _earningsSummary = results[0] as Map<String, dynamic>;
      _deliveryHistory = results[1] as List<dynamic>;
      _computeChartData();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _computeChartData() {
    // Reset
    _weeklyBreakdown = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
    };
    _hourlyBreakdown = {};

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    for (final order in _deliveryHistory) {
      final createdStr = order['created'] ?? order['updated_at'] ?? '';
      if (createdStr.isEmpty) continue;
      final date = DateTime.tryParse(createdStr);
      if (date == null) continue;

      final fee = _toDouble(order['delivery_fee'] ?? order['earnings'] ?? 0);

      // Weekly chart — last 7 days only
      if (date.isAfter(weekAgo)) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = days[date.weekday - 1];
        _weeklyBreakdown[dayName] = (_weeklyBreakdown[dayName] ?? 0) + fee;
      }

      // Hourly chart — all history
      _hourlyBreakdown[date.hour] =
          (_hourlyBreakdown[date.hour] ?? 0) + fee;
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  // Convenience getters from earnings summary
  double get _totalEarnings => _toDouble(_earningsSummary['total_earnings']);
  double get _todayEarnings => _toDouble(_earningsSummary['today_earnings']);
  double get _weeklyEarnings => _toDouble(_earningsSummary['weekly_earnings']);
  double get _monthlyEarnings => _toDouble(_earningsSummary['monthly_earnings']);
  double get _averagePerDelivery => _toDouble(_earningsSummary['average_per_delivery']);
  double get _acceptanceRate => _toDouble(_earningsSummary['acceptance_rate'] ?? _earningsSummary['acceptanceRate']);
  double get _completionRate => _toDouble(_earningsSummary['completion_rate'] ?? _earningsSummary['completionRate']);
  double get _averageRating => _toDouble(_earningsSummary['rating'] ?? _earningsSummary['average_rating']);
  double get _averageDeliveryTime => _toDouble(_earningsSummary['average_delivery_time'] ?? _earningsSummary['averageDeliveryTime']);
  double get _totalDistance => _toDouble(_earningsSummary['total_distance'] ?? _earningsSummary['totalDistance']);
  int get _totalDeliveries => _toInt(_earningsSummary['total_deliveries'] ?? _deliveryHistory.length);

  // Filter history by selected period
  List<dynamic> get _filteredHistory {
    final now = DateTime.now();
    return _deliveryHistory.where((o) {
      final createdStr = o['created'] ?? o['updated_at'] ?? '';
      final date = DateTime.tryParse(createdStr);
      if (date == null) return false;
      switch (_selectedPeriod) {
        case 'week':
          return date.isAfter(now.subtract(const Duration(days: 7)));
        case 'month':
          return date.isAfter(now.subtract(const Duration(days: 30)));
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor =
        isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor =
        isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText;
    final mutedColor =
        isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Earnings Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Refreshing analytics...'),
                backgroundColor: AppTheme.success,
              ));
            },
            color: textColor,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 48, color: AppTheme.error),
                      const SizedBox(height: 12),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondaryTextColor)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildEarningsOverview(),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(isDark, textColor),
                        const SizedBox(height: 16),
                        _buildEarningsChart(
                            isDark, textColor, secondaryTextColor, mutedColor),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(
                            isDark, textColor, secondaryTextColor),
                        const SizedBox(height: 16),
                        _buildRecentDeliveries(
                            isDark, textColor, secondaryTextColor, mutedColor),
                      ],
                    ),
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
          const Text('Total Earnings',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'MK${_totalEarnings.toInt()}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('Today', 'MK${_todayEarnings.toInt()}'),
              _buildOverviewItem('This Week', 'MK${_weeklyEarnings.toInt()}'),
              _buildOverviewItem('This Month', 'MK${_monthlyEarnings.toInt()}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Avg. MK${_averagePerDelivery.toInt()} per delivery',
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
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodSelector(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSecondaryBackground
            : AppTheme.lightSecondaryBackground,
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

  Widget _buildPeriodButton(
      String label, String period, bool isDark, Color textColor) {
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
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart(bool isDark, Color textColor,
      Color secondaryTextColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Earnings Overview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
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

  Widget _buildChartTypeButton(
      String label, int index, bool isDark, Color textColor) {
    final isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartIndex = index),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRed
              : (isDark
                  ? AppTheme.darkSecondaryBackground
                  : AppTheme.lightSecondaryBackground),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontSize: 12)),
      ),
    );
  }

  Widget _buildWeeklyChart(Color secondaryTextColor) {
    final hasData =
        _weeklyBreakdown.values.any((v) => v > 0);
    if (!hasData) {
      return Center(
          child: Text('No data for this week',
              style: TextStyle(color: secondaryTextColor)));
    }
    final maxVal =
        _weeklyBreakdown.values.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _weeklyBreakdown.entries.map((entry) {
        final barHeight =
            maxVal > 0 ? (entry.value / maxVal) * 150 : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('MK${entry.value.toInt()}',
                style: TextStyle(
                    fontSize: 9, color: secondaryTextColor)),
            const SizedBox(height: 4),
            Container(
              width: 35,
              height: barHeight,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(entry.key,
                style: TextStyle(
                    fontSize: 12, color: secondaryTextColor)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart(
      Color secondaryTextColor, Color mutedColor) {
    if (_hourlyBreakdown.isEmpty) {
      return Center(
          child: Text('No hourly data available',
              style: TextStyle(color: secondaryTextColor)));
    }
    final maxVal =
        _hourlyBreakdown.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (hour) {
          final earnings = _hourlyBreakdown[hour] ?? 0;
          final barHeight =
              earnings > 0 && maxVal > 0 ? (earnings / maxVal) * 150 : 5.0;
          return Container(
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (earnings > 0)
                  Text('MK${earnings.toInt()}',
                      style: TextStyle(
                          fontSize: 8, color: secondaryTextColor)),
                const SizedBox(height: 4),
                Container(
                  width: 25,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: earnings > 0
                        ? AppTheme.primaryRed
                        : mutedColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$hour:00',
                    style: TextStyle(
                        fontSize: 9, color: secondaryTextColor)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPerformanceMetrics(
      bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Metrics',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
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
                  _acceptanceRate > 0
                      ? '${_acceptanceRate.toStringAsFixed(1)}%'
                      : '—',
                  Icons.check_circle,
                  AppTheme.success,
                  isDark),
              _buildMetricCard(
                  'Completion Rate',
                  _completionRate > 0
                      ? '${_completionRate.toStringAsFixed(1)}%'
                      : '—',
                  Icons.verified,
                  AppTheme.success,
                  isDark),
              _buildMetricCard(
                  'Customer Rating',
                  _averageRating > 0
                      ? '${_averageRating.toStringAsFixed(1)} ★'
                      : '—',
                  Icons.star,
                  AppTheme.yellow,
                  isDark),
              _buildMetricCard(
                  'Avg Delivery Time',
                  _averageDeliveryTime > 0
                      ? '${_averageDeliveryTime.toStringAsFixed(0)} min'
                      : '—',
                  Icons.timer,
                  AppTheme.warning,
                  isDark),
              _buildMetricCard(
                  'Total Distance',
                  _totalDistance > 0
                      ? '${_totalDistance.toStringAsFixed(0)} km'
                      : '—',
                  Icons.route,
                  AppTheme.primaryRed,
                  isDark),
              _buildMetricCard(
                  'Total Deliveries',
                  '$_totalDeliveries',
                  Icons.delivery_dining,
                  Colors.blue,
                  isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSecondaryBackground
            : AppTheme.lightSecondaryBackground,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDeliveries(bool isDark, Color textColor,
      Color secondaryTextColor, Color mutedColor) {
    final filtered = _filteredHistory.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Deliveries',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: Text('No deliveries in this period',
                      style: TextStyle(color: secondaryTextColor))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppTheme.deepCrimson),
              itemBuilder: (context, index) {
                final order = filtered[index];
                final restaurantName = order['restaurant_name'] ??
                    order['restaurant']?['name'] ??
                    'Restaurant';
                final customerName = order['customer_name'] ??
                    order['customer']?['username'] ??
                    'Customer';
                final fee = _toDouble(
                    order['delivery_fee'] ?? order['earnings'] ?? 0);
                final createdStr =
                    order['created'] ?? order['updated_at'] ?? '';
                final date = DateTime.tryParse(createdStr);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSecondaryBackground
                          : AppTheme.lightSecondaryBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt,
                        size: 20, color: mutedColor),
                  ),
                  title: Text(restaurantName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  subtitle: Text(
                    '$customerName${date != null ? ' • ${_formatDate(date)}' : ''}',
                    style: TextStyle(
                        fontSize: 11, color: secondaryTextColor),
                  ),
                  trailing: Text(
                    'MK${fee.toInt()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.difference(now).inDays.abs() == 1) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}