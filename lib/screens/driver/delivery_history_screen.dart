import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/delivery_request.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  // Filter: 'all', 'completed', 'declined'
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Choose list based on filter
    final List<DeliveryRequest> history;
    switch (_filter) {
      case 'completed':
        history = driverProvider.completedOrders;
        break;
      case 'declined':
        history = driverProvider.declinedOrders;
        break;
      default:
        history = driverProvider.deliveryHistory;
    }

    return Column(
      children: [
        // ── Filter chips ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                value: 'all',
                selected: _filter,
                count: driverProvider.deliveryHistory.length,
                onTap: (v) => setState(() => _filter = v),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Completed',
                value: 'completed',
                selected: _filter,
                count: driverProvider.completedOrders.length,
                onTap: (v) => setState(() => _filter = v),
                isDark: isDark,
                activeColor: AppTheme.success,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Declined',
                value: 'declined',
                selected: _filter,
                count: driverProvider.declinedOrders.length,
                onTap: (v) => setState(() => _filter = v),
                isDark: isDark,
                activeColor: AppTheme.error,
              ),
            ],
          ),
        ),

        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: history.isEmpty
              ? _buildEmpty(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return _HistoryCard(
                      delivery: history[index],
                      isDark: isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty(bool isDark) {
    final isDeclinedFilter = _filter == 'declined';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDeclinedFilter ? Icons.cancel_outlined : Icons.history,
            size: 80,
            color: AppTheme.mutedText,
          ),
          const SizedBox(height: 16),
          Text(
            isDeclinedFilter ? 'No declined orders' : 'No delivery history',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDeclinedFilter
                ? 'Declined orders will appear here'
                : 'Completed and declined deliveries will appear here',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Filter chip widget ────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final int count;
  final void Function(String) onTap;
  final bool isDark;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.count,
    required this.onTap,
    required this.isDark,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final color = activeColor ?? AppTheme.primaryRed;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark
                  ? AppTheme.darkSecondaryBackground
                  : AppTheme.lightSecondaryBackground),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppTheme.secondaryText,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? color : AppTheme.mutedText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : AppTheme.mutedText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── History card widget ───────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final DeliveryRequest delivery;
  final bool isDark;

  const _HistoryCard({required this.delivery, required this.isDark});

  bool get _isDeclined => delivery.status == 'declined';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGlowGradient(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDeclined
              ? AppTheme.error.withOpacity(0.3)
              : AppTheme.deepCrimson.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _isDeclined
                  ? AppTheme.error.withOpacity(0.1)
                  : (isDark
                      ? AppTheme.darkSecondaryBackground
                      : AppTheme.lightSecondaryBackground),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isDeclined ? Icons.cancel : Icons.delivery_dining,
              size: 25,
              color: _isDeclined ? AppTheme.error : AppTheme.mutedText,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #${delivery.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  delivery.customerName,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  delivery.estimatedTime,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),

          // Earnings + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Only show earnings for completed orders
              if (!_isDeclined)
                Text(
                  'MK${delivery.earnings.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              if (_isDeclined)
                const Text(
                  'MK0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mutedText,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isDeclined
                      ? AppTheme.error.withOpacity(0.15)
                      : AppTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isDeclined ? 'Declined' : 'Completed',
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDeclined ? AppTheme.error : AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}