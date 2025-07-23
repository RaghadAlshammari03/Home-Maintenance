import 'package:baligny_technician/controller/provider/authProvider/mobileAuthProvider.dart';
import 'package:baligny_technician/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/firebase_options.dart';
import 'package:baligny_technician/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:baligny_technician/view/technicianRegistrationScreen/technicianRegistrationScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
    );
  runApp(const Baligny());
}

class Baligny extends StatelessWidget {
  const Baligny({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, _, __) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<MobileAuthProvider>(
              create: (_) => MobileAuthProvider(),
            ),
            ChangeNotifierProvider<ProfileProvider>(
              create: (_) => ProfileProvider(),
            ),
            ChangeNotifierProvider<TechnicianProvider>(
              create: (_) => TechnicianProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Baligny',
            theme: ThemeData(),
            //home: LoginScreen(),
            //home: OTPScreen(),
            //home: BottomNavigationBarBaligny(),
            home: const SignInLogicScreen(),
            //home: TechnicianRegistrationScreen(),
          ),
        );
      },
    );
  }
}
