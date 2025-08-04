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
  static fetchOrderDetails(String orderID) async {
    try {
      final snapshot = await realTimeDatabaseRef
          .child('Orders')
          .child(orderID)
          .get();
      ServiceOrderModel serviceData = ServiceOrderModel.fromMap(
        jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
      );
      return serviceData;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
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
