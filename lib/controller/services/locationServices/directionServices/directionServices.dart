import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:baligny_technician/controller/services/APIsKeys/APIs.dart';
import 'package:baligny_technician/model/directionModel/directionModel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionServices {
  static Future getDirectionDetails(
    LatLng pickupLocation,
    LatLng dropLocation,
    BuildContext context,
  ) async {
    final api = Uri.parse(APIs.directionAPI(pickupLocation, dropLocation));
    try {
      log("GETTING DIRECTIONS from: ${pickupLocation.latitude},${pickupLocation.longitude} to: ${dropLocation.latitude},${dropLocation.longitude}");
      var response = await http
          .get(api, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Connection Timed Out');
            },
          )
          .onError((error, stackTrace) {
            log(error.toString());
            throw Exception(error);
          });
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        log(decodedResponse.toString());
        if (decodedResponse['routes'].isEmpty) {
          print("❗ No routes found between these coordinates.");
          return null;
        }
        DirectionModel directionModel = DirectionModel(
          distanceInKM:
              decodedResponse['routes'][0]['legs'][0]['distance']['text'],
          distanceInMeter:
              decodedResponse['routes'][0]['legs'][0]['distance']['value'],
          durationInHour:
              decodedResponse['routes'][0]['legs'][0]['duration']['text'],
          duration:
              decodedResponse['routes'][0]['legs'][0]['duration']['value'],
          polylinePoints:
              decodedResponse['routes'][0]['overview_polyline']['points'],
        );
        log(directionModel.toMap().toString());
        return directionModel;
      } 
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
