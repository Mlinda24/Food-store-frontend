import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegistrationScreen(selectedRole: state.extra as String?),
    ),
  ],
);