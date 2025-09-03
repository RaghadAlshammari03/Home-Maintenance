import 'package:baligny/controller/provider/authProvider/mobileAuthProvider.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/controller/provider/technician_tracking_provider.dart';
import 'package:baligny/controller/provider/review_provider.dart';
import 'package:baligny/firebase_options.dart';
import 'package:baligny/view/signInLogicScreen/signInLogicScreen.dart';
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
            ChangeNotifierProvider<ReviewsProvider>(
              create: (_) => ReviewsProvider(),
            ),
            ChangeNotifierProvider<ItemOrderProvider>(
              create: (_) => ItemOrderProvider(),
            ),
            ChangeNotifierProvider<OrderProvider>(
              create: (_) => OrderProvider(),
            ),
            ChangeNotifierProvider<TechnicianProvider>(
              create: (_) => TechnicianProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Baligny',
            theme: ThemeData(),
            home: const SignInLogicScreen(),
          ),
        );
      },
    );
  }
}
