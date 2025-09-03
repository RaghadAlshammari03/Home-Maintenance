import 'dart:convert';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/orderServices/orderServices.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/view/ordersScreen/currentOrderScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Orders',
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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child('Technician/${auth.currentUser!.uid}')
                .onValue,
            builder: (context, techSnap) {
              if (techSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              String? activeDeliveryRequestID;
              if (techSnap.hasData && techSnap.data!.snapshot.value != null) {
                try {
                  final map =
                      jsonDecode(jsonEncode(techSnap.data!.snapshot.value))
                          as Map<String, dynamic>;
                  activeDeliveryRequestID =
                      map['activeDeliveryRequestID'] as String?;
                } catch (_) {}
              }

              return StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('Orders')
                    .orderByChild('technicianUID')
                    .equalTo(auth.currentUser!.uid)
                    .onValue,
                builder: (context, ordersSnap) {
                  if (ordersSnap.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  final raw = ordersSnap.data?.snapshot.value;

                  List<ServiceOrderModel> list = [];

                  if (raw is Map) {
                    raw.forEach((k, v) {
                      try {
                        final map =
                            jsonDecode(jsonEncode(v)) as Map<String, dynamic>;
                        final order = ServiceOrderModel.fromMap(map);
                        if (order.orderStatus == OrderServices.orderStatus(0)) {
                          list.add(order);
                        }
                      } catch (_) {}
                    });
                  } else if (raw is List) {
                    for (final item in raw) {
                      if (item == null) continue;
                      try {
                        final map =
                            jsonDecode(jsonEncode(item))
                                as Map<String, dynamic>;
                        final order = ServiceOrderModel.fromMap(map);
                        if (order.orderStatus == OrderServices.orderStatus(0)) {
                          list.add(order);
                        }
                      } catch (_) {}
                    }
                  }

                  // If technician has an activeDeliveryRequestID, fetch that order and include if under preparation
                  return FutureBuilder(
                    future: () async {
                      if (activeDeliveryRequestID == null ||
                          activeDeliveryRequestID.isEmpty)
                        return <ServiceOrderModel>[];
                      try {
                        final snap = await FirebaseDatabase.instance
                            .ref()
                            .child('Orders')
                            .child(activeDeliveryRequestID)
                            .get();
                        if (!snap.exists || snap.value == null)
                          return <ServiceOrderModel>[];
                        final map =
                            jsonDecode(jsonEncode(snap.value))
                                as Map<String, dynamic>;
                        final o = ServiceOrderModel.fromMap(map);
                        if (o.orderStatus == OrderServices.orderStatus(0)) {
                          // ensure it's not already in the list
                          if (!list.any((e) => e.orderID == o.orderID)) {
                            list.insert(0, o);
                          }
                        }
                      } catch (_) {}
                      return list;
                    }(),
                    builder: (context, snapshot) {
                      final merged = snapshot.data != null
                          ? (snapshot.data as List<ServiceOrderModel>)
                          : list;
                      if (merged.isEmpty) {
                        return Center(
                          child: Text(
                            'No skipped orders',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: merged.length,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        itemBuilder: (context, i) {
                          final order = merged[i];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 1.h),
                            child: ListTile(
                              title: Text(
                                order.primaryService.name ?? 'Service',
                              ),
                              subtitle: Text(order.orderID ?? ''),
                              trailing: TextButton(
                                onPressed: () async {
                                  // set provider orderData and navigate to CurrentOrderScreen
                                  final tp = context.read<TechnicianProvider>();
                                  tp.updateOrderData(order);
                                  tp.updateInDeliveryStatus(false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CurrentOrderScreen(),
                                    ),
                                  );
                                },
                                child: Text('Open'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
