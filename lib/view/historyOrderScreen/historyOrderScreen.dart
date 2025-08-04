import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baligny/constant/constant.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HistoryScreenScreen extends StatefulWidget {
  const HistoryScreenScreen({super.key});

  @override
  State<HistoryScreenScreen> createState() => _HistoryScreenScreenState();
}

class _HistoryScreenScreenState extends State<HistoryScreenScreen> {
  Widget _buildFilterButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: white),
          color: darkBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.body16.copyWith(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool today = true;
  bool month = false;
  bool year = false;
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

  // void checkTimestampIsToday(int timestamp) {
  //   DateTime now = DateTime.now();
  //   DateTime dateFromTimeStamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //   if (dateFromTimeStamp.year == now.year) {
  //     if (dateFromTimeStamp.month == now.month) {
  //       if (dateFromTimeStamp.day == now.day) {}
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            toolbarHeight: 80,
            backgroundColor: lightOrange,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            centerTitle: true,
            title: Text(
              'الطلبات السابقة',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (today)
                      _buildFilterButton('اليوم', () {
                        setState(() {
                          today = false;
                          month = true;
                          year = false;
                        });
                      }),
                    if (month)
                      _buildFilterButton('الشهر', () {
                        setState(() {
                          today = false;
                          month = false;
                          year = true;
                        });
                      }),
                    if (year)
                      _buildFilterButton('السنة', () {
                        setState(() {
                          today = true;
                          month = false;
                          year = false;
                        });
                      }),
                  ],
                ),

                SizedBox(height: 1.h),

                Expanded(
                  child: StreamBuilder(
                    stream: realTimeDatabaseRef
                        .child('OrderHistory')
                        .orderByChild('userUID')
                        .equalTo(auth.currentUser!.uid)
                        .onValue,
                    builder: (context, event) {
                      if (event.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      if (event.data == null) {
                        return Center(
                          child: Text(
                            'No Previous Orders',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }
                      if (event.data != null) {
                        Map<dynamic, dynamic> values =
                            event.data!.snapshot.value as Map<dynamic, dynamic>;

                        List<ServiceOrderModel> todayOrderDataList = [];
                        List<ServiceOrderModel> monthOrderDataList = [];
                        List<ServiceOrderModel> yearOrderDataList = [];
                        values.forEach((key, value) {
                          ServiceOrderModel foodData =
                              ServiceOrderModel.fromMap(
                                jsonDecode(jsonEncode(value))
                                    as Map<String, dynamic>,
                              );
                          DateTime now = DateTime.now();
                          DateTime dateFromTimeStamp =
                              DateTime.fromMillisecondsSinceEpoch(
                                foodData
                                    .orderDeliveredAt!
                                    .millisecondsSinceEpoch,
                              );
                          if (dateFromTimeStamp.year == now.year) {
                            yearOrderDataList.add(foodData);

                            if (dateFromTimeStamp.month == now.month) {
                              monthOrderDataList.add(foodData);
                              if (dateFromTimeStamp.day == now.day) {
                                todayOrderDataList.add(foodData);
                              }
                            }
                          }
                        });

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: today
                              ? todayOrderDataList.length
                              : month
                              ? monthOrderDataList.length
                              : yearOrderDataList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          itemBuilder: (context, index) {
                            ServiceOrderModel currentServiceData = today
                                ? todayOrderDataList[index]
                                : month
                                ? monthOrderDataList[index]
                                : yearOrderDataList[index];

                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 1.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.sp),
                                side: BorderSide(color: greyShade3),
                              ),
                              shadowColor: greyShade3,
                              color: white,
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        currentServiceData.servicedetail.name,
                                        style: AppTextStyles.body16.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (currentServiceData.serviceCharges !=
                                            null)
                                          Directionality(
                                            textDirection: ui.TextDirection.ltr,
                                            child: Text(
                                              '${currentServiceData.serviceCharges} SR',
                                              style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                    /* SizedBox(height: 0.5.h),
                                     Text(
                                      currentServiceData.servicedetail.detail,
                                      style: AppTextStyles.small12.copyWith(
                                        color: grey,
                                      ),
                                    ), */
                                    /* SizedBox(height: 3.h),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          /*  Row(
                                          children: [
                                            Text(
                                              '${(((int.parse(currentServiceData.foodDetails.actualPrice) - int.parse(currentServiceData.foodDetails.discountedPrice)) / int.parse(currentServiceData.foodDetails.actualPrice)) * 100).round().toString()} %',
                                              style: AppTextStyles.body14Bold,
                                            ),
                                            SizedBox(width: 2.w),
                                            FaIcon(
                                              FontAwesomeIcons.tag,
                                              color: success,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '₹${currentServiceData.foodDetails.actualPrice}',
                                              style: AppTextStyles.body14.copyWith(
                                                decoration: TextDecoration.lineThrough,
                                                color: grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${currentServiceData.foodDetails.discountedPrice}',
                                              style: AppTextStyles.body16Bold,
                                            ),
                                          ],
                                        ),*/
                                        ],
                                      ), */
                                    SizedBox(height: 1.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'الكمية: \t${currentServiceData.servicedetail.quantity}',
                                          style: AppTextStyles.body14,
                                        ),
                                        Text(
                                          DateFormat('d MMM, h:mm a').format(
                                            currentServiceData
                                                .orderDeliveredAt!,
                                          ),
                                          style: AppTextStyles.body14.copyWith(
                                            color: grey,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 1.h),
                                    /* RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Total: \t\t',
                                            style: AppTextStyles.body14,
                                          ),
                                          TextSpan(
                                            text:
                                                '${currentServiceData..servicedetail.quantity! * int.parse(currentServiceData.foodDetails.discountedPrice)}',
                                            style: AppTextStyles.body14Bold,
                                          ),
                                        ],
                                      ),
                                    ), */
                                    // SwipeButton(
                                    //   thumbPadding: EdgeInsets.all(1.w),
                                    //   thumb: Icon(Icons.chevron_right, color: white),
                                    //   inactiveThumbColor: black,
                                    //   activeThumbColor: black,
                                    //   inactiveTrackColor:
                                    //       foodData.requestedForDelivery == null
                                    //           ? greyShade3
                                    //           : Colors.green.shade200,
                                    //   activeTrackColor:
                                    //       foodData.requestedForDelivery == null
                                    //           ? greyShade3
                                    //           : Colors.green.shade200,
                                    //   elevationThumb: 2,
                                    //   elevationTrack: 2,
                                    //   onSwipe: () {
                                    //     context
                                    //         .read<DeliveryPartnerProvider>()
                                    //         .sendDeliveryRequestToNearbyDeliveryPartner(
                                    //             foodData);
                                    //     realTimeDatabaseRef
                                    //         .child(
                                    //             'Orders/${foodData.orderID}/requestedForDelivery')
                                    //         .set(true);
                                    //   },
                                    //   child: Text(
                                    //     'Request for Delivery',
                                    //     style: AppTextStyles.body14Bold,
                                    //   ),
                                    // ),
                                    //SizedBox(height: 2.h),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
            // FirebaseAnimatedList(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   padding: EdgeInsets.symmetric(vertical: 2.h),
            //   query: realTimeDatabaseRef
            //       .child('OrderHistory')
            //       .orderByChild('resturantUID')
            //       .equalTo(auth.currentUser!.uid),
            //   itemBuilder: (context, snapshot, animation, index) {
            //     ServiceOrderModel foodData = ServiceOrderModel.fromMap(
            //         jsonDecode(jsonEncode(snapshot.value))
            //             as Map<String, dynamic>);

            //   },
            // ),
          ),
        ),
      ),
    );
  }
}
