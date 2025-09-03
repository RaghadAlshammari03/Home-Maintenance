// filepath: lib/view/ordersScreen/currentOrderScreen.dart
import 'package:baligny_technician/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/orderServices/orderServices.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';

// Status helpers (from user's provided snippet)
const String STATUS_PREPARATION = 'SERVICE_UNDER_PREPERATION';
const String STATUS_ACCEPTED = 'SERVICE_ACCEPTED_BY_TECHNICIAN';
const String STATUS_ON_THE_WAY = 'TECHNICIAN_ON_THE_WAY';
const String STATUS_DELIVERED = 'SERVICE_DELIVERED';

String normalizeToCanonical(String raw) {
  final s = raw.trim();
  if (s == STATUS_PREPARATION) return STATUS_PREPARATION;
  if (s == STATUS_ACCEPTED) return STATUS_ACCEPTED;
  if (s == STATUS_ON_THE_WAY) return STATUS_ON_THE_WAY;
  if (s == STATUS_DELIVERED) return STATUS_DELIVERED;
  return s;
}

String statusToArabic(String raw) {
  final c = normalizeToCanonical(raw);
  switch (c) {
    case STATUS_PREPARATION:
      return 'قيد التحضير';
    case STATUS_ACCEPTED:
      return 'تم القبول';
    case STATUS_ON_THE_WAY:
      return 'في الطريق';
    case STATUS_DELIVERED:
      return 'مكتمل';
    default:
      return c.isEmpty ? 'غير معروف' : c;
  }
}

Color statusToColor(String raw) {
  final c = normalizeToCanonical(raw);
  switch (c) {
    case STATUS_PREPARATION:
      return Colors.orange.shade600;
    case STATUS_ACCEPTED:
      return Colors.blue.shade600;
    case STATUS_ON_THE_WAY:
      return Colors.indigo.shade600;
    case STATUS_DELIVERED:
      return Colors.green.shade800;
    default:
      return Colors.blueGrey.shade700;
  }
}

bool isTrackable(String raw) {
  final c = normalizeToCanonical(raw);
  return c == STATUS_ON_THE_WAY;
}

class CurrentOrderScreen extends StatelessWidget {
  const CurrentOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final techProv = context.watch<TechnicianProvider>();
    final ServiceOrderModel? order = techProv.orderData;

    // Helper: format DateTime human-friendly
    String formatDateTime(DateTime? dt) {
      if (dt == null) return '-';
      try {
        // Example: 18 Aug 2025, 02:30 PM
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {
        return dt.toString();
      }
    }

    // Helper: open phone dialer with the given number
    Future<void> _callPhone(String? number) async {
      if (number == null || number.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
        return;
      }
      final uri = Uri(scheme: 'tel', path: number.trim());
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open dialer')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error opening dialer')));
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Current Order',
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
          padding: EdgeInsets.all(3.w),
          child: order == null
              ? Center(
                  child: Text('No current order', style: AppTextStyles.body16),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order header card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                            horizontal: 4.w,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order',
                                      style: AppTextStyles.body14Bold,
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      order.orderID ?? '-',
                                      style: AppTextStyles.body14.copyWith(
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 1.h),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Chip(
                                          backgroundColor: statusToColor(
                                            order.orderStatus ?? '',
                                          ),
                                          label: Text(
                                            statusToArabic(
                                              order.orderStatus ?? '',
                                            ),
                                            style: AppTextStyles.body14
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                        if (isTrackable(
                                          order.orderStatus ?? '',
                                        ))
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              // placeholder: navigation to tracking page
                                            },
                                            icon: Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: statusToColor(
                                                order.orderStatus ?? '',
                                              ),
                                            ),
                                            label: Text(
                                              'Track',
                                              style: AppTextStyles.body14
                                                  .copyWith(
                                                    color: statusToColor(
                                                      order.orderStatus ?? '',
                                                    ),
                                                  ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: statusToColor(
                                                  order.orderStatus ?? '',
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 3.w),
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: greyShade3,
                                child: Icon(Icons.work, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Customer & Location card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                            horizontal: 4.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer', style: AppTextStyles.body16Bold),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Icon(Icons.person, color: lightOrange),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      // show mobileNumber
                                      order.userData?.mobileNumber ?? '-',
                                      style: AppTextStyles.body14,
                                    ),
                                  ),
                                  // phone icon in the Customer section
                                  IconButton(
                                    onPressed: () => _callPhone(
                                      order.userData?.mobileNumber,
                                    ),
                                    icon: Icon(Icons.phone, color: lightOrange),
                                    tooltip: 'Call customer',
                                  ),
                                ],
                              ),

                              SizedBox(height: 1.5.h),

                              if (order.userAddress != null) ...[
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: lightOrange),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Text(
                                        order.userAddress!.apartment,
                                        style: AppTextStyles.body14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                              ],

                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    order.orderPlacedAt != null
                                        ? formatDateTime(order.orderPlacedAt)
                                        : '-',
                                    style: AppTextStyles.body14.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Services
                      Text('Services', style: AppTextStyles.body16Bold),
                      SizedBox(height: 1.h),
                      Column(
                        children: order.servicesOrPrimary.map((svc) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: greyShade3,
                                child: Text(
                                  (svc.quantity ?? 1).toString(),
                                  style: AppTextStyles.body14,
                                ),
                              ),
                              title: Text(
                                svc.name ?? '-',
                                style: AppTextStyles.body14Bold,
                              ),
                              subtitle: svc.detail != null
                                  ? Text(
                                      svc.detail!,
                                      style: AppTextStyles.body14,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 2.h),

                      if (order.problemDescription != null &&
                          order.problemDescription!.isNotEmpty) ...[
                        Text('Problem', style: AppTextStyles.body16Bold),
                        SizedBox(height: 1.h),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Text(
                              order.problemDescription ?? '-',
                              style: AppTextStyles.body14,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],

                      if (order.attachedImages != null &&
                          order.attachedImages!.isNotEmpty) ...[
                        Text('Images', style: AppTextStyles.body16Bold),
                        SizedBox(height: 1.h),
                        SizedBox(
                          height: 26.w,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: order.attachedImages!.length,
                            separatorBuilder: (_, __) => SizedBox(width: 3.w),
                            itemBuilder: (ctx, i) {
                              final url = order.attachedImages![i];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      insetPadding: EdgeInsets.all(2.w),
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: greyShade3,
                                                height: 60.h,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 20.sp,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    width: 26.w,
                                    height: 26.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 26.w,
                                      height: 26.w,
                                      color: greyShade3,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],

                      // If order is still 'under preparation' (technician skipped earlier), show Accept control here
                      if (order.orderStatus ==
                          OrderServices.orderStatus(0)) ...[
                        SizedBox(height: 2.h),
                        SwipeButton(
                          thumbPadding: EdgeInsets.all(1.w),
                          thumb: Icon(Icons.chevron_right, color: white),
                          inactiveThumbColor: black,
                          activeThumbColor: black,
                          inactiveTrackColor: green200,
                          activeTrackColor: green200,
                          elevationThumb: 2,
                          elevationTrack: 2,
                          onSwipe: () async {
                            // mark order as accepted
                            await realTimeDatabaseRef
                                .child('Orders/${order.orderID}/orderStatus')
                                .set(OrderServices.orderStatus(1));

                            // set technician profile on order and attach activeDeliveryRequestID
                            await OrderServices.updateTechnicianProfileIntoServiceOrderModelAndAddActiveDeliveryRequest(
                              order.orderID!,
                              context,
                            );

                            // try to set provider locations and start tracking
                            try {
                              final pos =
                                  await LocationServices.getCurrentLocation(
                                    context: context,
                                  );
                              if (pos == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cannot access current location',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final technician = LatLng(
                                pos.latitude,
                                pos.longitude,
                              );
                              if (order.userAddress != null) {
                                final customer = LatLng(
                                  order.userAddress!.latitude,
                                  order.userAddress!.longitude,
                                );
                                context
                                    .read<TechnicianProvider>()
                                    .updateLatLngs(technician, customer);
                              }
                              final fresh =
                                  await OrderServices.fetchOrderDetails(
                                    order.orderID!,
                                  );
                              if (fresh != null) {
                                context
                                    .read<TechnicianProvider>()
                                    .updateOrderData(fresh);
                                try {
                                  context
                                      .read<OrderProvider>()
                                      .updateServiceOrderData(fresh);
                                } catch (_) {}
                                context
                                    .read<TechnicianProvider>()
                                    .updateInDeliveryStatus(true);
                                await context
                                    .read<TechnicianProvider>()
                                    .startLiveLocationTracking(context);
                              }
                            } catch (e) {
                              // ignore errors but keep UI responsive
                            }
                          },
                          child: Text('Accept', style: AppTextStyles.body16),
                        ),
                        SizedBox(height: 2.h),
                      ] else if (order.orderStatus ==
                          OrderServices.orderStatus(2)) ...[
                        // If technician is on the way, allow marking service done
                        SizedBox(height: 2.h),
                        SwipeButton(
                          thumbPadding: EdgeInsets.all(1.w),
                          thumb: Icon(Icons.check, color: white),
                          inactiveThumbColor: black,
                          activeThumbColor: black,
                          inactiveTrackColor: Colors.green.shade600,
                          activeTrackColor: Colors.green.shade600,
                          elevationThumb: 2,
                          elevationTrack: 2,
                          onSwipe: () async {
                            try {
                              // 1) mark order as done
                              await realTimeDatabaseRef
                                  .child('Orders/${order.orderID}/orderStatus')
                                  .set(OrderServices.orderStatus(3));

                              // 2) add to history
                              await OrderServices.addOrderDataToHistory(
                                order,
                                context,
                              );

                              // 3) remove the order from active Orders
                              OrderServices.removeOrder(order.orderID!);

                              // 4) clear technician activeDeliveryRequestID in DB
                              await realTimeDatabaseRef
                                  .child(
                                    'Technician/${auth.currentUser!.uid}/activeDeliveryRequestID',
                                  )
                                  .remove();

                              // 5) clear provider state so CurrentOrderScreen shows 'No current order'
                              try {
                                context
                                    .read<TechnicianProvider>()
                                    .clearRouteData();
                              } catch (_) {}
                              try {
                                context.read<OrderProvider>().emptyOrderData();
                              } catch (_) {}

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Service marked done and order cleared',
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error completing order'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Service Done',
                            style: AppTextStyles.body16,
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ] else ...[
                        SizedBox.shrink(),
                      ],

                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
