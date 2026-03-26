import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class SidebarMenu extends StatefulWidget {
  final Widget child;
  final List<SidebarMenuItem> items;
  final VoidCallback? onLogout;
  final String currentRoute;
  final Function(int)? onMenuItemTap;

  const SidebarMenu({
    super.key,
    required this.child,
    required this.items,
    this.onLogout,
    required this.currentRoute,
    this.onMenuItemTap,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      if (_isMenuOpen) {
        _animationController.reverse();
        _isMenuOpen = false;
      } else {
        _animationController.forward();
        _isMenuOpen = true;
      }
    });
  }

  void _onMenuItemTap(int index) {
    _toggleMenu();
    if (widget.onMenuItemTap != null) {
      widget.onMenuItemTap!(index);
    } else {
      final route = widget.items[index].route;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Stack(
        children: [
          // Main Content
          widget.child,
          
          // 3-Dot Menu Button - TOP LEFT
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGlowGradient,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppTheme.deepCrimson.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Overlay Background
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          
          // Menu Panel - TOP LEFT ALIGNED
          if (_isMenuOpen)
            Positioned(
              top: 70,
              left: 20,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGlowGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.deepCrimson.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User Info Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryButtonGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Foodie Express',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryText,
                                        ),
                                      ),
                                      Text(
                                        'Restaurant Owner',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: AppTheme.deepCrimson,
                          ),
                          // Menu Items
                          ...widget.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isSelected = widget.currentRoute == item.route;
                            return InkWell(
                              onTap: () => _onMenuItemTap(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryRed.withOpacity(0.1)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 20,
                                      color: isSelected
                                          ? AppTheme.primaryRed
                                          : AppTheme.secondaryText,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppTheme.primaryRed
                                              : AppTheme.secondaryText,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppTheme.primaryRed,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const Divider(
                            height: 1,
                            color: AppTheme.deepCrimson,
                          ),
                          // Logout Button
                          if (widget.onLogout != null)
                            InkWell(
                              onTap: () {
                                _toggleMenu();
                                widget.onLogout!();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 20,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SidebarMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const SidebarMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}