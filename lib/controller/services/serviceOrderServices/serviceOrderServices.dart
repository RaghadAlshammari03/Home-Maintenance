// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceOrderServices {
  static orderStatus(int status) {
    switch (status) {
      case 0:
        return 'SERVICE_UNDER_PREPERATION';
      case 1:
        return 'SERVICE_ACCEPTED_BY_TECHNICIAN';
      case 2:
        return 'TECHNICIAN_ON_THE_WAY';
      case 3:
        return 'SERVICE_DELIVERED';
    }
  }

  // Upload the data to firebase
  static serviceOrderRequest(
    ServiceOrderModel serviceOrderModel,
    String cartOrderID,
    BuildContext context,
  ) async {
    try {
      await realTimeDatabaseRef
          .child('Orders/${serviceOrderModel.orderID}')
          .set(serviceOrderModel.toMap());

      log(serviceOrderModel.toMap().toString());

      PushNotificationServices.sendNotificationToTechnicianByMajor(
        serviceOrderData: serviceOrderModel,
      );

      ToastService.sendScaffoldAlert(
        msg: 'تم إرسال الطلب بنجاح',
        toastStatus: 'SUCCESS',
        context: context,
      );
    } catch (e, stack) {
      log('Error in serviceOrderRequest: $e');
      log(stack.toString());

      ToastService.sendScaffoldAlert(
        msg: 'حدثت مشكلة أثناء إرسال الطلب',
        toastStatus: 'ERROR',
        context: context,
      );
    }
  }

  // Add the service to cart
  static addServiceToCart(
    ServiceModel serviceData,
    BuildContext context,
  ) async {
    try {
      await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .doc(serviceData.orderID)
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

  // Update the service quantity on the cart
  static updateQuantity(
    String cartItemID,
    int currentQuantity,
    BuildContext context,
    bool isAdded,
  ) async {
    try {
      if (currentQuantity == 1 && !isAdded) {
        await firestore
            .collection('Cart')
            .doc(auth.currentUser!.uid)
            .collection('CartItem')
            .doc(cartItemID)
            .delete()
            .then((value) {
              context.read<ItemOrderProvider>().fetchCartItems();
            });
        return;
      }
      await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .doc(cartItemID)
          .update({
            'quantity': isAdded ? currentQuantity + 1 : currentQuantity - 1,
          })
          .then((value) {
            context.read<ItemOrderProvider>().fetchCartItems();
          });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static clearCartItems() async {
    try {
      final snapshot = await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      log('Cart Cleared all items');
    } catch (e) {
      log('Error clearing cart: $e');
      rethrow;
    }
  }
}
