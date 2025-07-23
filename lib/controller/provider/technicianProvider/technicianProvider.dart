import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TechnicianProvider extends ChangeNotifier {
  Position? currentPosition;

  updateCurrentPosition(Position crrPosition) {
    currentPosition = crrPosition;
    notifyListeners();
  }
}
