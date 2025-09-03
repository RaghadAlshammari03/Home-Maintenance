import 'dart:developer';

import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/directionServices/directionServices.dart';
import 'package:baligny/model/directionModel/directionModel.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserProvider extends ChangeNotifier {
  String apiKey = dotenv.env['routesAPI']!;
  Position? currentPosition;
  ServiceOrderModel? currentOrder;
  LatLng? technicianLocation;
  LatLng? customerLocation;

  Set<Polyline> polylineSetTowardsTechnician = {};
  Set<Marker> markers = {};
  bool isTracking = false;
  bool _isUpdating = false;

  updateCurrentPosition(Position position) {
    currentPosition = position;
    notifyListeners();
  }

  updateOrderData(ServiceOrderModel order) {
    currentOrder = order;
    customerLocation = LatLng(
      order.userAddress!.latitude,
      order.userAddress!.longitude,
    );
    notifyListeners();
  }

  updateTechnicianLocation(LatLng newLocation) {
    technicianLocation = newLocation;
    notifyListeners();
  }

  Polyline decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);
    List<PointLatLng> data = PolylinePoints.decodePolyline(encodedPolyline);

    List<LatLng> latLngList = data
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      points: latLngList,
      width: 5,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
  }

  /// Start tracking technician location and update polyline live
  startTracking(String technicianUID, BuildContext context) async {
    if (isTracking) return;
    isTracking = true;

    // Listen to technician location from realtime DB
    final locationRef = realTimeDatabaseRef.child(
      'OnlineTechnicians/$technicianUID',
    );

    locationRef.onValue.listen((event) async {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map;
      final double lat = data['l'][0];
      final double lng = data['l'][1];
      LatLng technicianLatLng = LatLng(lat, lng);

      updateTechnicianLocation(technicianLatLng);

      // Update markers
      markers = {
        Marker(
          markerId: const MarkerId('technician'),
          position: technicianLatLng,
          infoWindow: const InfoWindow(title: 'الفني'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
        Marker(
          markerId: const MarkerId('customer'),
          position: customerLocation!,
          infoWindow: const InfoWindow(title: 'موقعك'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };

      // Fetch directions from technician to customer
      DirectionModel? direction = await DirectionServices.getDirectionDetails(
        technicianLatLng,
        customerLocation!,
        context,
      );

      if (direction != null) {
        Polyline polyline = decodePolyline(direction.polylinePoints);
        polylineSetTowardsTechnician.clear();
        polylineSetTowardsTechnician.add(polyline);
        notifyListeners();
      }
    });
  }

  stopTracking() {
    isTracking = false;
    polylineSetTowardsTechnician.clear();
    markers.clear();
    technicianLocation = null;
    notifyListeners();
  }
}
