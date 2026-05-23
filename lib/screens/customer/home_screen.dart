import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/featured_meal_card.dart';
import '../../widgets/customer/delivery_status_card.dart';
import 'search_screen.dart';
import 'checkout_screen.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';
import '../notifications/notifications_screen.dart';
import 'food_detail_screen.dart';

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

  // Updated featured meals with complete restaurant information
  final List<Map<String, dynamic>> _featuredMeals = [
    {
      'id': '1',
      'name': 'Salmon Poke Supreme',
      'description': 'Fresh salmon poke with avocado, cucumber, and special sauce. A healthy and delicious bowl that will leave you wanting more.',
      'price': 'MK4,000',
      'rating': 4.0,
      'reviews': 128,
      'prepTime': '15-20 min',
      'restaurant': 'Sushi Master',
      'restaurantId': '1',
      'restaurantAddress': '123 Beach Road, Cape Maclear',
      'restaurantRating': 4.8,
      'restaurantDeliveryTime': '25-35 min',
      'ingredients': ['Fresh Salmon', 'Avocado', 'Cucumber', 'Sesame Seeds', 'Special Sauce'],
    },
    {
      'id': '2',
      'name': 'Classic Lugga Kaki',
      'description': 'Traditional Malawian dish with tender beef, fresh vegetables, and served with nsima. A local favorite!',
      'price': 'MK8,000',
      'rating': 4.5,
      'reviews': 256,
      'prepTime': '20-25 min',
      'restaurant': 'Luspernando Food Hub',
      'restaurantId': '2',
      'restaurantAddress': '456 Freedom Road, Lilongwe',
      'restaurantRating': 4.9,
      'restaurantDeliveryTime': '30-40 min',
      'ingredients': ['Beef', 'Spinach', 'Tomatoes', 'Onions', 'Nsima'],
    },
    {
      'id': '3',
      'name': 'Spicy Chicken Burger',
      'description': 'Grilled chicken breast with spicy sauce, fresh lettuce, melted cheese, and a soft brioche bun.',
      'price': 'MK5,500',
      'rating': 4.3,
      'reviews': 89,
      'prepTime': '15-20 min',
      'restaurant': 'BossMan',
      'restaurantId': '3',
      'restaurantAddress': '789 Presidential Way, Blantyre',
      'restaurantRating': 4.7,
      'restaurantDeliveryTime': '20-30 min',
      'ingredients': ['Chicken Breast', 'Spicy Sauce', 'Lettuce', 'Cheese', 'Brioche Bun'],
    },
  ];

  final List<Map<String, dynamic>> _topRestaurants = [
    {
      'id': '1',
      'name': 'Luspernando Food Hub',
      'cuisine': 'Zombo • Chikanda • Ndekhalira',
      'rating': 4.9,
      'reviews': '1k+',
      'time': '10 min',
    },
    {
      'id': '2',
      'name': 'BossMan',
      'cuisine': 'Zombo • Chikanda • CHANCO',
      'rating': 4.7,
      'reviews': '800+',
      'time': '5 min',
    },
    {
      'id': '3',
      'name': 'Makawa',
      'cuisine': 'Zombo • Chikanda • Chikanda',
      'rating': 4.5,
      'reviews': '450+',
      'time': '15 min',
    },
  ];

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/search', extra: query.trim());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/search');
        break;
      case 2:
        context.push('/checkout');
        break;
      case 3:
        context.push('/my-orders');
        break;
      case 4:
        context.push('/settings');
        break;
      case 5:
        context.push('/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Welcome Text
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'What would you like to eat today?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.push('/notifications');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontSize: 14),
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search for sushi, pizza...',
                    hintStyle: TextStyle(color: AppTheme.getMutedTextColor(context), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppTheme.getMutedTextColor(context), size: 20),
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Categories Horizontal List
                    SizedBox(
                      height: 38,
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
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Meals',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Featured Meals Horizontal Scroll - Clickable
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _featuredMeals.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              context.push('/food-detail', extra: _featuredMeals[index]);
                            },
                            child: FeaturedMealCard(
                              meal: _featuredMeals[index],
                              onTap: () {
                                context.push('/food-detail', extra: _featuredMeals[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Top Rated Restaurants Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Rated Restaurants',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getPrimaryTextColor(context),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 13,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _topRestaurants.length,
                      itemBuilder: (context, index) {
                        return RestaurantCard(
                          restaurant: _topRestaurants[index],
                          onTap: () {
                            context.push('/restaurant-details');
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}