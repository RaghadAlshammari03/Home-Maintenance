import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/services/services_data/data.dart';
import 'package:baligny/view/services/widgets/service_card.dart';
import 'package:flutter/material.dart';

class PlumbingPage extends StatefulWidget {
  const PlumbingPage({super.key});

  @override
  State<PlumbingPage> createState() => _PlumbingPageState();
}

class _PlumbingPageState extends State<PlumbingPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'خدمات السباكة',
            style: AppTextStyles.heading20Bold.copyWith(color: white, fontWeight: FontWeight.bold),
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
            itemCount: plumbingServicesList.length,
            itemBuilder: (context, index) {
              final service = plumbingServicesList[index];
              return ServiceCard(
                title: service.serviceName,
                description: service.serviceDetail,
              );
            },
          ),
        ),
      ),
    );
  }
}