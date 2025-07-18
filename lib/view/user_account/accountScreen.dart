import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
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
    [FontAwesomeIcons.user, 'حسابي'],
    [FontAwesomeIcons.cartShopping, 'طلباتي'],
    [FontAwesomeIcons.locationDot, 'سجل العناوين'],
    [FontAwesomeIcons.creditCard, 'طرق الدفع'],
    [FontAwesomeIcons.bell, 'الاشعارات'],
    [FontAwesomeIcons.language, 'اللغة'],
    [FontAwesomeIcons.circleInfo, 'تواصل معنا'],
    [FontAwesomeIcons.rightFromBracket, 'تسجيل الخروج'],
  ];
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
                    'اسم المستخدم',
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
                  return ListTile(
                    leading: FaIcon(account[index][0], size: 3.h, color: black),
                    title: Text(account[index][1], style: AppTextStyles.body14),
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
