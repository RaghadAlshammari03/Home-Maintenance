// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/geoFireServices/geoFireServices.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:baligny_technician/controller/services/orderServices/orderServices.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> googleMapController = Completer();
  GoogleMapController? mapController;
  CameraPosition? currentPosition;
  late final DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();
    databaseReference = FirebaseDatabase.instance.ref().child(
      'Technician/${auth.currentUser!.uid}',
    );
    getCurrentLocationAndSetCamera();
  }

  Future<void> getCurrentLocationAndSetCamera() async {
    final position = await LocationServices.getCurrentLocation();
    if (position != null) {
      currentPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 11,
      );
      setState(() {});
    } else {
      debugPrint(
        "لم يتم منح صلاحية الوصول إلى الموقع أو أن خدمة الموقع غير مفعلة.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 10.h,
              width: 100.w,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: StreamBuilder(
                stream: databaseReference.onValue,
                builder: (context, event) {
                  if (event.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: black),
                    );
                  }
                  if (event.data != null) {
                    TechnicianModel technicianData = TechnicianModel.fromMap(
                      jsonDecode(jsonEncode(event.data!.snapshot.value))
                          as Map<String, dynamic>,
                    );

                    if (technicianData.activeDeliveryRequestID == null ||
                        technicianData.activeDeliveryRequestID!.isEmpty) {
                      return const SizedBox.shrink(); // No swipe button if there's no order
                    } else {
                      return StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .ref()
                            .child(
                              'Orders/${technicianData.activeDeliveryRequestID}',
                            )
                            .onValue,
                        builder: (context, event) {
                          if (event.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(color: black);
                          }

                          if (event.data == null ||
                              event.data!.snapshot.value == null) {
                            // Order doesn't exist or still loading
                            return const SizedBox.shrink(); // Don't show any swipe button
                          }

                          final orderMap = jsonDecode(
                            jsonEncode(event.data!.snapshot.value),
                          );
                          final serviceOrderData = ServiceOrderModel.fromMap(
                            orderMap as Map<String, dynamic>,
                          );
                          final currentStatus = serviceOrderData.orderStatus;

                          if (currentStatus == OrderServices.orderStatus(1)) {
                            // SERVICE_ACCEPTED_BY_TECHNICIAN -> show "On the Way" swipe
                            return SwipeButton(
                              thumbPadding: EdgeInsets.all(1.w),
                              thumb: Icon(Icons.chevron_right, color: white),
                              inactiveThumbColor: black,
                              activeThumbColor: black,
                              inactiveTrackColor: greyShade3,
                              activeTrackColor: greyShade3,
                              elevationThumb: 2,
                              elevationTrack: 2,
                              onSwipe: () {
                                realTimeDatabaseRef
                                    .child(
                                      'Orders/${technicianData.activeDeliveryRequestID}/orderStatus',
                                    )
                                    .set(
                                      OrderServices.orderStatus(2),
                                    );
                              },
                              child: Text(
                                'On The Way',
                                style: AppTextStyles.body16,
                              ),
                            );
                          } else if (currentStatus ==
                              OrderServices.orderStatus(2)) {
                            return SwipeButton(
                              thumbPadding: EdgeInsets.all(1.w),
                              thumb: Icon(Icons.chevron_right, color: white),
                              inactiveThumbColor: black,
                              activeThumbColor: black,
                              inactiveTrackColor: greyShade3,
                              activeTrackColor: greyShade3,
                              elevationThumb: 2,
                              elevationTrack: 2,
                              onSwipe: () async {
                                await OrderServices.addOrderDataToHistory(
                                  serviceOrderData,
                                  context,
                                );
                                await realTimeDatabaseRef
                                    .child(
                                      'Orders/${technicianData.activeDeliveryRequestID}/orderStatus',
                                    )
                                    .set(
                                      OrderServices.orderStatus(3),
                                    ); 

                                await realTimeDatabaseRef
                                    .child(
                                      'Technician/${auth.currentUser!.uid}/activeDeliveryRequestID',
                                    )
                                    .remove();

                                OrderServices.removeOrder(
                                  serviceOrderData.orderID!,
                                );

                                if (!context.mounted) return;

                                context
                                    .read<TechnicianProvider>()
                                    .updateInDeliveryStatus(false);

                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );

                                if (context.mounted) {
                                  context
                                      .read<TechnicianProvider>()
                                      .clearRouteData();
                                }
                              },
                              child: Text(
                                'Service Done',
                                style: AppTextStyles.body16,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    }
                  }
                  return Center(child: CircularProgressIndicator(color: black));
                },
              ),
            ),
            StreamBuilder(
              stream: databaseReference.onValue,
              builder: (context, event) {
                if (event.data == null) {
                  return Center(child: CircularProgressIndicator(color: black));
                }

                final technicianData = TechnicianModel.fromMap(
                  jsonDecode(jsonEncode(event.data!.snapshot.value))
                      as Map<String, dynamic>,
                );

                if (technicianData.activeDeliveryRequestID == null ||
                    technicianData.activeDeliveryRequestID!.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text(
                        'No service request in progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                debugPrint(
                  'Active delivery request found: ${technicianData.activeDeliveryRequestID}',
                );

                return StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('Orders/${technicianData.activeDeliveryRequestID}')
                      .onValue,
                  builder: (context, serviceOrderEvent) {
                    if (serviceOrderEvent.data == null) {
                      return Center(
                        child: CircularProgressIndicator(color: black),
                      );
                    }
                    final serviceOrderData = ServiceOrderModel.fromMap(
                      jsonDecode(
                            jsonEncode(serviceOrderEvent.data!.snapshot.value),
                          )
                          as Map<String, dynamic>,
                    );
                    return Expanded(
                      child: currentPosition == null
                          ? Center(
                              child: CircularProgressIndicator(color: black),
                            )
                          : Consumer<TechnicianProvider>(
                              builder: (context, technicianProvider, child) {
                                return GoogleMap(
                                  initialCameraPosition: currentPosition!,
                                  mapType: MapType.normal,
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  zoomControlsEnabled: true,
                                  zoomGesturesEnabled: true,
                                  polylines: technicianProvider
                                      .polylineSetTowardsCustomer,
                                  markers: technicianProvider.deliveryMarker,
                                );
                              },
                            ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
