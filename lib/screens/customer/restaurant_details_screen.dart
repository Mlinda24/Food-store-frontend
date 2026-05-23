import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../utils/delivery_fee_calculator.dart';
import '../../widgets/customer/menu_item_card.dart';
import '../customer/food_detail_screen.dart';

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
  
  // Delivery related variables
  Position? _currentLocation;
  double? _distanceInMeters;
  double? _deliveryFee;
  bool _canDeliver = true;
  String? _deliveryTier;
  int? _calculatedDeliveryTime;
  bool _isLoadingLocation = true;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
    });
    
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        if (!mounted) return;
        setState(() {
          _currentLocation = location;
        });
        await _calculateDeliveryFee();
      } else {
        if (!mounted) return;
        setState(() {
          _locationPermissionDenied = true;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      if (!mounted) return;
      setState(() {
        _locationPermissionDenied = true;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _calculateDeliveryFee() async {
    if (restaurant == null || _currentLocation == null) return;
    
    try {
      final restaurantData = await _apiService.getRestaurant(restaurant!.id);
      
      final restaurantLat = restaurantData['latitude'] != null 
          ? double.parse(restaurantData['latitude'].toString()) 
          : null;
      final restaurantLng = restaurantData['longitude'] != null 
          ? double.parse(restaurantData['longitude'].toString()) 
          : null;
      
      if (restaurantLat != null && restaurantLng != null) {
        final distanceInMeters = await Geolocator.distanceBetween(
          restaurantLat, restaurantLng,
          _currentLocation!.latitude, _currentLocation!.longitude,
        );
        
        final fee = DeliveryFeeCalculator.calculateFee(distanceInMeters);
        final canDeliver = DeliveryFeeCalculator.canDeliver(distanceInMeters);
        final tier = DeliveryFeeCalculator.getDeliveryTier(distanceInMeters);
        final deliveryTime = DeliveryFeeCalculator.calculateDeliveryTime(distanceInMeters);
        
        if (!mounted) return;
        
        setState(() {
          _distanceInMeters = distanceInMeters;
          _deliveryFee = fee;
          _canDeliver = canDeliver;
          _deliveryTier = tier;
          _calculatedDeliveryTime = deliveryTime;
        });
        
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.setDeliveryInfo(
          distanceInMeters: distanceInMeters,
          deliveryFee: fee > 0 ? fee : 2000.0,
          canDeliver: canDeliver,
          tier: tier,
        );
        cartProvider.setRestaurantLocation(lat: restaurantLat, lng: restaurantLng);
        cartProvider.setCalculatedDeliveryFee(fee > 0 ? fee : 2000.0);
        
        print('✅ Delivery fee synced with CartProvider: MK${fee.toStringAsFixed(0)} for ${DeliveryFeeCalculator.formatDistance(distanceInMeters)}');
      } else {
        if (!mounted) return;
        setState(() {
          _deliveryFee = restaurant?.deliveryFee ?? 2000.0;
          _canDeliver = true;
          _calculatedDeliveryTime = restaurant?.deliveryTime ?? 30;
        });
      }
    } catch (e) {
      print('Error calculating delivery fee: $e');
      if (!mounted) return;
      setState(() {
        _deliveryFee = restaurant?.deliveryFee ?? 2000.0;
        _canDeliver = true;
        _calculatedDeliveryTime = restaurant?.deliveryTime ?? 30;
      });
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
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
          deliveryFee: (data['delivery_fee'] ?? data['deliveryFee'] ?? 2000.0).toDouble(),
          minOrderAmount: (data['min_order_amount'] ?? data['minOrderAmount'] ?? 10.0).toDouble(),
          categories: data['categories'] != null 
              ? List<String>.from(data['categories']) 
              : [],
          isOpen: data['is_open'] ?? data['isOpen'] ?? true,
        );
        
        await _apiService.getRestaurant(restaurant!.id);
        await _loadMenuItems();
        
        if (_currentLocation != null) {
          await _calculateDeliveryFee();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'No restaurant data provided';
        });
      }
    } catch (e) {
      print('❌ Error loading data: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      final restaurantId = int.parse(restaurant!.id);
      print('📦 Loading menu items for restaurant ID: $restaurantId');
      
      final menuItemsData = await _apiService.getRestaurantMenu(restaurantId);
      
      print('📊 Received ${menuItemsData.length} menu items from API');
      
      final List<MenuItem> parsedItems = [];
      
      for (var itemData in menuItemsData) {
        try {
          final String itemName = itemData['name']?.toString() ?? 
                                  itemData['item_name']?.toString() ?? 
                                  'Unknown';
          
          final double itemPrice = (itemData['price'] != null) 
              ? (itemData['price'] is int 
                  ? (itemData['price'] as int).toDouble() 
                  : double.parse(itemData['price'].toString()))
              : 0.0;
          
          final String itemId = itemData['id']?.toString() ?? 
                                itemData['menu_item_id']?.toString() ?? 
                                DateTime.now().millisecondsSinceEpoch.toString();
          
          final String itemDescription = itemData['description']?.toString() ?? '';
          final String itemImage = itemData['image']?.toString() ?? '';
          final String itemCategory = itemData['category_name']?.toString() ?? 
                                      itemData['category']?.toString() ?? 
                                      'General';
          final bool itemIsAvailable = itemData['is_available'] == true || 
                                       itemData['available'] == true;
          
          final menuItem = MenuItem(
            id: itemId,
            name: itemName,
            description: itemDescription,
            price: itemPrice,
            image: itemImage,
            category: itemCategory,
            restaurantId: restaurantId.toString(),
            isAvailable: itemIsAvailable,
          );
          parsedItems.add(menuItem);
          print('   ✅ Parsed: ${menuItem.name} - MK${menuItem.price}');
        } catch (e) {
          print('   ❌ Error parsing item: $e');
          print('      Item data: $itemData');
        }
      }
      
      if (!mounted) return;
      
      setState(() {
        _menuItems = parsedItems;
        _isLoading = false;
      });
      
      final Set<String> categorySet = {'All'};
      for (var item in _menuItems) {
        if (item.category.isNotEmpty && item.category != 'General') {
          categorySet.add(item.category);
        }
      }
      _categories = categorySet.toList();
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ Loaded ${_menuItems.length} menu items');
      print('📂 Categories: ${_categories.join(', ')}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
    } catch (e) {
      print('❌ Error loading menu items: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load menu: $e';
        _isLoading = false;
        _menuItems = [];
      });
    }
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  void _navigateToFoodDetail(MenuItem item) {
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
      'delivery_fee': _deliveryFee ?? restaurant?.deliveryFee ?? 2000.0,
      'delivery_time': _calculatedDeliveryTime ?? restaurant?.deliveryTime ?? 0,
      'is_available': item.isAvailable,
    };
    
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
            onPressed: () {
              _loadData();
              _getUserLocation();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          await _getUserLocation();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRestaurantHeader(),
                    const SizedBox(height: 16),
                    _buildDeliveryInfoCard(),
                    if (_categories.isNotEmpty && _categories.length > 1) 
                      _buildCategoryFilter(),
                    filteredItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.restaurant_menu, size: 64, color: AppTheme.getMutedTextColor(context)),
                                const SizedBox(height: 16),
                                Text(
                                  'No menu items available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.getPrimaryTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for updates',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.getSecondaryTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadMenuItems,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh Menu'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    final displayDeliveryTime = _calculatedDeliveryTime ?? restaurant?.deliveryTime ?? 30;
    final deliveryTimeFormatted = DeliveryFeeCalculator.formatDeliveryTime(displayDeliveryTime);
    
    if (_isLoadingLocation) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Calculating delivery...'),
          ],
        ),
      );
    }
    
    if (_locationPermissionDenied) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warning),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: AppTheme.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location permission denied',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enable location to see accurate delivery info',
                    style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context)),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _getUserLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (!_canDeliver) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outside Delivery Zone',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We only deliver within 2.5 km radius',
                    style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: AppTheme.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Available',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_distanceInMeters != null) ...[
                      Text(
                        'Distance: ${DeliveryFeeCalculator.formatDistance(_distanceInMeters!)}',
                        style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context)),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: AppTheme.primaryRed),
                          const SizedBox(width: 4),
                          Text(
                            'Est. Time: $deliveryTimeFormatted',
                            style: TextStyle(fontSize: 12, color: AppTheme.getSecondaryTextColor(context)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MK${(_deliveryFee ?? restaurant?.deliveryFee ?? 2000).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  if (_deliveryTier != null)
                    Text(
                      _deliveryTier!,
                      style: TextStyle(fontSize: 10, color: AppTheme.getSecondaryTextColor(context)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min Order: MK${restaurant!.minOrderAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
              Row(
                children: [
                  Icon(Icons.motorcycle, size: 12, color: AppTheme.primaryRed),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    final displayDeliveryTime = _calculatedDeliveryTime ?? restaurant?.deliveryTime ?? 30;
    final deliveryTimeFormatted = DeliveryFeeCalculator.formatDeliveryTime(displayDeliveryTime);
    
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
                          image: NetworkImage(_apiService.getImageUrl(restaurant!.image)),
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
                          deliveryTimeFormatted,
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
            onTap: () { if (!mounted) return; setState(() => _selectedCategory = category); },
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


