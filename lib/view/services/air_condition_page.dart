// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/services/services_data/data.dart';
import 'package:baligny/view/services/widgets/service_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AirConditionPage extends StatefulWidget {
  const AirConditionPage({super.key});

  @override
  State<AirConditionPage> createState() => _AirConditionPageState();
}

class _AirConditionPageState extends State<AirConditionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'خدمات التكييف',
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
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: airConditionServicesList.length,
             itemBuilder: (context, index) {
              final service = airConditionServicesList[index];
              return ServiceCard(service: service);
            },
          ),
        ),
      ),
    );
  }
}
