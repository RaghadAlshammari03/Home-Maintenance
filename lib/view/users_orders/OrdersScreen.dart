import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreensState();
}

class _OrdersScreensState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Center(
        child: 
        Text(
          'Orders Screen',
          style: AppTextStyles.heading26,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}