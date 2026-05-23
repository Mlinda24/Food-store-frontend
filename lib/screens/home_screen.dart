import 'package:flutter/material.dart';
import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodie Express'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const Center(
        child: Text('Welcome to Foodie Express'),
      ),
    );
  }
}
