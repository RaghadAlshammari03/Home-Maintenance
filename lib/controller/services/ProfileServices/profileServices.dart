// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/view/accountScreen/accountScreen.dart';
import 'package:baligny_technician/widgets/toastService.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ProfileServices {
  static registerTechnician(
    TechnicianModel technicianData,
    BuildContext context,
  ) {
    realTimeDatabaseRef
        .child('Technician/${auth.currentUser!.uid}')
        .set(technicianData.toMap())
        .then((value) {
          ToastService.sendScaffoldAlert(
            msg: 'تم التسجيل بنجاح',
            toastStatus: 'SUCCESS',
            context: context,
          );
        })
        .onError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'حصلت مشكلة، الرجاء المحاولة مرة أخرى',
            toastStatus: 'ERROR',
            context: context,
          );
        });
  }

  static Future<bool> checkRegistration() async {
    try {
      final snapshot = await realTimeDatabaseRef
          .child('Technician/${auth.currentUser!.uid}')
          .get();
      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static Future<TechnicianModel?> getTechnicianData(String uid) async {
    try {
      final ref = FirebaseDatabase.instance
          .ref()
          .child('Technician')
          .child(uid);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(
          snapshot.value as Map,
        );
        return TechnicianModel.fromMap(data); 
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching technician data from Realtime DB: $e');
      return null;
    }
  }


}
