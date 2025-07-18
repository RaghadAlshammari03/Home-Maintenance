import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
//import 'package:baligny/view/cart/cart_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
      return AppBar(
        title: Text(
          'السلة',
          style: AppTextStyles.heading20Bold.copyWith(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 80,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: lightOrange,
        foregroundColor: Colors.white,
      );
  }
}
