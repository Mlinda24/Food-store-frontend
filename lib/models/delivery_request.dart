class DeliveryRequest {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerId;
  final String deliveryAddress;
  String status;
  final String items;
  final double distance;
  final double earnings;
  final double estimatedEarning;
  final int estimatedTime;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? customerPhone;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  DeliveryRequest({
    required this.id,
    this.restaurantId = '',
    required this.restaurantName,
    this.restaurantAddress = '',
    required this.customerName,
    this.customerId = '',
    required this.deliveryAddress,
    required this.status,
    this.items = '',
    this.distance = 0,
    required this.earnings,
    this.estimatedEarning = 0,
    this.estimatedTime = 0,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.customerPhone,
    this.specialInstructions,
    DateTime? createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeliveryRequest.fromAvailableOrder(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? 'Restaurant',
      restaurantAddress: json['restaurant_address'] ?? '',
      customerName: json['customer_name'] ?? 'Customer',
      customerId: json['customer_id']?.toString() ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      status: 'available',
      items: _formatItems(json['items']),
      distance: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0,
      earnings: double.tryParse(json['estimated_earning']?.toString() ?? '0') ?? 0,
      estimatedEarning: double.tryParse(json['estimated_earning']?.toString() ?? '0') ?? 0,
      estimatedTime: json['estimated_time_minutes'] ?? 30,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      customerPhone: json['customer_phone'],
      specialInstructions: json['special_instructions'],
      createdAt: DateTime.tryParse(json['created'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  factory DeliveryRequest.fromDelivery(Map<String, dynamic> json) {
    final order = json['order'] ?? json;
    return DeliveryRequest(
      id: json['id']?.toString() ?? order['id']?.toString() ?? '',
      restaurantId: order['restaurant_id']?.toString() ?? json['restaurant_id']?.toString() ?? '',
      restaurantName: order['restaurant_name'] ?? json['restaurant_name'] ?? 'Restaurant',
      restaurantAddress: order['restaurant_address'] ?? json['restaurant_address'] ?? '',
      customerName: order['customer_name'] ?? json['customer_name'] ?? 'Customer',
      customerId: order['customer_id']?.toString() ?? json['customer_id']?.toString() ?? '',
      deliveryAddress: order['delivery_address'] ?? json['delivery_address'] ?? '',
      status: json['status'] ?? order['status'] ?? 'assigned',
      items: _formatItems(order['items']),
      distance: double.tryParse(json['distance_km']?.toString() ?? order['distance_km']?.toString() ?? '0') ?? 0,
      earnings: double.tryParse(json['total_earning']?.toString() ?? '0') ?? 0,
      estimatedEarning: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0,
      estimatedTime: json['estimated_time_minutes'] ?? order['estimated_time_minutes'] ?? 30,
      subtotal: double.tryParse(order['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? order['delivery_fee']?.toString() ?? '0') ?? 0,
      total: double.tryParse(order['total_price']?.toString() ?? '0') ?? 0,
      customerPhone: order['customer_phone'] ?? json['customer_phone'],
      specialInstructions: order['special_instructions'] ?? json['special_instructions'],
      createdAt: DateTime.tryParse(order['created'] ?? order['created_at'] ?? '') ?? DateTime.now(),
      assignedAt: DateTime.tryParse(json['assigned_at'] ?? order['driver_assigned_at']),
      pickedUpAt: DateTime.tryParse(json['picked_up_at'] ?? order['driver_picked_up_at']),
      deliveredAt: DateTime.tryParse(json['delivered_at'] ?? order['delivered_at']),
    );
  }

  static String _formatItems(dynamic items) {
    if (items == null) return '';
    if (items is String) return items;
    if (items is List) {
      return items.map((item) {
        if (item is Map) {
          final quantity = item['quantity'] ?? 1;
          final name = item['name'] ?? item['item_name'] ?? 'Item';
          return '$quantity x $name';
        }
        return item.toString();
      }).join(', ');
    }
    return items.toString();
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'assigned': return 'Assigned';
      case 'accepted': return 'Accepted';
      case 'arrived': return 'Arrived at Restaurant';
      case 'picked_up': return 'Picked Up';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status.toUpperCase();
    }
  }

  DeliveryRequest copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    String? restaurantAddress,
    String? customerName,
    String? customerId,
    String? deliveryAddress,
    String? status,
    String? items,
    double? distance,
    double? earnings,
    double? estimatedEarning,
    int? estimatedTime,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? customerPhone,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      items: items ?? this.items,
      distance: distance ?? this.distance,
      earnings: earnings ?? this.earnings,
      estimatedEarning: estimatedEarning ?? this.estimatedEarning,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      customerPhone: customerPhone ?? this.customerPhone,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}