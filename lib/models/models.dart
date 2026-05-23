// lib/models/models.dart - ONLY DATA MODELS, NO UI WIDGETS!

enum UserRole { admin, customer, driver, restaurant }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatar;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return User(
      id: _toString(json['id']),
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'restaurant' ? UserRole.restaurant : UserRole.customer,
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['date_joined'] ?? '') ?? DateTime.now(),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String image;
  final String address;
  final String phone;
  final double rating;
  final int deliveryTime;
  final double deliveryFee;
  final double minOrderAmount;
  final List<String> categories;
  final bool isOpen;
  final String? owner;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.phone,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.categories,
    required this.isOpen,
    this.owner,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String _getImageUrl(dynamic image) {
      if (image == null) return '';
      String imageStr = image.toString();
      if (imageStr.isEmpty) return '';
      if (imageStr.startsWith('http')) return imageStr;
      if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
      return 'http://127.0.0.1:8000/media/$imageStr';
    }

    return Restaurant(
      id: _toString(json['id']),
      name: _toString(json['name']),
      description: _toString(json['description']),
      image: _getImageUrl(json['image']),
      address: _toString(json['address']),
      phone: _toString(json['phone']),
      rating: _toDouble(json['rating']),
      deliveryTime: _toInt(json['delivery_time'] ?? json['deliveryTime']),
      deliveryFee: _toDouble(json['delivery_fee'] ?? json['deliveryFee']),
      minOrderAmount: _toDouble(json['min_order_amount'] ?? json['minOrderAmount']),
      categories: json['categories'] != null ? List<String>.from(json['categories']) : [],
      isOpen: json['is_open'] ?? true,
      owner: _toString(json['owner']),
    );
  }
}

class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String imageUrl;  // ADDED: For full URL from backend
  final String category;
  final bool isAvailable;
  final List<String>? options;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.imageUrl = '',  // ADDED: Default empty string
    required this.category,
    required this.isAvailable,
    this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0.0;
      }
      return 0.0;
    }

    String _getImageUrl(dynamic image) {
      if (image == null) return '';
      String imageStr = image.toString();
      if (imageStr.isEmpty) return '';
      if (imageStr.startsWith('http')) return imageStr;
      if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
      return 'http://127.0.0.1:8000/media/$imageStr';
    }

    // Debug: Print the raw JSON to see what's coming from API
    print('🔍 Parsing MenuItem from JSON:');
    print('   id: ${json['id']}');
    print('   restaurant: ${json['restaurant']}');
    print('   name: ${json['name']}');
    print('   description: ${json['description']}');
    print('   price: ${json['price']}');
    print('   image: ${json['image']}');
    print('   image_url: ${json['image_url']}');
    print('   category: ${json['category']}');
    print('   category_name: ${json['category_name']}');
    print('   is_available: ${json['is_available']}');

    // Safe category extraction - handle both 'category' and 'category_name' fields
    String categoryValue = 'General';
    if (json['category_name'] != null && json['category_name'].toString().isNotEmpty) {
      categoryValue = json['category_name'].toString();
    } else if (json['category'] != null && json['category'].toString().isNotEmpty) {
      categoryValue = json['category'].toString();
    }

    // Get image URL - prefer image_url from backend, otherwise build from image field
    String imageUrl = '';
    if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      imageUrl = json['image_url'].toString();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imageUrl = _getImageUrl(json['image']);
    }

    return MenuItem(
      id: _toString(json['id']),
      restaurantId: _toString(json['restaurant']),
      name: _toString(json['name']),
      description: _toString(json['description']),
      price: _toDouble(json['price']),
      image: _toString(json['image']),
      imageUrl: imageUrl,  // ADDED: Use the full URL
      category: categoryValue,
      isAvailable: json['is_available'] ?? true,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'is_available': isAvailable,
      'options': options,
    };
  }
}

class CartItem {
  final String menuItemId;
  final String name;
  int quantity;
  final double price;
  final String? image;
  final String restaurantId;
  final String restaurantName;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
    required this.restaurantId,
    required this.restaurantName,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String _getImageUrl(dynamic image) {
      if (image == null) return '';
      String imageStr = image.toString();
      if (imageStr.isEmpty) return '';
      if (imageStr.startsWith('http')) return imageStr;
      if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
      return 'http://127.0.0.1:8000/media/$imageStr';
    }

    return CartItem(
      menuItemId: _toString(json['menu_item']),
      name: _toString(json['menu_item_name']),
      quantity: json['quantity'] ?? 1,
      price: _toDouble(json['menu_item_price']),
      image: _getImageUrl(json['menu_item_image']),
      restaurantId: _toString(json['restaurant']),
      restaurantName: '',
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickedUp,
  onTheWay,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.confirmed: return 'confirmed';
      case OrderStatus.preparing: return 'preparing';
      case OrderStatus.ready: return 'ready';
      case OrderStatus.pickedUp: return 'picked_up';
      case OrderStatus.onTheWay: return 'on_the_way';
      case OrderStatus.delivered: return 'delivered';
      case OrderStatus.cancelled: return 'cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'picked_up': return OrderStatus.pickedUp;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}

class OrderItemModel {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final List<String>? selectedOptions;

  OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedOptions,
  });

  double get total => quantity * price;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return OrderItemModel(
      menuItemId: _toString(json['menu_item']),
      name: _toString(json['menu_item_name']),
      quantity: json['quantity'] ?? 1,
      price: _toDouble(json['price']),
      selectedOptions: json['selected_options'] != null 
          ? List<String>.from(json['selected_options']) 
          : null,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String? driverId;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String deliveryAddress;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.driverId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.deliveryAddress,
    this.specialInstructions,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return Order(
      id: _toString(json['id']),
      userId: _toString(json['customer'] ?? json['user']),
      restaurantId: _toString(json['restaurant']),
      driverId: _toString(json['driver']),
      items: (json['items'] as List? ?? []).map((item) => OrderItemModel.fromJson(item)).toList(),
      status: OrderStatusExtension.fromString(_toString(json['status'])),
      subtotal: _toDouble(json['total_price']),
      deliveryFee: _toDouble(json['delivery_fee'] ?? 2.99),
      tax: _toDouble(json['tax'] ?? 0),
      total: _toDouble(json['total_price']),
      deliveryAddress: _toString(json['delivery_address']),
      specialInstructions: _toString(json['note']),
      createdAt: DateTime.tryParse(_toString(json['created'])) ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(_toString(json['updated_at'])) : null,
    );
  }
}

class RestaurantOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double total;
  final DateTime orderTime;
  final String? specialInstructions;
  final int estimatedPrepTime;

  RestaurantOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.status,
    required this.total,
    required this.orderTime,
    this.specialInstructions,
    required this.estimatedPrepTime,
  });

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return RestaurantOrder(
      id: _toString(json['id']),
      customerName: _toString(json['customer_name'] ?? json['customer']?['username']),
      customerPhone: _toString(json['customer_phone'] ?? json['customer']?['phone']),
      customerAddress: _toString(json['customer_address'] ?? json['delivery_address']),
      items: (json['items'] as List? ?? []).map((item) => OrderItemModel.fromJson(item)).toList(),
      status: OrderStatusExtension.fromString(_toString(json['status'])),
      total: _toDouble(json['total_price']),
      orderTime: DateTime.tryParse(_toString(json['created'])) ?? DateTime.now(),
      specialInstructions: _toString(json['note']),
      estimatedPrepTime: json['estimated_prep_time'] ?? 15,
    );
  }
}

class RestaurantStats {
  final double todayEarnings;
  final int todayOrders;
  final double totalEarnings;
  final int totalOrders;
  final double averageRating;
  final int activeOrders;
  final double monthlyEarnings;
  final int monthlyOrders;

  RestaurantStats({
    required this.todayEarnings,
    required this.todayOrders,
    required this.totalEarnings,
    required this.totalOrders,
    required this.averageRating,
    required this.activeOrders,
    required this.monthlyEarnings,
    required this.monthlyOrders,
  });

  factory RestaurantStats.empty() {
    return RestaurantStats(
      todayEarnings: 0,
      todayOrders: 0,
      totalEarnings: 0,
      totalOrders: 0,
      averageRating: 0,
      activeOrders: 0,
      monthlyEarnings: 0,
      monthlyOrders: 0,
    );
  }

  factory RestaurantStats.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return RestaurantStats(
      todayEarnings: _toDouble(json['todayEarnings']),
      todayOrders: _toInt(json['todayOrders']),
      totalEarnings: _toDouble(json['totalEarnings']),
      totalOrders: _toInt(json['totalOrders']),
      averageRating: _toDouble(json['averageRating']),
      activeOrders: _toInt(json['activeOrders']),
      monthlyEarnings: _toDouble(json['monthlyEarnings']),
      monthlyOrders: _toInt(json['monthlyOrders']),
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String? icon;
  final int itemCount;

  MenuCategory({
    required this.id,
    required this.name,
    this.icon,
    required this.itemCount,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return MenuCategory(
      id: _toString(json['id']),
      name: _toString(json['name']),
      icon: _toString(json['icon']),
      itemCount: json['item_count'] ?? 0,
    );
  }
}

class RestaurantSettings {
  final bool isOpen;
  final int estimatedPrepTime;
  final double minimumOrderAmount;
  final double deliveryFee;
  final String? bannerImage;
  final String? logoImage;

  RestaurantSettings({
    required this.isOpen,
    required this.estimatedPrepTime,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    this.bannerImage,
    this.logoImage,
  });

  factory RestaurantSettings.defaultSettings() {
    return RestaurantSettings(
      isOpen: true,
      estimatedPrepTime: 20,
      minimumOrderAmount: 10.0,
      deliveryFee: 2.99,
    );
  }

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String _toString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return RestaurantSettings(
      isOpen: json['is_open'] ?? true,
      estimatedPrepTime: _toInt(json['estimated_prep_time']),
      minimumOrderAmount: _toDouble(json['min_order_amount']),
      deliveryFee: _toDouble(json['delivery_fee']),
      bannerImage: _toString(json['banner_image']),
      logoImage: _toString(json['logo_image']),
    );
  }
}