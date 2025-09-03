import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/home/home.dart';
import 'package:baligny/view/specialOffersScreen/specialOffersScreen.dart';
import 'package:baligny/view/accountScreen/accountScreen.dart';
import 'package:baligny/view/basketScreen/basketScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarBaligny extends StatefulWidget {
  const BottomNavigationBarBaligny({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BottomNavigationBarBaligny> createState() =>
      _BottomNavigationBarBalignyState();
}

class _BottomNavigationBarBalignyState
    extends State<BottomNavigationBarBaligny> {
  late PersistentTabController controller;

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: widget.initialIndex);
    context.read<ProfileProvider>().fetchUserAddress();
    context.read<ProfileProvider>().fetchUserData();
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const SpecialOffersScreen(),
      const BasketScreen(),
      const AccountScreen(),
    ];
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
        icon: FaIcon(FontAwesomeIcons.tags),
        title: ("العروض"),
        textStyle: AppTextStyles.body16,
        activeColorPrimary: lightOrange,
        inactiveColorPrimary: grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.basketShopping),
        title: ("السلة"),
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
