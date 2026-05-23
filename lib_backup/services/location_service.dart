import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../utils/delivery_fee_calculator.dart';

class LocationService {
  // ============================================
  // GROUP 1: PERMISSION HANDLING
  // ============================================
  
  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }
  
  static Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }
  
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // ============================================
  // GROUP 2: LOCATION RETRIEVAL
  // ============================================
  
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }
  
  static Future<Position?> getCurrentLocationWithTimeout({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );
    } catch (e) {
      print('Error getting location with timeout: $e');
      return null;
    }
  }
  
  static Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }
  
  // ============================================
  // GROUP 3: DISTANCE CALCULATION (METERS)
  // ============================================
  
  static Future<double> calculateDistanceInMeters(
    double lat1, double lon1, double lat2, double lon2
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  static Future<double> calculateDistanceInKm(
    double lat1, double lon1, double lat2, double lon2
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
  
  static double calculateDistanceInMetersSync(
    double lat1, double lon1, double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  static double calculateDistanceInKmSync(
    double lat1, double lon1, double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
  
  // ============================================
  // GROUP 4: DELIVERY FEE CALCULATION
  // ============================================
  
  static Future<Map<String, dynamic>> getDeliveryFee(
    String restaurantId, double customerLat, double customerLng
  ) async {
    final apiService = ApiService();
    try {
      return await apiService.getRestaurantDeliveryInfo(restaurantId, customerLat, customerLng);
    } catch (e) {
      print('Error getting delivery fee from API: $e');
      return {
        'distance_meters': null,
        'distance_km': null,
        'delivery_fee': 2000.0,
        'can_deliver': true,
        'tier': null,
        'tier_number': null,
        'max_delivery_radius': 2500.0,
        'free_delivery_radius': 0.0,
      };
    }
  }
  
  static Future<Map<String, dynamic>> calculateDeliveryInfo(
    double restaurantLat, double restaurantLng,
    double customerLat, double customerLng,
  ) async {
    // Calculate distance in meters
    final distanceInMeters = await calculateDistanceInMeters(
      restaurantLat, restaurantLng,
      customerLat, customerLng,
    );
    
    // Calculate delivery fee using the 5-tier structure
    final deliveryFee = DeliveryFeeCalculator.calculateFee(distanceInMeters);
    final canDeliver = DeliveryFeeCalculator.canDeliver(distanceInMeters);
    final tier = DeliveryFeeCalculator.getDeliveryTier(distanceInMeters);
    final tierNumber = DeliveryFeeCalculator.getTierNumber(distanceInMeters);
    
    return {
      'distance_meters': distanceInMeters,
      'distance_km': distanceInMeters / 1000,
      'distance_formatted': DeliveryFeeCalculator.formatDistance(distanceInMeters),
      'delivery_fee': deliveryFee,
      'delivery_fee_formatted': DeliveryFeeCalculator.formatFee(deliveryFee),
      'can_deliver': canDeliver,
      'tier': tier,
      'tier_number': tierNumber,
    };
  }
  
  // ============================================
  // GROUP 5: LOCATION VALIDATION
  // ============================================
  
  static bool isValidCoordinate(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }
  
  static bool isWithinRadius(
    double lat1, double lon1, double lat2, double lon2, double radiusInMeters
  ) {
    final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distance <= radiusInMeters;
  }
  
  static Future<bool> canDeliverToCustomer(
    double restaurantLat, double restaurantLng,
    double customerLat, double customerLng,
    double maxRadiusInMeters,
  ) async {
    final distance = await calculateDistanceInMeters(
      restaurantLat, restaurantLng,
      customerLat, customerLng,
    );
    return distance <= maxRadiusInMeters;
  }
  
  // ============================================
  // GROUP 6: ADDRESS TO COORDINATES (Placeholder for geocoding)
  // ============================================
  
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    // This requires a geocoding service
    // You can implement using Google Maps Geocoding API
    // For now, returns null
    print('Geocoding not implemented. Please implement with a geocoding service.');
    return null;
  }
  
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    // This requires reverse geocoding
    // You can implement using Google Maps Geocoding API
    // For now, returns null
    print('Reverse geocoding not implemented. Please implement with a geocoding service.');
    return null;
  }
}