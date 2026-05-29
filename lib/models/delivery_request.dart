class DeliveryRequest {
  final String id;
  final String? deliveryId;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String deliveryAddress;
  String status;
  final String items;
  final String distance;
  final double earnings;
  final String estimatedTime;
  final String? customerPhone;
  final String? specialInstructions;

  DeliveryRequest({
    required this.id,
    this.deliveryId,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.deliveryAddress,
    required this.status,
    required this.items,
    required this.distance,
    required this.earnings,
    required this.estimatedTime,
    this.customerPhone,
    this.specialInstructions,
  });

  DeliveryRequest copyWith({
    String? id,
    String? deliveryId,
    String? restaurantName,
    String? restaurantAddress,
    String? customerName,
    String? deliveryAddress,
    String? status,
    String? items,
    String? distance,
    double? earnings,
    String? estimatedTime,
    String? customerPhone,
    String? specialInstructions,
  }) {
    return DeliveryRequest(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      customerName: customerName ?? this.customerName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      items: items ?? this.items,
      distance: distance ?? this.distance,
      earnings: earnings ?? this.earnings,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      customerPhone: customerPhone ?? this.customerPhone,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}