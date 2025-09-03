// ignore_for_file: use_build_context_synchronously

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/provider/itemOrderProvider/itemOrderProvider.dart';
import 'package:baligny/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/trackOrderScreen/track_technician_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:baligny/utils/order_status_utils.dart';
import 'package:baligny/view/submitProblem/submit_problem_screen.dart';
import 'package:baligny/widgets/service_card_widget.dart';
import 'package:baligny/widgets/full_width_floating_button.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreensState();
}

class _BasketScreensState extends State<BasketScreen> {
  bool hasActiveOrder =
      false; // tracks whether user currently has an active order
  StreamSubscription<DatabaseEvent>? _ordersSub;
  int _debugCartCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ItemOrderProvider>().fetchCartItems();
      context.read<OrderProvider>().fetchCurrentOrder(auth.currentUser!.uid);
    });

    // Attach a single listener to maintain active-order state and avoid calling setState from the StreamBuilder repeatedly
    _ordersSub = FirebaseDatabase.instance
        .ref()
        .child('Orders')
        .orderByChild('userUID')
        .equalTo(auth.currentUser!.uid)
        .onValue
        .listen((event) {
          bool has = false;
          final raw = event.snapshot.value;
          final List<String> foundStatuses = [];
          if (raw != null) {
            // Handle map-of-orders
            if (raw is Map) {
              for (final entry in raw.values) {
                try {
                  final orderMap =
                      jsonDecode(jsonEncode(entry)) as Map<String, dynamic>;
                  final status = (orderMap['orderStatus'] ?? '').toString();
                  foundStatuses.add(status);
                  if (status != 'SERVICE_DELIVERED' && status.isNotEmpty) {
                    has = true;
                    // don't break — collect statuses for logging
                  }
                } catch (_) {
                  // ignore malformed entry
                  continue;
                }
              }
            } else if (raw is List) {
              // Firebase can sometimes return a List; iterate non-null elements
              for (final entry in raw) {
                if (entry == null) continue;
                try {
                  final orderMap =
                      jsonDecode(jsonEncode(entry)) as Map<String, dynamic>;
                  final status = (orderMap['orderStatus'] ?? '').toString();
                  foundStatuses.add(status);
                  if (status != 'SERVICE_DELIVERED' && status.isNotEmpty) {
                    has = true;
                  }
                } catch (_) {
                  continue;
                }
              }
            }
          }

          log(
            'BasketScreen Orders snapshot — hasActiveCandidate=$has; statuses=${foundStatuses.join(',')}',
          );
          if (mounted && hasActiveOrder != has)
            setState(() => hasActiveOrder = has);
        });
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Ensure RTL direction for the whole screen
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'سلة الطلبات',
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
          backgroundColor: const Color(0xFFF5F5F5),
          body: Stack(
            children: [
              StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child('Orders')
                    .orderByChild('userUID')
                    .equalTo(auth.currentUser!.uid)
                    .onValue,
                builder: (context, event) {
                  // Treat waiting the same as no-data to avoid flicker
                  if (event.connectionState == ConnectionState.waiting ||
                      event.data == null ||
                      event.data!.snapshot.value == null) {
                    // No active order, display cart items
                    return Consumer<ItemOrderProvider>(
                      builder: (context, itemOrderProvider, child) {
                        if (itemOrderProvider.cartItems.isEmpty) {
                          return Center(
                            child: Text(
                              'السلة فارغة',
                              style: AppTextStyles.body16,
                            ),
                          );
                        } else {
                          return ListView(
                            padding: EdgeInsets.only(
                              left: 2.w,
                              right: 2.w,
                              top: 2.h,
                              bottom: 16.h,
                            ),
                            children: [
                              ...itemOrderProvider.cartItems.map(
                                (serviceData) => ServiceCardWidget(
                                  service: serviceData,
                                  showQuantityControls: true,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  }

                  // Build list of ALL active orders for this user instead of only the first one
                  final rawData =
                      event.data!.snapshot.value as Map<dynamic, dynamic>;
                  final List<ServiceOrderModel> userOrders = rawData.values.map(
                    (value) {
                      final orderMap =
                          jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
                      return ServiceOrderModel.fromMap(orderMap);
                    },
                  ).toList();

                  if (userOrders.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد طلبات حالياً',
                        style: AppTextStyles.body16,
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    children: [
                      ...userOrders.map((o) => _OrderCard(order: o)),
                      SizedBox(height: 14.h), // space for floating button
                    ],
                  );
                },
              ),

              // Floating button replaced by Scaffold.bottomNavigationBar for consistency
            ],
          ),
          bottomNavigationBar: Consumer<ItemOrderProvider>(
            builder: (context, itemOrderProvider, _) {
              log(
                'BasketScreen bottomNav rebuild — hasActiveOrder=$hasActiveOrder, cartItems=${itemOrderProvider.cartItems.length}',
              );
              // update debug cart count after frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    _debugCartCount != itemOrderProvider.cartItems.length) {
                  setState(
                    () => _debugCartCount = itemOrderProvider.cartItems.length,
                  );
                }
              });
              // Show the button when there is at least one item in the cart
              final hasItems = itemOrderProvider.cartItems.isNotEmpty;
              final visible =
                  hasItems; // ignore active orders, show when cart has items
              return FullWidthFloatingButton(
                label: 'اطلب الآن',
                onPressed: (!visible)
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubmitProblemScreen(),
                          ),
                        );
                      },
                isLoading: false,
                visible: visible,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ServiceOrderModel order;
  const _OrderCard({required this.order});

  // Use shared utilities for strict mapping of the exact status strings
  String _arabicStatus(String raw) => statusToArabic(raw);

  Color _statusColor(String raw) => statusToColor(raw);

  bool _showTrack(String raw) => isTrackable(raw);

  @override
  Widget build(BuildContext context) {
    final hasMultiple = order.services != null && order.services!.isNotEmpty;
    final servicesList = hasMultiple ? order.services! : [order.servicedetail];
    final rawStatus = (order.orderStatus ?? '').toString();
    final displayStatus = _arabicStatus(rawStatus);
    final color = _statusColor(rawStatus);

    return Card(
      margin: EdgeInsets.only(bottom: 1.4.h),
      elevation: 3,
      color: white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: greyShade3.withOpacity(.25),
      child: Padding(
        padding: EdgeInsets.all(3.8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    'رقم الطلب: ${order.orderID?.substring(0, 8) ?? ''}',
                    style: AppTextStyles.body16Bold.copyWith(color: darkBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      SizedBox(width: 1.5.w),
                      Text(
                        displayStatus,
                        style: AppTextStyles.body14.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.2.h),

            if (hasMultiple)
              Text(
                'عدد الخدمات: ${servicesList.length}',
                style: AppTextStyles.body14.copyWith(color: Colors.black87),
              ),

            SizedBox(height: 1.h),

            // Services list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < servicesList.length; i++) ...[
                  _ServiceLine(index: i + 1, service: servicesList[i]),
                  if (i != servicesList.length - 1) SizedBox(height: 0.8.h),
                ],
              ],
            ),

            // Track button
            if (_showTrack(rawStatus)) ...[
              SizedBox(height: 1.2.h),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    backgroundColor: darkBlue.withOpacity(.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TrackTechnicianScreen(orderId: order.orderID!),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.location_searching,
                    color: darkBlue,
                    size: 2.2.h,
                  ),
                  label: Text(
                    'تتبع الفني',
                    style: AppTextStyles.body14.copyWith(
                      color: darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServiceLine extends StatelessWidget {
  final int index;
  final ServiceModel service;
  const _ServiceLine({required this.index, required this.service});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.4.h),
          height: 7,
          width: 7,
          decoration: BoxDecoration(color: darkBlue, shape: BoxShape.circle),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name ?? 'الخدمة',
                style: AppTextStyles.body14Bold.copyWith(color: Colors.black87),
              ),
              if ((service.detail ?? '').trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 0.2.h),
                  child: Text(
                    service.detail!,
                    style: AppTextStyles.body14.copyWith(
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: 0.2.h),
                child: Text(
                  'الكمية: ${service.quantity ?? 1}',
                  style: AppTextStyles.body14.copyWith(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
