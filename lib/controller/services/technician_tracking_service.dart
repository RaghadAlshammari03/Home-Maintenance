import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TechnicianTrackingService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Live location update subscription (device side)
  static StreamSubscription<Position>? _positionSub;

  // Start continuous live location updates for a technician device
  static Future<void> startLiveLocationUpdates(String technicianID) async {
    await stopLiveLocationUpdates();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('TechnicianTrackingService: Location services disabled');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('TechnicianTrackingService: Location permission denied');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) async {
            try {
              await FirebaseDatabase.instance
                  .ref()
                  .child('Technician/$technicianID/location')
                  .update({
                    'latitude': pos.latitude,
                    'longitude': pos.longitude,
                    'heading': pos.heading,
                    'speed': pos.speed,
                    'updatedAt': ServerValue.timestamp,
                  });
            } catch (e) {
              debugPrint(
                'TechnicianTrackingService: Failed updating live location: $e',
              );
            }
          },
          onError: (e) => debugPrint(
            'TechnicianTrackingService: Location stream error: $e',
          ),
          cancelOnError: false,
        );
  }

  static Future<void> stopLiveLocationUpdates() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  static Stream<DatabaseEvent> listenToTechnicianLocationRaw(
    String technicianID,
  ) {
    return FirebaseDatabase.instance
        .ref()
        .child('Technician/$technicianID/location')
        .onValue;
  }

  // Normalize dynamic map structures
  Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    if (value is Map) {
      return Map<String, dynamic>.from(
        (value as Map).map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return <String, dynamic>{};
  }

  Future<LatLng?> getTechnicianLocation(String technicianId) async {
    try {
      final snapshot = await _databaseRef
          .child('Technician/$technicianId/location')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        final data = _normalizeMap(snapshot.value);
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) return LatLng(lat, lng);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching technician location: $e');
    }
    return null;
  }

  Future<String?> getOrderStatus(String orderId) async {
    try {
      final snapshot = await _databaseRef
          .child('Orders/$orderId/orderStatus')
          .get();
      if (snapshot.exists) {
        final value = snapshot.value;
        if (value is String) return value;
        return value?.toString();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching order status: $e');
    }
    return null;
  }

  Stream<LatLng?> trackTechnicianLatLng(String technicianId) {
    return _databaseRef.child('Technician/$technicianId/location').onValue.map((
      event,
    ) {
      final data = _normalizeMap(event.snapshot.value);
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    });
  }

  Stream<String?> trackOrderStatus(String orderId) {
    return _databaseRef
        .child('Orders/$orderId/orderStatus')
        .onValue
        .map((event) => event.snapshot.value?.toString());
  }

  Stream<Map<String, dynamic>?> trackOrder(String orderId) {
    return _databaseRef.child('Orders/$orderId').onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw == null) return null;
      if (raw is Map) {
        final map = _normalizeMap(raw);
        if (map.containsKey('orderID')) return map;
        if (map.containsKey(orderId) && map[orderId] is Map) {
          return _normalizeMap(map[orderId]);
        }
        return map;
      }
      return null;
    });
  }
}
