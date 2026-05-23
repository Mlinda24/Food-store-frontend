import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/sidebar_menu.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  late DriverStats _stats;
  
  final List<Widget> _screens = [
    const _DriverDashboardContent(),
    const _AvailableOrdersContent(),
    const _ActiveDeliveriesContent(),
    const _DeliveryHistoryContent(),
  ];
  
  final List<SidebarMenuItem> _menuItems = const [
    SidebarMenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/driver/dashboard'),
    SidebarMenuItem(title: 'Available Orders', icon: Icons.delivery_dining_outlined, route: '/driver/available'),
    SidebarMenuItem(title: 'Active Deliveries', icon: Icons.local_shipping_outlined, route: '/driver/active'),
    SidebarMenuItem(title: 'History', icon: Icons.history_outlined, route: '/driver/history'),
    SidebarMenuItem(title: 'Profile', icon: Icons.person_outline, route: '/driver/profile'),
    SidebarMenuItem(title: 'Earnings', icon: Icons.attach_money_outlined, route: '/driver/earnings'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _stats = DriverStats(
      todayEarnings: 2450,
      totalDeliveries: 342,
      rating: 4.8,
      totalEarnings: 45800,
      activeDeliveries: 2,
      completedToday: 5,
    );
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

  void _handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    context.go('/login');
  }

  String _getCurrentRoute() {
    switch (_selectedIndex) {
      case 0:
        return '/driver/dashboard';
      case 1:
        return '/driver/available';
      case 2:
        return '/driver/active';
      case 3:
        return '/driver/history';
      default:
        return '/driver/dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final driverName = authProvider.currentUser?.name ?? 'Driver';

    return SidebarMenu(
      currentRoute: _getCurrentRoute(),
      items: _menuItems,
      onLogout: _handleLogout,
      child: Scaffold(
        backgroundColor: AppTheme.mainBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.mainBackground,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driverName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Driver Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
          actions: [
            // Online Status Toggle
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isOnline ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOnline ? AppTheme.success : AppTheme.error,
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
                      color: _isOnline ? AppTheme.success : AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _isOnline ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                      _showSnackBar(
                        _isOnline ? 'You are now online' : 'You are now offline',
                      );
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
        body: _screens[_selectedIndex],
      ),
    );
  }
}

// Driver Dashboard Content
class _DriverDashboardContent extends StatelessWidget {
  const _DriverDashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Today\'s Earnings',
                  value: 'MK2,450',
                  icon: Icons.attach_money,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Deliveries',
                  value: '342',
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
                child: _buildStatCard(
                  title: 'Rating',
                  value: '4.8',
                  icon: Icons.star,
                  color: AppTheme.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Active Orders',
                  value: '2',
                  icon: Icons.shopping_bag,
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Today's Schedule
          Container(
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
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _buildScheduleItem(
                  orderId: 'ORD-001',
                  restaurant: 'Luigi\'s Pizza',
                  customer: 'John Doe',
                  time: '12:30 PM',
                  status: 'Ready for Pickup',
                ),
                const SizedBox(height: 12),
                _buildScheduleItem(
                  orderId: 'ORD-002',
                  restaurant: 'Burger King',
                  customer: 'Jane Smith',
                  time: '1:15 PM',
                  status: 'Preparing',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Earnings
          const Text(
            'Recent Earnings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildEarningsItem(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String orderId,
    required String restaurant,
    required String customer,
    required String time,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #$orderId • $customer',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsItem(int index) {
    final earnings = [
      {'order': 'ORD-001', 'amount': 'MK450', 'time': '12:30 PM'},
      {'order': 'ORD-002', 'amount': 'MK380', 'time': '11:15 AM'},
      {'order': 'ORD-003', 'amount': 'MK520', 'time': '10:00 AM'},
    ];
    final earning = earnings[index];

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
            child: const Icon(Icons.receipt, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${earning['order']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                Text(
                  earning['time']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            earning['amount']!,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ready for Pickup':
        return AppTheme.success;
      case 'Preparing':
        return AppTheme.warning;
      default:
        return AppTheme.mutedText;
    }
  }
}

// Available Orders Content
class _AvailableOrdersContent extends StatelessWidget {
  const _AvailableOrdersContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        final orders = [
          {
            'restaurant': 'Luigi\'s Pizza',
            'customer': 'John Doe',
            'distance': '1.2 km',
            'earnings': 'MK450',
            'items': '2 items',
            'time': '12:30 PM',
          },
          {
            'restaurant': 'Burger King',
            'customer': 'Jane Smith',
            'distance': '0.8 km',
            'earnings': 'MK380',
            'items': '1 item',
            'time': '1:15 PM',
          },
          {
            'restaurant': 'Sushi Master',
            'customer': 'Mike Johnson',
            'distance': '2.5 km',
            'earnings': 'MK520',
            'items': '3 items',
            'time': '2:00 PM',
          },
        ];
        final order = orders[index];

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
                  Text(
                    order['restaurant']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['earnings']!,
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
                  Text(
                    order['customer']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 14, color: AppTheme.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    order['distance']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.fastfood, size: 14, color: AppTheme.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    order['items']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 14, color: AppTheme.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    order['time']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order accepted!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Accept Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Active Deliveries Content
class _ActiveDeliveriesContent extends StatelessWidget {
  const _ActiveDeliveriesContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        final deliveries = [
          {
            'orderId': 'ORD-001',
            'restaurant': 'Luigi\'s Pizza',
            'customer': 'John Doe',
            'address': '123 Main St, Area 3',
            'status': 'Pickup',
            'eta': '5 min',
          },
          {
            'orderId': 'ORD-002',
            'restaurant': 'Burger King',
            'customer': 'Jane Smith',
            'address': '456 Oak Ave, Area 47',
            'status': 'Delivering',
            'eta': '15 min',
          },
        ];
        final delivery = deliveries[index];

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
                  Text(
                    'Order #${delivery['orderId']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: delivery['status'] == 'Pickup'
                          ? AppTheme.warning.withOpacity(0.2)
                          : AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      delivery['status']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: delivery['status'] == 'Pickup'
                            ? AppTheme.warning
                            : AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant, size: 16, color: AppTheme.mutedText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery['restaurant']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        Text(
                          delivery['address']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    'ETA: ${delivery['eta']}',
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
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Contact Support'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Update Status'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Delivery History Content
class _DeliveryHistoryContent extends StatelessWidget {
  const _DeliveryHistoryContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        final deliveries = [
          {'orderId': 'ORD-001', 'restaurant': 'Luigi\'s Pizza', 'earnings': 'MK450', 'date': 'Today', 'time': '12:30 PM'},
          {'orderId': 'ORD-002', 'restaurant': 'Burger King', 'earnings': 'MK380', 'date': 'Today', 'time': '11:15 AM'},
          {'orderId': 'ORD-003', 'restaurant': 'Sushi Master', 'earnings': 'MK520', 'date': 'Yesterday', 'time': '2:00 PM'},
          {'orderId': 'ORD-004', 'restaurant': 'Tasty Bites', 'earnings': 'MK410', 'date': 'Yesterday', 'time': '12:45 PM'},
          {'orderId': 'ORD-005', 'restaurant': 'Flame Grill', 'earnings': 'MK490', 'date': '2 days ago', 'time': '6:30 PM'},
        ];
        final delivery = deliveries[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGlowGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delivery_dining, size: 25, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery['restaurant']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Order #${delivery['orderId']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${delivery['date']} • ${delivery['time']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                delivery['earnings']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Driver Stats Model
class DriverStats {
  final double todayEarnings;
  final int totalDeliveries;
  final double rating;
  final double totalEarnings;
  final int activeDeliveries;
  final int completedToday;

  DriverStats({
    required this.todayEarnings,
    required this.totalDeliveries,
    required this.rating,
    required this.totalEarnings,
    required this.activeDeliveries,
    required this.completedToday,
  });
}