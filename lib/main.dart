// ignore_for_file: avoid_print

import 'package:baligny_technician/controller/provider/authProvider/mobileAuthProvider.dart';
import 'package:baligny_technician/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny_technician/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny_technician/firebase_options.dart';
import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/view/signInLogicScreen/signInLogicScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const Baligny());
}

class Baligny extends StatefulWidget {
  const Baligny({super.key});

  @override
  State<Baligny> createState() => _BalignyState();
}

class _BalignyState extends State<Baligny> {
  @override
  void initState() {
    super.initState();
    // Initialize FCM after first frame so context & providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PushNotificationServices.initializeFCM(context);
      }
    });
  }

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
            ChangeNotifierProvider<OrderProvider>(
              create: (_) => OrderProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            title: 'Baligny',
            theme: ThemeData(),
            // Enforce LTR across the whole app
            builder: (context, child) => Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            ),
            home: const SignInLogicScreen(),
          ),
        );
      },
    );
  }
}
