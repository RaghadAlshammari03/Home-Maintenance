import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/user_account/logOutScreen.dart';
import 'package:baligny/view/user_account/ContactUsScreen.dart';
import 'package:baligny/view/user_account/addressScreen.dart';
import 'package:baligny/view/user_account/paymentMethodsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List account = [
    [FontAwesomeIcons.locationDot, 'سجل العناوين'],
    [FontAwesomeIcons.creditCard, 'طرق الدفع'],
    [FontAwesomeIcons.circleInfo, 'تواصل معنا'],
    [FontAwesomeIcons.rightFromBracket, 'تسجيل الخروج'],
  ];

  final String userNumber =
      FirebaseAuth.instance.currentUser?.phoneNumber ?? 'الرقم غير متوفر';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 3.h,
                    backgroundColor: lightOrange,
                    child: CircleAvatar(
                      radius: 3.h - 2,
                      backgroundColor: white,
                      child: FaIcon(
                        FontAwesomeIcons.user,
                        size: 4.h,
                        color: lightOrange,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    userNumber,
                    style: AppTextStyles.body16Bold.copyWith(
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 80,
            toolbarOpacity: 0.8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            elevation: 0.00,
            backgroundColor: lightOrange,
            foregroundColor: Colors.white,
          ),

          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            children: [
              ListView.builder(
                itemCount: account.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 2.h,
                          horizontal: 4.w,
                        ),
                        backgroundColor: white,
                        foregroundColor: black,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddressScreen(),
                              ),
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentMethods(),
                              ),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUs(),
                              ),
                            );
                            break;
                          case 3:
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد تسجيل الخروج'),
                                content: const Text(
                                  'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      LogOut(context);
                                    },
                                    child: const Text('خروج'),
                                  ),
                                ],
                              ),
                            );
                            break;
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FaIcon(
                            account[index][0],
                            size: 2.8.h,
                            color: lightOrange,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            account[index][1],
                            style: AppTextStyles.body16.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
