import 'dart:async';

import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();
  int resendOTPCounter = 60;

  decreaseOTPCounter() async {
    // Handle the case when the counter reaches zero, enable resending OTP
    if (resendOTPCounter > 0) {
      setState(() {
        resendOTPCounter--;
      });
      await Future.delayed(const Duration(seconds: 1), () {
        decreaseOTPCounter();
      });
    } else {
      // Handle the case when the counter reaches zero, enable resending OTP
    }
  }

  @override
  void initState() {
    super.initState();
    // Start the countdown for the OTP resend counter after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    decreaseOTPCounter();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Stack(
          children: [
            Positioned(
              left: 10.w,
              bottom: 3.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: greyShade3,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(2.h),
                  elevation: 2,
                ),
                child: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  size: 3.h,
                  color: black,
                ),
              ),
            ),
            Positioned(
              right: 3.w,
              bottom: 3.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: greyShade3,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  elevation: 2,
                ),
                child: Row(
                  children: [
                    Text(
                      'التالي',
                      style: AppTextStyles.body16.copyWith(color: black),
                    ),
                    SizedBox(width: 3.w),
                    FaIcon(
                      FontAwesomeIcons.arrowRight,
                      size: 3.h,
                      color: black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
          children: [
            SizedBox(height: 3.h),

            Text(
              'أدخل رمز التحقق',
              style: AppTextStyles.heading22,
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'لقد أرسلنا رسالة نصية تحتوي على رمز التفعيل إلى هاتفك',
              style: AppTextStyles.body16.copyWith(color: grey),
              textAlign: TextAlign.right,
            ),

            SizedBox(height: 3.h),

            PinCodeTextField(
              appContext: context,
              length: 5,
              obscureText: false,
              animationType: AnimationType.fade,
              cursorColor: black,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 72,
                fieldWidth: 63,
                inactiveFillColor: greyShade3,
                selectedFillColor: white,
                activeFillColor: white,
                inactiveColor: greyShade3,
                selectedColor: black38,
              ),
              animationDuration: const Duration(milliseconds: 200),
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: otpController,
              onCompleted: (v) {},
              onChanged: (value) {},
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return false;
              },
            ),

            SizedBox(height: 3.h),

            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: greyShade3,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  resendOTPCounter > 0
                      ? 'إرسال الرمز مرة أخرى بعد $resendOTPCounter ثانية'
                      : 'إرسال الرمز مرة أخرى',
                  style: AppTextStyles.body14.copyWith(
                    color: resendOTPCounter > 0 ? grey : black,
                    decoration: resendOTPCounter > 0
                        ? TextDecoration.none
                        : TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
