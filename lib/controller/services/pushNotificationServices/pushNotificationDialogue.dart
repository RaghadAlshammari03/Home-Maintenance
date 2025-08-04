// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/orderProvider/orderProvider.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:baligny_technician/controller/services/orderServices/orderServices.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PushNotificationDialogue {
  static serviceRequestDialogue(String orderID, BuildContext context) async {
    audioPlayer
        .setAsset('assets/sounds/alert.mp3')
        .then((_) {
          audioPlayer.play();
        })
        .catchError((e) {
          log("Audio error: $e");
        });
    ServiceOrderModel serviceOrderData = await OrderServices.fetchOrderDetails(
      orderID,
    );
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 50.h,
            width: 60.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have a new service request',
                    style: AppTextStyles.body18,
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Customer Location\t\t',
                          style: AppTextStyles.body14,
                        ),
                        TextSpan(
                          text: serviceOrderData.userAddress!.apartment,
                          style: AppTextStyles.body14,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SwipeButton(
                    thumbPadding: EdgeInsets.all(1.w),
                    thumb: Icon(Icons.chevron_right, color: white),
                    inactiveThumbColor: black,
                    activeThumbColor: black,
                    inactiveTrackColor: greyShade3,
                    activeTrackColor: greyShade3,
                    elevationThumb: 2,
                    elevationTrack: 2,
                    onSwipe: () async {
                      await realTimeDatabaseRef
                          .child('Orders/$orderID/orderStatus')
                          .set(OrderServices.orderStatus(0));

                      audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text('Leave for later', style: AppTextStyles.body16),
                  ),

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
                      await realTimeDatabaseRef
                          .child('Orders/$orderID/orderStatus')
                          .set(OrderServices.orderStatus(1));
                          
                      Position? technicianPosition =
                          await LocationServices.getCurrentLocation();
                      LatLng technician = LatLng(
                        technicianPosition!.latitude,
                        technicianPosition.longitude,
                      );
                      LatLng customer = LatLng(
                        serviceOrderData.userAddress!.latitude,
                        serviceOrderData.userAddress!.longitude,
                      );
                      context.read<TechnicianProvider>().updateLatLngs(
                        technician,
                        customer,
                      );
                      OrderServices.updateTechnicianProfileIntoServiceOrderModelAndAddActiveDeliveryRequest(
                        orderID,
                        context,
                      );
                      context
                          .read<TechnicianProvider>()
                          .fetchCrrLocationToCustomerPolyline(context);

                      ServiceOrderModel orderData =
                          await OrderServices.fetchOrderDetails(orderID);
                      context.read<TechnicianProvider>().updateOrderData(
                        orderData,
                      );
                      context.read<OrderProvider>().updateServiceOrderData(
                        orderData,
                      );
                      context.read<TechnicianProvider>().updateInDeliveryStatus(
                        true,
                      );
                      context.read<TechnicianProvider>().updateMarker(context);

                      audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text('Accept', style: AppTextStyles.body16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
