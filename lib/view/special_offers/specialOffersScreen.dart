import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';

class SpecialOffersScreen extends StatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  State<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Center(
        child: 
        Text(
          'Special Offers Screen',
          style: AppTextStyles.heading26,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}