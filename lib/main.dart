import 'package:baligny/controller/provider/authProvider/mobileAuthProvider.dart';
import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/firebase_options.dart';
import 'package:baligny/view/signInLogicScreen/signInLogicScreen.dart';
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
            ChangeNotifierProvider(
              create: (_) => ProfileProvider()
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
