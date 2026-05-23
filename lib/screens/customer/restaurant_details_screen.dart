import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/customer/menu_item_card.dart';
import '../customer/food_detail_screen.dart'; // Import the FoodDetailScreen

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurantData;
  
  const RestaurantDetailsScreen({super.key, this.restaurantData});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final ApiService _apiService = ApiService();
  Restaurant? restaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.restaurantData != null) {
        final data = widget.restaurantData!;
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🏪 Restaurant Details Screen');
        print('   Restaurant ID: ${data['id']}');
        print('   Restaurant Name: ${data['name']}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        restaurant = Restaurant(
          id: data['id'].toString(),
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          image: data['image'] ?? '',
          address: data['address'] ?? '',
          phone: data['phone'] ?? '',
          rating: (data['rating'] ?? 4.5).toDouble(),
          deliveryTime: data['delivery_time'] ?? data['deliveryTime'] ?? 30,
          deliveryFee: (data['delivery_fee'] ?? data['deliveryFee'] ?? 2.99).toDouble(),
          minOrderAmount: (data['min_order_amount'] ?? data['minOrderAmount'] ?? 10.0).toDouble(),
          categories: data['categories'] != null 
              ? List<String>.from(data['categories']) 
              : [],
          isOpen: data['is_open'] ?? data['isOpen'] ?? true,
        );
        
        await _loadMenuItems();
      } else {
        setState(() {
          _isLoading = false;
          _error = 'No restaurant data provided';
        });
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      final restaurantId = restaurant!.id;
      print('📦 Loading menu items for restaurant ID: $restaurantId');
      
      final allItems = await _apiService.getMenuItems();
      print('   Raw items from API: ${allItems.length}');
      
      final allMenuItems = <MenuItem>[];
      
      for (int i = 0; i < allItems.length; i++) {
        final item = allItems[i];
        print('   --- Item ${i + 1} ---');
        try {
          final menuItem = MenuItem.fromJson(item);
          allMenuItems.add(menuItem);
          print('   ✅ Successfully parsed: ${menuItem.name}');
        } catch (e, stackTrace) {
          print('   ❌ Error parsing item: $e');
          print('   Item data: $item');
        }
      }
      
      _menuItems = allMenuItems.where((item) => 
        item.restaurantId == restaurantId
      ).toList();
      
      print('   Filtered menu items for this restaurant: ${_menuItems.length}');
      
      if (_menuItems.isNotEmpty) {
        print('   Menu items found:');
        for (var item in _menuItems) {
          print('     - ${item.name} (ID: ${item.id})');
        }
      }
      
      final Set<String> categorySet = {'All'};
      for (var item in _menuItems) {
        if (item.category.isNotEmpty && item.category != 'General') {
          categorySet.add(item.category);
        }
      }
      _categories = categorySet.toList();
      
      setState(() {
        _isLoading = false;
      });
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      print('❌ Error loading menu items: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  /// Navigates to the FoodDetailScreen when a meal is clicked.
  /// This links the meal card to the restaurant details page,
  /// passing all relevant meal and restaurant information.
  void _navigateToFoodDetail(MenuItem item) {
    // Format the price with MK prefix
    final formattedPrice = 'MK${item.price.toStringAsFixed(0)}';
    
    final foodData = {
      'id': item.id,
      'name': item.name,
      'description': item.description,
      'price': formattedPrice,
      'image': item.image,
      'category': item.category,
      'restaurantId': item.restaurantId,
      'restaurant': restaurant?.name ?? '',
      'restaurant_address': restaurant?.address ?? '',
      'rating': restaurant?.rating ?? 0.0,
      'delivery_fee': restaurant?.deliveryFee ?? 0.0,
      'delivery_time': restaurant?.deliveryTime ?? 0,
      'is_available': item.isAvailable,
    };
    
    // Navigate to the FoodDetailScreen
    context.push('/food-detail', extra: foodData);
  }

  @override
  Widget build(BuildContext context) {
    if (restaurant == null && _isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && restaurant == null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('Error loading restaurant', style: TextStyle(color: AppTheme.error)),
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          restaurant!.name,
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.getPrimaryTextColor(context)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildRestaurantHeader(),
                  const SizedBox(height: 16),
                  if (_categories.isNotEmpty) _buildCategoryFilter(),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu, size: 64, color: AppTheme.getMutedTextColor(context)),
                                const SizedBox(height: 16),
                                Text(
                                  'No menu items available',
                                  style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for updates',
                                  style: TextStyle(color: AppTheme.getMutedTextColor(context)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return GestureDetector(
                                onTap: () => _navigateToFoodDetail(item),
                                child: MenuItemCard(
                                  item: item,
                                  restaurantId: restaurant!.id,
                                  restaurantName: restaurant!.name,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: restaurant!.image.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(restaurant!.image),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppTheme.getSurfaceColor(context),
                ),
                child: restaurant!.image.isEmpty
                    ? Icon(Icons.restaurant, size: 40, color: AppTheme.getMutedTextColor(context))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant!.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppTheme.yellow),
                        const SizedBox(width: 4),
                        Text(
                          restaurant!.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getPrimaryTextColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant!.deliveryTime} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant!.address,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (restaurant!.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: AppTheme.getSecondaryTextColor(context)),
                          const SizedBox(width: 4),
                          Text(
                            restaurant!.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: restaurant!.isOpen ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: restaurant!.isOpen ? AppTheme.success : AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  restaurant!.isOpen ? 'Open Now' : 'Closed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: restaurant!.isOpen ? AppTheme.success : AppTheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Min Order: MK${restaurant!.minOrderAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Delivery: MK${restaurant!.deliveryFee.toStringAsFixed(0)}',
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryButtonGradient : null,
                color: isSelected ? null : AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? null : Border.all(color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}