import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:baligny/controller/services/APIsKeys/APIs.dart';
import 'package:baligny/model/directionModel/directionModel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionServices {
  static Future<DirectionModel?> getDirectionDetails(
    LatLng from,
    LatLng to,
    BuildContext context,
  ) async {
    final apiUrl = Uri.parse(APIs.directionAPI(from, to));
    try {
      log("Fetching directions from ${from.latitude},${from.longitude} to ${to.latitude},${to.longitude}");
      var response = await http.get(apiUrl, headers: {'Content-Type': 'application/json'}).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['routes'].isEmpty) {
          log("No routes found.");
          return null;
        }
        var leg = data['routes'][0]['legs'][0];
        DirectionModel direction = DirectionModel(
          distanceInKM: leg['distance']['text'],
          distanceInMeter: leg['distance']['value'],
          durationInHour: leg['duration']['text'],
          duration: leg['duration']['value'],
          polylinePoints: data['routes'][0]['overview_polyline']['points'],
        );
        return direction;
      } else {
        log("Failed to fetch directions: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error fetching directions: $e");
      return null;
    }
  }
}
