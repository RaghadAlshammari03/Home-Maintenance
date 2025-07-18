import 'package:baligny/view/authScreens/otpScreen.dart';
import 'package:flutter/material.dart';
import 'view/authScreens/login_screen.dart';
import 'package:sizer/sizer.dart';
import 'view/bottomNavigation/bottomNavigationBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Baligny',
          theme: ThemeData(),
          //home: LoginScreen(),
          //home: OTPScreen(),
          home: BottomNavigationBarBaligny(),
        );
      },
    );
  }
}
