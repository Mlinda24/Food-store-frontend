class DeliveryRecord {
  final String id;
  final String orderId;
  final DateTime timestamp;
  final double distance;
  final int duration;
  final double earnings;
  final double tip;
  final double baseFee;
  final double distanceFee;
  final double timeFee;
  final double bonus;
  final double customerRating;
  final String restaurantName;
  final String customerName;

  DeliveryRecord({
    required this.id,
    required this.orderId,
    required this.timestamp,
    required this.distance,
    required this.duration,
    required this.earnings,
    required this.tip,
    required this.baseFee,
    required this.distanceFee,
    required this.timeFee,
    required this.bonus,
    required this.customerRating,
    required this.restaurantName,
    required this.customerName,
  });
}

class DriverAnalyticsData {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final double averagePerDelivery;
  final double acceptanceRate;
  final double completionRate;
  final double averageRating;
  final double averageDeliveryTime;
  final double totalDistance;
  final Map<String, double> weeklyBreakdown;
  final Map<int, double> hourlyBreakdown;

  DriverAnalyticsData({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.averagePerDelivery,
    required this.acceptanceRate,
    required this.completionRate,
    required this.averageRating,
    required this.averageDeliveryTime,
    required this.totalDistance,
    required this.weeklyBreakdown,
    required this.hourlyBreakdown,
  });
}