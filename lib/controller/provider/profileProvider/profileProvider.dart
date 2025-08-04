import 'package:baligny_technician/controller/services/ProfileServices/profileServices.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  TechnicianModel? technicianProfile;

  updateTechnicianProfile() async {
    technicianProfile = await ProfileServices.getTechnicianProfileData();
    notifyListeners();
  }
}
