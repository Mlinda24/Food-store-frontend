import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/customer/restaurant_card.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/featured_meal_card.dart';
import '../../widgets/customer/delivery_status_card.dart';

// Simple animation widgets
class FadeInUp extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeInUp({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class FadeInDown extends StatelessWidget {
  final Widget child;

  const FadeInDown({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Data from API
  List<Map<String, dynamic>> _featuredMeals = [];
  List<Map<String, dynamic>> _topRestaurants = [];
  List<Map<String, dynamic>> _allMenuItems = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String? _error;

  // Search results state
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  /// Derives the correct bottom nav index from the current route.
  int _getNavIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/cart')) return 1;
    if (location.startsWith('/my-orders')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load cart from backend
      await context.read<CartProvider>().loadCart();

      // Fetch restaurants from API
      final restaurantsData = await _apiService.getRestaurants();
      final List<Map<String, dynamic>> restaurants = [];
      for (var rest in restaurantsData) {
        final imageUrl = _getImageUrl(rest['image']);

        restaurants.add({
          'id': rest['id'].toString(),
          'name': rest['name'] ?? 'Restaurant',
          'cuisine': _getCuisineString(rest['categories']),
          'rating': _getRating(rest),
          'type': 'restaurant',
          'address': rest['address'] ?? '',
          'is_open': rest['is_open'] ?? true,
          'image': imageUrl,
        });
      }
      _topRestaurants = restaurants;

      // Fetch menu items from API
      final menuItemsData = await _apiService.getMenuItems();
      _allMenuItems = [];
      final Set<String> categorySet = {'All'};

      for (var item in menuItemsData) {
        String itemCategory = _getCategoryName(item['category']);
        categorySet.add(itemCategory);

        final imageUrl = _getImageUrl(item['image']);

        final menuItem = {
          'id': item['id'].toString(),
          'name': item['name'] ?? 'Menu Item',
          'description': item['description'] ?? 'Delicious meal prepared with fresh ingredients',
          'price': 'MK${_formatPrice(item['price'])}',
          'price_value': double.tryParse(item['price']?.toString() ?? '0') ?? 0,
          'rating': _getMenuItemRating(item),
          'restaurant': _getRestaurantNameById(item['restaurant'].toString(), restaurantsData),
          'restaurantId': item['restaurant'].toString(),
          'image': imageUrl,
          'category': itemCategory,
          'is_available': item['is_available'] ?? true,
        };
        _allMenuItems.add(menuItem);
      }

      _categories = categorySet.toList();

      // Get featured meals (first 6 available items)
      _featuredMeals = _allMenuItems.where((item) => item['is_available'] == true).take(6).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading home data: $e');
    }
  }

  double _getRating(Map<String, dynamic> restaurant) {
    if (restaurant['rating'] != null) {
      if (restaurant['rating'] is double) return restaurant['rating'] as double;
      if (restaurant['rating'] is int) return (restaurant['rating'] as int).toDouble();
      if (restaurant['rating'] is String) {
        return double.tryParse(restaurant['rating'] as String) ?? 4.5;
      }
    }
    return 4.5;
  }

  double _getMenuItemRating(Map<String, dynamic> item) => 4.0;

  String _getImageUrl(dynamic image) {
    if (image == null) return '';
    if (image is String && image.isNotEmpty) {
      if (image.startsWith('http')) return image;
      if (image.startsWith('/media/')) return 'http://192.168.137.1:8000$image';
      if (image.startsWith('/')) return 'http://192.168.137.1:8000$image';
      return 'http://192.168.137.1:8000/media/$image';
    }
    return '';
  }

  String _getCategoryName(dynamic category) {
    if (category == null) return 'Uncategorized';
    if (category is Map) return category['name'] ?? 'Uncategorized';
    return category.toString();
  }

  String _getRestaurantNameById(String restaurantId, List<dynamic> restaurants) {
    for (var rest in restaurants) {
      if (rest['id'].toString() == restaurantId) return rest['name'] ?? 'Restaurant';
    }
    return 'Foodie Express';
  }

  String _getCuisineString(dynamic categories) {
    if (categories == null) return 'Delicious Food';
    if (categories is List && categories.isNotEmpty) {
      if (categories[0] is Map) return categories.map((c) => c['name'] ?? '').join(' • ');
      return categories.join(' • ');
    }
    return 'Various Cuisines';
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double val = double.tryParse(price.toString()) ?? 0;
    return val.toStringAsFixed(0);
  }

  List<Map<String, dynamic>> get _filteredMeals {
    if (_selectedCategory == 'All') return _featuredMeals;
    return _featuredMeals.where((meal) => meal['category'] == _selectedCategory).toList();
  }

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
            (r['cuisine']?.toString().toLowerCase().contains(lowerQuery) ?? false)).toList();
        final mealMatches = _featuredMeals.where((m) =>
            m['name'].toString().toLowerCase().contains(lowerQuery) ||
            (m['restaurant']?.toString().toLowerCase().contains(lowerQuery) ?? false) ||
            (m['description']?.toString().toLowerCase().contains(lowerQuery) ?? false)).toList();
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

  /// Use context.go() so routes REPLACE instead of stacking.
  /// This means pressing back won't leave a stale nav index.
  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        await context.read<CartProvider>().loadCart();
        context.go('/cart');
        break;
      case 2:
        context.go('/my-orders');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredMeals = _filteredMeals;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name?.split('@')[0] ?? 'Guest';

    // Derive nav index from the actual current route — never from stale state.
    final currentNavIndex = _getNavIndex(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header with Welcome Text
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Hello, ', style: TextStyle(fontSize: 14, color: AppTheme.getSecondaryTextColor(context))),
                              Flexible(
                                child: Text(
                                  userName,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getPrimaryTextColor(context)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.restaurant, size: 22, color: AppTheme.primaryRed),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('What would you like to eat today?',
                              style: TextStyle(fontSize: 13, color: AppTheme.getSecondaryTextColor(context))),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryButtonGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primaryRed.withOpacity(0.3), blurRadius: 10)],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppTheme.getPrimaryTextColor(context), fontSize: 14),
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search for restaurants or dishes...',
                    hintStyle: TextStyle(color: AppTheme.getMutedTextColor(context), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: Icon(Icons.clear, color: AppTheme.getMutedTextColor(context), size: 18), onPressed: _clearSearch)
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                ),
              ),
            ),
            // Scrollable Content OR Search Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                              const SizedBox(height: 16),
                              Text('Unable to load content', style: TextStyle(color: AppTheme.error, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(_error!, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : _isSearching
                          ? _buildSearchResults(context)
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  const DeliveryStatusCard(),

                                  // Categories Section
                                  if (_categories.length > 1)
                                    FadeInUp(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                                        child: Row(
                                          children: [
                                            Text('Categories',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.getPrimaryTextColor(context))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (_categories.length > 1)
                                    FadeInUp(
                                      child: SizedBox(
                                        height: 45,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          itemCount: _categories.length,
                                          itemBuilder: (context, index) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: CategoryChip(
                                              label: _categories[index],
                                              isSelected: _selectedCategory == _categories[index],
                                              onTap: () => setState(() => _selectedCategory = _categories[index]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Featured Meals Section (Horizontal)
                                  if (filteredMeals.isNotEmpty)
                                    FadeInUp(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.local_fire_department, color: AppTheme.primaryRed, size: 20),
                                                const SizedBox(width: 8),
                                                Text('Featured Meals',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.getPrimaryTextColor(context))),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 290,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              itemCount: filteredMeals.length,
                                              itemBuilder: (context, index) => Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: FeaturedMealCard(
                                                  meal: filteredMeals[index],
                                                  onTap: () => context.push('/food-detail', extra: filteredMeals[index]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Featured Restaurants Section
                                  if (_topRestaurants.isNotEmpty)
                                    FadeInUp(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star, color: AppTheme.yellow, size: 20),
                                                const SizedBox(width: 8),
                                                Text('Featured Restaurants',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.getPrimaryTextColor(context))),
                                              ],
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            itemCount: _topRestaurants.length,
                                            itemBuilder: (context, index) => Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: RestaurantCard(
                                                restaurant: _topRestaurants[index],
                                                onTap: () => context.push('/restaurant-details', extra: _topRestaurants[index]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final itemCount = cartProvider.itemCount;
          return Container(
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))]),
            child: BottomNavigationBar(
              // KEY FIX: currentIndex is derived from the actual route, not local state.
              currentIndex: currentNavIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.getCardColor(context),
              selectedItemColor: AppTheme.primaryRed,
              unselectedItemColor: AppTheme.getMutedTextColor(context),
              elevation: 0,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Stack(clipBehavior: Clip.none, children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(12)),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text('$itemCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                  ]),
                  activeIcon: Stack(clipBehavior: Clip.none, children: [
                    const Icon(Icons.shopping_cart),
                    if (itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(12)),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text('$itemCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                  ]),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.receipt_outlined), activeIcon: Icon(Icons.receipt), label: 'Orders'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppTheme.getMutedTextColor(context)),
            const SizedBox(height: 16),
            Text('No results found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getPrimaryTextColor(context))),
            const SizedBox(height: 8),
            Text('Try searching for something else', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final isRestaurant = item.containsKey('cuisine');
        if (isRestaurant) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(
              restaurant: item,
              onTap: () {
                _clearSearch();
                context.push('/restaurant-details', extra: item);
              },
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FeaturedMealCard(
              meal: item,
              onTap: () {
                _clearSearch();
                context.push('/food-detail', extra: item);
              },
            ),
          );
        }
      },
    );
  }
}