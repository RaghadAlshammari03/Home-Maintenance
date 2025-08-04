// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/authProvider/mobileAuthProvider.dart';
import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny_technician/view/authScreens/login_screen.dart';
import 'package:baligny_technician/view/authScreens/otpScreen.dart';
import 'package:baligny_technician/view/bottomNavigation/bottomNavigationBar.dart';
import 'package:baligny_technician/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:baligny_technician/view/technicianRegistrationScreen/technicianRegistrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MobileAuthServices {
  static checkAuthentication(BuildContext context) {
    User? user = auth.currentUser;

    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      return false;
    }
    checkUserRegistration(context: context);
  }

  static receiveOTP({
    required BuildContext context,
    required String mobileNumber,
  }) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        verificationCompleted: (PhoneAuthCredential credentials) {
          log(credentials.toString());
        },
        verificationFailed: (FirebaseAuthException exception) {
          log(exception.toString());
          throw Exception(exception);
        },
        codeSent: (String verificationID, int? resendToken) {
          context.read<MobileAuthProvider>().updateVerificationID(
            verificationID,
          );
          Navigator.push(
            context,
            PageTransition(
              child: const OTPScreen(),
              type: PageTransitionType.leftToRight,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {},
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static verifyOTP({required BuildContext context, required String otp}) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: context.read<MobileAuthProvider>().verificationID!,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
      Navigator.push(
        context,
        PageTransition(
          child: const SignInLogicScreen(),
          type: PageTransitionType.leftToRight,
        ),
      );
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  static checkUserRegistration({required BuildContext context}) async {
    try {
      bool userIsRegistered = await ProfileServices.checkRegistration();
      if (userIsRegistered) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: const BottomNavigationBarBaligny(),
            type: PageTransitionType.rightToLeft,
          ),
          (route) => false,
        );
      } else { 
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: const TechnicianRegistrationScreen(),
            type: PageTransitionType.rightToLeft,
          ),
          (route) => false,
        );
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
