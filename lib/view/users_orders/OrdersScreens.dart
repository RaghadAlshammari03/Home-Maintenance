import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';

class OrdersScreens extends StatefulWidget {
  const OrdersScreens({super.key});

  @override
  State<OrdersScreens> createState() => _OrdersScreensState();
}

class _OrdersScreensState extends State<OrdersScreens> {
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