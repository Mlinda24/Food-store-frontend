import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/customer/featured_meal_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Appetising meals only - no restaurants
  final List<Map<String, dynamic>> _featuredMeals = [
    {
      'id': '1',
      'name': 'Grilled Chambo',
      'description': 'Fresh Lake Malawi chambo fish, grilled to perfection with local spices',
      'price': 'MK6,500',
      'rating': 4.9,
      'image': 'assets/images/chambo.jpg',
      'type': 'meal',
    },
    {
      'id': '2',
      'name': 'Nsima with Beef',
      'description': 'Traditional Malawian nsima served with tender beef stew and vegetables',
      'price': 'MK4,500',
      'rating': 4.8,
      'image': 'assets/images/nsima.jpg',
      'type': 'meal',
    },
    {
      'id': '3',
      'name': 'Spicy Chicken Wings',
      'description': 'Crispy chicken wings tossed in spicy peri-peri sauce',
      'price': 'MK3,800',
      'rating': 4.7,
      'image': 'assets/images/wings.jpg',
      'type': 'meal',
    },
    {
      'id': '4',
      'name': 'Zitumbuwa (Banana Fritters)',
      'description': 'Sweet ripe banana fritters, crispy outside and soft inside',
      'price': 'MK2,500',
      'rating': 4.6,
      'image': 'assets/images/zitumbuwa.jpg',
      'type': 'meal',
    },
    {
      'id': '5',
      'name': 'Beef Burger Deluxe',
      'description': 'Juicy beef patty with cheese, lettuce, tomato, and special sauce',
      'price': 'MK5,500',
      'rating': 4.5,
      'image': 'assets/images/burger.jpg',
      'type': 'meal',
    },
    {
      'id': '6',
      'name': 'Vegetable Pasta',
      'description': 'Penne pasta with fresh vegetables in creamy Alfredo sauce',
      'price': 'MK4,200',
      'rating': 4.4,
      'image': 'assets/images/pasta.jpg',
      'type': 'meal',
    },
    {
      'id': '7',
      'name': 'Grilled Chicken',
      'description': 'Half chicken marinated in herbs and grilled to perfection',
      'price': 'MK7,000',
      'rating': 4.8,
      'image': 'assets/images/grilled_chicken.jpg',
      'type': 'meal',
    },
    {
      'id': '8',
      'name': 'Fish and Chips',
      'description': 'Crispy battered fish served with golden fries and tartar sauce',
      'price': 'MK4,800',
      'rating': 4.3,
      'image': 'assets/images/fish_chips.jpg',
      'type': 'meal',
    },
    {
      'id': '9',
      'name': 'Chicken Curry',
      'description': 'Tender chicken in aromatic coconut curry sauce with rice',
      'price': 'MK5,200',
      'rating': 4.7,
      'image': 'assets/images/curry.jpg',
      'type': 'meal',
    },
    {
      'id': '10',
      'name': 'Margherita Pizza',
      'description': 'Classic pizza with tomato sauce, fresh mozzarella, and basil',
      'price': 'MK4,500',
      'rating': 4.6,
      'image': 'assets/images/pizza.jpg',
      'type': 'meal',
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
        _searchResults = _featuredMeals.where((m) =>
            m['name'].toString().toLowerCase().contains(lowerQuery) ||
            m['description'].toString().toLowerCase().contains(lowerQuery)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Welcome Text and Login Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delicious Food',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover the best meals in town',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  // Login Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontSize: 14),
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search for delicious meals...',
                    hintStyle: TextStyle(color: AppTheme.getMutedTextColor(context), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppTheme.getMutedTextColor(context), size: 18),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(context)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Hero Section
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryButtonGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=200',
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '50% OFF',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'on your first order',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () => context.go('/role-selection'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppTheme.primaryRed,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          ),
                                          child: const Text('Order Now'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Featured Meals Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(Icons.local_fire_department, color: AppTheme.primaryRed, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Popular Meals',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getPrimaryTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _featuredMeals.length,
                            itemBuilder: (context, index) {
                              final meal = _featuredMeals[index];
                              return _buildMealCard(meal);
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return GestureDetector(
      onTap: () => context.push('/food-detail', extra: meal),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Image Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.fastfood,
                  size: 50,
                  color: AppTheme.primaryRed.withOpacity(0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        meal['rating'].toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        meal['price'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Text(
              'No meals found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final meal = _searchResults[index];
        return _buildMealCard(meal);
      },
    );
  }
}