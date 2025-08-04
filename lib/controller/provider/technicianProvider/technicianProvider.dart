import 'dart:developer';

import 'package:baligny_technician/controller/services/locationServices/directionServices/directionServices.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:baligny_technician/model/directionModel/directionModel.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TechnicianProvider extends ChangeNotifier {
  Position? currentPosition;
  String apiKey = dotenv.env['routesAPI']!;

  // Google maps variables
  LatLng? technicianLocation;
  LatLng? customerLocation;
  ServiceOrderModel? orderData;

  Set<Polyline> polylineSetTowardsCustomer = {};
  Polyline? polylineTowardsCustomer;
  List<LatLng> polylineCoordinatesListTowardsCustomer = [];

  // Marker
  /* BitmapDescriptor? destinationIcon;
  BitmapDescriptor? crrLocationIcon; */
  Set<Marker> deliveryMarker = Set<Marker>();
  bool inDelivery = false;
  bool _isUpdatingMarker = false;

  updateInDeliveryStatus(bool newStatus) {
    inDelivery = newStatus;
    notifyListeners();
  }

  updateOrderData(ServiceOrderModel data) {
    orderData = data;
    notifyListeners();
  }

  // Update current GPS position
  updateCurrentPosition(Position crrPosition) {
    currentPosition = crrPosition;
    debugPrint("Current position updated: $currentPosition");
    notifyListeners();
  }

  // Update Technician & Customer locations
  updateLatLngs(LatLng technician, LatLng customer) {
    technicianLocation = technician;
    customerLocation = customer;
    debugPrint("Technician location set to: $technicianLocation");
    debugPrint("Customer location set to: $customerLocation");
    notifyListeners();
  }

  // Decode polyline using flutter_polyline_points
  Polyline decodePolyline(String encodedPolyline) {
    debugPrint("Decoding polyline: $encodedPolyline");
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);
    List<PointLatLng> data = PolylinePoints.decodePolyline(encodedPolyline);

    if (data.isEmpty) {
      debugPrint("Warning: Decoded polyline points are empty!");
    }

    List<LatLng> polylineCoordinatesList = [];
    for (var latlngPoint in data) {
      polylineCoordinatesList.add(
        LatLng(latlngPoint.latitude, latlngPoint.longitude),
      );
    }
    debugPrint("Decoded ${polylineCoordinatesList.length} points.");

    polylineSetTowardsCustomer.clear();
    Polyline polyline = Polyline(
      polylineId: const PolylineId('polyline'),
      color: darkBlue,
      points: polylineCoordinatesList,
      jointType: JointType.round,
      width: 3,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    return polyline;
  }

  fetchCrrLocationToCustomerPolyline(BuildContext context) async {
    if (!inDelivery || technicianLocation == null || customerLocation == null) {
      debugPrint("Skipping polyline update: not in delivery or missing data.");
      return;
    }

    debugPrint("Fetching polyline from technician to customer...");

    if (technicianLocation == null || customerLocation == null) {
      debugPrint("Error: technicianLocation or customerLocation is null!");
      return;
    }

    polylineSetTowardsCustomer.clear();
    DirectionModel? directionModel =
        await DirectionServices.getDirectionDetails(
          technicianLocation!,
          customerLocation!,
          context,
        );

    if (directionModel == null) {
      debugPrint('No direction data returned from API.');
      return;
    }

    debugPrint(
      "Direction data received: Distance - ${directionModel.distanceInKM}, Duration - ${directionModel.durationInHour}",
    );
    Polyline polyline = decodePolyline(directionModel.polylinePoints);

    if (polyline.points.isEmpty) {
      debugPrint("Error: Decoded polyline points list is empty!");
      return;
    }

    polylineSetTowardsCustomer.add(polyline);
    debugPrint("Polyline added to polylineSetTowardsCustomer.");
    notifyListeners();
  }

  updatePolyline(String encodedPolyline) {
    debugPrint("Updating polyline with new encoded string...");
    polylineSetTowardsCustomer.clear();

    Polyline polyline = decodePolyline(encodedPolyline);

    if (polyline.points.isEmpty) {
      debugPrint(
        "Error: Decoded polyline points list is empty in updatePolyline!",
      );
      return;
    }

    polylineTowardsCustomer = polyline;
    polylineSetTowardsCustomer.add(polylineTowardsCustomer!);
    debugPrint("Polyline updated successfully.");
    notifyListeners();
  }

  /* createIcons(BuildContext context) async {
    // Current location icon
    ImageConfiguration imageConfigurationCrrLocation =
        createLocalImageConfiguration(context, size: Size(2, 2));
    crrLocationIcon = await BitmapDescriptor.fromAssetImage(
      imageConfigurationCrrLocation,
      'assets/images/ride/crrLocation.png',
    );

    // Destination Icon
    ImageConfiguration imageConfigurationDestinationLocation =
        createLocalImageConfiguration(context, size: Size(2, 2));
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      imageConfigurationDestinationLocation,
      'assets/images/ride/destination.png',
    );
    log(
      'Icons Created: crrLocationIcon=$crrLocationIcon, destinationIcon=$destinationIcon',
    );
    notifyListeners();
  } */

  updateMarker(BuildContext context) async {
    if (!inDelivery) {
      debugPrint("Not in delivery, skipping updateMarker.");
      return;
    }

    if (_isUpdatingMarker) {
      debugPrint("Already updating marker, skipping duplicate call.");
      return;
    }

    _isUpdatingMarker = true;

    deliveryMarker = Set<Marker>();
    Position? crrPosition = await LocationServices.getCurrentLocation();
    ServiceOrderModel itemOrderData = orderData!;

    LatLng currentTechnicianLatLng = LatLng(
      crrPosition!.latitude,
      crrPosition.longitude,
    );

    LatLng CustomerLocation = LatLng(
      itemOrderData.userAddress!.latitude,
      itemOrderData.userAddress!.longitude,
    );

    // Update locations
    updateLatLngs(currentTechnicianLatLng, CustomerLocation);

    // Recalculate polyline route to reflect updated technician location
    await fetchCrrLocationToCustomerPolyline(context);

    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(crrPosition.latitude, crrPosition.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationLocation'),
      position: CustomerLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    deliveryMarker.add(currentLocationMarker);
    deliveryMarker.add(destinationMarker);

    notifyListeners();
    log('Markers Updated');
    // Check every 5s if the technician changed location to update the marker
    await Future.delayed(const Duration(seconds: 5));
    if (inDelivery) {
      await updateMarker(context);
    }
    _isUpdatingMarker = false;
  }

  clearRouteData() {
    inDelivery = false;
    debugPrint("Clearing route data...");
    polylineSetTowardsCustomer.clear();
    polylineTowardsCustomer = null;
    polylineCoordinatesListTowardsCustomer.clear();
    deliveryMarker = Set<Marker>();
    // technicianLocation = null;
    customerLocation = null;
    orderData = null;
    notifyListeners();
  }
}
