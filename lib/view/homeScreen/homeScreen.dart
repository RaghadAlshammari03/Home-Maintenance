// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/geoFireServices/geoFireServices.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:baligny_technician/utils/textStyles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      debugPrint("لم يتم منح صلاحية الوصول إلى الموقع أو أن خدمة الموقع غير مفعلة.");
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
                    if (technicianData.technicianStatus == 'ONLINE') {
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
                          GeoFireServices.goOffline();
                        },
                        child: Text(
                          'Done for today',
                          style: AppTextStyles.body16,
                        ),
                      );
                    } else {
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
                          await GeoFireServices.goOnline();
                          await GeoFireServices.updateLocationRealtime(context);
                        },
                        child: Text('Go online', style: AppTextStyles.body16),
                      );
                    }
                  }
                  return Center(child: CircularProgressIndicator(color: black));
                },
              ),
            ),
            Expanded(
              child: currentPosition == null
                  ? Center(child: CircularProgressIndicator(color: black))
                  : GoogleMap(
                      initialCameraPosition: currentPosition!,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
