import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Country? selectedCountry;
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = Country.parse('SA'); // Saudi Arabia by default
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
          children: [
            SizedBox(height: 3.h),

            Text(
              'تسجيل الدخول',
              style: AppTextStyles.heading22,
              textAlign: TextAlign.right,
            ),

            SizedBox(height: 0.5.h),

            Text(
              'يرجى تأكيد رمز بلدك وإدخال رقم هاتفك',
              style: AppTextStyles.body16.copyWith(color: grey),
              textAlign: TextAlign.right,
            ),

            SizedBox(height: 2.5.h),

            Divider(color: grey),
            Row(
              children: [
                Text(
                  selectedCountry!.flagEmoji,
                  style: TextStyle(fontSize: 35),
                ),
                SizedBox(width: 3.w),
                Text(selectedCountry!.name, style: AppTextStyles.body16),
              ],
            ),

            Divider(color: grey),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      onSelect: (Country country) {
                        setState(() {
                          selectedCountry = country;
                        });
                        print(
                          'Selected country: ${country.flagEmoji} ${country.displayName}',
                        );
                      },
                      showPhoneCode: true,
                      favorite: ['SA'],
                    );
                  },
                  child: Container(
                    height: 5.5.h,
                    width: 20.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      border: Border.all(color: grey),
                      // color: greyShade3,
                    ),
                    child: Text(
                      '+${selectedCountry!.phoneCode}',
                      style: AppTextStyles.body14,
                    ),
                  ),
                ),

                SizedBox(
                  width: 68.w,
                  child: TextField(
                    controller: phoneController,
                    cursorColor: black,
                    style: AppTextStyles.textFieldTextStyle,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 3.w,
                      ),
                      hintText: '0 000 000 000',
                      // filled: true,
                      // fillColor: greyShade3,
                      hintStyle: AppTextStyles.textFieldHintTextStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: black),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 0.4.h),
            Divider(color: grey),
            SizedBox(height: 4.h),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                minimumSize: Size(90.w, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'المتابعة',
                      style: AppTextStyles.body16.copyWith(color: white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
