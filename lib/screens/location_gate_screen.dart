import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class LocationGateScreen extends StatefulWidget {
  const LocationGateScreen({super.key});

  @override
  State<LocationGateScreen> createState() => _LocationGateScreenState();
}

class _LocationGateScreenState extends State<LocationGateScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isWithinZomba = false;
  bool _devOverride = false; // developer override flag
  Position? _currentPosition;

  // Zomba district center coordinates (approximate)
  static const double zombaLat = -15.386;
  static const double zombaLon = 35.318;
  // Radius increased to 50 km to cover wider area
  static const double allowedRadius = 50000; // 50 km

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndProceed();
  }

  Future<void> _checkLocationPermissionAndProceed() async {
    setState(() => _isLoading = true);

    // Developer override: skip real location check
    if (_devOverride) {
      setState(() {
        _isWithinZomba = true;
        _isLoading = false;
      });
      return;
    }

    // Check and request permission
    final status = await Permission.location.request();
    if (status.isDenied) {
      setState(() {
        _errorMessage = 'Location permission is required to use Foodie Express.';
        _isLoading = false;
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Location permission permanently denied. Please enable it in settings.';
        _isLoading = false;
      });
      return;
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _currentPosition = position;

      // Check if within Zomba radius
      final distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        zombaLat, zombaLon,
      );
      _isWithinZomba = distance <= allowedRadius;

      // Debug output
      debugPrint('Distance to Zomba center: ${distance.toStringAsFixed(0)} meters');
      debugPrint('Within allowed radius: $_isWithinZomba');

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to get your location. Please check GPS.';
        _isLoading = false;
      });
    }
  }

  void _showOutOfAreaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Service Not Available'),
        content: const Text(
          'Foodie Express is currently only available in Zomba district.\n\n'
          'We are expanding soon – stay tuned!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _proceedToAuth() {
    context.go('/login');
  }

  // Developer override: long press on the hero image
  void _enableDevOverride() {
    setState(() {
      _devOverride = true;
      _isLoading = true;
    });
    _checkLocationPermissionAndProceed();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Developer override: location check bypassed (simulating inside Zomba)'),
        backgroundColor: AppTheme.warning,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && !_devOverride
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 80, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.error)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _checkLocationPermissionAndProceed,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero image with long-press override
                        GestureDetector(
                          onLongPress: _enableDevOverride,
                          child: Container(
                            height: 250,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _devOverride ? 'DEV MODE: Zomba Simulated' : 'Taste the Best of Zomba',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black.withOpacity(0.5))],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Food grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              _buildFoodItem('https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400', 'Margherita Pizza'),
                              _buildFoodItem('https://images.unsplash.com/photo-1551782450-17144efb9c50?w=400', 'Burger & Fries'),
                              _buildFoodItem('https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400', 'Chicken Biryani'),
                              _buildFoodItem('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400', 'Healthy Bowl'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Location prompt & action
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGlowGradient(context),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, color: _isWithinZomba ? AppTheme.success : AppTheme.primaryRed),
                                  const SizedBox(width: 8),
                                  Text(
                                    _devOverride ? 'DEV OVERRIDE: Zomba' : (_isWithinZomba ? 'You are in Zomba!' : 'You are outside Zomba'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _isWithinZomba ? AppTheme.success : AppTheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isWithinZomba
                                    ? 'Great! Pick your location and start ordering.'
                                    : 'Foodie Express is not yet available in your area. We are expanding soon!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                              ),
                              const SizedBox(height: 24),
                              if (_isWithinZomba)
                                Column(
                                  children: [
                                    Text(
                                      'You are almost there!',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Login or sign up to enjoy our delicious meals delivered to your doorstep.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _proceedToAuth,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryRed,
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                              else
                                ElevatedButton(
                                  onPressed: _checkLocationPermissionAndProceed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.error,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Text('Retry Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_devOverride)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '⚠️ Developer mode: Location check bypassed',
                              style: TextStyle(fontSize: 12, color: AppTheme.warning),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildFoodItem(String imageUrl, String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.getCardColor(context),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.getPrimaryTextColor(context))),
          ),
        ],
      ),
    );
  }
}
