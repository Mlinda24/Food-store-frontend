import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const Center(
        child: Text('Driver Dashboard'),
      ),
    );
  }
}
