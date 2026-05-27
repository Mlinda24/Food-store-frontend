import '../../services/restaurant_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/restaurant_service.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  Map<String, dynamic>? _restaurant;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await RestaurantService.getMyRestaurant();
      // API returns a list for my_restaurant
      setState(() {
        _restaurant = data is List && data.isNotEmpty ? data[0] as Map<String, dynamic> : data as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showEditDialog() {
    if (_restaurant == null) return;
    final nameCtrl = TextEditingController(text: _restaurant!['name'] ?? '');
    final descCtrl = TextEditingController(text: _restaurant!['description'] ?? '');
    final addressCtrl = TextEditingController(text: _restaurant!['address'] ?? '');
    final phoneCtrl = TextEditingController(text: _restaurant!['phone'] ?? '');
    final feeCtrl = TextEditingController(text: _restaurant!['delivery_fee']?.toString() ?? '');
    final minOrderCtrl = TextEditingController(text: _restaurant!['min_order_amount']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Restaurant Name')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Delivery Fee (MK)')),
            const SizedBox(height: 12),
            TextField(controller: minOrderCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Order (MK)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await RestaurantService.updateMyRestaurant({
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                  'address': addressCtrl.text,
                  'phone': phoneCtrl.text,
                  'delivery_fee': feeCtrl.text,
                  'min_order_amount': minOrderCtrl.text,
                });
                _loadProfile();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.success));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));

    if (_error != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
        const SizedBox(height: 12),
        Text('Failed to load profile', style: TextStyle(color: AppTheme.secondaryText)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
      ]));
    }

    final r = _restaurant;
    final rating = double.tryParse(r?['rating']?.toString() ?? '0') ?? 0;
    final totalOrders = r?['total_orders'] ?? 0;
    final deliveryTime = r?['delivery_time'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppTheme.primaryRed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGlowGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            child: Column(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryRed, width: 3),
                ),
                child: r?['image'] != null
                    ? ClipOval(child: Image.network(r!['image'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 50, color: Colors.white)))
                    : const Center(child: Icon(Icons.restaurant, size: 50, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Text(r?['name'] ?? 'My Restaurant', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              const SizedBox(height: 8),
              Text(r?['owner_name'] ?? '', style: TextStyle(fontSize: 14, color: AppTheme.secondaryText)),
              const SizedBox(height: 4),
              Text(r?['phone'] ?? '', style: TextStyle(fontSize: 14, color: AppTheme.secondaryText)),
            ]),
          ),
          const SizedBox(height: 24),

          // Restaurant Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppTheme.cardGlowGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Restaurant Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              const SizedBox(height: 16),
              _buildInfoRow('Address', r?['address'] ?? '-'),
              _buildInfoRow('Description', r?['description'] ?? '-'),
              _buildInfoRow('Delivery Fee', r?['delivery_fee'] != null ? 'MK${r!['delivery_fee']}' : '-'),
              _buildInfoRow('Min Order', r?['min_order_amount'] != null ? 'MK${r!['min_order_amount']}' : '-'),
              _buildInfoRow('Avg Delivery', '$deliveryTime min'),
              _buildInfoRow('Status', r?['is_open'] == true ? 'Open ✓' : 'Closed'),
            ]),
          ),
          const SizedBox(height: 24),

          // Performance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppTheme.cardGlowGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              const SizedBox(height: 16),
              _buildInfoRow('Average Rating', '$rating ★'),
              _buildInfoRow('Total Orders', '$totalOrders'),
            ]),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showEditDialog,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 14, color: AppTheme.secondaryText))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryText))),
      ]),
    );
  }
}