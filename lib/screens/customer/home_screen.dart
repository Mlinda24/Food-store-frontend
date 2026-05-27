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
  final ScrollController _scrollController = ScrollController();

  // Data from API
  List<Map<String, dynamic>> _featuredMeals = [];
  List<Map<String, dynamic>> _topRestaurants = [];
  // Full list of all loaded menu items (used for infinite scroll display)
  List<Map<String, dynamic>> _allMenuItems = [];
  // Complete list fetched from API (used as source for pagination)
  List<Map<String, dynamic>> _allMenuItemsSource = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String? _error;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 10;

  // Search
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore && !_isSearching) {
        _loadMoreMenuItems();
      }
    }
  }

  // ──────────────────────────────────────────────
  // DATA LOADING
  // ──────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load cart from backend
      await context.read<CartProvider>().loadCart();

      // Fetch restaurants
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

      // Fetch ALL menu items (aggregated across every restaurant)
      await _fetchAllMenuItemsFromApi();

      // Slice first page into the display list
      _applyFirstPage();

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

  /// Calls ApiService.getMenuItems() with no restaurantId so it aggregates
  /// every restaurant's menu. Builds [_allMenuItemsSource] and [_categories].
  Future<void> _fetchAllMenuItemsFromApi() async {
    try {
      // getMenuItems() with no argument now fetches from ALL restaurants
      final rawItems = await _apiService.getMenuItems();

      final Set<String> categorySet = {'All'};
      final List<Map<String, dynamic>> processed = [];

      for (var item in rawItems) {
        final String itemCategory = _getCategoryName(item['category']);
        categorySet.add(itemCategory);

        final String imageUrl = _getImageUrl(item['image']);

        // restaurant_name is injected by getMenuItems() when fetching all
        final String restaurantName = item['restaurant_name']?.toString() ??
            _getRestaurantNameById(
              item['restaurant']?.toString() ?? '',
              _topRestaurants,
            );

        processed.add({
          'id': item['id']?.toString() ?? '',
          'name': item['name'] ?? 'Menu Item',
          'description': item['description'] ??
              'Delicious meal prepared with fresh ingredients',
          'price': 'MK${_formatPrice(item['price'])}',
          'price_value':
              double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
          'rating': 4.0,
          'restaurant': restaurantName,
          'restaurantId': item['restaurant']?.toString() ?? '',
          'image': imageUrl,
          'category': itemCategory,
          'is_available': item['is_available'] ?? true,
        });
      }

      _allMenuItemsSource = processed;
      _categories = categorySet.toList();

      print('✅ Source list ready: ${_allMenuItemsSource.length} items, '
          '${_categories.length} categories');
    } catch (e) {
      print('❌ Error in _fetchAllMenuItemsFromApi: $e');
      _allMenuItemsSource = [];
    }
  }

  /// Slices the first [_pageSize] items from the source into the display list
  /// and sets up featured meals.
  void _applyFirstPage() {
    _currentPage = 1;
    _allMenuItems = [];

    final source = _filteredSource; // respects selected category
    final end = source.length < _pageSize ? source.length : _pageSize;
    _allMenuItems = source.sublist(0, end);
    _hasMore = source.length > _pageSize;
    _currentPage = 2;

    // Featured meals: first 6 available items from full source
    _featuredMeals = _allMenuItemsSource
        .where((item) => item['is_available'] == true)
        .take(6)
        .toList();

    print(
        '📄 Page 1: showing ${_allMenuItems.length} items, hasMore: $_hasMore');
  }

  Future<void> _loadMoreMenuItems() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final source = _filteredSource;
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex < source.length) {
      final slice = source.sublist(
        startIndex,
        endIndex > source.length ? source.length : endIndex,
      );
      _allMenuItems.addAll(slice);
      _currentPage++;
      _hasMore = endIndex < source.length;
      print(
          '📄 Loaded more: ${_allMenuItems.length} total, hasMore: $_hasMore');
    } else {
      _hasMore = false;
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  // ──────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────

  /// Source list filtered by the currently selected category.
  List<Map<String, dynamic>> get _filteredSource {
    if (_selectedCategory == 'All') return _allMenuItemsSource;
    return _allMenuItemsSource
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  double _getRating(Map<String, dynamic> restaurant) {
    if (restaurant['rating'] != null) {
      if (restaurant['rating'] is double) return restaurant['rating'] as double;
      if (restaurant['rating'] is int)
        return (restaurant['rating'] as int).toDouble();
      if (restaurant['rating'] is String)
        return double.tryParse(restaurant['rating'] as String) ?? 4.5;
    }
    return 4.5;
  }

  String _getImageUrl(dynamic image) {
    if (image == null) return '';
    if (image is String && image.isNotEmpty) {
      if (image.startsWith('http')) return image;
      if (image.startsWith('/media/')) return 'http://127.0.0.1:8000$image';
      if (image.startsWith('/')) return 'http://127.0.0.1:8000$image';
      return 'http://127.0.0.1:8000/media/$image';
    }
    return '';
  }

  String _getCategoryName(dynamic category) {
    if (category == null) return 'Uncategorized';
    if (category is Map) return category['name'] ?? 'Uncategorized';
    return category.toString();
  }

  String _getRestaurantNameById(
      String restaurantId, List<Map<String, dynamic>> restaurants) {
    for (var rest in restaurants) {
      if (rest['id'].toString() == restaurantId) {
        return rest['name'] ?? 'Restaurant';
      }
    }
    return 'Foodie Express';
  }

  String _getCuisineString(dynamic categories) {
    if (categories == null) return 'Delicious Food';
    if (categories is List && categories.isNotEmpty) {
      if (categories[0] is Map)
        return categories.map((c) => c['name'] ?? '').join(' • ');
      return categories.join(' • ');
    }
    return 'Various Cuisines';
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final double val = double.tryParse(price.toString()) ?? 0;
    return val.toStringAsFixed(0);
  }

  // ──────────────────────────────────────────────
  // CATEGORY SELECTION
  // ──────────────────────────────────────────────

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    // Re-slice the display list for the new category
    _applyFirstPage();
    setState(() {}); // trigger rebuild with new display list
  }

  // ──────────────────────────────────────────────
  // SEARCH
  // ──────────────────────────────────────────────

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        final lowerQuery = query.toLowerCase();
        final restaurantMatches = _topRestaurants
            .where((r) =>
                r['name'].toString().toLowerCase().contains(lowerQuery) ||
                (r['cuisine']?.toString().toLowerCase().contains(lowerQuery) ??
                    false))
            .toList();
        final mealMatches = _allMenuItemsSource
            .where((m) =>
                m['name'].toString().toLowerCase().contains(lowerQuery) ||
                (m['restaurant']
                        ?.toString()
                        .toLowerCase()
                        .contains(lowerQuery) ??
                    false) ||
                (m['description']
                        ?.toString()
                        .toLowerCase()
                        .contains(lowerQuery) ??
                    false))
            .toList();
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

  // ──────────────────────────────────────────────
  // NAV
  // ──────────────────────────────────────────────

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

  // ──────────────────────────────────────────────
  // ADD TO CART
  // ──────────────────────────────────────────────

  Future<void> _addToCart(Map<String, dynamic> itemData) async {
    try {
      final cartProvider = context.read<CartProvider>();

      final menuItem = MenuItem(
        id: itemData['id'],
        name: itemData['name'],
        description: itemData['description'] ?? '',
        price: itemData['price_value'],
        image: itemData['image'] ?? '',
        category: itemData['category'] ?? 'Uncategorized',
        isAvailable: itemData['is_available'] ?? true,
        restaurantId: itemData['restaurantId'],
      );

      await cartProvider.addItem(
        menuItem,
        restaurantId: itemData['restaurantId'],
        restaurantName: itemData['restaurant'] ?? 'Foodie Express',
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${itemData['name']} added to cart'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${itemData['name']} to cart'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name?.split('@')[0] ?? 'Guest';
    final currentNavIndex = _getNavIndex(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(context, userName, isDark),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _buildSearchBar(context, isDark),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorWidget(context)
                      : _isSearching
                          ? _buildSearchResults(context)
                          : _buildMainContent(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, currentNavIndex),
    );
  }

  // ──────────────────────────────────────────────
  // HEADER WITH LOGO - FIXED VERSION
  // ──────────────────────────────────────────────

  Widget _buildProfessionalHeader(
      BuildContext context, String userName, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.darkSurface, AppTheme.darkBackground]
              : [AppTheme.lightSurface, AppTheme.lightBackground],
        ),
      ),
      child: Row(
        children: [
          // Logo Image - Clean, no shadows
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 45,
                height: 45,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryRed,
                    child: const Icon(Icons.restaurant_menu,
                        color: Colors.white, size: 25),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Brand Name and Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foodie Express',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Delivering happiness to your door',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          // Welcome Message
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: AppTheme.primaryRed),
                  const SizedBox(width: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Notification Icon
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppTheme.primaryRed, size: 22),
              onPressed: () => context.push('/notifications'),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // SEARCH BAR
  // ──────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context), fontSize: 14),
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Search for restaurants or dishes...',
          hintStyle: TextStyle(
              color: AppTheme.getMutedTextColor(context), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryRed, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppTheme.getMutedTextColor(context), size: 18),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ERROR
  // ──────────────────────────────────────────────

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('Unable to load content',
              style: TextStyle(color: AppTheme.error, fontSize: 18)),
          const SizedBox(height: 8),
          Text(_error!,
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // MAIN CONTENT
  // ──────────────────────────────────────────────

  Widget _buildMainContent(BuildContext context) {
    // Featured meals always show from the full source list (not paginated)
    final featuredMeals = _selectedCategory == 'All'
        ? _featuredMeals
        : _allMenuItemsSource
            .where((m) =>
                m['category'] == _selectedCategory && m['is_available'] == true)
            .take(6)
            .toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200) {
          if (_hasMore && !_isLoadingMore && !_isSearching) {
            _loadMoreMenuItems();
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Delivery Status Card
            const DeliveryStatusCard(),

            // Categories
            if (_categories.length > 1) _buildCategoriesSection(context),

            // Featured Restaurants
            if (_topRestaurants.isNotEmpty)
              _buildFeaturedRestaurantsSection(context),

            // Featured Meals (horizontal scroll)
            if (featuredMeals.isNotEmpty)
              _buildFeaturedMealsSection(context, featuredMeals),

            // All Menu Items (paginated grid)
            if (_allMenuItems.isNotEmpty)
              _buildAllMenuItemsSection(context, _allMenuItems)
            else if (!_isLoading)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.no_food,
                        size: 64, color: AppTheme.getMutedTextColor(context)),
                    const SizedBox(height: 12),
                    Text(
                      'No menu items available',
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // CATEGORIES
  // ──────────────────────────────────────────────

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      children: [
        FadeInUp(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Icon(Icons.category, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Browse Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                  onTap: () => _onCategorySelected(_categories[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // FEATURED RESTAURANTS
  // ──────────────────────────────────────────────

  Widget _buildFeaturedRestaurantsSection(BuildContext context) {
    return FadeInUp(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
            child: Row(
              children: [
                Icon(Icons.star, color: AppTheme.yellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Featured Restaurants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
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
                onTap: () => context.push('/restaurant-details',
                    extra: _topRestaurants[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // FEATURED MEALS
  // ──────────────────────────────────────────────

  Widget _buildFeaturedMealsSection(
      BuildContext context, List<Map<String, dynamic>> meals) {
    return FadeInUp(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
            child: Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  '🔥 Featured Meals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 290,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: meals.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FeaturedMealCard(
                  meal: meals[index],
                  onTap: () =>
                      context.push('/food-detail', extra: meals[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ALL MENU ITEMS (paginated grid)
  // ──────────────────────────────────────────────

  Widget _buildAllMenuItemsSection(
      BuildContext context, List<Map<String, dynamic>> items) {
    return FadeInUp(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  '🍽️ All Menu Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getPrimaryTextColor(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredSource.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _buildMenuItemCard(context, items[index]),
          ),
          // Loading indicator
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // End of list message
          if (!_hasMore && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© 2026 Foodie Express. All rights reserved.',
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/food-detail', extra: item),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGlowGradient(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.deepCrimson.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Hero(
                    tag: 'menu_${item['id']}',
                    child: CachedNetworkImage(
                      imageUrl: item['image'] ?? '',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightBackground,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightBackground,
                        child: Icon(
                          Icons.fastfood,
                          size: 40,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${item['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Unavailable overlay
                  if (!(item['is_available'] as bool? ?? true))
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: const Center(
                          child: Text(
                            'Currently Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['restaurant'] ?? 'Foodie Express',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['price'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryButtonGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_shopping_cart,
                              size: 16, color: Colors.white),
                          onPressed: (item['is_available'] as bool? ?? true)
                              ? () => _addToCart(item)
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          iconSize: 16,
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

  // ──────────────────────────────────────────────
  // SEARCH RESULTS
  // ──────────────────────────────────────────────

  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 80, color: AppTheme.getMutedTextColor(context)),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed),
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

  // ──────────────────────────────────────────────
  // BOTTOM NAV
  // ──────────────────────────────────────────────

  Widget _buildBottomNavBar(BuildContext context, int currentNavIndex) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final itemCount = cartProvider.itemCount;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentNavIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.getCardColor(context),
            selectedItemColor: AppTheme.primaryRed,
            unselectedItemColor: AppTheme.getMutedTextColor(context),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_outlined),
                activeIcon: Icon(Icons.receipt),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
