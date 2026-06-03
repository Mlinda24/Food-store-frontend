class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String deliveryAddress;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.deliveryAddress,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      restaurantId: json['restaurant_id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? 'Restaurant',
      deliveryAddress: json['delivery_address'] ?? '',
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['menu_item_name'] ?? 'Item',
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}
