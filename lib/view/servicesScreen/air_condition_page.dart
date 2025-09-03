// ignore_for_file: use_build_context_synchronously

import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/controller/services/services_service.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/widgets/service_card_widget.dart';
import 'package:flutter/material.dart';

class AirConditionPage extends StatefulWidget {
  const AirConditionPage({super.key});

  @override
  State<AirConditionPage> createState() => _AirConditionPageState();
}

class _AirConditionPageState extends State<AirConditionPage> {
  final ServicesService _servicesService = ServicesService();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
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
          body: FutureBuilder<List<ServiceModel>>(
            future: _servicesService.getServicesByType('airCondition'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final services = snapshot.data ?? [];
              if (services.isEmpty) return Center(child: Text('لا توجد خدمات', style: AppTextStyles.body14));
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCardWidget(service: service, showAddButton: true);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
