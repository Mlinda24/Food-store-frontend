import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // ── Get current GPS position ──────────────────────────────────────────
  static Future<Position?> getCurrentLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) return null;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ LocationService.getCurrentLocation error: $e');
      return null;
    }
  }

  // ── Distance in metres between two coordinates ────────────────────────
  static Future<double> calculateDistanceInMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // ── Check permission without prompting ────────────────────────────────
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // ── Check if device GPS is on ─────────────────────────────────────────
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  // ── Open device location settings ─────────────────────────────────────
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}