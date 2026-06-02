import 'api_service.dart';

class DriverService {
  static final ApiService _apiService = ApiService();

  static Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.getDriverProfile();
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    return await _apiService.updateDriverProfile(data);
  }

  static Future<Map<String, dynamic>> updateStatus(String status) async {
    return await _apiService.updateDriverStatus(status);
  }

  static Future<Map<String, dynamic>> updateLocation(
      double lat, double lng) async {
    return await _apiService.updateDriverLocation(lat, lng);
  }

  static Future<List<dynamic>> getAvailableOrders() async {
    return await _apiService.getAvailableOrders();
  }

  static Future<List<dynamic>> getMyDeliveries() async {
    return await _apiService.getMyDeliveries();
  }

  static Future<Map<String, dynamic>> getActiveDelivery() async {
    return await _apiService.getActiveDelivery();
  }

  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    return await _apiService.acceptDelivery(orderId);
  }

  static Future<Map<String, dynamic>> declineOrder(String orderId) async {
    return await _apiService.declineDelivery(orderId);
  }

  static Future<Map<String, dynamic>> updateDeliveryStatus(
      String orderId, String status) async {
    return await _apiService.updateDeliveryStatus(orderId, status);
  }

  static Future<Map<String, dynamic>> getEarningsSummary() async {
    return await _apiService.getEarningsSummary();
  }

  static Future<Map<String, dynamic>> getDeliveryHistory() async {
    return await _apiService.getDeliveryHistory();
  }
}
