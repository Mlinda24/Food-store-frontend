import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/driver/driver_dashboard_screen.dart';
import '../screens/restaurant/restaurant_dashboard_screen.dart';
import '../screens/driver/driver_settings_screen.dart';
import '../screens/driver/driver_analytics_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: <GoRoute>[
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role-selection',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/driver',
      name: 'driver',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/restaurant',
      name: 'restaurant',
      builder: (context, state) => const RestaurantDashboardScreen(),
    ),
    GoRoute(
      path: '/driver-settings',
      name: 'driver-settings',
      builder: (context, state) => const DriverSettingsScreen(),
    ),
    GoRoute(
      path: '/driver-analytics',
      name: 'driver-analytics',
      builder: (context, state) => const DriverAnalyticsScreen(),
    ),
  ],
);