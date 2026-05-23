import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground, // #0F0A0A
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackground, // #0F0A0A
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.primaryText, // #FFFFFF
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGlowGradient, // #2A0F0F → #7A0C18
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryRed.withOpacity(0.5), // #FF2E2E
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryText, // #FFFFFF
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Precious Kapakasa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText, // #FFFFFF
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'precious@example.com',
                    style: TextStyle(
                      color: AppTheme.secondaryText, // #C9C9C9
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+265 888 123 456',
                    style: TextStyle(
                      color: AppTheme.secondaryText, // #C9C9C9
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Total Orders',
                      value: '12',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star_outline,
                      label: 'Ratings',
                      value: '4.8',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_offer_outlined,
                      label: 'Saved',
                      value: '3',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.history,
              title: 'Order History',
              onTap: () {
                context.go('/my-orders');
              },
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                context.go('/notifications');
              },
            ),
            _buildMenuItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English / Chichewa',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              textColor: AppTheme.error, // #EF4444
              onTap: () {
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient, // #2A0F0F → #7A0C18
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.deepCrimson.withOpacity(0.3), // #B11226
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 24), // #FF2E2E
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText, // #FFFFFF
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText, // #C9C9C9
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient, // #2A0F0F → #7A0C18
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.deepCrimson.withOpacity(0.3), // #B11226
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryRed, size: 24), // #FF2E2E
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppTheme.primaryText, // #FFFFFF
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.secondaryText, // #C9C9C9
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.mutedText, // #8A8A8A
        ),
        onTap: onTap,
      ),
    );
  }
}