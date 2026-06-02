import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/customer/order_tracking_screen.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/restaurant_details_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/shopping_cart_screen.dart';
import '../screens/customer/my_orders_screen.dart';
import '../screens/customer/search_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/customer/settings_screen.dart';
import '../screens/customer/food_detail_screen.dart';
import '../screens/restaurant/restaurant_dashboard_screen.dart';
import '../screens/restaurant/restaurant_profile_screen.dart';
import '../screens/restaurant/withdraw_screen.dart';
import '../screens/restaurant/restaurant_setup_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/driver/available_orders_screen.dart';
import '../screens/driver/delivery_history_screen.dart';
import '../screens/driver/driver_earnings_screen.dart';
import '../screens/driver/driver_settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/landing',
  redirect: (context, state) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    await Future.delayed(Duration.zero);

    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.currentUser;

    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/role-selection';

    final isPublicRoute = state.matchedLocation == '/landing';

    // If not authenticated and trying to access protected route
    if (!isAuthenticated && !isAuthRoute && !isPublicRoute) {
      return '/login';
    }

    // If authenticated and trying to access auth routes, redirect based on role
    if (isAuthenticated && isAuthRoute) {
      if (user != null) {
        if (user.role == UserRole.customer) return '/home';
        if (user.role == UserRole.restaurant) {
          try {
            await restaurantProvider.loadRestaurantInfo();
            if (restaurantProvider.restaurant == null) {
              return '/restaurant-setup';
            }
            return '/restaurant';
          } catch (e) {
            return '/restaurant-setup';
          }
        }
        if (user.role == UserRole.driver) return '/driver';
      }
    }

    return null;
  },
  routes: [
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
      path: '/restaurant-setup',
      name: 'restaurant-setup',
      builder: (context, state) => const RestaurantSetupScreen(),
    ),
    GoRoute(
      path: '/restaurant-profile',
      name: 'restaurant-profile',
      builder: (context, state) => const RestaurantProfileScreen(),
    ),
    GoRoute(
      path: '/withdraw',
      name: 'withdraw',
      builder: (context, state) => const WithdrawScreen(),
    ),
    // Driver Routes
    GoRoute(
      path: '/driver',
      name: 'driver',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/driver/available-orders',
      name: 'driver-available-orders',
      builder: (context, state) => const AvailableOrdersScreen(),
    ),
    GoRoute(
      path: '/driver/delivery-history',
      name: 'driver-delivery-history',
      builder: (context, state) => const DeliveryHistoryScreen(),
    ),
    GoRoute(
      path: '/driver/earnings',
      name: 'driver-earnings',
      builder: (context, state) => const DriverEarningsScreen(),
    ),
    GoRoute(
      path: '/driver/settings',
      name: 'driver-settings',
      builder: (context, state) => const DriverSettingsScreen(),
    ),
  ],
);
