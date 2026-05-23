import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../utils/delivery_fee_calculator.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Location and Delivery Settings
  double? _restaurantLatitude;
  double? _restaurantLongitude;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _hasLocation = false;
  
  // Delivery Fee Settings
  final _baseFeeController = TextEditingController();
  final _feePerKmController = TextEditingController();
  final _freeDeliveryRadiusController = TextEditingController();
  final _maxDeliveryRadiusController = TextEditingController();
  
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      final restaurant = restaurantProvider.restaurant;
      
      if (restaurant != null) {
        _nameController.text = restaurant.name;
        _emailController.text = ''; // Email would come from user data
        _phoneController.text = restaurant.phone;
        _addressController.text = restaurant.address;
        _descriptionController.text = restaurant.description;
        
        // Load additional restaurant data from API
        final restaurantData = await _apiService.getMyRestaurant();
        if (restaurantData.isNotEmpty) {
          if (restaurantData['latitude'] != null) {
            _restaurantLatitude = double.parse(restaurantData['latitude'].toString());
            _restaurantLongitude = double.parse(restaurantData['longitude'].toString());
            _hasLocation = _restaurantLatitude != null && _restaurantLongitude != null;
          }
          
          // Load delivery settings
          _baseFeeController.text = restaurantData['base_delivery_fee']?.toString() ?? '2000';
          _feePerKmController.text = restaurantData['fee_per_km']?.toString() ?? '1000';
          _freeDeliveryRadiusController.text = restaurantData['free_delivery_radius']?.toString() ?? '0';
          _maxDeliveryRadiusController.text = restaurantData['max_delivery_radius']?.toString() ?? '2500';
        }
      }
    } catch (e) {
      print('Error loading restaurant data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _restaurantLatitude = location.latitude;
          _restaurantLongitude = location.longitude;
          _hasLocation = true;
        });
        _showSuccess('Location captured successfully!');
      } else {
        setState(() {
          _locationError = 'Could not get location. Please enable GPS.';
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error getting location: $e';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      
      // Update restaurant info
      final restaurantData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
      };
      
      await restaurantProvider.updateMyRestaurant(restaurantData);
      
      // Update location and delivery settings
      if (_hasLocation) {
        final locationData = {
          'latitude': _restaurantLatitude,
          'longitude': _restaurantLongitude,
          'base_delivery_fee': double.tryParse(_baseFeeController.text) ?? 2000,
          'fee_per_km': double.tryParse(_feePerKmController.text) ?? 1000,
          'free_delivery_radius': double.tryParse(_freeDeliveryRadiusController.text) ?? 0,
          'max_delivery_radius': double.tryParse(_maxDeliveryRadiusController.text) ?? 2500,
        };
        
        await restaurantProvider.updateMyRestaurant(locationData);
      }
      
      _showSuccess('Profile updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      _showError('Error updating profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _baseFeeController.dispose();
    _feePerKmController.dispose();
    _freeDeliveryRadiusController.dispose();
    _maxDeliveryRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Restaurant Profile',
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryRed, width: 3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // ============================================
                  // GROUP 1: BASIC INFORMATION
                  // ============================================
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    context,
                    label: 'Restaurant Name',
                    controller: _nameController,
                    icon: Icons.restaurant,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    context,
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    context,
                    label: 'Address',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoField(
                    context,
                    label: 'Description',
                    controller: _descriptionController,
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.deepCrimson),
                  const SizedBox(height: 24),
                  
                  // ============================================
                  // GROUP 2: RESTAURANT LOCATION
                  // ============================================
                  const Text(
                    'Restaurant Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set your restaurant location for distance-based delivery fees',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        if (_hasLocation) ...[
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Location set: ${_restaurantLatitude!.toStringAsFixed(6)}, ${_restaurantLongitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        ElevatedButton.icon(
                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(_hasLocation ? 'Update Location' : 'Get Current Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        if (_locationError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _locationError!,
                            style: TextStyle(color: AppTheme.error, fontSize: 12),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        Text(
                          'This location will be used to calculate delivery distances',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.getMutedTextColor(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.deepCrimson),
                  const SizedBox(height: 24),
                  
                  // ============================================
                  // GROUP 3: DELIVERY FEE SETTINGS (5-TIER STRUCTURE)
                  // ============================================
                  const Text(
                    'Delivery Fee Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delivery fees are calculated based on distance:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Display the 5-tier delivery fee structure
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Current Delivery Fee Structure',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFeeTierRow('0 - 500 m', 'MK1,000'),
                        _buildFeeTierRow('501 m - 1 km', 'MK2,000'),
                        _buildFeeTierRow('1 km - 1.5 km', 'MK3,000'),
                        _buildFeeTierRow('1.5 km - 2 km', 'MK4,000'),
                        _buildFeeTierRow('2 km - 2.5 km', 'MK5,000'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Beyond 2.5 km: Not deliverable',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Custom delivery settings
                  Text(
                    'Customize Delivery Pricing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDeliverySettingField(
                    context,
                    label: 'Base Delivery Fee (MK)',
                    controller: _baseFeeController,
                    hint: 'e.g., 2000',
                    icon: Icons.money,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDeliverySettingField(
                    context,
                    label: 'Fee per KM (MK)',
                    controller: _feePerKmController,
                    hint: 'e.g., 1000',
                    icon: Icons.straighten,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDeliverySettingField(
                    context,
                    label: 'Free Delivery Radius (km)',
                    controller: _freeDeliveryRadiusController,
                    hint: 'e.g., 0 (set to 0 for no free delivery)',
                    icon: Icons.celebration,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDeliverySettingField(
                    context,
                    label: 'Maximum Delivery Radius (km)',
                    controller: _maxDeliveryRadiusController,
                    hint: 'e.g., 2.5',
                    icon: Icons.radio_button_checked,
                  ),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Set maximum radius to limit delivery zone. Customers beyond this radius will not be able to order.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.deepCrimson),
                  const SizedBox(height: 24),
                  
                  // ============================================
                  // GROUP 4: SAVE BUTTON
                  // ============================================
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save All Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildFeeTierRow(String range, String fee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            range,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            fee,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryRed),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySettingField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryRed, size: 20),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: AppTheme.getMutedTextColor(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
