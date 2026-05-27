import 'package:flutter/material.dart';
import '../screens/customer/order_tracking_screen.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/location_gate_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/restaurant_details_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/shopping_cart_screen.dart';
import '../screens/customer/my_orders_screen.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/customer/settings_screen.dart';
import '../screens/customer/food_detail_screen.dart';
import '../screens/restaurant/restaurant_dashboard_screen.dart';
import '../screens/restaurant/restaurant_profile_screen.dart';
import '../screens/restaurant/withdraw_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/models.dart';

final GoRouter router = GoRouter(
  initialLocation: '/location-gate',
  routes: [
    // Location gate (first screen)
    GoRoute(
      path: '/location-gate',
      name: 'location-gate',
      builder: (context, state) => const LocationGateScreen(),
    ),
    // Landing Screen
    GoRoute(
      path: '/landing',
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    // Auth Routes
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) {
        final selectedRole = state.extra as String?;
        return RegistrationScreen(selectedRole: selectedRole);
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
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
        final restaurantData = state.extra as Map<String, dynamic>?;
        return RestaurantDetailsScreen(restaurantData: restaurantData ?? {});
      },
    ),
    GoRoute(
      path: '/food-detail',
      name: 'food-detail',
      builder: (context, state) {
        final food = state.extra as Map<String, dynamic>?;
        return FoodDetailScreen(food: food ?? {});
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const ShoppingCartScreen(),
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
    // Withdraw Route (for restaurant owners)
    GoRoute(
      path: '/withdraw',
      name: 'withdraw',
      builder: (context, state) => const WithdrawScreen(),
    ),
    // Driver Route
    GoRoute(
      path: '/driver',
      name: 'driver',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
  ],
);
