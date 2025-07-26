// ignore_for_file: use_build_context_synchronously

import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/controller/services/userDataCRUDServices/userDataCRUDServices.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/user_account/addAddresssScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'قائمة العناوين',
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

          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            children: [
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const AddAddresssScreen(),
                        type: PageTransitionType.leftToRight,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.plus, color: white),
                      SizedBox(width: 3.w),
                      Text(
                        'إضافة موقع',
                        style: AppTextStyles.body16.copyWith(color: white),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.addresses.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد عناوين محفوظة',
                        style: AppTextStyles.body16.copyWith(color: grey),
                      ),
                    );
                  } else {
                    List<UserAddressModel> addresses =
                        profileProvider.addresses;
                    return ListView.builder(
                      itemCount: addresses.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        UserAddressModel address = addresses[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 1.5.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.sp),
                            color: white,
                            boxShadow: [
                              BoxShadow(
                                color: grey,
                                spreadRadius: 0.5,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    address.addressTitle,
                                    style: AppTextStyles.heading20Bold,
                                  ),
                                  CircleAvatar(
                                    radius: 1.h,
                                    backgroundColor: address.isActive
                                        ? success
                                        : transparent,
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.8.h),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'رقم المنزل:\t\t',
                                      style: AppTextStyles.body16Bold,
                                    ),
                                    TextSpan(
                                      text: address.roomNo,
                                      style: AppTextStyles.body14,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'رقم الشقة ، الحي :\t\t',
                                      style: AppTextStyles.body16Bold,
                                    ),
                                    TextSpan(
                                      text: address.apartment,
                                      style: AppTextStyles.body14,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),

                              Builder(
                                builder: (context) {
                                  if (address.isActive) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) => AlertDialog(
                                                title: const Text(
                                                  'تأكيد الحذف',
                                                ),
                                                content: const Text(
                                                  'هذا العنوان مفعل حالياً، هل ترغب بحذفه؟ سيتم إلغاء تفعيله أولاً.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          dialogContext,
                                                          false,
                                                        ),
                                                    child: const Text('إلغاء'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          dialogContext,
                                                          true,
                                                        ),
                                                    child: const Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              // 1. Deactivate it first
                                              await UserDataCRUDServices.setActiveStatusById(
                                                address.addressID,
                                                false,
                                              );

                                              // 2. Delete it
                                              await UserDataCRUDServices.deleteAddress(
                                                address.addressID,
                                              );

                                              // 3. Refresh the list
                                              context
                                                  .read<ProfileProvider>()
                                                  .fetchUserAddress();
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 1.h,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.sp),
                                              color: greyShade1,
                                            ),
                                            child: Text(
                                              'حذف',
                                              style: AppTextStyles.body16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            await UserDataCRUDServices.setActiveAddress(
                                              address,
                                              context,
                                            );
                                            context
                                                .read<ProfileProvider>()
                                                .fetchUserAddress();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 1.h,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.sp),
                                              color: greyShade1,
                                            ),
                                            child: Text(
                                              'تفعيل كموقع افتراضي',
                                              style: AppTextStyles.body16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        InkWell(
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                  'تأكيد الحذف',
                                                ),
                                                content: const Text(
                                                  'هل أنت متأكد أنك تريد حذف هذا العنوان؟',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await UserDataCRUDServices.deleteAddress(
                                                address.addressID,
                                              );
                                              context
                                                  .read<ProfileProvider>()
                                                  .fetchUserAddress();
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                              vertical: 1.h,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.sp),
                                              color: greyShade1,
                                            ),
                                            child: Text(
                                              'حذف',
                                              style: AppTextStyles.body16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
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
      ),
    );
  }
}
