import 'dart:developer';

import 'package:baligny/controller/services/directionServices/directionServices.dart';
import 'package:baligny/controller/services/locationServices/locationServices.dart';
import 'package:baligny/model/directionModel/directionModel.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TechnicianProvider extends ChangeNotifier {
  Position? currentPosition;
  late String apiKey;

  TechnicianProvider() {
    apiKey = dotenv.env['routesAPI'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint('Warning: routesAPI key not found in .env');
    }
  }

  // Google maps variables
  LatLng? technicianLocation;
  LatLng? customerLocation;
  ServiceOrderModel? orderData;
  double? technicianHeading; // newly tracked heading (degrees)
  double? technicianSpeed; // optional speed (m/s)
  DateTime?
  technicianLastUpdate; // time of the last received technician location update

  Set<Polyline> polylineSetTowardsCustomer = {};
  Polyline? polylineTowardsCustomer;
  List<LatLng> polylineCoordinatesListTowardsCustomer = [];

  // Marker
  Set<Marker> deliveryMarker = Set<Marker>();
  bool inDelivery = false;
  bool _isUpdatingMarker = false;

  // Latest computed route metadata (for UI display)
  String? routeDurationText; // e.g. "11 mins"
  int? routeDurationSeconds; // raw seconds
  String? routeDistanceText; // e.g. "2.1 km"

  // Throttle route recomputation
  DateTime? _lastRouteUpdateAt;
  LatLng? _lastRouteOrigin;
  static const Duration _routeMinInterval = Duration(seconds: 25);
  static const double _routeMinDisplacementMeters = 100; // 100m

  // Throttle marker churn on tiny movements
  LatLng? _lastMarkerPosition;
  static const double _markerMinDisplacementMeters =
      2; // lowered from 5m to 2m for smoother updates

  double _distanceMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  updateInDeliveryStatus(bool newStatus) {
    inDelivery = newStatus;
    notifyListeners();
  }

  updateOrderData(ServiceOrderModel data) {
    debugPrint("Updating orderData with: ");
    debugPrint(data.toString());
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

  // Update only technician location
  void setTechnicianLocation(LatLng technician) {
    technicianLocation = technician;
    debugPrint("Technician location updated: $technicianLocation");
    notifyListeners();
  }

  // Update technician pose (location + heading + speed)
  void updateTechnicianPose({
    required LatLng position,
    double? heading,
    double? speed,
    DateTime? lastUpdate,
  }) {
    technicianLocation = position;
    if (heading != null && !heading.isNaN) {
      technicianHeading = heading;
    }
    if (speed != null && !speed.isNaN) {
      technicianSpeed = speed;
    }
    // record last update time (if not provided, use now)
    technicianLastUpdate = lastUpdate ?? DateTime.now();
    notifyListeners();
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
      return;
    }

    // Save route metadata for UI
    routeDurationText = directionModel.durationInHour;
    routeDurationSeconds = directionModel.duration;
    routeDistanceText = directionModel.distanceInKM;

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

  updateMarker(BuildContext context) async {
    // Removed hard early return on !inDelivery so technician marker always updates
    if (_isUpdatingMarker) {
      debugPrint("Already updating marker, skipping duplicate call.");
      return;
    }

    _isUpdatingMarker = true;
    try {
      LatLng? currentTech = technicianLocation;
      if (currentTech == null) {
        try {
          Position? crrPosition = await LocationServices.getCurrentLocation();
          if (crrPosition != null) {
            currentTech = LatLng(crrPosition.latitude, crrPosition.longitude);
            technicianHeading ??= crrPosition.heading;
            technicianSpeed ??= crrPosition.speed;
          }
        } catch (e) {
          debugPrint('Failed to get current device location: $e');
        }
      }

      if (currentTech == null) {
        debugPrint(
          'Technician location still unknown; skipping marker update.',
        );
        return;
      }

      // Skip churn if technician barely moved
      if (_lastMarkerPosition != null) {
        final moved = _distanceMeters(currentTech, _lastMarkerPosition!);
        if (moved < _markerMinDisplacementMeters) {
          debugPrint(
            'Skipping marker update (< ${_markerMinDisplacementMeters}m movement).',
          );
          return;
        }
      }

      // Build markers
      final newMarkers = <Marker>{
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentTech,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          rotation: (technicianHeading ?? 0).clamp(0, 360).toDouble(),
          // Using flat marker allows rotation to represent heading
          flat: true,
          anchor: const Offset(0.5, 0.5),
        ),
      };

      LatLng? customerLatLng;
      if (orderData?.userAddress != null) {
        final custLat = orderData!.userAddress!.latitude;
        final custLng = orderData!.userAddress!.longitude;
        customerLatLng = LatLng(custLat, custLng);
        newMarkers.add(
          Marker(
            markerId: const MarkerId('destinationLocation'),
            position: customerLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }

      // Update stored locations
      if (customerLatLng != null) {
        updateLatLngs(currentTech, customerLatLng);
      } else {
        setTechnicianLocation(currentTech); // only technician for now
      }

      // Only compute / refresh route when we have destination AND are in delivery
      if (customerLatLng != null && inDelivery) {
        bool shouldUpdateRoute = false;
        final now = DateTime.now();
        if (_lastRouteUpdateAt == null || _lastRouteOrigin == null) {
          shouldUpdateRoute = true;
        } else {
          final elapsed = now.difference(_lastRouteUpdateAt!);
          final moved = _distanceMeters(currentTech, _lastRouteOrigin!);
          if (elapsed >= _routeMinInterval ||
              moved >= _routeMinDisplacementMeters) {
            shouldUpdateRoute = true;
          }
        }
        if (shouldUpdateRoute) {
          await fetchCrrLocationToCustomerPolyline(context);
          _lastRouteUpdateAt = now;
          _lastRouteOrigin = currentTech;
        } else {
          debugPrint('Skipping route recomputation (throttled).');
        }
      } else {
        // Clear route if we previously had one but no longer valid
        if (polylineSetTowardsCustomer.isNotEmpty && customerLatLng == null) {
          polylineSetTowardsCustomer.clear();
        }
      }

      deliveryMarker = newMarkers;
      _lastMarkerPosition = currentTech;
      notifyListeners();
      log('Markers Updated (count: ${deliveryMarker.length}).');
    } finally {
      _isUpdatingMarker = false;
    }
  }

  clearRouteData() {
    inDelivery = false;
    debugPrint("Clearing route data...");
    polylineSetTowardsCustomer.clear();
    polylineTowardsCustomer = null;
    polylineCoordinatesListTowardsCustomer.clear();
    deliveryMarker = Set<Marker>();
    customerLocation = null;
    orderData = null;
    _lastMarkerPosition = null;
    technicianHeading = null; // reset
    technicianSpeed = null; // reset
    technicianLastUpdate = null; // reset
    // Reset throttling state
    _lastRouteUpdateAt = null;
    _lastRouteOrigin = null;
    notifyListeners();
  }
}
