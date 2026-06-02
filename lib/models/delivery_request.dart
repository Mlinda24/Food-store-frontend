class DeliveryRequest {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String items;
  final double earnings;
  final String distance;
  final String estimatedTime;
  final String status;
  final DateTime? assignedAt;
  final DateTime? deliveredAt;

  DeliveryRequest({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.earnings,
    required this.distance,
    required this.estimatedTime,
    required this.status,
    this.assignedAt,
    this.deliveredAt,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? json['restaurantName'] ?? '',
      restaurantAddress:
          json['restaurant_address'] ?? json['restaurantAddress'] ?? '',
      customerName: json['customer_name'] ?? json['customerName'] ?? '',
      customerPhone: json['customer_phone'] ?? json['customerPhone'] ?? '',
      deliveryAddress:
          json['delivery_address'] ?? json['deliveryAddress'] ?? '',
      items: json['items_summary'] ?? json['items'] ?? '',
      earnings: (json['total_earning'] ??
              json['earnings'] ??
              json['delivery_fee'] ??
              0)
          .toDouble(),
      distance: json['distance'] ?? '2.5 km',
      estimatedTime: json['estimated_time'] ?? '25-35 min',
      status: json['status'] ?? 'pending',
      assignedAt: json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'])
          : (json['accepted_at'] != null
              ? DateTime.tryParse(json['accepted_at'])
              : null),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
    );
  }
}
