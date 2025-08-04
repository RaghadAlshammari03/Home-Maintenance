import 'package:baligny_technician/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/pushNotificationServices/pushNotificationServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/view/accountScreen/accountScreen.dart';
import 'package:baligny_technician/view/homeScreen/homeScreen.dart';
import 'package:baligny_technician/view/ordersScreen/historyScreen.dart';
import 'package:baligny_technician/view/ordersScreen/ordersScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarBaligny extends StatefulWidget {
  const BottomNavigationBarBaligny({super.key});

  @override
  State<BottomNavigationBarBaligny> createState() =>
      _BottomNavigationBarBalignyState();
}

class _BottomNavigationBarBalignyState
    extends State<BottomNavigationBarBaligny> {
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PushNotificationServices.initializeFCM(context);
      context.read<ProfileProvider>().updateTechnicianProfile();
      // context.read<TechnicianProvider>().createIcons(context);
    });
  }

  List<Widget> _buildScreens() {
    return [const HomeScreen(), const HistoryScreen(), const AccountScreen()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.house),
        title: ("الرئيسية"),
        textStyle: AppTextStyles.body16,
        activeColorPrimary: lightOrange,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.list),
        title: ("الطلبات"),
        textStyle: AppTextStyles.body16,
        activeColorPrimary: lightOrange,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.user),
        title: ("المزيد"),
        textStyle: AppTextStyles.body16,
        activeColorPrimary: lightOrange,
        inactiveColorPrimary: grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      backgroundColor: white,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style6,
    );
  }
}
