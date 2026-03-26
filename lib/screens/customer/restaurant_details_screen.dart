import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant? restaurant;
  
  const RestaurantDetailsScreen({
    super.key,
    this.restaurant,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  String _selectedCategory = 'Popular';
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;

  final List<String> _categories = ['Popular', 'Pizza', 'Burgers', 'Sushi', 'Desserts'];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _menuItems = [
          MenuItem(
            id: '1',
            restaurantId: widget.restaurant?.id ?? '1',
            name: 'Margherita Pizza',
            description: 'Fresh mozzarella, tomato sauce, basil',
            price: 4500,
            image: '',
            category: 'Pizza',
            isAvailable: true,
          ),
          MenuItem(
            id: '2',
            restaurantId: widget.restaurant?.id ?? '1',
            name: 'Pepperoni Pizza',
            description: 'Classic pepperoni with mozzarella',
            price: 5500,
            image: '',
            category: 'Pizza',
            isAvailable: true,
          ),
          MenuItem(
            id: '3',
            restaurantId: widget.restaurant?.id ?? '1',
            name: 'Cheeseburger',
            description: 'Beef patty with cheese, lettuce, tomato',
            price: 3800,
            image: '',
            category: 'Burgers',
            isAvailable: true,
          ),
          MenuItem(
            id: '4',
            restaurantId: widget.restaurant?.id ?? '1',
            name: 'Veggie Burger',
            description: 'Plant-based patty with fresh veggies',
            price: 4200,
            image: '',
            category: 'Burgers',
            isAvailable: true,
          ),
          MenuItem(
            id: '5',
            restaurantId: widget.restaurant?.id ?? '1',
            name: 'Chicken Wings',
            description: 'Spicy buffalo wings with dip',
            price: 3900,
            image: '',
            category: 'Popular',
            isAvailable: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _addToCart(MenuItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(
      item,
      restaurantId: widget.restaurant?.id ?? '1',
      restaurantName: widget.restaurant?.name ?? 'Restaurant',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.success,
      ),
    );
    setState(() {}); // Force rebuild to update cart badge and bottom bar
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
      ),
    );
    return cartItem.quantity;
  }

  void _goToCheckout() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.hasItems) {
      print('Navigating to checkout...'); // Debug print
      context.go('/checkout');
    } else {
      print('Cart is empty'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant ?? Restaurant(
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

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        // Debug print to check cart items
        print('Cart items count: ${cartProvider.itemCount}');
        
        return Scaffold(
          backgroundColor: AppTheme.mainBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.mainBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
              onPressed: () => context.pop(),
            ),
            title: Text(
              restaurant.name,
              style: const TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              // LARGER CLICKABLE CART BUTTON
              GestureDetector(
                onTap: _goToCheckout,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: cartProvider.hasItems 
                          ? AppTheme.primaryRed 
                          : AppTheme.deepCrimson.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 22,
                        color: cartProvider.hasItems 
                            ? AppTheme.primaryRed 
                            : AppTheme.secondaryText,
                      ),
                      if (cartProvider.itemCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Restaurant Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.elevatedPanel,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 30,
                            color: AppTheme.mutedText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppTheme.yellow),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating.toString(),
                                    style: const TextStyle(color: AppTheme.secondaryText),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 14, color: AppTheme.mutedText),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant.deliveryTime} min',
                                    style: const TextStyle(color: AppTheme.secondaryText),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: restaurant.isOpen ? AppTheme.success : AppTheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.isOpen ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      color: restaurant.isOpen ? AppTheme.success : AppTheme.error,
                                    ),
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
                        const Icon(Icons.location_on, size: 14, color: AppTheme.mutedText),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.address,
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: restaurant.categories.map((category) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Categories
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: _selectedCategory == category
                              ? AppTheme.primaryButtonGradient
                              : null,
                          color: _selectedCategory == category ? null : AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(30),
                          border: _selectedCategory == category
                              ? null
                              : Border.all(color: AppTheme.mutedText.withOpacity(0.3)),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: _selectedCategory == category ? Colors.white : AppTheme.secondaryText,
                            fontWeight: _selectedCategory == category ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Menu Items
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final quantity = _getQuantity(item.id);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGlowGradient,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppTheme.elevatedPanel,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 35,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.secondaryText,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'MK${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    children: [
                                      if (quantity > 0)
                                        GestureDetector(
                                          onTap: () => _updateQuantity(item, quantity - 1),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: AppTheme.primaryRed,
                                            ),
                                          ),
                                        ),
                                      if (quantity > 0)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryText,
                                            ),
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () => _addToCart(item),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            quantity == 0 ? Icons.add_shopping_cart : Icons.add,
                                            size: 16,
                                            color: AppTheme.primaryRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Bottom Cart Bar - CLICKABLE
          bottomNavigationBar: cartProvider.hasItems && cartProvider.restaurantId == restaurant.id
              ? GestureDetector(
                  onTap: _goToCheckout,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${cartProvider.itemCount} item${cartProvider.itemCount > 1 ? 's' : ''} in cart',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'MK${cartProvider.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryButtonGradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: _goToCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shopping_cart, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'View Cart',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}