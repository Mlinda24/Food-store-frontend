import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RestaurantProfileScreen extends StatelessWidget {
  const RestaurantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final restaurant = authProvider.currentUser;

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
      body: SingleChildScrollView(
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
            
            // Restaurant Name Field
            _buildInfoField(
              context,
              label: 'Restaurant Name',
              value: restaurant?.name ?? 'My Restaurant',
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 16),
            
            // Email Field
            _buildInfoField(
              context,
              label: 'Email Address',
              value: restaurant?.email ?? 'restaurant@example.com',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            
            // Phone Field
            _buildInfoField(
              context,
              label: 'Phone Number',
              value: restaurant?.phone ?? '+265 888 123 456',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            
            // Address Field
            _buildInfoField(
              context,
              label: 'Address',
              value: '123 Main Street, Downtown',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            
            // Description Field
            _buildInfoField(
              context,
              label: 'Description',
              value: 'Authentic Italian cuisine serving the best pizza and pasta in town.',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Save Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
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
            controller: TextEditingController(text: value),
            style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
            maxLines: maxLines,
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
}