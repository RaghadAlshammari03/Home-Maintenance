import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceOrderServices {
  orderStatus(int status) {
    switch (status) {
      case 0:
        return 'SERVICE_UNDER_PREPERATION';
      case 1:
        return 'SERVICE_ACCEPTED_BY_TECHNICIAN';
      case 2:
        return 'TECHNICIAN_ON_THE_WAY';
      case 3:
        return 'SERVICE_DERLIVERED';
    }
  }

  // Upload the data to firebase
  static serviceOrderRequest(
    ServiceOrderModel serviceOrderModel,
    String cartOrderID,
    BuildContext context,
  ) async {
    realTimeDatabaseRef
        .child('Orders/${serviceOrderModel.orderID}')
        .set(serviceOrderModel.toMap())
        .then((value) async {
          log(serviceOrderModel.toMap().toString());
          PushNotificationServices.sendNotificationToTechnicianByMajor(
            serviceOrder: serviceOrderModel,
          );
          Navigator.pop(context);
          ToastService.sendScaffoldAlert(
            msg: 'تم إرسال الطلب بنجاح',
            toastStatus: 'SUCCESS',
            context: context,
          );
        })
        .onError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'حدثت مشكلة أثناء إرسال الطلب',
            toastStatus: 'ERROR',
            context: context,
          );
        });
  }

  // Add the service to cart
  static addServiceToCart(
    ServiceModel serviceData,
    BuildContext context,
  ) async {
    try {
      String serviceID = uuid.v1();
      await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .doc(serviceID)
          .set(serviceData.toMap())
          .whenComplete(() {
            ToastService.sendScaffoldAlert(
              msg: 'تم إضافة الخدمة في السلة بنجاح',
              toastStatus: 'SUCCESS',
              context: context,
            );
          });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // Fetch All cart's data
  static fetchCartData() async {
    List<ServiceModel> itemAddedToCart = [];
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .orderBy('addedToCartAt', descending: true)
          .get();
      snapshot.docs.forEach((element) {
        itemAddedToCart.add(ServiceModel.fromMap(element.data()));
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
    return itemAddedToCart;
  }


}
