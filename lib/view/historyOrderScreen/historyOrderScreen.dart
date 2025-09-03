import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baligny/constant/constant.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

  // segmented filter control for اليوم / الشهر / السنة
  Widget _segmentedButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: selected ? darkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: selected ? white : darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedFilters() {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segmentedButton('اليوم', today, () {
            setState(() {
              today = true;
              month = false;
              year = false;
            });
          }),
          SizedBox(width: 6),
          _segmentedButton('الشهر', month, () {
            setState(() {
              today = false;
              month = true;
              year = false;
            });
          }),
          SizedBox(width: 6),
          _segmentedButton('السنة', year, () {
            setState(() {
              today = false;
              month = false;
              year = true;
            });
          }),
        ],
      ),
    );
  }

  bool today = true;
  bool month = false;
  bool year = false;
  int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

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
                    // modern segmented control
                    _buildSegmentedFilters(),
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
                      // Handle errors
                      if (event.hasError) {
                        return Center(
                          child: Text(
                            'حدث خطأ في تحميل البيانات',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }
                      // If no event yet or snapshot value is null -> no orders
                      if (event.data == null ||
                          event.data!.snapshot.value == null) {
                        return Center(
                          child: Text(
                            'لا توجد طلبات سابقة',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }

                      final raw = event.data!.snapshot.value;
                      Map<dynamic, dynamic> values = {};
                      if (raw is Map) {
                        values = raw;
                      } else if (raw is List) {
                        // Convert list (with possible null gaps) to map keyed by index
                        values = {
                          for (int i = 0; i < raw.length; i++)
                            if (raw[i] != null) i.toString(): raw[i],
                        };
                      } else {
                        // Unexpected type
                        return Center(
                          child: Text(
                            'لا توجد طلبات سابقة',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }

                      if (values.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد طلبات سابقة',
                            style: AppTextStyles.body16,
                          ),
                        );
                      }

                      List<ServiceOrderModel> todayOrderDataList = [];
                      List<ServiceOrderModel> monthOrderDataList = [];
                      List<ServiceOrderModel> yearOrderDataList = [];

                      values.forEach((key, value) {
                        try {
                          ServiceOrderModel foodData =
                              ServiceOrderModel.fromMap(
                                jsonDecode(jsonEncode(value))
                                    as Map<String, dynamic>,
                              );
                          if (foodData.orderDeliveredAt == null)
                            return; // skip if null
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
                        } catch (_) {
                          // Ignore malformed entry
                        }
                      });

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            color: white,
                            shadowColor: greyShade3.withOpacity(.25),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 2.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: Order ID and date/time
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'رقم الطلب: ${currentServiceData.orderID?.substring(0, 8) ?? ''}',
                                          style: AppTextStyles.body16.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        currentServiceData.orderDeliveredAt !=
                                                null
                                            ? DateFormat(
                                                'd MMM, h:mm a',
                                              ).format(
                                                currentServiceData
                                                    .orderDeliveredAt!,
                                              )
                                            : (currentServiceData
                                                          .orderPlacedAt !=
                                                      null
                                                  ? DateFormat(
                                                      'd MMM, h:mm a',
                                                    ).format(
                                                      currentServiceData
                                                          .orderPlacedAt!,
                                                    )
                                                  : ''),
                                        style: AppTextStyles.body14.copyWith(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 0.8.h),

                                  // Services count and charges
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'الخدمات: ${currentServiceData.allServices().length}',
                                        style: AppTextStyles.body14,
                                      ),
                                      Text(
                                        currentServiceData.serviceCharges !=
                                                null
                                            ? '${currentServiceData.serviceCharges} SR'
                                            : '-',
                                        style: AppTextStyles.body14.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 0.8.h),

                                  // Short description
                                  Text(
                                    currentServiceData.problemDescription !=
                                                null &&
                                            currentServiceData
                                                .problemDescription!
                                                .trim()
                                                .isNotEmpty
                                        ? (currentServiceData
                                                      .problemDescription!
                                                      .length >
                                                  120
                                              ? '${currentServiceData.problemDescription!.substring(0, 120)}...'
                                              : currentServiceData
                                                    .problemDescription!)
                                        : 'لا يوجد وصف',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body14.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),

                                  SizedBox(height: 1.h),

                                  // Action button
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: darkBlue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                HistoryOrderDetailsScreen(
                                                  order: currentServiceData,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text('عرض التفاصيل'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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

class HistoryOrderDetailsScreen extends StatefulWidget {
  final ServiceOrderModel order;
  const HistoryOrderDetailsScreen({Key? key, required this.order})
    : super(key: key);

  @override
  State<HistoryOrderDetailsScreen> createState() =>
      _HistoryOrderDetailsScreenState();
}

class _HistoryOrderDetailsScreenState extends State<HistoryOrderDetailsScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final images = order.attachedImages ?? [];
    final services = order.servicesOrPrimary;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تفاصيل الطلب',
            style: AppTextStyles.heading20Bold.copyWith(color: white),
          ),
          backgroundColor: lightOrange,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Images PageView with indicators
              Container(
                height: 30.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    itemCount: images.isNotEmpty ? images.length : 1,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                    itemBuilder: (context, idx) {
                      if (images.isEmpty) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      }
                      final url = images[idx];
                      return GestureDetector(
                        onTap: () {},
                        child: Image.network(
                          url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Indicator moved under the image
              SizedBox(height: 1.h),
              if (images.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _pageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? darkBlue
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                    );
                  }),
                ),
              SizedBox(height: 1.h),

              SizedBox(height: 2.h),

              // Header card: Order id + status + date
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب #${order.orderID ?? ''}',
                              style: AppTextStyles.body18.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              order.orderStatus ?? '',
                              style: AppTextStyles.body14.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        order.orderDeliveredAt != null
                            ? DateFormat(
                                'd MMM, h:mm a',
                              ).format(order.orderDeliveredAt!)
                            : (order.orderPlacedAt != null
                                  ? DateFormat(
                                      'd MMM, h:mm a',
                                    ).format(order.orderPlacedAt!)
                                  : ''),
                        style: AppTextStyles.body14.copyWith(
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 1.5.h),

              // Problem description
              Text('وصف المشكلة', style: AppTextStyles.body16Bold),
              SizedBox(height: 0.8.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Text(
                    order.problemDescription ?? 'لا يوجد وصف',
                    style: AppTextStyles.body14.copyWith(color: Colors.black87),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Services list with quantity badges
              Text('الخدمات', style: AppTextStyles.body16Bold),
              SizedBox(height: 0.8.h),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Column(
                    children: services.map((s) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: lightOrange.withOpacity(0.12),
                          child: Text(
                            'x${s.quantity ?? 1}',
                            style: AppTextStyles.body14.copyWith(
                              color: darkBlue,
                            ),
                          ),
                        ),
                        title: Text(s.name ?? '', style: AppTextStyles.body16),
                        subtitle:
                            s.detail != null && s.detail!.trim().isNotEmpty
                            ? Text(
                                s.detail!,
                                style: AppTextStyles.body14.copyWith(
                                  color: Colors.black54,
                                ),
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Charges / address / timestamps
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.serviceCharges != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('سعر الخدمة', style: AppTextStyles.body14),
                            Text(
                              '${order.serviceCharges} SR',
                              style: AppTextStyles.body16Bold,
                            ),
                          ],
                        ),
                      if (order.serviceCharges != null) SizedBox(height: 1.h),

                      if (order.userAddress != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('العنوان', style: AppTextStyles.body16Bold),
                            SizedBox(height: 0.6.h),
                            Text(
                              order.userAddress?.addressTitle ?? '-',
                              style: AppTextStyles.body14,
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              '${order.userAddress?.apartment ?? ''} - ${order.userAddress?.roomNo ?? ''}',
                              style: AppTextStyles.body14.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('تاريخ الطلب', style: AppTextStyles.body14),
                          Text(
                            order.orderPlacedAt != null
                                ? DateFormat(
                                    'd MMM, h:mm a',
                                  ).format(order.orderPlacedAt!)
                                : '-',
                            style: AppTextStyles.body14,
                          ),
                        ],
                      ),
                      SizedBox(height: 0.6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('تاريخ التسليم', style: AppTextStyles.body14),
                          Text(
                            order.orderDeliveredAt != null
                                ? DateFormat(
                                    'd MMM, h:mm a',
                                  ).format(order.orderDeliveredAt!)
                                : '-',
                            style: AppTextStyles.body14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 3.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: EdgeInsets.symmetric(vertical: 1.4.h),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'رجوع',
                  style: AppTextStyles.body16.copyWith(color: white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
