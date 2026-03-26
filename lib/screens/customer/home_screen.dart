import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/featured_meal_card.dart';
import '../../widgets/customer/delivery_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  final List<String> _categories = [
    'All',
    'Pizza',
    'Burgers',
    'Sushi',
    'Local',
    'Desserts'
  ];

  final List<Map<String, dynamic>> _featuredMeals = [
    {
      'name': 'Salmon Poke Supreme',
      'description': 'Green Garden + 15-20 min',
      'price': 'MK4,000',
      'rating': 4.0,
      'image': null,
    },
    {
      'name': 'Classic Lugga Kaki',
      'description': 'Traditional taste',
      'price': 'MK8,000',
      'rating': 4.5,
      'image': null,
    },
    {
      'name': 'Spicy Chicken Burger',
      'description': 'Grilled chicken + 20 min',
      'price': 'MK5,500',
      'rating': 4.3,
      'image': null,
    },
  ];

  final List<Map<String, dynamic>> _topRestaurants = [
    {
      'name': 'Luspernando Food Hub',
      'cuisine': 'Zombo • Chikanda • Ndekhalira',
      'rating': 4.9,
      'reviews': '1k+',
      'time': '10 min',
      'image': null,
    },
    {
      'name': 'BossMan',
      'cuisine': 'Zombo • Chikanda • CHANCO',
      'rating': 4.7,
      'reviews': '800+',
      'time': '5 min',
      'image': null,
    },
    {
      'name': 'Makawa',
      'cuisine': 'Zombo • Chikanda • Chikanda',
      'rating': 4.5,
      'reviews': '450+',
      'time': '15 min',
      'image': null,
    },
    {
      'name': 'Tasty Bites',
      'cuisine': 'Burger • Pizza • Pasta',
      'rating': 4.6,
      'reviews': '600+',
      'time': '12 min',
      'image': null,
    },
    {
      'name': 'Flame Grill',
      'cuisine': 'Steak • Chicken • Ribs',
      'rating': 4.8,
      'reviews': '900+',
      'time': '20 min',
      'image': null,
    },
  ];

  void _handleLogout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    context.go('/login');
  }

  String _getCurrentRoute() {
    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      const SidebarMenuItem(title: 'Home', icon: Icons.home_outlined, route: '/home'),
      const SidebarMenuItem(title: 'Search', icon: Icons.search_outlined, route: '/search'),
      const SidebarMenuItem(title: 'My Cart', icon: Icons.shopping_cart_outlined, route: '/checkout'),
      const SidebarMenuItem(title: 'My Orders', icon: Icons.receipt_outlined, route: '/my-orders'),
      const SidebarMenuItem(title: 'Profile', icon: Icons.person_outline, route: '/profile'),
      const SidebarMenuItem(title: 'Notifications', icon: Icons.notifications_outlined, route: '/notifications'),
    ];

    return SidebarMenu(
      currentRoute: _getCurrentRoute(),
      items: menuItems,
      onLogout: _handleLogout,
      child: Scaffold(
        backgroundColor: AppTheme.mainBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Header with Delivery Info
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY TO',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Precious Kapakasa',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: AppTheme.mutedText,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppTheme.primaryText, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search for sushi, pizza...',
                      hintStyle: TextStyle(color: AppTheme.mutedText, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: AppTheme.mutedText, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const DeliveryStatusCard(),
                      
                      // Categories Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Categories Horizontal List
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            return CategoryChip(
                              label: _categories[index],
                              isSelected: _selectedCategory == _categories[index],
                              onTap: () {
                                setState(() {
                                  _selectedCategory = _categories[index];
                                });
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Featured Meals Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Featured Meals',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Featured Meals Horizontal List
                      SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _featuredMeals.length,
                          itemBuilder: (context, index) {
                            return FeaturedMealCard(
                              meal: _featuredMeals[index],
                              onTap: () {
                                // Navigate to food details
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Top Rated Restaurants Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Top Rated Restaurants',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Restaurants List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _topRestaurants.length,
                        itemBuilder: (context, index) {
                          return RestaurantCard(
                            restaurant: _topRestaurants[index],
                            onTap: () {
                              context.go('/restaurant-details');
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}