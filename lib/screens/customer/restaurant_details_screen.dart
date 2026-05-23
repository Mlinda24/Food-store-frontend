import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../models/models.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant? restaurant;

  const RestaurantDetailsScreen({super.key, this.restaurant});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  // Sample menu items
  final List<Map<String, dynamic>> _menuItems = [
    {'id': '1', 'name': 'Margherita Pizza', 'desc': 'Fresh mozzarella, tomato sauce, basil', 'price': 4500},
    {'id': '2', 'name': 'Pepperoni Pizza', 'desc': 'Classic pepperoni with mozzarella', 'price': 5500},
    {'id': '3', 'name': 'Cheeseburger', 'desc': 'Beef patty with cheese, lettuce, tomato', 'price': 3800},
  ];

  void _goToCheckout(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.hasItems) {
      context.go('/checkout');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a default restaurant if none is provided
    final Restaurant rest = widget.restaurant ?? Restaurant(
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
        final hasItems = cartProvider.hasItems;
        final itemCount = cartProvider.itemCount;
        final total = cartProvider.total;

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
              rest.name,
              style: const TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              
              GestureDetector(
                onTap: () => _goToCheckout(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: hasItems ? AppTheme.primaryButtonGradient : AppTheme.cardGlowGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasItems ? AppTheme.primaryRed : AppTheme.deepCrimson.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 18,
                        color: hasItems ? Colors.white : AppTheme.secondaryText,
                      ),
                      if (itemCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$itemCount',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.cardBackground,
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
                            child: const Icon(Icons.restaurant, size: 30, color: AppTheme.mutedText),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rest.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppTheme.yellow),
                                    const SizedBox(width: 4),
                                    Text(rest.rating.toString(), style: const TextStyle(color: AppTheme.secondaryText)),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time, size: 14, color: AppTheme.mutedText),
                                    const SizedBox(width: 4),
                                    Text('${rest.deliveryTime} min', style: const TextStyle(color: AppTheme.secondaryText)),
                                    const SizedBox(width: 12),
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: rest.isOpen ? AppTheme.success : AppTheme.error, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text(rest.isOpen ? 'Open' : 'Closed', style: TextStyle(color: rest.isOpen ? AppTheme.success : AppTheme.error)),
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
                          Expanded(child: Text(rest.address, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: rest.categories.map((cat) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.secondaryBackground, borderRadius: BorderRadius.circular(20)),
                          child: Text(cat, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Menu Items
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                      const SizedBox(height: 16),
                      ..._menuItems.map((item) => _buildMenuItem(context, item, rest.id, rest.name)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: hasItems
              ? Container(
                  padding: const EdgeInsets.all(12),
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
                                '${itemCount} item${itemCount > 1 ? 's' : ''} in cart',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'MK${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          width: 100,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryButtonGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ElevatedButton(
                            onPressed: () => _goToCheckout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'View Cart',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item, String restaurantId, String restaurantName) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItem = cartProvider.items.firstWhere(
          (i) => i.menuItemId == item['id'],
          orElse: () => CartItem(menuItemId: '', name: '', quantity: 0, price: 0),
        );
        final qty = cartItem.quantity;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: AppTheme.elevatedPanel, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.fastfood, size: 35, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                    const SizedBox(height: 4),
                    Text(item['desc'], style: TextStyle(fontSize: 11, color: AppTheme.secondaryText), maxLines: 2),
                    const SizedBox(height: 8),
                    Text('MK${item['price']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: AppTheme.secondaryBackground, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    if (qty > 0)
                      IconButton(
                        onPressed: () {
                          cartProvider.updateQuantity(item['id'], qty - 1);
                        },
                        icon: const Icon(Icons.remove, size: 16, color: AppTheme.primaryRed),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (qty > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('$qty', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                      ),
                    IconButton(
                      onPressed: () {
                        final menuItem = MenuItem(
                          id: item['id'],
                          restaurantId: restaurantId,
                          name: item['name'],
                          description: item['desc'],
                          price: (item['price'] as num).toDouble(),
                          image: '',
                          category: '',
                          isAvailable: true,
                        );
                        cartProvider.addItem(menuItem, restaurantId: restaurantId, restaurantName: restaurantName);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${item['name']} added to cart'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppTheme.success,
                        ));
                      },
                      icon: Icon(qty == 0 ? Icons.add_shopping_cart : Icons.add, size: 16, color: AppTheme.primaryRed),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}