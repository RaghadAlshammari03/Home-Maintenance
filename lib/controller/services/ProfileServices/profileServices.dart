// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:baligny_technician/widgets/toastService.dart';
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
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              child: const SignInLogicScreen(),
            ),
            (route) => false,
          );
        })
        .onError((error, stackTrace) {
          ToastService.sendScaffoldAlert(
            msg: 'حصلت مشكلة، الرجاء المحاولة مرة أخرى',
            toastStatus: 'ERROR',
            context: context,
          );
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              child: const SignInLogicScreen(),
            ),
            (route) => false,
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
}
