import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionHelper {
  /// Ensures location services are enabled and permission is granted.
  /// If [context] is provided, the helper will show dialogs and can open settings.
  /// Returns true if the app is allowed to access location (whileInUse or always).
  static Future<bool> ensurePermission({BuildContext? context}) async {
    try {
      // 1) Check device location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context != null) {
          final open = await _showEnableLocationDialog(context);
          if (open == true) await Geolocator.openLocationSettings();
        }
        return false;
      }

      // 2) Check app permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (context != null) {
          final open = await _showPermissionDeniedForeverDialog(context);
          if (open == true) await Geolocator.openAppSettings();
        }
        return false;
      }

      if (permission == LocationPermission.denied) {
        // user denied (not forever)
        if (context != null) {
          _showSimpleMessage(
            context,
            'يجب منح إذن الموقع لاستخدام هذه الخاصية',
          );
        }
        return false;
      }

      // permission granted
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      if (context != null)
        _showSimpleMessage(context, 'حدث خطأ بالوصول للموقع');
      return false;
    }
  }

  static Future<bool?> _showEnableLocationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تشغيل الموقع'),
        content: const Text(
          'يجب تشغيل خدمات الموقع لتتمكن من استخدام هذه الميزة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showPermissionDeniedForeverDialog(
    BuildContext context,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الموقع مطلوب'),
        content: const Text(
          'يتم حظر الإذن نهائياً. افتح إعدادات التطبيق لمنحه إذن الموقع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  static void _showSimpleMessage(BuildContext context, String msg) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(SnackBar(content: Text(msg)));
  }
}
