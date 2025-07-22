// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/model/userAddressModel.dart';
import 'package:baligny/model/userModel.dart';
import 'package:baligny/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class UserDataCRUDServices {
  static registerUser(UserModel data, BuildContext context) async {
    try {
      await firestore
          .collection('User')
          .doc(auth.currentUser!.uid)
          .set(data.toMap())
          .whenComplete(() {
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                child: const SignInLogicScreen(),
                type: PageTransitionType.rightToLeft,
              ),
              (route) => false,
            );
          });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static addAddress(UserAddressModel data, BuildContext context) async {
    try {
      String docID = uuid.v1().toString();
      await firestore
          .collection('Address')
          .doc(docID)
          .set(data.toMap())
          .whenComplete(() {
            ToastService.sendScaffoldAlert(
              msg: 'تم إضافة الموقع بنجاح',
              toastStatus: 'SUCCESS',
              context: context,
            );
          });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static fetchUserData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('User')
          .doc(auth.currentUser!.uid)
          .get();

      UserModel data = UserModel.fromMap(snapshot.data()!);
      return data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static fetchAddresses() async {
    List<UserAddressModel> addresses = [];
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('Address')
          .where('userID', isEqualTo: auth.currentUser!.uid)
          .get();
      snapshot.docs.forEach((element) {
        addresses.add(UserAddressModel.fromMap(element.data()));
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
    return addresses;
  }
}
