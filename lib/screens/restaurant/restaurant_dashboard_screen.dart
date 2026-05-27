import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import 'restaurant_orders_screen.dart';
import 'menu_management_screen.dart';
import 'restaurant_profile_screen.dart';
import 'withdraw_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    provider.loadRestaurantData();
    provider.loadRestaurantOrders();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Orders';
      case 2:
        return 'Menu';
      case 3:
        return 'Settings';
      default:
        return 'Restaurant Dashboard';
    }
  }

  List<Widget> _getScreens() {
    return [
      const _DashboardContent(),
      const RestaurantOrdersScreen(),
      const MenuManagementScreen(),
      const _SettingsContent(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryTextColor(context),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: _getScreens()[_selectedIndex],
      ),
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

// Dashboard Content with real data
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  String _formatCurrency(dynamic value) {
    if (value == null) return 'MK0';
    double numValue;
    if (value is double) {
      numValue = value;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else {
      numValue = 0;
    }
    return 'MK${numValue.toStringAsFixed(0)}';
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value is double) return value.toInt().toString();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.toInt().toString();
      }
      return value;
    }
    return '0';
  }

  String _formatRating(dynamic value) {
    if (value == null) return '0.0';
    double numValue;
    if (value is double) {
      numValue = value;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else {
      numValue = 0;
    }
    return numValue.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);
    final stats = provider.stats;
    final isLoading = provider.isLoading;
    final restaurant = provider.restaurant;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: Today's Earnings & Today's Orders
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Today\'s Earnings',
                  value: _formatCurrency(stats?.todayEarnings),
                  icon: Icons.today,
                  color: AppTheme.primaryRed,
                  subtitle: 'From ${_formatNumber(stats?.todayOrders)} orders',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Today\'s Orders',
                  value: _formatNumber(stats?.todayOrders),
                  icon: Icons.receipt,
                  color: AppTheme.orange,
                  subtitle: '${_formatNumber(stats?.activeOrders)} active',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Available Balance (Withdrawable) & Rating
          Row(
            children: [
              Expanded(
                child: _buildStatCardWithWithdraw(
                  context,
                  title: 'Available Balance',
                  value: _formatCurrency(stats?.walletBalance),
                  icon: Icons.wallet,
                  color: AppTheme.success,
                  subtitle: 'Withdrawable amount (after fees)',
                  onWithdraw: () {
                    context.push('/withdraw');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Rating',
                  value: _formatRating(stats?.averageRating),
                  icon: Icons.star,
                  color: AppTheme.yellow,
                  subtitle: '★ ${_formatNumber(stats?.totalOrders)} reviews',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total Earnings Card (for reference - not withdrawable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: AppTheme.getSecondaryTextColor(context)),
                    const SizedBox(width: 8),
                    Text(
                      'Total Lifetime Earnings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(stats?.totalEarnings),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Open/Close Toggle
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: restaurant?.isOpen == true
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: restaurant?.isOpen == true
                    ? AppTheme.success
                    : AppTheme.error,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: restaurant?.isOpen == true
                            ? AppTheme.success
                            : AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Restaurant Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: restaurant?.isOpen == true,
                  onChanged: (value) async {
                    await provider.toggleRestaurantStatus(value);
                  },
                  activeColor: AppTheme.success,
                  inactiveThumbColor: AppTheme.error,
                ),
              ],
            ),
          ),

          // Restaurant Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGlowGradient(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  restaurant?.name ?? 'Restaurant Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant?.address ?? 'Address not set',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant?.phone ?? 'Phone not set',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardWithWithdraw(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onWithdraw,
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
              GestureDetector(
                onTap: onWithdraw,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wallet, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Withdraw',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
}

// Settings Content
class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => __SettingsContentState();
}

class __SettingsContentState extends State<_SettingsContent> {
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
        title: Text('Logout',
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
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
                      side: BorderSide(
                          color: AppTheme.getMutedTextColor(context)
                              .withOpacity(0.5)),
                    ),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context))),
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
                  child: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final restaurant = restaurantProvider.restaurant;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryRed.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 50,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  restaurant?.name ?? 'My Restaurant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant?.address ?? 'Address not set',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Menu Items
          ListTile(
            leading:
                const Icon(Icons.restaurant_menu, color: AppTheme.primaryRed),
            title: const Text('Manage Menu'),
            subtitle: const Text('Add, edit or remove menu items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final state = context
                  .findAncestorStateOfType<_RestaurantDashboardScreenState>();
              if (state != null) {
                state.setState(() {
                  state._selectedIndex = 2;
                });
              }
            },
          ),

          const Divider(),

          // Orders
          ListTile(
            leading: const Icon(Icons.receipt, color: AppTheme.primaryRed),
            title: const Text('View Orders'),
            subtitle: const Text('Manage incoming orders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final state = context
                  .findAncestorStateOfType<_RestaurantDashboardScreenState>();
              if (state != null) {
                state.setState(() {
                  state._selectedIndex = 1;
                });
              }
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primaryRed),
            title: const Text('Restaurant Profile'),
            subtitle: const Text('View and edit profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/restaurant-profile');
            },
          ),

          const Divider(),

          // Withdraw (Quick Action)
          ListTile(
            leading: const Icon(Icons.wallet, color: AppTheme.primaryRed),
            title: const Text('Withdraw Funds'),
            subtitle: const Text('Withdraw your earnings to mobile money'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/withdraw');
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: Text('Logout', style: TextStyle(color: AppTheme.error)),
            trailing: Icon(Icons.chevron_right, color: AppTheme.error),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}
