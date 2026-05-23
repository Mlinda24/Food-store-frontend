import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurantData;

  const RestaurantDetailsScreen({super.key, this.restaurantData});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  String _selectedCategory = 'Popular';
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  late Restaurant restaurant;

  final List<String> _categories = [
    'Popular',
    'Pizza',
    'Burgers',
    'Sushi',
    'Desserts'
  ];

  @override
  void initState() {
    super.initState();
    _initRestaurant();
    _loadMenuItems();
  }

  void _initRestaurant() {
    final data = widget.restaurantData;
    if (data != null) {
      int deliveryTime = 25;
      final timeStr = data['time'] as String?;
      if (timeStr != null && timeStr.contains(' ')) {
        deliveryTime = int.tryParse(timeStr.split(' ')[0]) ?? 25;
      }

      double rating = 4.5;
      final ratingValue = data['rating'];
      if (ratingValue is double) {
        rating = ratingValue;
      } else if (ratingValue is int) {
        rating = ratingValue.toDouble();
      }

      List<String> categories = ['Local'];
      final cuisineStr = data['cuisine'] as String?;
      if (cuisineStr != null && cuisineStr.isNotEmpty) {
        categories = cuisineStr.split(' • ');
      }

      restaurant = Restaurant(
        id: data['id'] ?? '1',
        name: data['name'] ?? 'Restaurant',
        description: cuisineStr ?? 'Delicious local cuisine',
        image: '',
        address: 'Address not provided',
        rating: rating,
        deliveryTime: deliveryTime,
        deliveryFee: 1.99,
        minOrderAmount: 5.0,
        categories: categories,
        isOpen: true,
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _menuItems = [
          MenuItem(
              id: '1',
              restaurantId: restaurant.id,
              name: 'Margherita Pizza',
              description: 'Fresh mozzarella, tomato sauce, basil',
              price: 4500,
              image: '',
              category: 'Pizza',
              isAvailable: true),
          MenuItem(
              id: '2',
              restaurantId: restaurant.id,
              name: 'Pepperoni Pizza',
              description: 'Classic pepperoni with mozzarella',
              price: 5500,
              image: '',
              category: 'Pizza',
              isAvailable: true),
          MenuItem(
              id: '3',
              restaurantId: restaurant.id,
              name: 'Cheeseburger',
              description: 'Beef patty with cheese, lettuce, tomato',
              price: 3800,
              image: '',
              category: 'Burgers',
              isAvailable: true),
          MenuItem(
              id: '4',
              restaurantId: restaurant.id,
              name: 'Veggie Burger',
              description: 'Plant-based patty with fresh veggies',
              price: 4200,
              image: '',
              category: 'Burgers',
              isAvailable: true),
          MenuItem(
              id: '5',
              restaurantId: restaurant.id,
              name: 'Chicken Wings',
              description: 'Spicy buffalo wings with dip',
              price: 3900,
              image: '',
              category: 'Popular',
              isAvailable: true),
        ];
        _isLoading = false;
      });
    }
  }

  void _addToCart(MenuItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      item,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${item.name} added to cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.success),
    );
    setState(() {});
  }

  void _updateQuantity(MenuItem item, int newQuantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (newQuantity <= 0) {
      cartProvider.removeItem(item.id);
    } else {
      cartProvider.updateQuantity(item.id, newQuantity);
    }
    setState(() {});
  }

  int _getQuantity(String itemId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = cartProvider.items.firstWhere(
      (i) => i.menuItemId == itemId,
      orElse: () => CartItem(
        menuItemId: '',
        name: '',
        quantity: 0,
        price: 0,
        restaurantId: '',
        restaurantName: '',
      ),
    );
    return cartItem.quantity;
  }

  void _goToCart() {
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          restaurant.name,
          style: TextStyle(
              color: AppTheme.getPrimaryTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _goToCart,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryRed,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('View Cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.getCardColor(context),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.restaurant,
                            size: 30,
                            color: AppTheme.getMutedTextColor(context)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.getPrimaryTextColor(context)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14, color: AppTheme.yellow),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.rating.toString(),
                                  style: TextStyle(
                                      color: AppTheme
                                          .getSecondaryTextColor(context)),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.access_time,
                                    size: 14,
                                    color:
                                        AppTheme.getMutedTextColor(context)),
                                const SizedBox(width: 4),
                                Text(
                                  '${restaurant.deliveryTime} min',
                                  style: TextStyle(
                                      color: AppTheme
                                          .getSecondaryTextColor(context)),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: restaurant.isOpen
                                          ? AppTheme.success
                                          : AppTheme.error,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.isOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                      color: restaurant.isOpen
                                          ? AppTheme.success
                                          : AppTheme.error),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14,
                          color: AppTheme.getMutedTextColor(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme
                                  .getSecondaryTextColor(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: restaurant.categories.map((cat) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        cat,
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                AppTheme.getSecondaryTextColor(context)),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
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
                    onTap: () =>
                        setState(() => _selectedCategory = category),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppTheme.primaryButtonGradient
                            : null,
                        color: isSelected
                            ? null
                            : AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(30),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppTheme.getMutedTextColor(context)
                                    .withOpacity(0.3)),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.getSecondaryTextColor(
                                    context)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryTextColor(context)),
                  ),
                  const SizedBox(height: 16),
                  ..._menuItems.map((item) {
                    final quantity = _getQuantity(item.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: AppTheme.getElevatedPanelColor(
                                    context),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.fastfood,
                                size: 35,
                                color: AppTheme.getMutedTextColor(context)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme
                                          .getPrimaryTextColor(context)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme
                                          .getSecondaryTextColor(context)),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'MK${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRed),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: AppTheme.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(25)),
                            child: Row(
                              children: [
                                if (quantity > 0)
                                  IconButton(
                                    onPressed: () =>
                                        _updateQuantity(item, quantity - 1),
                                    icon: const Icon(Icons.remove,
                                        size: 16,
                                        color: AppTheme.primaryRed),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                if (quantity > 0)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme
                                              .getPrimaryTextColor(context)),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () => _addToCart(item),
                                  icon: Icon(
                                      quantity == 0
                                          ? Icons.add_shopping_cart
                                          : Icons.add,
                                      size: 16,
                                      color: AppTheme.primaryRed),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}