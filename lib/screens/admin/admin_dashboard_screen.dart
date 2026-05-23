import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/sidebar_menu.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  late AdminStats _stats;
  
  final List<Widget> _screens = [
    const _AdminDashboardContent(),
    const _UserManagementContent(),
    const _RestaurantManagementContent(),
    const _DriverManagementContent(),
    const _ReportsContent(),
  ];
  
  final List<SidebarMenuItem> _menuItems = const [
    SidebarMenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/admin/dashboard'),
    SidebarMenuItem(title: 'Users', icon: Icons.people_outline, route: '/admin/users'),
    SidebarMenuItem(title: 'Restaurants', icon: Icons.restaurant_outlined, route: '/admin/restaurants'),
    SidebarMenuItem(title: 'Drivers', icon: Icons.delivery_dining_outlined, route: '/admin/drivers'),
    SidebarMenuItem(title: 'Reports', icon: Icons.bar_chart_outlined, route: '/admin/reports'),
    SidebarMenuItem(title: 'Settings', icon: Icons.settings_outlined, route: '/admin/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _stats = AdminStats(
      totalUsers: 1245,
      totalRestaurants: 87,
      totalDrivers: 32,
      totalOrders: 3420,
      totalRevenue: 1245000,
      pendingRestaurants: 5,
      pendingDrivers: 3,
      activeOrders: 28,
      completedOrders: 124,
      cancelledOrders: 8,
      monthlyGrowth: 15.5,
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
        return '/admin/dashboard';
      case 1:
        return '/admin/users';
      case 2:
        return '/admin/restaurants';
      case 3:
        return '/admin/drivers';
      case 4:
        return '/admin/reports';
      default:
        return '/admin/dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminName = authProvider.currentUser?.name ?? 'Admin';

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
                adminName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex],
      ),
    );
  }
}

// Admin Dashboard Content
class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Cards Row 1
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Users',
                  value: '1,245',
                  icon: Icons.people,
                  color: AppTheme.primaryRed,
                  change: '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Restaurants',
                  value: '87',
                  icon: Icons.restaurant,
                  color: AppTheme.orange,
                  change: '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Active Drivers',
                  value: '32',
                  icon: Icons.delivery_dining,
                  color: AppTheme.success,
                  change: '+8%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Orders',
                  value: '3,420',
                  icon: Icons.receipt,
                  color: AppTheme.yellow,
                  change: '+18%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Revenue',
                  value: 'MK1.24M',
                  icon: Icons.attach_money,
                  color: AppTheme.teal,
                  change: '+22%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Active Orders',
                  value: '28',
                  icon: Icons.shopping_bag,
                  color: AppTheme.warning,
                  change: '-3%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pending Approvals Section
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
                  'Pending Approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPendingItem(
                  title: 'Restaurant Approvals',
                  count: 5,
                  icon: Icons.restaurant,
                  color: AppTheme.warning,
                ),
                const SizedBox(height: 12),
                _buildPendingItem(
                  title: 'Driver Applications',
                  count: 3,
                  icon: Icons.delivery_dining,
                  color: AppTheme.orange,
                ),
                const SizedBox(height: 12),
                _buildPendingItem(
                  title: 'Customer Complaints',
                  count: 2,
                  icon: Icons.report_problem,
                  color: AppTheme.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'Recent Activity',
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
              return _buildActivityItem(index);
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
    required String change,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: change.startsWith('+') ? AppTheme.success : AppTheme.error,
                ),
              ),
            ],
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

  Widget _buildPendingItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 18),
            color: AppTheme.primaryRed,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    final List<Map<String, String>> activities = [
      {'action': 'New restaurant registered', 'user': 'Luigi\'s Pizza', 'time': '5 min ago'},
      {'action': 'Driver application submitted', 'user': 'John Doe', 'time': '15 min ago'},
      {'action': 'Order #3421 completed', 'user': 'Customer', 'time': '1 hour ago'},
    ];
    final activity = activities[index];

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
            child: const Icon(Icons.notifications, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['user']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// User Management Content
class _UserManagementContent extends StatelessWidget {
  const _UserManagementContent();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {'name': 'John Doe', 'email': 'john@example.com', 'role': 'Customer', 'status': 'Active'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'Restaurant', 'status': 'Pending'},
      {'name': 'Mike Johnson', 'email': 'mike@example.com', 'role': 'Driver', 'status': 'Active'},
      {'name': 'Sarah Wilson', 'email': 'sarah@example.com', 'role': 'Customer', 'status': 'Blocked'},
      {'name': 'Luigi\'s Pizza', 'email': 'luigi@example.com', 'role': 'Restaurant', 'status': 'Active'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

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
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.person, size: 25, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      user['email']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user['role']!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['role']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getRoleColor(user['role']!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user['status'] == 'Active'
                                ? AppTheme.success.withOpacity(0.2)
                                : AppTheme.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['status']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: user['status'] == 'Active'
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppTheme.mutedText),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Customer':
        return AppTheme.primaryRed;
      case 'Restaurant':
        return AppTheme.warning;
      case 'Driver':
        return AppTheme.teal;
      default:
        return AppTheme.mutedText;
    }
  }
}

// Restaurant Management Content
class _RestaurantManagementContent extends StatelessWidget {
  const _RestaurantManagementContent();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> restaurants = [
      {'name': 'Luigi\'s Pizza', 'owner': 'Luigi', 'status': 'Active', 'orders': 145, 'rating': 4.8},
      {'name': 'Burger King', 'owner': 'BK Corp', 'status': 'Pending', 'orders': 0, 'rating': 0},
      {'name': 'Sushi Master', 'owner': 'Tanaka', 'status': 'Active', 'orders': 89, 'rating': 4.5},
      {'name': 'Tasty Bites', 'owner': 'Smith', 'status': 'Active', 'orders': 234, 'rating': 4.7},
      {'name': 'Flame Grill', 'owner': 'Johnson', 'status': 'Suspended', 'orders': 45, 'rating': 3.9},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];

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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, size: 25, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      'Owner: ${restaurant['owner']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if ((restaurant['rating'] as double) > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                              const SizedBox(width: 2),
                              Text(
                                restaurant['rating'].toString(),
                                style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        Text(
                          '${restaurant['orders']} orders',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(restaurant['status'] as String),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['status'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(restaurant['status'] as String),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppTheme.mutedText),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppTheme.success;
      case 'Pending':
        return AppTheme.warning;
      case 'Suspended':
        return AppTheme.error;
      default:
        return AppTheme.mutedText;
    }
  }
}

// Driver Management Content
class _DriverManagementContent extends StatelessWidget {
  const _DriverManagementContent();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> drivers = [
      {'name': 'Mike Johnson', 'phone': '+265 888 123 456', 'status': 'Active', 'deliveries': 342, 'rating': 4.9},
      {'name': 'David Brown', 'phone': '+265 999 789 012', 'status': 'Pending', 'deliveries': 0, 'rating': 0},
      {'name': 'Chris Wilson', 'phone': '+265 777 456 789', 'status': 'Active', 'deliveries': 156, 'rating': 4.7},
      {'name': 'Alex Turner', 'phone': '+265 666 321 654', 'status': 'Inactive', 'deliveries': 89, 'rating': 4.5},
      {'name': 'Sam Lee', 'phone': '+265 555 987 321', 'status': 'Active', 'deliveries': 278, 'rating': 4.8},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];

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
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.delivery_dining, size: 25, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      driver['phone'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if ((driver['rating'] as double) > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                              const SizedBox(width: 2),
                              Text(
                                driver['rating'].toString(),
                                style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        Text(
                          '${driver['deliveries']} deliveries',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(driver['status'] as String),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver['status'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(driver['status'] as String),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppTheme.mutedText),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppTheme.success;
      case 'Pending':
        return AppTheme.warning;
      case 'Inactive':
        return AppTheme.error;
      default:
        return AppTheme.mutedText;
    }
  }
}

// Reports Content
class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Revenue Chart Placeholder
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
                  'Revenue Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Revenue Chart',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Order Stats
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
                  'Order Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReportRow('Total Orders', '3,420'),
                _buildReportRow('Completed Orders', '3,124'),
                _buildReportRow('Active Orders', '28'),
                _buildReportRow('Cancelled Orders', '268'),
                _buildReportRow('Average Order Value', 'MK3,640'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// Admin Stats Model
class AdminStats {
  final int totalUsers;
  final int totalRestaurants;
  final int totalDrivers;
  final int totalOrders;
  final double totalRevenue;
  final int pendingRestaurants;
  final int pendingDrivers;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double monthlyGrowth;

  AdminStats({
    required this.totalUsers,
    required this.totalRestaurants,
    required this.totalDrivers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingRestaurants,
    required this.pendingDrivers,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.monthlyGrowth,
  });
}