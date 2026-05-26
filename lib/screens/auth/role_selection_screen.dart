import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
Widget build(BuildContext context) {
    final List<Map<String, dynamic>> roles = [
      {
        'title': 'Customer',
        'icon': Icons.person_outline,
        'description': 'Order food from your favorite restaurants',
        'color': AppTheme.primaryRed,
        'roleValue': 'customer',
      },
      {
        'title': 'Restaurant Owner',
        'icon': Icons.restaurant_outlined,
        'description': 'Manage your restaurant and orders',
        'color': AppTheme.warning,
        'roleValue': 'restaurant',
      },
      {
        'title': 'Delivery Driver',
        'icon': Icons.delivery_dining_outlined,
        'description': 'Deliver food and earn money',
        'color': AppTheme.teal,
        'roleValue': 'driver',
      },
      {
        'title': 'Admin',
        'icon': Icons.admin_panel_settings_outlined,
        'description': 'Manage platform and users',
        'color': AppTheme.orange,
        'roleValue': 'admin',
      },
    ];

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
          'Select Your Role',
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Choose how you want to use the app',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGlowGradient(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.deepCrimson.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (role['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          role['icon'] as IconData,
                          color: role['color'] as Color,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        role['title'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                      subtitle: Text(
                        role['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryRed,
                        size: 18,
                      ),
                      onTap: () {
                        context.push(
                          '/register',
                          extra: role['roleValue'] as String,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}