import '../../services/order_service.dart';
import '../../services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../services/restaurant_service.dart';
import '../../services/order_service.dart';
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
  Map<String, dynamic>? _stats;
  bool _statsLoading = true;

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

  Future<void> _loadStats() async {
    try {
      final stats = await RestaurantService.getRestaurantStats();
      setState(() { _stats = stats is Map ? stats as Map<String, dynamic> : null; _statsLoading = false; });
    } catch (e) {
      setState(() { _statsLoading = false; });
    }
  }

  Future<void> _toggleOpen(bool value) async {
    try {
      await RestaurantService.updateMyRestaurant({'is_open': value});
      setState(() => _isRestaurantOpen = value);
      _showSnackBar(_isRestaurantOpen ? 'Restaurant is now Open' : 'Restaurant is now Closed');
    } catch (e) {
      _showSnackBar('Failed to update status', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      duration: const Duration(seconds: 2),
    ));
  }

  void _handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    context.go('/login');
  }

  String _getCurrentRoute() {
    switch (_selectedIndex) {
      case 0: return '/restaurant/dashboard';
      case 1: return '/restaurant/orders';
      case 2: return '/restaurant/menu';
      case 3: return '/restaurant/profile';
      default: return '/restaurant/dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantName = authProvider.currentUser?.name ?? 'My Restaurant';

    final screens = [
      _DashboardContent(stats: _stats, statsLoading: _statsLoading, onViewAllOrders: () => setState(() => _selectedIndex = 1)),
      const RestaurantOrdersScreen(),
      const MenuManagementScreen(),
      const RestaurantProfileScreen(),
    ];

    return SidebarMenu(
      currentRoute: _getCurrentRoute(),
      items: _menuItems,
      onLogout: _handleLogout,
      onMenuItemTap: (index) => setState(() => _selectedIndex = index),
      child: Scaffold(
        backgroundColor: AppTheme.mainBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.mainBackground,
          elevation: 0,
          title: const Text('Restaurant Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isRestaurantOpen ? AppTheme.success.withOpacity(0.15) : AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isRestaurantOpen ? AppTheme.success : AppTheme.error, width: 0.8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: _isRestaurantOpen ? AppTheme.success : AppTheme.error, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_isRestaurantOpen ? 'Open' : 'Closed',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _isRestaurantOpen ? AppTheme.success : AppTheme.error)),
                const SizedBox(width: 6),
                Transform.scale(scale: 0.7, child: Switch(
                  value: _isRestaurantOpen,
                  onChanged: _toggleOpen,
                  activeColor: AppTheme.success,
                  inactiveThumbColor: AppTheme.error,
                  inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                )),
              ]),
            ),
          ],
        ),
        body: screens[_selectedIndex],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final Map<String, dynamic>? stats;
  final bool statsLoading;
  final VoidCallback onViewAllOrders;

  const _DashboardContent({this.stats, required this.statsLoading, required this.onViewAllOrders});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  List<dynamic> _recentOrders = [];
  bool _ordersLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentOrders();
  }

  Future<void> _loadRecentOrders() async {
    try {
      final orders = await OrderService.getOrders();
      setState(() {
        _recentOrders = (orders as List).take(3).toList();
        _ordersLoading = false;
      });
    } catch (e) {
      setState(() => _ordersLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final todayEarnings = double.tryParse(stats?['today_earnings']?.toString() ?? '0') ?? 0;
    final todayOrders = stats?['today_orders'] ?? 0;
    final totalEarnings = double.tryParse(stats?['total_earnings']?.toString() ?? '0') ?? 0;
    final rating = double.tryParse(stats?['average_rating']?.toString() ?? '0') ?? 0;
    final activeOrders = stats?['active_orders'] ?? 0;
    final totalOrders = stats?['total_orders'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadRecentOrders,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            widget.statsLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.primaryRed)))
                : Column(children: [
                    Row(children: [
                      Expanded(child: _buildStatCard(title: 'Today\'s Earnings', value: 'MK${todayEarnings.toInt()}', icon: Icons.today, color: AppTheme.primaryRed, subtitle: '$activeOrders active orders')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(title: 'Today\'s Orders', value: '$todayOrders', icon: Icons.receipt, color: AppTheme.orange, subtitle: '$activeOrders active')),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _buildStatCard(title: 'Total Earnings', value: 'MK${totalEarnings.toInt()}', icon: Icons.attach_money, color: AppTheme.success, subtitle: '$totalOrders total orders')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(title: 'Rating', value: '$rating', icon: Icons.star, color: AppTheme.yellow, subtitle: '★ reviews')),
                    ]),
                  ]),

            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              GestureDetector(
                onTap: widget.onViewAllOrders,
                child: const Text('View All', style: TextStyle(fontSize: 12, color: AppTheme.primaryRed, fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 12),

            _ordersLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
                : _recentOrders.isEmpty
                    ? Center(child: Text('No recent orders', style: TextStyle(color: AppTheme.secondaryText)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentOrders.length,
                        itemBuilder: (context, index) => _buildRecentOrderCard(_recentOrders[index]),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.mutedText)),
      ]),
    );
  }

  Widget _buildRecentOrderCard(dynamic order) {
    final items = (order['items'] as List?) ?? [];
    final total = order['total_price'] ?? '0';
    final createdStr = order['created'] as String?;
    final created = createdStr != null ? DateTime.tryParse(createdStr) : null;
    final timeAgo = created != null ? '${DateTime.now().difference(created).inMinutes} min ago' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.secondaryBackground, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, size: 20, color: AppTheme.mutedText)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order['customer_name'] ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          const SizedBox(height: 2),
          Text('${items.length} items • MK$total', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
        ])),
        Text(timeAgo, style: TextStyle(fontSize: 11, color: AppTheme.mutedText)),
      ]),
    );
  }
}