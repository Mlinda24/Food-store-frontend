import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/featured_meal_card.dart';
import '../../widgets/customer/delivery_status_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  
  // Search state
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'All', 'Pizza', 'Burgers', 'Sushi', 'Local', 'Desserts'
  ];

  // Expanded featured meals with more Malawian dishes
  final List<Map<String, dynamic>> _featuredMeals = [
    // Original meals
    {
      'id': '1',
      'name': 'Salmon Poke Supreme',
      'description': 'Fresh salmon poke with avocado, cucumber, and special sauce',
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
      'type': 'meal',
    },
    {
      'id': '2',
      'name': 'Classic Lugga Kaki',
      'description': 'Traditional Malawian dish with tender beef and nsima',
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
      'type': 'meal',
    },
    {
      'id': '3',
      'name': 'Spicy Chicken Burger',
      'description': 'Grilled chicken breast with spicy sauce and cheese',
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
      'type': 'meal',
    },
    // New Malawian meals
    {
      'id': '4',
      'name': 'Chambo with Nsima',
      'description': 'Fresh grilled Chambo fish served with soft nsima and tomato onion relish',
      'price': 'MK6,500',
      'rating': 4.9,
      'reviews': 312,
      'prepTime': '25-30 min',
      'restaurant': 'Lakeshore Delights',
      'restaurantId': '4',
      'restaurantAddress': 'Cape Maclear Beach',
      'restaurantRating': 4.9,
      'restaurantDeliveryTime': '35-45 min',
      'ingredients': ['Chambo', 'Nsima', 'Tomatoes', 'Onions', 'Local Spices'],
      'type': 'meal',
    },
    {
      'id': '5',
      'name': 'Zitumbuwa (Banana Fritters)',
      'description': 'Sweet ripe banana fritters, crispy outside and soft inside',
      'price': 'MK2,500',
      'rating': 4.6,
      'reviews': 178,
      'prepTime': '10-15 min',
      'restaurant': 'Sweet Tooth Cafe',
      'restaurantId': '5',
      'restaurantAddress': 'Lilongwe City Mall',
      'restaurantRating': 4.5,
      'restaurantDeliveryTime': '15-20 min',
      'ingredients': ['Ripe Bananas', 'Flour', 'Sugar', 'Oil'],
      'type': 'meal',
    },
    {
      'id': '6',
      'name': 'Kachumbari Salad',
      'description': 'Fresh tomato, onion, and chili salad with lime juice',
      'price': 'MK1,800',
      'rating': 4.2,
      'reviews': 95,
      'prepTime': '5-10 min',
      'restaurant': 'Healthy Bites',
      'restaurantId': '6',
      'restaurantAddress': 'Blantyre City Centre',
      'restaurantRating': 4.3,
      'restaurantDeliveryTime': '10-15 min',
      'ingredients': ['Tomatoes', 'Onions', 'Chili', 'Lime', 'Coriander'],
      'type': 'meal',
    },
    {
      'id': '7',
      'name': 'Mpunga wa Mbewa (Rice with Peas)',
      'description': 'Fragrant rice cooked with local peas and coconut milk',
      'price': 'MK3,200',
      'rating': 4.4,
      'reviews': 143,
      'prepTime': '20-25 min',
      'restaurant': 'Mulanje Kitchen',
      'restaurantId': '7',
      'restaurantAddress': 'Mulanje Town',
      'restaurantRating': 4.6,
      'restaurantDeliveryTime': '25-30 min',
      'ingredients': ['Rice', 'Green Peas', 'Coconut Milk', 'Onions', 'Spices'],
      'type': 'meal',
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
      'type': 'restaurant',
    },
    {
      'id': '2',
      'name': 'BossMan',
      'cuisine': 'Zombo • Chikanda • CHANCO',
      'rating': 4.7,
      'reviews': '800+',
      'time': '5 min',
      'type': 'restaurant',
    },
    {
      'id': '3',
      'name': 'Makawa',
      'cuisine': 'Zombo • Chikanda • Chikanda',
      'rating': 4.5,
      'reviews': '450+',
      'time': '15 min',
      'type': 'restaurant',
    },
  ];

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        final lowerQuery = query.toLowerCase();
        final restaurantMatches = _topRestaurants.where((r) =>
            r['name'].toString().toLowerCase().contains(lowerQuery) ||
            r['cuisine'].toString().toLowerCase().contains(lowerQuery)).toList();
        final mealMatches = _featuredMeals.where((m) =>
            m['name'].toString().toLowerCase().contains(lowerQuery) ||
            m['restaurant'].toString().toLowerCase().contains(lowerQuery) ||
            m['description'].toString().toLowerCase().contains(lowerQuery)).toList();
        _searchResults = [...restaurantMatches, ...mealMatches];
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _onSearchChanged(query);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.push('/search');
        break;
      case 2:
        context.push('/cart');
        break;
      case 3:
        context.push('/my-orders');
        break;
      case 4:
        context.push('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Welcome Text and Notification Icon
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: AppTheme.getPrimaryTextColor(context), size: 26),
                    onPressed: () => context.push('/notifications'),
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
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search for sushi, pizza...',
                    hintStyle: TextStyle(color: AppTheme.getMutedTextColor(context), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppTheme.getMutedTextColor(context), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppTheme.getMutedTextColor(context), size: 18),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            // Main content: either search results or normal home feed
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(context)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const DeliveryStatusCard(),
                          // Categories section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Categories',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                        color: AppTheme.getPrimaryTextColor(context))),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('See All',
                                      style: TextStyle(color: AppTheme.primaryRed, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) => CategoryChip(
                                label: _categories[index],
                                isSelected: _selectedCategory == _categories[index],
                                onTap: () => setState(() => _selectedCategory = _categories[index]),
                              ),
                            ),
                          ),
                          // Featured Meals - with reduced card size
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Featured Meals',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                        color: AppTheme.getPrimaryTextColor(context))),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('See All',
                                      style: TextStyle(color: AppTheme.primaryRed, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 220, // Reduced height for smaller cards
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _featuredMeals.length,
                              itemBuilder: (context, index) {
                                final meal = _featuredMeals[index];
                                return GestureDetector(
                                  onTap: () => context.push('/food-detail', extra: meal),
                                  child: FeaturedMealCard(
                                    meal: meal,
                                    onTap: () => context.push('/food-detail', extra: meal),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Top Rated Restaurants
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Top Rated Restaurants',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                        color: AppTheme.getPrimaryTextColor(context))),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('See All',
                                      style: TextStyle(color: AppTheme.primaryRed, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _topRestaurants.length,
                            itemBuilder: (context, index) => RestaurantCard(
                              restaurant: _topRestaurants[index],
                              onTap: () => context.push('/restaurant-details', extra: _topRestaurants[index]),
                            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_outlined), activeIcon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.getMutedTextColor(context)),
            const SizedBox(height: 16),
            Text('No results found for "${_searchController.text}"',
                style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        if (item['type'] == 'restaurant') {
          return RestaurantCard(
            restaurant: item,
            onTap: () {
              _clearSearch();
              context.push('/restaurant-details', extra: item);
            },
          );
        } else {
          return GestureDetector(
            onTap: () {
              _clearSearch();
              context.push('/food-detail', extra: item);
            },
            child: FeaturedMealCard(meal: item, onTap: () {}),
          );
        }
      },
    );
  }
}