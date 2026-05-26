import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/delivery_request.dart';
import '../../widgets/driver/stat_card.dart';
import '../../widgets/driver/schedule_item.dart';
import '../../widgets/driver/earnings_item.dart';
import '../../widgets/driver/status_chip.dart';
import '../../widgets/driver/progress_timeline.dart';
import '../../widgets/driver/info_section.dart';
import '../../widgets/dialogs/new_request_dialog.dart';
import '../../widgets/dialogs/update_status_dialog.dart';
import 'available_orders_screen.dart';
import 'delivery_history_screen.dart';
import 'driver_analytics_screen.dart';
import 'driver_settings_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _showActiveDeliveryFullView = false;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.delivery_dining, 'label': 'Available'},
    {'icon': Icons.history, 'label': 'History'},
    {'icon': Icons.analytics, 'label': 'Analytics'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForIncomingRequests();
    });
  }

  void _checkForIncomingRequests() {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      
      if (driverProvider.isOnline && 
          driverProvider.activeDelivery == null && 
          driverProvider.availableOrders.isNotEmpty) {
        _showNewRequestDialog();
      }
    } catch (e) {
      debugPrint('Provider not ready yet');
    }
  }

  void _showNewRequestDialog() {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      if (driverProvider.availableOrders.isEmpty) return;
      
      final order = driverProvider.availableOrders.first;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NewRequestDialog(
          request: order,
          onAccept: () {
            driverProvider.acceptOrder(order);
            Navigator.pop(context);
            _showSnackBar('Order accepted! Head to the restaurant.');
            setState(() {
              _selectedIndex = 0;
              _showActiveDeliveryFullView = true;
            });
          },
          onDecline: () {
            driverProvider.declineOrder(order);
            Navigator.pop(context);
            _showSnackBar('Order declined', isError: true);
            Future.delayed(const Duration(seconds: 2), () {
              if (driverProvider.isOnline && 
                  driverProvider.activeDelivery == null && 
                  driverProvider.availableOrders.isNotEmpty) {
                _showNewRequestDialog();
              }
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('Error showing dialog: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateOrderStatus(String newStatus) {
    try {
      final driverProvider = Provider.of<DriverProvider>(context, listen: false);
      driverProvider.updateOrderStatus(newStatus);
      
      if (newStatus == 'delivered') {
        _showSnackBar('Delivery completed! Great job! 🎉');
        setState(() {
          _showActiveDeliveryFullView = false;
        });
      } else {
        _showSnackBar('Status updated to: ${_getStatusDisplay(newStatus)}');
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'accepted': return 'Accepted';
      case 'picked_up': return 'Picked Up';
      case 'delivered': return 'Delivered';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final driverName = authProvider.currentUser?.name ?? 'John Driver';
    final stats = driverProvider.stats;
    final activeDelivery = driverProvider.activeDelivery;
    
    // Get theme-aware colors
    final backgroundColor = themeProvider.isDarkMode 
        ? AppTheme.mainBackground 
        : AppTheme.lightBackground;
    final textColor = themeProvider.isDarkMode 
        ? AppTheme.primaryText 
        : AppTheme.lightPrimaryText;
    final cardColor = themeProvider.isDarkMode 
        ? AppTheme.cardBackground 
        : AppTheme.lightCardBackground;
    final secondaryTextColor = themeProvider.isDarkMode 
        ? AppTheme.secondaryText 
        : AppTheme.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              driverName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _selectedIndex == 0 ? 'Driver Dashboard' : _navItems[_selectedIndex]['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: driverProvider.isOnline 
                  ? AppTheme.success.withOpacity(0.2) 
                  : AppTheme.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: driverProvider.isOnline ? AppTheme.success : AppTheme.error,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: driverProvider.isOnline ? AppTheme.success : AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  driverProvider.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: driverProvider.isOnline ? AppTheme.success : AppTheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: driverProvider.isOnline,
                  onChanged: (value) {
                    driverProvider.toggleOnlineStatus(value);
                    _showSnackBar(
                      value ? 'You are now online' : 'You are now offline',
                    );
                    if (value) {
                      Future.delayed(const Duration(seconds: 3), () {
                        _checkForIncomingRequests();
                      });
                    }
                  },
                  activeColor: AppTheme.success,
                  inactiveThumbColor: AppTheme.error,
                  inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboardContent(activeDelivery, stats, themeProvider)
          : _buildSelectedScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: secondaryTextColor,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardContent(DeliveryRequest? activeDelivery, DriverStats stats, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.primaryText : AppTheme.lightPrimaryText;
    final secondaryTextColor = isDark ? AppTheme.secondaryText : AppTheme.lightSecondaryText;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (activeDelivery != null && _showActiveDeliveryFullView)
            _buildActiveDeliveryExpanded(activeDelivery),
          
          if (activeDelivery != null && !_showActiveDeliveryFullView)
            _buildActiveDeliveryBanner(activeDelivery),
          
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Today\'s Earnings',
                  value: 'MK${stats.todayEarnings.toInt()}',
                  icon: Icons.attach_money,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Total Deliveries',
                  value: '${stats.totalDeliveries}',
                  icon: Icons.delivery_dining,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Rating',
                  value: '${stats.rating} ★',
                  icon: Icons.star,
                  color: AppTheme.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Active Orders',
                  value: activeDelivery != null ? '1' : '0',
                  icon: Icons.shopping_bag,
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
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
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (activeDelivery != null)
                  ScheduleItem(
                    orderId: activeDelivery.id,
                    restaurant: activeDelivery.restaurantName,
                    customer: activeDelivery.customerName,
                    time: activeDelivery.estimatedTime,
                    status: activeDelivery.status == 'accepted' 
                        ? 'Ready for Pickup' 
                        : activeDelivery.status == 'picked_up'
                        ? 'Out for Delivery'
                        : 'In Progress',
                    onTap: () {
                      setState(() {
                        _showActiveDeliveryFullView = true;
                      });
                    },
                  ),
                ScheduleItem(
                  orderId: 'ORD-002',
                  restaurant: 'Burger King',
                  customer: 'Jane Smith',
                  time: '1:15 PM',
                  status: 'Preparing',
                  onTap: () {},
                ),
                ScheduleItem(
                  orderId: 'ORD-003',
                  restaurant: 'Sushi Master',
                  customer: 'Mike Johnson',
                  time: '2:00 PM',
                  status: 'Scheduled',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Recent Earnings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return EarningsItem(index: index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryBanner(DeliveryRequest delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showActiveDeliveryFullView = true;
          });
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Delivery',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Order #${delivery.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    delivery.restaurantName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveryExpanded(DeliveryRequest activeDelivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                'Order #${activeDelivery.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              Row(
                children: [
                  StatusChip(status: activeDelivery.status),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showActiveDeliveryFullView = false;
                      });
                    },
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ProgressTimeline(status: activeDelivery.status),
          const SizedBox(height: 24),
          
          InfoSection(
            icon: Icons.restaurant,
            title: 'Restaurant',
            subtitle: activeDelivery.restaurantName,
            address: activeDelivery.restaurantAddress,
          ),
          const SizedBox(height: 16),
          
          InfoSection(
            icon: Icons.home,
            title: 'Delivery Address',
            subtitle: activeDelivery.customerName,
            address: activeDelivery.deliveryAddress,
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.fastfood, size: 20, color: AppTheme.mutedText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activeDelivery.items,
                    style: const TextStyle(color: AppTheme.secondaryText),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.attach_money, size: 20, color: AppTheme.primaryRed),
                const SizedBox(width: 4),
                Text(
                  'MK${activeDelivery.earnings.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          if (activeDelivery.status != 'delivered')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => UpdateStatusDialog(
                      currentStatus: activeDelivery.status,
                      onStatusUpdate: (newStatus) {
                        _updateOrderStatus(newStatus);
                        if (newStatus == 'delivered') {
                          setState(() {
                            _showActiveDeliveryFullView = false;
                          });
                        }
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Update Delivery Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showActiveDeliveryFullView = false;
                  });
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Delivery Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedScreen(int index) {
    switch (index) {
      case 1:
        return const AvailableOrdersScreen();
      case 2:
        return const DeliveryHistoryScreen();
      case 3:
        return const DriverAnalyticsScreen();
      case 4:
        return const DriverSettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}