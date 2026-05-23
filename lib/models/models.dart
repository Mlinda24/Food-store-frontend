// User Models
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
    // Safe double to int conversion
    String parseId(dynamic id) {
      if (id == null) return '';
      if (id is int) return id.toString();
      if (id is double) return id.toInt().toString();
      return id.toString();
    }

    return User(
      id: parseId(json['id']),
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'restaurant' ? UserRole.restaurant : UserRole.customer,
      avatar: json['avatar'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['date_joined'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'phone': phone,
      'role': role == UserRole.restaurant ? 'restaurant' : 'customer',
      'avatar': avatar,
      'is_active': isActive,
    };
  }
}

// Restaurant Models
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
    // Safe double parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Safe image URL construction
    String getImageUrl(dynamic image) {
      if (image == null) return '';
      String imageStr = image.toString();
      if (imageStr.isEmpty) return '';
      if (imageStr.startsWith('http')) return imageStr;
      if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
      return 'http://127.0.0.1:8000/media/$imageStr';
    }

    return Restaurant(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: getImageUrl(json['image']),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      rating: parseDouble(json['rating']),
      deliveryTime: parseInt(json['delivery_time'] ?? json['deliveryTime']),
      deliveryFee: parseDouble(json['delivery_fee'] ?? json['deliveryFee']),
      minOrderAmount: parseDouble(json['min_order_amount'] ?? json['minOrderAmount']),
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      isOpen: json['is_open'] ?? json['isOpen'] ?? true,
      owner: json['owner']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'address': address,
      'phone': phone,
      'rating': rating,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'min_order_amount': minOrderAmount,
      'categories': categories,
      'is_open': isOpen,
    };
  }
}

// Menu Item Models
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
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
    required this.category,
    required this.isAvailable,
    this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Safe double parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Safe image URL construction
    String getImageUrl(dynamic image) {
      if (image == null) return '';
      String imageStr = image.toString();
      if (imageStr.isEmpty) return '';
      if (imageStr.startsWith('http')) return imageStr;
      if (imageStr.startsWith('/media/')) return 'http://127.0.0.1:8000$imageStr';
      return 'http://127.0.0.1:8000/media/$imageStr';
    }

    return MenuItem(
      id: json['id'].toString(),
      restaurantId: json['restaurant'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parseDouble(json['price']),
      image: getImageUrl(json['image']),
      category: json['category']?.toString() ?? 'General',
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

// Cart Item Model
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CartItem(
      menuItemId: json['menu_item'].toString(),
      name: json['menu_item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: parseDouble(json['menu_item_price']),
      image: json['menu_item_image'],
      restaurantId: json['restaurant']?.toString() ?? '',
      restaurantName: '',
    );
  }
}

// Order Models
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
      case 'on_the_way': return OrderStatus.onTheWay;
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderItemModel(
      menuItemId: json['menu_item'].toString(),
      name: json['menu_item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: parseDouble(json['price']),
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Order(
      id: json['id'].toString(),
      userId: json['customer']?.toString() ?? json['user']?.toString() ?? '',
      restaurantId: json['restaurant'].toString(),
      driverId: json['driver']?.toString(),
      items: (json['items'] as List? ?? []).map((item) => OrderItemModel.fromJson(item)).toList(),
      status: OrderStatusExtension.fromString(json['status'] ?? 'pending'),
      subtotal: parseDouble(json['total_price']),
      deliveryFee: parseDouble(json['delivery_fee'] ?? 2.99),
      tax: parseDouble(json['tax'] ?? 0),
      total: parseDouble(json['total_price']),
      deliveryAddress: json['delivery_address'] ?? '',
      specialInstructions: json['note'],
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant': restaurantId,
      'delivery_address': deliveryAddress,
      'note': specialInstructions,
      'payment_method': 'cash',
    };
  }
}

// Restaurant Order with additional details
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

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(orderTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return RestaurantOrder(
      id: json['id'].toString(),
      customerName: json['customer_name'] ?? json['customer']?['username'] ?? 'Customer',
      customerPhone: json['customer_phone'] ?? json['customer']?['phone'] ?? '',
      customerAddress: json['customer_address'] ?? json['delivery_address'] ?? '',
      items: (json['items'] as List? ?? []).map((item) => OrderItemModel.fromJson(item)).toList(),
      status: OrderStatusExtension.fromString(json['status'] ?? 'pending'),
      total: parseDouble(json['total_price']),
      orderTime: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      specialInstructions: json['note'],
      estimatedPrepTime: json['estimated_prep_time'] ?? 15,
    );
  }
}

// Menu Category
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
    return MenuCategory(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      icon: json['icon'],
      itemCount: json['item_count'] ?? 0,
    );
  }
}

// Restaurant Stats
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return RestaurantStats(
      todayEarnings: parseDouble(json['todayEarnings']),
      todayOrders: parseInt(json['todayOrders']),
      totalEarnings: parseDouble(json['totalEarnings']),
      totalOrders: parseInt(json['totalOrders']),
      averageRating: parseDouble(json['averageRating']),
      activeOrders: parseInt(json['activeOrders']),
      monthlyEarnings: parseDouble(json['monthlyEarnings']),
      monthlyOrders: parseInt(json['monthlyOrders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayEarnings': todayEarnings,
      'todayOrders': todayOrders,
      'totalEarnings': totalEarnings,
      'totalOrders': totalOrders,
      'averageRating': averageRating,
      'activeOrders': activeOrders,
      'monthlyEarnings': monthlyEarnings,
      'monthlyOrders': monthlyOrders,
    };
  }
}

// Restaurant Settings
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return RestaurantSettings(
      isOpen: json['is_open'] ?? true,
      estimatedPrepTime: json['estimated_prep_time'] ?? 20,
      minimumOrderAmount: parseDouble(json['min_order_amount']),
      deliveryFee: parseDouble(json['delivery_fee']),
      bannerImage: json['banner_image'],
      logoImage: json['logo_image'],
    );
  }
}