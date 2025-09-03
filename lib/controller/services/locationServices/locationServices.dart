import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:baligny_technician/utils/location_permission.dart';

class LocationServices {
  static Future<Position?> getCurrentLocation({BuildContext? context}) async {
    // Ensure device/service and runtime permissions are OK
    final granted = await LocationPermissionHelper.ensurePermission(
      context: context,
    );
    if (!granted) {
      log("Location permission/service not granted");
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      log("تم الحصول على الموقع: $position");
      return position;
    } catch (e) {
      log("حدث خطأ أثناء الحصول على الموقع: $e");
      return null;
    }
  }
}
