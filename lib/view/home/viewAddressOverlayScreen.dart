// ignore_for_file: use_build_context_synchronously

import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/controller/services/userDataCRUDServices/userDataCRUDServices.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/user_account/addAddresssScreen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ViewAddressOverlayScreen extends StatefulWidget {
  const ViewAddressOverlayScreen({super.key});

  @override
  State<ViewAddressOverlayScreen> createState() =>
      _ViewAddressOverlayScreenState();
}

class _ViewAddressOverlayScreenState extends State<ViewAddressOverlayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 3.w,
          right: 3.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: const AddAddresssScreen(),
                    ),
                  );
                  context.read<ProfileProvider>().fetchUserAddress();
                },
                style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                child: Text(
                  'إضافة عنوان جديد',
                  style: AppTextStyles.body16.copyWith(color: white),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                if (provider.addresses.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد عناوين محفوظة',
                      style: AppTextStyles.body16,
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: provider.addresses.length,
                    itemBuilder: (context, index) {
                      final address = provider.addresses[index];
                      return InkWell(
                        onTap: () async {
                          await UserDataCRUDServices.setActiveAddress(
                            address,
                            context,
                          );
                          context.read<ProfileProvider>().fetchUserAddress();
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      address.addressTitle,
                                      style: AppTextStyles.heading20,
                                    ),
                                    CircleAvatar(
                                      radius: 1.h,
                                      backgroundColor: address.isActive
                                          ? success
                                          : transparent,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: [
                                    Text(
                                      address.roomNo,
                                      style: AppTextStyles.body14,
                                    ),
                                    SizedBox(width: 1.h),
                                    Text(
                                      ', ${address.apartment}',
                                      style: AppTextStyles.body14,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
