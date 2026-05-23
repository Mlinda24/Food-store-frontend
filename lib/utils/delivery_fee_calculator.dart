// lib/utils/delivery_fee_calculator.dart

import 'dart:math';

class DeliveryFeeCalculator {
  // ============================================
  // GROUP 1: DELIVERY FEE STRUCTURE (5-TIER)
  // ============================================
  // Group 1: 0 - 500 meters = MK1,000
  // Group 2: 501 - 1000 meters = MK2,000
  // Group 3: 1001 - 1500 meters = MK3,000
  // Group 4: 1501 - 2000 meters = MK4,000
  // Group 5: 2001 - 2500 meters = MK5,000
  // Beyond 2500 meters = Not deliverable
  
  static const Map<String, double> DELIVERY_FEES = {
    'tier_1': 1000.0,  // 0 - 500 m
    'tier_2': 2000.0,  // 501 - 1000 m
    'tier_3': 3000.0,  // 1001 - 1500 m
    'tier_4': 4000.0,  // 1501 - 2000 m
    'tier_5': 5000.0,  // 2001 - 2500 m
  };
  
  static const double MAX_DELIVERY_DISTANCE = 2500.0; // 2.5 km in meters
  static const double FREE_DELIVERY_RADIUS = 0.0; // No free delivery by default
  
  // ============================================
  // GROUP 2: DELIVERY TIME STRUCTURE (BASED ON DISTANCE)
  // ============================================
  // Each 100 meters = +10 minutes
  // 0-100m = 10 min, 101-200m = 20 min, 201-300m = 30 min, etc.
  // Maximum delivery time = 120 minutes (2 hours)
  
  static const int BASE_TIME_MINUTES = 10; // Base time for first 100 meters
  static const int TIME_PER_100M = 10;     // +10 minutes per additional 100m
  static const int MAX_DELIVERY_TIME = 120; // Max 120 minutes (2 hours)
  static const int PREPARATION_TIME = 15;   // Base preparation time in minutes
  
  // Tier ranges with time
  static const List<Map<String, dynamic>> TIER_RANGES = [
    {'min': 0, 'max': 100, 'tier': 1, 'name': 'Very Close (≤100m)', 'fee': 1000.0, 'time': 10},
    {'min': 101, 'max': 200, 'tier': 1, 'name': 'Very Close (≤200m)', 'fee': 1000.0, 'time': 20},
    {'min': 201, 'max': 300, 'tier': 1, 'name': 'Very Close (≤300m)', 'fee': 1000.0, 'time': 30},
    {'min': 301, 'max': 400, 'tier': 1, 'name': 'Very Close (≤400m)', 'fee': 1000.0, 'time': 40},
    {'min': 401, 'max': 500, 'tier': 1, 'name': 'Very Close (≤500m)', 'fee': 1000.0, 'time': 50},
    {'min': 501, 'max': 600, 'tier': 2, 'name': 'Close (≤600m)', 'fee': 2000.0, 'time': 60},
    {'min': 601, 'max': 700, 'tier': 2, 'name': 'Close (≤700m)', 'fee': 2000.0, 'time': 70},
    {'min': 701, 'max': 800, 'tier': 2, 'name': 'Close (≤800m)', 'fee': 2000.0, 'time': 80},
    {'min': 801, 'max': 900, 'tier': 2, 'name': 'Close (≤900m)', 'fee': 2000.0, 'time': 90},
    {'min': 901, 'max': 1000, 'tier': 2, 'name': 'Close (≤1km)', 'fee': 2000.0, 'time': 100},
    {'min': 1001, 'max': 1500, 'tier': 3, 'name': 'Medium (≤1.5km)', 'fee': 3000.0, 'time': 110},
    {'min': 1501, 'max': 2000, 'tier': 4, 'name': 'Far (≤2km)', 'fee': 4000.0, 'time': 120},
    {'min': 2001, 'max': 2500, 'tier': 5, 'name': 'Very Far (≤2.5km)', 'fee': 5000.0, 'time': 120},
  ];
  
  // ============================================
  // GROUP 2a: DELIVERY TIME CALCULATION METHODS
  // ============================================
  
  /// Calculate delivery time in minutes based on distance in meters
  /// Formula: Base time (10 min) + (distance_in_meters / 100) * 10 min
  static int calculateDeliveryTime(double distanceInMeters) {
    if (distanceInMeters < 0) return BASE_TIME_MINUTES;
    
    if (distanceInMeters <= 100) {
      return 10; // 0-100m = 10 min
    } else if (distanceInMeters <= 200) {
      return 20; // 101-200m = 20 min
    } else if (distanceInMeters <= 300) {
      return 30; // 201-300m = 30 min
    } else if (distanceInMeters <= 400) {
      return 40; // 301-400m = 40 min
    } else if (distanceInMeters <= 500) {
      return 50; // 401-500m = 50 min
    } else if (distanceInMeters <= 600) {
      return 60; // 501-600m = 60 min
    } else if (distanceInMeters <= 700) {
      return 70; // 601-700m = 70 min
    } else if (distanceInMeters <= 800) {
      return 80; // 701-800m = 80 min
    } else if (distanceInMeters <= 900) {
      return 90; // 801-900m = 90 min
    } else if (distanceInMeters <= 1000) {
      return 100; // 901-1000m = 100 min
    } else if (distanceInMeters <= 1500) {
      return 110; // 1001-1500m = 110 min
    } else if (distanceInMeters <= 2000) {
      return 120; // 1501-2000m = 120 min
    } else if (distanceInMeters <= 2500) {
      return 120; // 2001-2500m = 120 min
    } else {
      return MAX_DELIVERY_TIME;
    }
  }
  
  /// Alternative: Progressive calculation (each 100m = 10 minutes)
  static int calculateDeliveryTimeProgressive(double distanceInMeters) {
    if (distanceInMeters < 0) return BASE_TIME_MINUTES;
    
    // Each 100 meters adds 10 minutes
    final timeInMinutes = ((distanceInMeters / 100).ceil() * TIME_PER_100M);
    return timeInMinutes > MAX_DELIVERY_TIME ? MAX_DELIVERY_TIME : timeInMinutes;
  }
  
  /// Calculate total delivery time including preparation time
  static int calculateTotalDeliveryTime(double distanceInMeters) {
    final travelTime = calculateDeliveryTime(distanceInMeters);
    return travelTime + PREPARATION_TIME;
  }
  
  /// Get delivery time based on tier
  static int getDeliveryTimeByTier(int tier) {
    switch (tier) {
      case 1: return 30;  // 0-500m
      case 2: return 60;  // 501-1000m
      case 3: return 75;  // 1001-1500m
      case 4: return 90;  // 1501-2000m
      case 5: return 120; // 2001-2500m
      default: return 45;
    }
  }
  
  /// Format delivery time for display
  static String formatDeliveryTime(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes min';
    }
    return '$minutes min';
  }
  
  /// Get estimated delivery time range
  static String getDeliveryTimeRange(double distanceInMeters) {
    final time = calculateDeliveryTime(distanceInMeters);
    final minTime = (time * 0.8).toInt();
    final maxTime = (time * 1.2).toInt();
    return '$minTime-$maxTime min';
  }
  
  // ============================================
  // GROUP 2b: FEE CALCULATION METHODS
  // ============================================
  
  /// Calculate delivery fee based on distance in meters
  static double calculateFee(double distanceInMeters) {
    if (distanceInMeters < 0) return -1;
    
    if (distanceInMeters <= 500) {
      return DELIVERY_FEES['tier_1']!;
    } else if (distanceInMeters <= 1000) {
      return DELIVERY_FEES['tier_2']!;
    } else if (distanceInMeters <= 1500) {
      return DELIVERY_FEES['tier_3']!;
    } else if (distanceInMeters <= 2000) {
      return DELIVERY_FEES['tier_4']!;
    } else if (distanceInMeters <= 2500) {
      return DELIVERY_FEES['tier_5']!;
    } else {
      return -1;
    }
  }
  
  /// Calculate delivery fee and return as integer
  static int calculateFeeAsInt(double distanceInMeters) {
    final fee = calculateFee(distanceInMeters);
    return fee > 0 ? fee.toInt() : -1;
  }
  
  /// Calculate delivery fee with custom tier fees
  static double calculateFeeWithCustomTiers(
    double distanceInMeters, {
    double tier1Fee = 1000.0,
    double tier2Fee = 2000.0,
    double tier3Fee = 3000.0,
    double tier4Fee = 4000.0,
    double tier5Fee = 5000.0,
  }) {
    if (distanceInMeters < 0) return -1;
    
    if (distanceInMeters <= 500) return tier1Fee;
    if (distanceInMeters <= 1000) return tier2Fee;
    if (distanceInMeters <= 1500) return tier3Fee;
    if (distanceInMeters <= 2000) return tier4Fee;
    if (distanceInMeters <= 2500) return tier5Fee;
    return -1;
  }
  
  // ============================================
  // GROUP 3: DELIVERY VALIDATION METHODS
  // ============================================
  
  static bool canDeliver(double distanceInMeters) {
    if (distanceInMeters < 0) return false;
    return distanceInMeters <= MAX_DELIVERY_DISTANCE;
  }
  
  static bool canDeliverWithRadius(double distanceInMeters, double maxRadius) {
    if (distanceInMeters < 0 || maxRadius < 0) return false;
    return distanceInMeters <= maxRadius;
  }
  
  static bool isFreeDelivery(double distanceInMeters, double freeRadius) {
    if (distanceInMeters < 0 || freeRadius < 0) return false;
    return freeRadius > 0 && distanceInMeters <= freeRadius;
  }
  
  // ============================================
  // GROUP 4: TIER INFORMATION METHODS
  // ============================================
  
  static Map<String, dynamic> getDeliveryTierInfo(double distanceInMeters) {
    if (distanceInMeters < 0) {
      return {
        'tier': 0,
        'name': 'Invalid Distance',
        'fee': -1,
        'min_distance': 0,
        'max_distance': 0,
        'can_deliver': false,
        'delivery_time': BASE_TIME_MINUTES,
        'delivery_time_formatted': formatDeliveryTime(BASE_TIME_MINUTES),
        'total_time': BASE_TIME_MINUTES + PREPARATION_TIME,
        'total_time_formatted': formatDeliveryTime(BASE_TIME_MINUTES + PREPARATION_TIME),
      };
    }
    
    // Find the matching tier
    for (var tier in TIER_RANGES) {
      if (distanceInMeters >= tier['min'] && distanceInMeters <= tier['max']) {
        final deliveryTime = tier['time'] as int;
        return {
          'tier': tier['tier'],
          'name': tier['name'],
          'fee': tier['fee'],
          'min_distance': tier['min'],
          'max_distance': tier['max'],
          'can_deliver': true,
          'delivery_time': deliveryTime,
          'delivery_time_formatted': formatDeliveryTime(deliveryTime),
          'total_time': deliveryTime + PREPARATION_TIME,
          'total_time_formatted': formatDeliveryTime(deliveryTime + PREPARATION_TIME),
        };
      }
    }
    
    // Default calculation for custom distances
    final deliveryTime = calculateDeliveryTime(distanceInMeters);
    return {
      'tier': getTierNumber(distanceInMeters),
      'name': getDeliveryTier(distanceInMeters),
      'fee': calculateFee(distanceInMeters),
      'min_distance': 0,
      'max_distance:': distanceInMeters,
      'can_deliver': canDeliver(distanceInMeters),
      'delivery_time': deliveryTime,
      'delivery_time_formatted': formatDeliveryTime(deliveryTime),
      'total_time': deliveryTime + PREPARATION_TIME,
      'total_time_formatted': formatDeliveryTime(deliveryTime + PREPARATION_TIME),
    };
  }
  
  static String getDeliveryTier(double distanceInMeters) {
    if (distanceInMeters < 0) return 'Invalid Distance';
    
    if (distanceInMeters <= 500) return 'Very Close (≤500m)';
    if (distanceInMeters <= 1000) return 'Close (≤1km)';
    if (distanceInMeters <= 1500) return 'Medium (≤1.5km)';
    if (distanceInMeters <= 2000) return 'Far (≤2km)';
    if (distanceInMeters <= 2500) return 'Very Far (≤2.5km)';
    return 'Outside Delivery Zone';
  }
  
  static int getTierNumber(double distanceInMeters) {
    if (distanceInMeters < 0) return 0;
    if (distanceInMeters <= 500) return 1;
    if (distanceInMeters <= 1000) return 2;
    if (distanceInMeters <= 1500) return 3;
    if (distanceInMeters <= 2000) return 4;
    if (distanceInMeters <= 2500) return 5;
    return 0;
  }
  
  static double getFeeForTier(int tier) {
    switch (tier) {
      case 1: return DELIVERY_FEES['tier_1']!;
      case 2: return DELIVERY_FEES['tier_2']!;
      case 3: return DELIVERY_FEES['tier_3']!;
      case 4: return DELIVERY_FEES['tier_4']!;
      case 5: return DELIVERY_FEES['tier_5']!;
      default: return -1;
    }
  }
  
  // ============================================
  // GROUP 5: FORMATTING METHODS
  // ============================================
  
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 0) return 'Invalid';
    if (distanceInMeters >= 1000) {
      final km = distanceInMeters / 1000;
      if (km >= 10) return '${km.toStringAsFixed(0)} km';
      return '${km.toStringAsFixed(1)} km';
    }
    return '${distanceInMeters.toStringAsFixed(0)} m';
  }
  
  static String formatFee(double fee) {
    if (fee < 0) return 'Not Deliverable';
    return 'MK${fee.toStringAsFixed(0)}';
  }
  
  static String formatFeeWithPrefix(double fee) => formatFee(fee);
  
  static String formatDeliveryInfo(double distanceInMeters, double fee) {
    return '${formatDistance(distanceInMeters)} - ${formatFee(fee)}';
  }
  
  static String formatCompleteDeliveryInfo(double distanceInMeters) {
    final info = getDeliveryTierInfo(distanceInMeters);
    return '''
Distance: ${formatDistance(distanceInMeters)}
Fee: ${formatFee(info['fee'] as double)}
Time: ${info['delivery_time_formatted']}
Total: ${info['total_time_formatted']}
Tier: ${info['name']}
''';
  }
  
  // ============================================
  // GROUP 6: GET ALL DELIVERY OPTIONS
  // ============================================
  
  static List<Map<String, dynamic>> getDeliveryOptions() {
    return [
      {'range': '0 - 100 m', 'fee': 1000, 'tier': 1, 'time': 10, 'description': 'Very Close'},
      {'range': '101 - 200 m', 'fee': 1000, 'tier': 1, 'time': 20, 'description': 'Very Close'},
      {'range': '201 - 300 m', 'fee': 1000, 'tier': 1, 'time': 30, 'description': 'Very Close'},
      {'range': '301 - 400 m', 'fee': 1000, 'tier': 1, 'time': 40, 'description': 'Very Close'},
      {'range': '401 - 500 m', 'fee': 1000, 'tier': 1, 'time': 50, 'description': 'Very Close'},
      {'range': '501 - 600 m', 'fee': 2000, 'tier': 2, 'time': 60, 'description': 'Close'},
      {'range': '601 - 700 m', 'fee': 2000, 'tier': 2, 'time': 70, 'description': 'Close'},
      {'range': '701 - 800 m', 'fee': 2000, 'tier': 2, 'time': 80, 'description': 'Close'},
      {'range': '801 - 900 m', 'fee': 2000, 'tier': 2, 'time': 90, 'description': 'Close'},
      {'range': '901 m - 1 km', 'fee': 2000, 'tier': 2, 'time': 100, 'description': 'Close'},
      {'range': '1 km - 1.5 km', 'fee': 3000, 'tier': 3, 'time': 110, 'description': 'Medium'},
      {'range': '1.5 km - 2 km', 'fee': 4000, 'tier': 4, 'time': 120, 'description': 'Far'},
      {'range': '2 km - 2.5 km', 'fee': 5000, 'tier': 5, 'time': 120, 'description': 'Very Far'},
    ];
  }
  
  // ============================================
  // GROUP 7: DISTANCE CALCULATION HELPERS
  // ============================================
  
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return R * c;
  }
  
  static double calculateDistanceInKm(double lat1, double lon1, double lat2, double lon2) {
    return calculateDistance(lat1, lon1, lat2, lon2) / 1000;
  }
  
  static bool isValidCoordinates(double lat, double lon) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
  
  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _sin(double x) => sin(x);
  static double _cos(double x) => cos(x);
  static double _sqrt(double x) => sqrt(x);
  static double _atan2(double y, double x) => atan2(y, x);
}