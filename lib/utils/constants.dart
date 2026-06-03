class AppConstants {
  static const double defaultDeliveryFee = 2000.0;
  static const double maxDeliveryRadius = 2500.0; // meters
  static const double freeDeliveryRadius = 0.0;
  static const double deliveryFeePerKm = 1000.0;

  static const String paymentMethodMpamba = 'mpamba';
  static const String paymentMethodAirtel = 'airtel_money';
  static const String paymentMethodPaychangu = 'paychangu';

  static const List<String> deliveryTiers = ['Standard', 'Express', 'Premium'];
}
