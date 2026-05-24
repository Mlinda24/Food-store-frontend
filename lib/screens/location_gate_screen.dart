import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

const _kZombaLat = -15.386;
const _kZombaLng = 35.318;
const _kZombaRadius = 50000.0;

class LocationGateScreen extends StatefulWidget {
  const LocationGateScreen({super.key});

  @override
  State<LocationGateScreen> createState() => _LocationGateScreenState();
}

class _LocationGateScreenState extends State<LocationGateScreen> {
  final MapController _mapController = MapController();

  LatLng? _tappedPoint;
  bool _isInsideZomba = false;
  bool _locationPermissionDenied = false;
  bool _isLocatingMe = false;
  bool _devOverride = false;

  // ── Haversine distance ────────────────────────────────────────────────
  double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    double toRad(double d) => d * pi / 180;
    final dLat = toRad(b.latitude - a.latitude);
    final dLng = toRad(b.longitude - a.longitude);
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRad(a.latitude)) *
            cos(toRad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  bool _withinZomba(LatLng point) =>
      _distanceMeters(point, const LatLng(_kZombaLat, _kZombaLng)) <=
      _kZombaRadius;

  // ── Map tap ───────────────────────────────────────────────────────────
  void _onMapTap(TapPosition _, LatLng point) {
    setState(() {
      _tappedPoint = point;
      _isInsideZomba = _withinZomba(point);
    });
  }

  // ── GPS button ────────────────────────────────────────────────────────
  Future<void> _useMyLocation() async {
    setState(() => _isLocatingMe = true);

    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _locationPermissionDenied = true;
        _isLocatingMe = false;
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LatLng(pos.latitude, pos.longitude);
      _mapController.move(point, 12);
      setState(() {
        _tappedPoint = point;
        _isInsideZomba = _withinZomba(point);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not get GPS location. Tap the map instead.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocatingMe = false);
    }
  }

  // ── Dev override ──────────────────────────────────────────────────────
  void _enableDevOverride() {
    setState(() {
      _devOverride = true;
      _tappedPoint = const LatLng(_kZombaLat, _kZombaLng);
      _isInsideZomba = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dev override: simulating inside Zomba'),
        backgroundColor: AppTheme.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _proceed() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    final accepted = _devOverride || _isInsideZomba;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            GestureDetector(
              onLongPress: _enableDevOverride,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _devOverride
                          ? 'DEV MODE – Zomba simulated'
                          : 'Pick your delivery location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _devOverride
                            ? AppTheme.warning
                            : AppTheme.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap anywhere on the map — we deliver within Zomba',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Map ─────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          const LatLng(_kZombaLat, _kZombaLng),
                      initialZoom: 10,
                      onTap: _onMapTap,
                    ),
                    children: [
                      // OpenStreetMap tiles — no API key needed
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.yourapp.foodie_express_mobile',
                      ),

                      // Zomba delivery zone circle
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: const LatLng(_kZombaLat, _kZombaLng),
                            radius: _kZombaRadius,
                            useRadiusInMeter: true,
                            color:
                                const Color(0xFFE63946).withOpacity(0.12),
                            borderColor: const Color(0xFFE63946),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),

                      // "Zomba district" label
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: const LatLng(_kZombaLat - 0.15,
                                _kZombaLng),
                            width: 120,
                            height: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.88),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Zomba district',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFb91c1c)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Tapped pin
                      if (_tappedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _tappedPoint!,
                              width: 40,
                              height: 50,
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.location_pin,
                                size: 40,
                                color: _isInsideZomba
                                    ? AppTheme.success
                                    : AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // GPS FAB
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'gps',
                      backgroundColor: AppTheme.primaryRed,
                      onPressed: _isLocatingMe ? null : _useMyLocation,
                      child: _isLocatingMe
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.my_location,
                              color: Colors.white),
                    ),
                  ),

                  // First-tap hint
                  if (_tappedPoint == null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tap the map to pin your location',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Permission denied banner
                  if (_locationPermissionDenied)
                    Positioned(
                      top: 8,
                      left: 12,
                      right: 12,
                      child: Material(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_off,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Location permission denied — tap the map manually.',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _locationPermissionDenied = false),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Result card ──────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: _tappedPoint == null && !_devOverride
                    ? AppTheme.getCardColor(context)
                    : accepted
                        ? AppTheme.success.withOpacity(0.08)
                        : AppTheme.error.withOpacity(0.08),
                border: Border(
                  top: BorderSide(
                    color: _tappedPoint == null && !_devOverride
                        ? AppTheme.getMutedTextColor(context)
                            .withOpacity(0.2)
                        : accepted
                            ? AppTheme.success
                            : AppTheme.error,
                    width: 1.5,
                  ),
                ),
              ),
              child: _devOverride
                  ? _buildSuccess(context)
                  : _tappedPoint == null
                      ? _buildIdle(context)
                      : accepted
                          ? _buildSuccess(context)
                          : _buildError(context),
            ),

            // ── Get Started button ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accepted
                        ? AppTheme.primaryRed
                        : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: const StadiumBorder(),
                    elevation: accepted ? 2 : 0,
                  ),
                  onPressed: accepted ? _proceed : null,
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdle(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.touch_app_outlined,
            color: AppTheme.getMutedTextColor(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Tap the map to choose your delivery location',
            style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.success),
            const SizedBox(width: 6),
            Text(
              _devOverride ? 'DEV – Zomba (simulated)' : 'You are in Zomba!',
              style: TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'You are almost there!',
          style: TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
        const SizedBox(height: 4),
        Text(
          'Login or sign up to enjoy our delicious meals delivered to your doorstep.',
          style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_off, color: AppTheme.error),
            const SizedBox(width: 6),
            Text(
              'You are almost there!',
              style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Login or sign up to enjoy our delicious meals delivered to your doorstep.',
          style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          'Foodie Express is currently only available in Zomba district. We are expanding soon!',
          style: TextStyle(
              color: AppTheme.error.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }
}