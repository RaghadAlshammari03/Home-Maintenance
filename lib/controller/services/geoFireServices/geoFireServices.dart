import 'dart:async';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/provider/technicianProvider/technicianProvider.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class GeoFireServices {
  static final DatabaseReference statusRef = FirebaseDatabase.instance
      .ref()
      .child('Technician/${auth.currentUser!.uid}/technicianStatus');

  static Future<void> goOnline() async {
    try {
      Position? currentPosition = await LocationServices.getCurrentLocation();

      if (currentPosition == null) {
        print("لم يتم الحصول على الموقع الحالي");
        return;
      }

      // Initialize and set location in GeoFire
      Geofire.initialize('OnlineTechnicians');
      Geofire.setLocation(
        auth.currentUser!.uid,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // Save technician status to Firebase
      await statusRef.set("ONLINE");
      print("تم تفعيل الوضع النشط");
      print("تم تحديد الموقع: ${currentPosition.latitude}, ${currentPosition.longitude}");
    } catch (e) {
      print("حدث خطأ أثناء الذهاب إلى الوضع النشط: $e");
    }
  }

  static Future<void> goOffline() async {
    try {
      await Geofire.removeLocation(auth.currentUser!.uid);
      await statusRef.set("OFFLINE");
      print("تم إيقاف الوضع النشط");
    } catch (e) {
      print("حدث خطأ أثناء إيقاف الوضع النشط: $e");
    }
  }

  static updateLocationRealtime(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    StreamSubscription<Position> technicianPositionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((event) {
      Geofire.setLocation(
        auth.currentUser!.uid,
        event.latitude,
        event.longitude,
      );
      context.read<TechnicianProvider>().updateCurrentPosition(event);
    });
  }
}
