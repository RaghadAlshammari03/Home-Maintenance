// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/model/userAddressModel.dart';
import 'package:baligny/model/userModel.dart';
import 'package:baligny/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:baligny/widgets/toastService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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
      await firestore
          .collection('Address')
          .doc(data.addressID)
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
        final data = element.data();
        data['addressID'] = element.id;
        addresses.add(UserAddressModel.fromMap(data));
      });
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
    return addresses;
  }

  static setActiveAddress(UserAddressModel data, BuildContext context) async {
    List<UserAddressModel> addresses = context
        .read<ProfileProvider>()
        .addresses;

    for (var addressData in addresses) {
      if (addressData.addressID != data.addressID) {
        await firestore.collection('Address').doc(addressData.addressID).update(
          {'isActive': false},
        );
      }
    }
    await firestore.collection('Address').doc(data.addressID).update({
      'isActive': true,
    });
  }

  static setActiveStatusById(String addressID, bool isActive) async {
    await firestore.collection('Address').doc(addressID).update({'isActive': isActive});
  }

  static deleteAddress(String addressID) async {
    try {
      await firestore.collection('Address').doc(addressID).delete();
    } catch (e) {
      log('Error deleting address: $e');
      throw Exception(e);
    }
  }
}
