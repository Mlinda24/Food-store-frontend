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
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere((e) => e.toString() == json['role']),
      avatar: json['avatar'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'avatar': avatar,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
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
  final double rating;
  final int deliveryTime;
  final double deliveryFee;
  final double minOrderAmount;
  final List<String> categories;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.categories,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      address: json['address'],
      rating: json['rating'],
      deliveryTime: json['deliveryTime'],
      deliveryFee: json['deliveryFee'],
      minOrderAmount: json['minOrderAmount'],
      categories: List<String>.from(json['categories']),
      isOpen: json['isOpen'],
    );
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
    return MenuItem(
      id: json['id'],
      restaurantId: json['restaurantId'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
      category: json['category'],
      isAvailable: json['isAvailable'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }
}

// Cart Item Model
class CartItem {
  final String menuItemId;
  final String name;
  int quantity;
  final double price;
  final String? image;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  double get total => price * quantity;
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
    return Order(
      id: json['id'],
      userId: json['userId'],
      restaurantId: json['restaurantId'],
      driverId: json['driverId'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel(
                menuItemId: item['menuItemId'],
                name: item['name'],
                quantity: item['quantity'],
                price: item['price'],
                selectedOptions: item['selectedOptions'] != null
                    ? List<String>.from(item['selectedOptions'])
                    : null,
              ))
          .toList(),
      status: OrderStatus.values.firstWhere((e) => e.toString() == json['status']),
      subtotal: json['subtotal'],
      deliveryFee: json['deliveryFee'],
      tax: json['tax'],
      total: json['total'],
      deliveryAddress: json['deliveryAddress'],
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

// ============= RESTAURANT OWNER MODELS =============

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
    return RestaurantStats(
      todayEarnings: json['todayEarnings'] ?? 0,
      todayOrders: json['todayOrders'] ?? 0,
      totalEarnings: json['totalEarnings'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      averageRating: json['averageRating'] ?? 0,
      activeOrders: json['activeOrders'] ?? 0,
      monthlyEarnings: json['monthlyEarnings'] ?? 0,
      monthlyOrders: json['monthlyOrders'] ?? 0,
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
  final int estimatedPrepTime; // in minutes

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

  String get formattedDate {
    return '${orderTime.day}/${orderTime.month}/${orderTime.year} ${orderTime.hour}:${orderTime.minute.toString().padLeft(2, '0')}';
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    return RestaurantOrder(
      id: json['id'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel(
                menuItemId: item['menuItemId'],
                name: item['name'],
                quantity: item['quantity'],
                price: item['price'],
                selectedOptions: item['selectedOptions'] != null
                    ? List<String>.from(item['selectedOptions'])
                    : null,
              ))
          .toList(),
      status: OrderStatus.values.firstWhere((e) => e.toString() == json['status']),
      total: json['total'],
      orderTime: DateTime.parse(json['orderTime']),
      specialInstructions: json['specialInstructions'],
      estimatedPrepTime: json['estimatedPrepTime'] ?? 15,
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
}

// Restaurant Settings
class RestaurantSettings {
  final bool isOpen;
  final int estimatedPrepTime; // in minutes
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
}