import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/customer/menu_item_card.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurantData;
  
  const RestaurantDetailsScreen({super.key, this.restaurantData});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  Restaurant? restaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.restaurantData != null) {
      final data = widget.restaurantData!;
      restaurant = Restaurant(
        id: data['id'].toString(),
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        image: data['image'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        rating: (data['rating'] ?? 0).toDouble(),
        deliveryTime: data['deliveryTime'] ?? 30,
        deliveryFee: (data['deliveryFee'] ?? 2.99).toDouble(),
        minOrderAmount: (data['minOrderAmount'] ?? 10).toDouble(),
        categories: data['categories'] != null ? List<String>.from(data['categories']) : [],
        isOpen: data['is_open'] ?? true,
      );
      _loadMenuItems();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMenuItems() async {
    // Here you would fetch menu items from API
    setState(() {
      _menuItems = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (restaurant == null) {
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildRestaurantHeader(),
                const SizedBox(height: 16),
                _buildCategoryFilter(),
                Expanded(
                  child: _menuItems.isEmpty
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
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _menuItems.length,
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            // FIXED: Use 'item' not 'menuItem'
                            return MenuItemCard(
                              item: item,
                              restaurantId: restaurant!.id,
                              restaurantName: restaurant!.name,
                            );
                          },
                        ),
                ),
              ],
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
                          restaurant!.rating.toString(),
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