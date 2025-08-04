import 'package:baligny_technician/controller/services/APIsKeys/credential.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class APIs {  
  static String apiKey = dotenv.env['routesAPI']!;
  static directionAPI(LatLng start, LatLng end) =>
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$apiKey';
}
