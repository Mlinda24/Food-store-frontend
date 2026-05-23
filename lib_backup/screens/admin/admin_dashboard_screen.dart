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
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                adminName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getMutedTextColor(context),
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
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
                  context,
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
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGlowGradient(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Approvals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPendingItem(
                  context,
                  title: 'Restaurant Approvals',
                  count: 5,
                  icon: Icons.restaurant,
                  color: AppTheme.warning,
                ),
                const SizedBox(height: 12),
                _buildPendingItem(
                  context,
                  title: 'Driver Applications',
                  count: 3,
                  icon: Icons.delivery_dining,
                  color: AppTheme.orange,
                ),
                const SizedBox(height: 12),
                _buildPendingItem(
                  context,
                  title: 'Customer Complaints',
                  count: 2,
                  icon: Icons.report_problem,
                  color: AppTheme.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildActivityItem(context, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient(context),
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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.getPrimaryTextColor(context),
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

  Widget _buildActivityItem(BuildContext context, int index) {
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
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.notifications, size: 20, color: AppTheme.getMutedTextColor(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['user']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.getMutedTextColor(context),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Customer':
        return AppTheme.primaryRed;
      case 'Restaurant':
        return AppTheme.warning;
      case 'Driver':
        return AppTheme.teal;
      default:
        return const Color(0xFF8A8A8A);  // AppTheme.mutedText color value
    }
  }

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
            gradient: AppTheme.cardGlowGradient(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.person, size: 25, color: AppTheme.getMutedTextColor(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    Text(
                      user['email']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
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
                              color: user['status'] == 'Active' ? AppTheme.success : AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: AppTheme.getMutedTextColor(context)),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

// Restaurant Management Content
class _RestaurantManagementContent extends StatelessWidget {
  const _RestaurantManagementContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Restaurant Management',
        style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
      ),
    );
  }
}

// Driver Management Content
class _DriverManagementContent extends StatelessWidget {
  const _DriverManagementContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Driver Management',
        style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
      ),
    );
  }
}

// Reports Content
class _ReportsContent extends StatelessWidget {
  const _ReportsContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reports',
        style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
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