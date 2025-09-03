// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:convert';

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
  static const String _unavailableSlotCollection = 'UnavailableSlots';

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

  // Helper: Check if user already has an active (not delivered) order in Realtime DB
  static Future<bool> userHasActiveOrder(String userId) async {
    try {
      final ordersSnap = await realTimeDatabaseRef.child('Orders').get();
      if (!ordersSnap.exists || ordersSnap.value == null) return false;
      final data = ordersSnap.value;
      if (data is Map) {
        for (final entry in data.entries) {
          if (entry.value is Map) {
            final map = Map<String, dynamic>.from(
              jsonDecode(jsonEncode(entry.value)),
            );
            final uid = map['userUID'];
            final status = map['orderStatus'];
            if (uid == userId && status != orderStatus(3)) {
              return true; // Found an active (not delivered) order
            }
          }
        }
      }
    } catch (e) {
      log('userHasActiveOrder check failed: $e');
    }
    return false;
  }

  // Add the service to cart
  static addServiceToCart(
    ServiceModel serviceData,
    BuildContext context,
  ) async {
    try {
      // Prevent adding if there's an active order (not delivered yet)
      final hasActive = await userHasActiveOrder(auth.currentUser!.uid);
      if (hasActive) {
        ToastService.sendScaffoldAlert(
          msg: 'لديك طلب جارٍ قيد التنفيذ',
          toastStatus: 'ERROR',
          context: context,
        );
        return;
      }

      // New logic: prevent mixing different service types in the cart
      final existingCartSnapshot = await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .get();
      if (existingCartSnapshot.docs.isNotEmpty) {
        bool hasDifferentType = existingCartSnapshot.docs.any((doc) {
          final data = doc.data();
          return data['type'] != null && data['type'] != serviceData.type;
        });
        if (hasDifferentType) {
          ToastService.sendScaffoldAlert(
            msg: 'لا يمكنك إضافة خدمة من نوع مختلف أثناء وجود نوع آخر في السلة',
            toastStatus: 'ERROR',
            context: context,
          );
          return; // Stop here, do not add
        }
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Cart')
          .doc(auth.currentUser!.uid)
          .collection('CartItem')
          .where('serviceID', isEqualTo: serviceData.serviceID)
          .get();

      if (snapshot.docs.isEmpty) {
        await firestore
            .collection('Cart')
            .doc(auth.currentUser!.uid)
            .collection('CartItem')
            .doc(serviceData.orderID)
            .set(serviceData.toMap())
            .then((_) async {
              // Refresh local provider so UI updates immediately after first add
              try {
                context.read<ItemOrderProvider>().fetchCartItems();
              } catch (_) {}
              ToastService.sendScaffoldAlert(
                msg: 'تم إضافة الخدمة في السلة بنجاح',
                toastStatus: 'SUCCESS',
                context: context,
              );
            });
      } else {
        int quantity = snapshot.docs[0]['quantity'];
        String orderID = snapshot.docs[0]['orderID'];
        log(quantity.toString());
        await firestore
            .collection('Cart')
            .doc(auth.currentUser!.uid)
            .collection('CartItem')
            .doc(orderID)
            .update({'quantity': quantity + serviceData.quantity!})
            .then((value) {
              context.read<ItemOrderProvider>().fetchCartItems();
              ToastService.sendScaffoldAlert(
                msg: 'تم إضافة الخدمة في السلة بنجاح',
                toastStatus: 'SUCCESS',
                context: context,
              );
            });
      }
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

  static Future<List<String>> getUnavailableSlots(String date) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection(_unavailableSlotCollection)
          .doc(date)
          .get();

      if (doc.exists && doc.data() != null) {
        return List<String>.from((doc.data() as Map<String, dynamic>)['slots']);
      }
    } catch (e) {
      print('Error getting unavailable slots: $e');
    }
    return [];
  }

  static Future<void> addUnavailableSlot(String date, String timeSlot) async {
    try {
      DocumentReference docRef = firestore
          .collection(_unavailableSlotCollection)
          .doc(date);
      DocumentSnapshot doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        List<String> existingSlots = List<String>.from(
          (doc.data() as Map<String, dynamic>)['slots'],
        );
        if (!existingSlots.contains(timeSlot)) {
          existingSlots.add(timeSlot);
          await docRef.update({'slots': existingSlots});
        }
      } else {
        await docRef.set({
          'slots': [timeSlot],
        });
      }
    } catch (e) {
      print('Error adding unavailable slot: $e');
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
