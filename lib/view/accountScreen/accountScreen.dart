import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/view/technicianRegistrationScreen/technicianRegistrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  TechnicianModel? technician;
  bool isLooding = true;

  @override
  void initState() {
    super.initState();
    loadTechnicianData();
  }

  Future<void> loadTechnicianData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    TechnicianModel? data = await ProfileServices.getTechnicianData(uid);
    setState(() {
      technician = data;
      isLooding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLooding) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: darkBlue)),
      );
    }
    if (technician == null) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Text('لا يوجد بيانات', style: AppTextStyles.body16),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianRegistrationScreen(),
                    ),
                  ).then((_) {
                    loadTechnicianData(); // refresh the data
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                ),
                child: Text(
                  'اضافة البيانات',
                  style: AppTextStyles.body16.copyWith(color: white),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'معلومات الفني',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
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
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الاسم',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.name ?? 'لم يتم العثور على اسم',
                    style: AppTextStyles.body14,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 3.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'رقم الجوال',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.mobileNumber ?? 'لم يتم العثور على رقم الجوال',
                    style: AppTextStyles.body14,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 3.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'التخصص',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.major ?? 'لم يتم العثور على تخصص',
                    style: AppTextStyles.body14,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 6.h),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianRegistrationScreen(),
                      ),
                    ).then((_) {
                      loadTechnicianData(); // refresh data
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                  ),
                  child: Text(
                    'تعديل البيانات',
                    style: AppTextStyles.body16.copyWith(color: white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
