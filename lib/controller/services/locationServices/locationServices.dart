import 'dart:developer';
import 'package:geolocator/geolocator.dart';

class LocationServices {
  static Future<Position?> getCurrentLocation() async {
    // Check if GPS is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("خدمات الموقع غير مفعلة، الرجاء تفعيلها من إعدادات الجوال");
      return null;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      log("خدمات الموقع غير مفعلة، الرجاء تفعيلها من إعدادات الجوال");
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