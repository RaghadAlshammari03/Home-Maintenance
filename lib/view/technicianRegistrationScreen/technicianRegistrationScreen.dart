import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/widgets/commonTextField.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TechnicianRegistrationScreen extends StatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  State<TechnicianRegistrationScreen> createState() =>
      _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState
    extends State<TechnicianRegistrationScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  bool registerButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          children: [
            SizedBox(height: 2.h),
            CommonTextfield(
              controller: nameController,
              title: 'الاسم',
              hintText: 'الاسم',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 2.h),
            CommonTextfield(
              controller: mobileNumberController,
              title: 'رقم الجوال',
              hintText: 'رقم الجوال',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  registerButtonPressed = true;
                });
                TechnicianModel technicianData = TechnicianModel(
                  name: nameController.text.trim(),
                  mobileNumber: auth.currentUser!.phoneNumber,
                  technicianID: auth.currentUser!.uid,
                );
                ProfileServices.registerTechnician(technicianData, context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
              child: registerButtonPressed
                  ? CircularProgressIndicator(color: white)
                  : Text(
                      'تسجيل',
                      style: AppTextStyles.body16.copyWith(color: white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
