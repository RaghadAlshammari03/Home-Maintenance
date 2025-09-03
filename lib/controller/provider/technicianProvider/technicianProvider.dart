import 'dart:developer';
import 'dart:async';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/locationServices/directionServices/directionServices.dart';
import 'package:baligny_technician/controller/services/locationServices/locationServices.dart';
import 'package:baligny_technician/model/directionModel/directionModel.dart';
import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny_technician/utils/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:baligny_technician/utils/location_permission.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TechnicianProvider extends ChangeNotifier {
  final DatabaseReference _liveLocRef = FirebaseDatabase.instance.ref().child(
    'Technician/${auth.currentUser!.uid}/location',
  );
  Position? currentPosition;

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
  bool _rehydrated = false; // prevents duplicate rehydrate calls during build
  bool _tracking = false;
  StreamSubscription<Position>? _positionSub;
  DateTime _lastMarkerUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // Route summary (duration/distance) shown on map
  String? routeDurationText;
  String? routeDistanceText;

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

  void _publishLocation(Position p) {
    _liveLocRef
        .update({
          'latitude': p.latitude,
          'longitude': p.longitude,
          'heading': p.heading,
          'speed': p.speed,
          'updatedAt': ServerValue.timestamp,
        })
        .catchError((e) => debugPrint('Live loc write failed: $e'));
  }

  // Decode polyline using flutter_polyline_points
  Polyline decodePolyline(String encodedPolyline) {
    debugPrint("Decoding polyline: $encodedPolyline");
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
      // clear any previous route summary
      routeDurationText = null;
      routeDistanceText = null;
      notifyListeners();
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

    // Update route summary text (safe fallback if nulls)
    routeDurationText = directionModel.durationInHour;
    routeDistanceText = directionModel.distanceInKM;

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
    Position? crrPosition = await LocationServices.getCurrentLocation(
      context: context,
    );
    if (crrPosition == null || orderData == null) {
      _isUpdatingMarker = false;
      return;
    }
    ServiceOrderModel itemOrderData = orderData!;

    LatLng currentTechnicianLatLng = LatLng(
      crrPosition.latitude,
      crrPosition.longitude,
    );

    LatLng CustomerLocation = LatLng(
      itemOrderData.userAddress!.latitude,
      itemOrderData.userAddress!.longitude,
    );

    updateLatLngs(currentTechnicianLatLng, CustomerLocation);

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

    _lastMarkerUpdate = DateTime.now();
    _isUpdatingMarker = false; // release before potential next schedule
    notifyListeners();
    log('Markers Updated');

    // Schedule next update (polling fallback) only if no live tracking
    if (inDelivery && !_tracking) {
      Future.delayed(const Duration(seconds: 5), () {
        if (inDelivery) {
          updateMarker(context);
        }
      });
    }
  }

  Future<void> startLiveLocationTracking(BuildContext context) async {
    if (_tracking) return;
    _tracking = true;

    try {
      // Ensure permission and device settings first
      final granted = await LocationPermissionHelper.ensurePermission(
        context: context,
      );
      if (!granted) {
        debugPrint(
          'Location permission not granted - aborting live tracking start',
        );
        _tracking = false;
        return;
      }

      final first = await LocationServices.getCurrentLocation(context: context);
      if (first == null) {
        debugPrint(
          'Unable to obtain initial position; aborting live tracking start',
        );
        _tracking = false;
        return;
      }
      updateCurrentPosition(first);
      // Set technician location (and customer if order already known)
      technicianLocation = LatLng(first.latitude, first.longitude);
      if (orderData?.userAddress != null) {
        customerLocation ??= LatLng(
          orderData!.userAddress!.latitude,
          orderData!.userAddress!.longitude,
        );
      }

      _publishLocation(first);
      // Immediate map + polyline update (will throttle later updates)
      await updateMarker(context);
    } catch (e) {
      debugPrint('Initial position error: $e');
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    // Start position stream only if permissions still valid
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      debugPrint('Permission lost before starting stream: $perm');
      _tracking = false;
      return;
    }

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(
          (pos) {
            updateCurrentPosition(pos);
            _publishLocation(pos);
            if (inDelivery && !_isUpdatingMarker) {
              if (DateTime.now().difference(_lastMarkerUpdate).inSeconds >= 4) {
                updateMarker(context);
              }
            }
          },
          onError: (e) {
            debugPrint('Live location stream error: $e');
          },
        );
  }

  void stopLiveLocationTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _tracking = false;
  }

  // Rehydrate state after cold start if an active order exists in DB
  Future<void> rehydrateFromExistingOrder(
    ServiceOrderModel order,
    BuildContext context,
  ) async {
    if (_rehydrated) {
      debugPrint('Rehydrate skipped: already done.');
      return;
    }
    // If already hydrated with markers and polyline, skip
    if (orderData != null &&
        inDelivery &&
        polylineSetTowardsCustomer.isNotEmpty &&
        deliveryMarker.isNotEmpty) {
      debugPrint('Rehydrate skipped: state already populated.');
      _rehydrated = true;
      return;
    }

    debugPrint(
      'Rehydrating provider state from existing active order ${order.orderID}',
    );

    // Attach order data but only mark inDelivery/start tracking when status indicates technician accepted or on the way
    orderData = order;
    final status = order.orderStatus ?? '';
    final shouldBeInDelivery =
        (status == 'SERVICE_ACCEPTED_BY_TECHNICIAN' ||
        status == 'TECHNICIAN_ON_THE_WAY');
    inDelivery = shouldBeInDelivery;
    notifyListeners();

    if (!shouldBeInDelivery) {
      // Do not start tracking or set markers for 'under preparation' state.
      _rehydrated = true;
      debugPrint(
        'Rehydrate complete: order attached but not inDelivery (status=$status)',
      );
      return;
    }

    // Ensure we have current GPS position before starting tracking
    Position? pos =
        currentPosition ??
        await LocationServices.getCurrentLocation(context: context);
    if (pos == null) {
      debugPrint('Cannot rehydrate: current GPS position unavailable.');
      return;
    }

    if (order.userAddress == null) {
      debugPrint('Cannot rehydrate: order has no userAddress');
      return;
    }

    LatLng techLatLng = LatLng(pos.latitude, pos.longitude);
    LatLng custLatLng = LatLng(
      order.userAddress!.latitude,
      order.userAddress!.longitude,
    );
    updateLatLngs(techLatLng, custLatLng);

    await fetchCrrLocationToCustomerPolyline(context);
    await updateMarker(context);

    _rehydrated = true;
    debugPrint(
      'Rehydrate complete: markers=${deliveryMarker.length}, polylines=${polylineSetTowardsCustomer.length}',
    );
  }

  clearRouteData() {
    inDelivery = false;
    _rehydrated = false;
    stopLiveLocationTracking();
    debugPrint("Clearing route data...");
    polylineSetTowardsCustomer.clear();
    polylineTowardsCustomer = null;
    polylineCoordinatesListTowardsCustomer.clear();
    deliveryMarker = Set<Marker>();
    // technicianLocation = null;
    customerLocation = null;
    orderData = null;
    // clear route summary
    routeDurationText = null;
    routeDistanceText = null;
    notifyListeners();
  }
}
