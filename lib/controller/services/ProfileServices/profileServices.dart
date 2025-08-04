// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/widgets/toastService.dart';
import 'package:flutter/material.dart';

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

  static Future<TechnicianModel?> getTechnicianProfileData() async {
    try {
      final ref = realTimeDatabaseRef.child('Technician/${auth.currentUser!.uid}');
      final snapshot = await ref.get();
      log(snapshot.value.toString());

      if (snapshot.exists) {
        TechnicianModel technicianData = TechnicianModel.fromMap(
          jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>,
        );
        log(technicianData.toMap().toString());
        return technicianData;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching technician data from Realtime DB: $e');
      return null;
    }
  }
}
