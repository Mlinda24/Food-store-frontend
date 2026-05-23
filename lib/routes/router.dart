import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/restaurant_details_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/my_orders_screen.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/customer/settings_screen.dart';
import '../screens/customer/food_detail_screen.dart';  // IMPORTANT: Add this import
import '../screens/restaurant/restaurant_dashboard_screen.dart';
import '../screens/restaurant/restaurant_profile_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/models.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    // Customer Routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/restaurant-details',
      name: 'restaurant-details',
      builder: (context, state) {
        final restaurant = state.extra as Restaurant?;
        return RestaurantDetailsScreen(restaurant: restaurant);
      },
    ),
    // IMPORTANT: Add the food-detail route
    GoRoute(
      path: '/food-detail',
      name: 'food-detail',
      builder: (context, state) {
        final food = state.extra as Map<String, dynamic>;
        return FoodDetailScreen(food: food);
      },
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/my-orders',
      name: 'my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: '/order-tracking',
      name: 'order-tracking',
      builder: (context, state) {
        final order = state.extra as Order?;
        return OrderTrackingScreen(order: order);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const CustomerProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // Restaurant Routes
    GoRoute(
      path: '/restaurant',
      name: 'restaurant',
      builder: (context, state) => const RestaurantDashboardScreen(),
    ),
    GoRoute(
      path: '/restaurant-profile',
      name: 'restaurant-profile',
      builder: (context, state) => const RestaurantProfileScreen(),
    ),
    // Driver Route
    GoRoute(
      path: '/driver',
      name: 'driver',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
  ],
);