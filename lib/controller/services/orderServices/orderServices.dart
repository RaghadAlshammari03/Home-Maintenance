import 'dart:convert';
import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/widgets/toastService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderServices {
  static Future<ServiceOrderModel?> fetchOrderDetails(String orderID) async {
    try {
      log('fetchOrderDetails: start for orderID=$orderID');
      final ref = realTimeDatabaseRef.child('Orders').child(orderID);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        log('fetchOrderDetails: Order $orderID not found (null snapshot)');
        return null;
      }

      final raw = snapshot.value;
      // Log raw snapshot safely (try JSON encode, fallback to toString)
      try {
        log(
          'fetchOrderDetails: raw snapshot for $orderID -> ${jsonEncode(raw)}',
        );
      } catch (e) {
        log(
          'fetchOrderDetails: raw snapshot for $orderID (toString) -> ${raw.toString()}',
        );
      }

      if (raw is! Map) {
        log(
          'fetchOrderDetails: Unexpected data type for order $orderID -> ${raw.runtimeType}',
        );
        return null;
      }

      ServiceOrderModel serviceData = ServiceOrderModel.fromMap(
        Map<String, dynamic>.from(raw as Map),
      );
      log(
        'fetchOrderDetails: parsed ServiceOrderModel orderID=${serviceData.orderID} status=${serviceData.orderStatus}',
      );
      return serviceData;
    } catch (e, st) {
      log('fetchOrderDetails error for $orderID: $e\n$st');
      return null; // swallow & return null instead of throwing to avoid crashes
    }
  }

  static updateTechnicianProfileIntoServiceOrderModelAndAddActiveDeliveryRequest(
    String orderID,
    BuildContext context,
  ) async {
    TechnicianModel technicianData = context
        .read<ProfileProvider>()
        .technicianProfile!;

    realTimeDatabaseRef
        .child('Orders/$orderID/technicianData')
        .set(technicianData.toMap());

    realTimeDatabaseRef
        .child('Technician/${auth.currentUser!.uid}/activeDeliveryRequestID')
        .set(orderID);
  }

  static orderStatus(int status) {
    switch (status) {
      case 0:
        return 'SERVICE_UNDER_PREPERATION';
      case 1:
        return 'SERVICE_ACCEPTED_BY_TECHNICIAN';
      case 2:
        return 'TECHNICIAN_ON_THE_WAY';
      case 3:
        return 'SERVICE_DONE';
    }
  }

  static addOrderDataToHistory(
    ServiceOrderModel serviceOrderData,
    BuildContext context,
  ) async {
    ServiceOrderModel serviceData = ServiceOrderModel(
      servicedetail: serviceOrderData.servicedetail,
      services: serviceOrderData.services,
      userAddress: serviceOrderData.userAddress,
      userData: serviceOrderData.userData,
      technicianData: serviceOrderData.technicianData,
      technicianUID: auth.currentUser!.uid,
      serviceCharges: serviceOrderData.serviceCharges,
      orderID: serviceOrderData.orderID,
      orderStatus: serviceOrderData.orderStatus,
      userUID: serviceOrderData.userUID,
      orderPlacedAt: serviceOrderData.orderPlacedAt,
      orderDeliveredAt: DateTime.now(),
      addedToCartAt: serviceOrderData.addedToCartAt,
      problemDescription: serviceOrderData.problemDescription,
      attachedImages: serviceOrderData.attachedImages,
    );

    String orderHistoryID = uuid.v1();

    await realTimeDatabaseRef
        .child('OrderHistory/$orderHistoryID')
        .set(serviceData.toMap())
        .then((value) {
          ToastService.sendScaffoldAlert(
            msg: 'Order added to history',
            toastStatus: 'SUCCESS',
            context: context,
          );
        })
        .onError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'Error adding order record',
            toastStatus: 'ERROR',
            context: context,
          );
        });
  }

  static removeOrder(String orderID) {
    realTimeDatabaseRef.child('Orders/$orderID').remove();
  }
}
