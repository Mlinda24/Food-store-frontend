import '../models/driver_analytics.dart';

class MockAnalyticsService {
  static List<DeliveryRecord> _generateMockDeliveries() {
    final List<DeliveryRecord> deliveries = [];
    final now = DateTime.now();
    
    // Generate last 45 days of mock deliveries
    for (int i = 0; i < 45; i++) {
      final date = now.subtract(Duration(days: i));
      final randomRating = 3.5 + (DateTime.now().millisecondsSinceEpoch % 15) / 10;
      final distanceValue = 1.5 + (i % 5) * 0.5;
      final durationValue = 15 + (i % 20);
      final earningsValue = 450.0 + (i % 30) * 10;
      final tipValue = i % 3 == 0 ? 100.0 + (i % 20) * 5 : 0.0;
      final bonusValue = i % 4 == 0 ? 200.0 : 0.0;
      
      deliveries.add(DeliveryRecord(
        id: 'del_$i',
        orderId: 'ORD-${1000 + i}',
        timestamp: date,
        distance: distanceValue,
        duration: durationValue,
        earnings: earningsValue,
        tip: tipValue,
        baseFee: 500.0,
        distanceFee: distanceValue * 200,
        timeFee: durationValue * 50.0,
        bonus: bonusValue,
        customerRating: randomRating > 5 ? 5.0 : randomRating,
        restaurantName: ['Luigi\'s Pizza', 'Burger King', 'Sushi Master', 'Tasty Bites'][i % 4],
        customerName: ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson'][i % 4],
      ));
    }
    return deliveries;
  }

  static List<DeliveryRecord> getDeliveries() {
    return _generateMockDeliveries();
  }

  static DriverAnalyticsData getAnalytics() {
    final deliveries = _generateMockDeliveries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    // Calculate today's earnings
    final todayEarnings = deliveries
        .where((d) => d.timestamp.isAfter(today))
        .fold(0.0, (sum, d) => sum + d.earnings);

    // Calculate weekly earnings
    final weeklyEarnings = deliveries
        .where((d) => d.timestamp.isAfter(weekAgo))
        .fold(0.0, (sum, d) => sum + d.earnings);

    // Calculate monthly earnings
    final monthlyEarnings = deliveries
        .where((d) => d.timestamp.isAfter(monthAgo))
        .fold(0.0, (sum, d) => sum + d.earnings);

    // Calculate total earnings
    final totalEarnings = deliveries.fold(0.0, (sum, d) => sum + d.earnings);

    // Calculate average per delivery
    final averagePerDelivery = deliveries.isEmpty ? 0.0 : totalEarnings / deliveries.length;

    // Calculate average rating
    final averageRating = deliveries.isEmpty 
        ? 0.0 
        : deliveries.fold(0.0, (sum, d) => sum + d.customerRating) / deliveries.length;

    // Calculate average delivery time
    final averageDeliveryTime = deliveries.isEmpty 
        ? 0.0 
        : deliveries.fold(0.0, (sum, d) => sum + d.duration) / deliveries.length;

    // Calculate total distance
    final totalDistance = deliveries.fold(0.0, (sum, d) => sum + d.distance);

    // Weekly breakdown
    final weeklyBreakdown = {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };
    
    for (var delivery in deliveries.where((d) => d.timestamp.isAfter(weekAgo))) {
      final weekday = delivery.timestamp.weekday;
      final dayName = _getDayName(weekday);
      weeklyBreakdown[dayName] = (weeklyBreakdown[dayName] ?? 0) + delivery.earnings;
    }

    // Hourly breakdown
    final hourlyBreakdown = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final earnings = deliveries
          .where((d) => d.timestamp.hour == hour)
          .fold(0.0, (sum, d) => sum + d.earnings);
      if (earnings > 0) {
        hourlyBreakdown[hour] = earnings;
      }
    }

    return DriverAnalyticsData(
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      monthlyEarnings: monthlyEarnings,
      totalEarnings: totalEarnings,
      averagePerDelivery: averagePerDelivery,
      acceptanceRate: 92.5,
      completionRate: 98.2,
      averageRating: averageRating,
      averageDeliveryTime: averageDeliveryTime,
      totalDistance: totalDistance,
      weeklyBreakdown: weeklyBreakdown,
      hourlyBreakdown: hourlyBreakdown,
    );
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}