// ignore_for_file: avoid_print

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/widgets/commonTextField.dart';
import 'package:baligny_technician/widgets/toastService.dart';
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
  String? selectedMajor;
  List<String> majorOptions = ['كهرباء', 'تكييف', 'سباكة'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              'تعديل معلومات الفني',
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
            SizedBox(height: 2.h),
            Text('التخصص', style: AppTextStyles.body16),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: selectedMajor,
              decoration: InputDecoration(
                filled: true,
                fillColor: greyShade3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: majorOptions.map((major) {
                return DropdownMenuItem(value: major, child: Text(major));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMajor = value;
                });
              },
              hint: Text('اختر التخصص'),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  setState(() {
                    registerButtonPressed = true;
                  });
                  TechnicianModel technicianData = TechnicianModel(
                    name: nameController.text.trim(),
                    mobileNumber: auth.currentUser!.phoneNumber,
                    technicianID: auth.currentUser!.uid,
                    major: selectedMajor,
                  );
                  await ProfileServices.registerTechnician(technicianData, context);
                  Navigator.pop(context);
                } catch (e) {
                  print('Error during technician registration: $e');
                  ToastService.sendScaffoldAlert(
                    msg: 'حدث خطأ أثناء التعديل',
                    toastStatus: 'ERROR',
                    context: context,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
              child: registerButtonPressed
                  ? CircularProgressIndicator(color: white)
                  : Text(
                      'تعديل',
                      style: AppTextStyles.body16.copyWith(color: white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
