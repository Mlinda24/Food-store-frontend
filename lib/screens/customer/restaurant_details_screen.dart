import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/customer/menu_item_card.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurantData;

  const RestaurantDetailsScreen({super.key, this.restaurantData});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final ApiService _apiService = ApiService();
  String _selectedCategory = 'All';
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  late Restaurant restaurant;
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _initRestaurant();
    _loadMenuItems();
  }

  void _initRestaurant() {
    final data = widget.restaurantData;
    if (data != null) {
      double rating = data['rating'] is double ? data['rating'] : 4.5;
      List<String> categories = ['Local'];
      final cuisineStr = data['cuisine'] as String?;
      if (cuisineStr != null && cuisineStr.isNotEmpty) {
        categories = cuisineStr.split(' • ');
      }

      restaurant = Restaurant(
        id: data['id'] ?? '1',
        name: data['name'] ?? 'Restaurant',
        description: cuisineStr ?? 'Delicious local cuisine',
        image: data['image'] ?? '',
        address: data['address'] ?? 'Address not provided',
        rating: rating,
        deliveryTime: 25,
        deliveryFee: 1.99,
        minOrderAmount: 5.0,
        categories: categories,
        isOpen: data['is_open'] ?? true,
      );
    } else {
      restaurant = Restaurant(
        id: '1',
        name: 'Chef Luigi\'s Kitchen',
        description: 'Authentic Italian cuisine',
        image: '',
        address: '123 Main Street, Downtown',
        rating: 4.8,
        deliveryTime: 25,
        deliveryFee: 2.99,
        minOrderAmount: 10.0,
        categories: ['Italian', 'Pizza'],
        isOpen: true,
      );
    }
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final menuItemsData = await _apiService.getMenuItems();
      final List<MenuItem> items = [];
      final Set<String> categorySet = {'All'};

      for (var item in menuItemsData) {
        if (item['restaurant'].toString() == restaurant.id) {
          String itemCategory = _getCategoryName(item['category']);
          categorySet.add(itemCategory);
          
          items.add(MenuItem(
            id: item['id'].toString(),
            restaurantId: item['restaurant'].toString(),
            name: item['name'] ?? 'Menu Item',
            description: item['description'] ?? '',
            price: _getPriceValue(item['price']),
            image: _getImageUrl(item['image']),
            category: itemCategory,
            isAvailable: item['is_available'] ?? true,
          ));
        }
      }

      _categories = categorySet.toList();
      _menuItems = items;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading menu items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _getPriceValue(dynamic price) {
    if (price == null) return 0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
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
    if (category is String) return category;
    return 'Uncategorized';
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  void _goToCart() {
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _filteredItems;
    final imageUrl = restaurant.image.isNotEmpty ? restaurant.image : '';
    final isOpen = restaurant.isOpen;
    final availableItems = _menuItems.where((item) => item.isAvailable).length;
    final unavailableItems = _menuItems.length - availableItems;

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
          restaurant.name,
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.itemCount;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined,
                        color: AppTheme.getPrimaryTextColor(context)),
                    onPressed: _goToCart,
                    tooltip: 'View Cart',
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
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
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Restaurant Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.getCardColor(context),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Restaurant Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80,
                                        height: 80,
                                        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 80,
                                        height: 80,
                                        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                                        child: Icon(Icons.restaurant,
                                            size: 40,
                                            color: AppTheme.getMutedTextColor(context)),
                                      ),
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.getSurfaceColor(context),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.restaurant,
                                          size: 40,
                                          color: AppTheme.getMutedTextColor(context)),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getPrimaryTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Rating Row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.yellow.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, size: 12, color: AppTheme.yellow),
                                            const SizedBox(width: 4),
                                            Text(
                                              restaurant.rating.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.getPrimaryTextColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Delivery Time
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: AppTheme.getMutedTextColor(context)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${restaurant.deliveryTime} min',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.getSecondaryTextColor(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Open/Closed Status with Icon
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOpen 
                                          ? AppTheme.success.withOpacity(0.1) 
                                          : AppTheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isOpen ? Icons.check_circle : Icons.cancel,
                                          size: 14,
                                          color: isOpen ? AppTheme.success : AppTheme.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isOpen ? 'Open Now' : 'Closed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isOpen ? AppTheme.success : AppTheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Address
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: AppTheme.getMutedTextColor(context)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                restaurant.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.getSecondaryTextColor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Categories
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: restaurant.categories.map((cat) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSecondaryTextColor(context),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                        // Stats Row
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Delivery Fee
                              Column(
                                children: [
                                  Icon(Icons.motorcycle, size: 20, color: AppTheme.primaryRed),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Delivery Fee',
                                    style: TextStyle(fontSize: 10, color: AppTheme.getMutedTextColor(context)),
                                  ),
                                  Text(
                                    'MK${restaurant.deliveryFee.toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 30, color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
                              // Min Order
                              Column(
                                children: [
                                  Icon(Icons.shopping_bag, size: 20, color: AppTheme.primaryRed),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Min Order',
                                    style: TextStyle(fontSize: 10, color: AppTheme.getMutedTextColor(context)),
                                  ),
                                  Text(
                                    'MK${restaurant.minOrderAmount.toStringAsFixed(0)}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 30, color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
                              // Menu Items Count
                              Column(
                                children: [
                                  Icon(Icons.menu_book, size: 20, color: AppTheme.primaryRed),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Menu Items',
                                    style: TextStyle(fontSize: 10, color: AppTheme.getMutedTextColor(context)),
                                  ),
                                  Text(
                                    '${_menuItems.length}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Availability Summary
                  if (unavailableItems > 0)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$unavailableItems item${unavailableItems > 1 ? 's are' : ' is'} currently unavailable',
                              style: TextStyle(fontSize: 12, color: AppTheme.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Categories Filter
                  if (_categories.length > 1)
                    SizedBox(
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
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  // Category-specific icons
                                  if (category == 'Popular')
                                    Icon(Icons.local_fire_department, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Pizza')
                                    Icon(Icons.local_pizza, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Burgers')
                                    Icon(Icons.lunch_dining, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Sushi')
                                    Icon(Icons.set_meal, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Desserts')
                                    Icon(Icons.cake, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Drinks')
                                    Icon(Icons.local_cafe, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Chicken')
                                    Icon(Icons.emoji_food_beverage, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Seafood')
                                    Icon(Icons.set_meal, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Pasta')
                                    Icon(Icons.emoji_food_beverage, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Salads')
                                    Icon(Icons.eco, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Breakfast')
                                    Icon(Icons.brightness_7, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Lunch')
                                    Icon(Icons.lunch_dining, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (category == 'Dinner')
                                    Icon(Icons.dinner_dining, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  if (!['Popular', 'Pizza', 'Burgers', 'Sushi', 'Desserts', 'Drinks', 'Chicken', 'Seafood', 'Pasta', 'Salads', 'Breakfast', 'Lunch', 'Dinner'].contains(category))
                                    Icon(Icons.restaurant_menu, size: 14, color: isSelected ? Colors.white : AppTheme.primaryRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Menu List
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book, color: AppTheme.primaryRed, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getPrimaryTextColor(context),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filteredItems.length} items',
                              style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (filteredItems.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(Icons.menu_book, size: 64, color: AppTheme.getMutedTextColor(context)),
                                const SizedBox(height: 16),
                                Text(
                                  'No menu items available',
                                  style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                                ),
                              ],
                            ),
                          )
                        else
                          ...filteredItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MenuItemCard(
                              item: item,
                              restaurantId: restaurant.id,
                              restaurantName: restaurant.name,
                            ),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}