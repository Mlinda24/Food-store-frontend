import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import 'restaurant_orders_screen.dart';
import 'menu_management_screen.dart';

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
    const _SettingsContent(),  // Settings with Profile
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantName = authProvider.currentUser?.name ?? 'My Restaurant';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          'Menu Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryTextColor(context),
          ),
        ),
        centerTitle: true,
        actions: [
          // Shop Status Toggle
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.getCardColor(context),
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: AppTheme.getMutedTextColor(context),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Dashboard Content
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  void _viewAllOrders(BuildContext context) {
    final state = context.findAncestorStateOfType<_RestaurantDashboardScreenState>();
    if (state != null) {
      state.setState(() {
        state._selectedIndex = 1;
      });
    }
  }

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
                  context,
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
                  context,
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
                  context,
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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
              ),
              GestureDetector(
                onTap: () => _viewAllOrders(context),
                child: Text(
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
              return _buildRecentOrderCard(context, index);
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
    required String subtitle,
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.getMutedTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, int index) {
    final List<Map<String, String>> orders = [
      {'customer': 'John Doe', 'items': '2 items', 'total': 'MK8,500', 'time': '10 min ago'},
      {'customer': 'Jane Smith', 'items': '3 items', 'total': 'MK12,200', 'time': '25 min ago'},
      {'customer': 'Mike Johnson', 'items': '1 item', 'total': 'MK4,500', 'time': '35 min ago'},
    ];
    final order = orders[index];

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
            child: Icon(Icons.person, size: 20, color: AppTheme.getMutedTextColor(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['customer']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order['items']} • ${order['total']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            order['time']!,
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

// Settings Content with Profile
class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Text('Logout', style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    authProvider.logout();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurantName = authProvider.currentUser?.name ?? 'My Restaurant';
    final restaurantEmail = authProvider.currentUser?.email ?? 'restaurant@example.com';
    final restaurantPhone = authProvider.currentUser?.phone ?? '+265 888 123 456';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card - THIS IS THE PROFILE SECTION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGlowGradient(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                // Profile Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryButtonGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryRed, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Restaurant Name
                Text(
                  restaurantName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  restaurantEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                // Phone
                Text(
                  restaurantPhone,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                // Edit Profile Button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/restaurant-profile');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Account Actions Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'ACCOUNT ACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.getMutedTextColor(context),
                letterSpacing: 1,
              ),
            ),
          ),
          
          // Switch to Customer Button
          _buildSettingsItem(
            context,
            icon: Icons.switch_account_outlined,
            title: 'Switch to Customer',
            subtitle: 'Switch to customer mode',
            onTap: () {
              context.go('/settings');
            },
            iconColor: AppTheme.warning,
          ),
          
          const Divider(height: 1, color: AppTheme.deepCrimson, indent: 70, endIndent: 16),
          
          // Logout Button
          _buildSettingsItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context),
            textColor: AppTheme.error,
            iconColor: AppTheme.error,
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor ?? AppTheme.primaryRed),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.getMutedTextColor(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Restaurant Stats Model
class RestaurantStats {
  final double todayEarnings;
  final int todayOrders;
  final double totalEarnings;
  final int totalOrders;
  final double averageRating;
  final int activeOrders;
  final double monthlyEarnings;
  final int monthlyOrders;

  RestaurantStats({
    required this.todayEarnings,
    required this.todayOrders,
    required this.totalEarnings,
    required this.totalOrders,
    required this.averageRating,
    required this.activeOrders,
    required this.monthlyEarnings,
    required this.monthlyOrders,
  });
}