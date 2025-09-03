import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:baligny_technician/view/ordersScreen/historyScreen.dart';
import 'package:baligny_technician/view/technicianRegistrationScreen/technicianRegistrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:baligny_technician/view/ordersScreen/ordersScreen.dart';
import 'package:baligny_technician/view/authScreens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny_technician/controller/provider/profileProvider/profileProvider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  TechnicianModel? technician;
  bool isLooding = true;

  @override
  void initState() {
    super.initState();
    loadTechnicianData();
  }

  Future<void> loadTechnicianData() async {
    TechnicianModel? data = await ProfileServices.getTechnicianProfileData();
    setState(() {
      technician = data;
      isLooding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLooding) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: darkBlue)),
      );
    }
    if (technician == null) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Text('No data available', style: AppTextStyles.body16),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianRegistrationScreen(),
                    ),
                  ).then((_) {
                    loadTechnicianData(); // refresh the data
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                ),
                child: Text(
                  'Add data',
                  style: AppTextStyles.body16.copyWith(color: white),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Account',
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
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Name',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.name ?? 'No name found',
                    style: AppTextStyles.body14,
                  ),
                ),
                SizedBox(height: 3.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Mobile number',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.mobileNumber ?? 'No mobile number found',
                    style: AppTextStyles.body14,
                  ),
                ),
                SizedBox(height: 3.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Specialty',
                    style: AppTextStyles.body16.copyWith(color: darkBlue),
                  ),
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    technician!.major ?? 'No specialty found',
                    style: AppTextStyles.body14,
                  ),
                ),
                SizedBox(height: 6.h),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianRegistrationScreen(
                          technician: technician,
                        ),
                      ),
                    ).then((_) {
                      loadTechnicianData(); // refresh data
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                  ),
                  child: Text(
                    'Modify data',
                    style: AppTextStyles.body16.copyWith(color: white),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                  ),
                  child: Text(
                    'Order History',
                    style: AppTextStyles.body16.copyWith(color: white),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Sign out', style: AppTextStyles.body16Bold),
                        content: Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text('Confirm'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    try {
                      // Stop live location tracking and clear route/order state to avoid DB listeners after sign-out
                      try {
                        final techProvider = context.read<TechnicianProvider>();
                        techProvider.stopLiveLocationTracking();
                        techProvider.clearRouteData();
                      } catch (_) {}

                      try {
                        context.read<OrderProvider>().emptyOrderData();
                      } catch (_) {}

                      try {
                        context.read<ProfileProvider>().clearProfile();
                      } catch (_) {}

                      // Remove stored FCM token from RTDB
                      try {
                        final uid = auth.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseDatabase.instance
                              .ref('Technician/$uid/cloudMessagingToken')
                              .remove()
                              .catchError((_) {});
                        }
                      } catch (_) {}

                      // Unsubscribe from topic
                      try {
                        await FirebaseMessaging.instance.unsubscribeFromTopic('TECHNICIAN');
                      } catch (_) {}

                      // Perform sign out
                      await FirebaseAuth.instance.signOut();

                      // Navigate to login and clear stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                  ),
                  child: Text(
                    'Sign out',
                    style: AppTextStyles.body16.copyWith(color: white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
