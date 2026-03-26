import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/sidebar_menu.dart';
import 'restaurant_orders_screen.dart';
import 'menu_management_screen.dart';
import 'restaurant_profile_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _selectedIndex = 0;
  bool _isRestaurantOpen = true;
  late RestaurantStats _stats;
  
  final List<Widget> _screens = [
    const _DashboardContent(),
    const RestaurantOrdersScreen(),
    const MenuManagementScreen(),
    const RestaurantProfileScreen(),
  ];
  
  final List<SidebarMenuItem> _menuItems = const [
    SidebarMenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/restaurant/dashboard'),
    SidebarMenuItem(title: 'Orders', icon: Icons.receipt_outlined, route: '/restaurant/orders'),
    SidebarMenuItem(title: 'Menu', icon: Icons.restaurant_menu_outlined, route: '/restaurant/menu'),
    SidebarMenuItem(title: 'Profile', icon: Icons.person_outline, route: '/restaurant/profile'),
    SidebarMenuItem(title: 'Settings', icon: Icons.settings_outlined, route: '/restaurant/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _stats = RestaurantStats(
      todayEarnings: 24500,
      todayOrders: 8,
      totalEarnings: 125000,
      totalOrders: 42,
      averageRating: 4.8,
      activeOrders: 3,
      monthlyEarnings: 87400,
      monthlyOrders: 28,
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

  void _onMenuItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getCurrentRoute() {
    switch (_selectedIndex) {
      case 0:
        return '/restaurant/dashboard';
      case 1:
        return '/restaurant/orders';
      case 2:
        return '/restaurant/menu';
      case 3:
        return '/restaurant/profile';
      default:
        return '/restaurant/dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantName = authProvider.currentUser?.name ?? 'My Restaurant';

    return SidebarMenu(
      currentRoute: _getCurrentRoute(),
      items: _menuItems,
      onLogout: _handleLogout,
      onMenuItemTap: _onMenuItemTap,
      child: Scaffold(
        backgroundColor: AppTheme.mainBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.mainBackground,
          elevation: 0,
          // 3-dot button is now handled by SidebarMenu at top-left
          // So we remove the leading from here
          title: const Text(
            'Restaurant Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          centerTitle: true,
          actions: [
            // Open/Close Toggle - Moved to top-right, reduced size
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isRestaurantOpen ? AppTheme.success.withOpacity(0.15) : AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRestaurantOpen ? AppTheme.success : AppTheme.error,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isRestaurantOpen ? AppTheme.success : AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isRestaurantOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _isRestaurantOpen ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: _isRestaurantOpen,
                      onChanged: (value) {
                        setState(() {
                          _isRestaurantOpen = value;
                        });
                        _showSnackBar(
                          _isRestaurantOpen ? 'Restaurant is now Open' : 'Restaurant is now Closed',
                        );
                      },
                      activeColor: AppTheme.success,
                      inactiveThumbColor: AppTheme.error,
                      inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                    ),
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

// Dashboard Content
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

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
                  value: 'MK24,500',
                  icon: Icons.today,
                  color: AppTheme.primaryRed,
                  subtitle: '+15% from yesterday',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Today\'s Orders',
                  value: '8',
                  icon: Icons.receipt,
                  color: AppTheme.orange,
                  subtitle: '3 active orders',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Earnings',
                  value: 'MK125,000',
                  icon: Icons.attach_money,
                  color: AppTheme.success,
                  subtitle: 'Lifetime',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Rating',
                  value: '4.8',
                  icon: Icons.star,
                  color: AppTheme.yellow,
                  subtitle: '★ 124 reviews',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Orders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final state = context.findAncestorStateOfType<_RestaurantDashboardScreenState>();
                  if (state != null) {
                    state.setState(() {
                      state._selectedIndex = 1;
                    });
                  }
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildRecentOrderCard(index);
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
    required String subtitle,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderCard(int index) {
    final List<Map<String, String>> orders = [
      {'customer': 'John Doe', 'items': '2 items', 'total': 'MK8,500', 'time': '10 min ago', 'orderId': 'ORD-001'},
      {'customer': 'Jane Smith', 'items': '3 items', 'total': 'MK12,200', 'time': '25 min ago', 'orderId': 'ORD-002'},
      {'customer': 'Mike Johnson', 'items': '1 item', 'total': 'MK4,500', 'time': '35 min ago', 'orderId': 'ORD-003'},
    ];
    final order = orders[index];

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
            child: const Icon(Icons.person, size: 20, color: AppTheme.mutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order['items']} • ${order['total']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            order['time']!,
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