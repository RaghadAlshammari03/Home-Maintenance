import 'package:flutter/material.dart'; 
import 'package:baligny/controller/services/userDataCRUDServices/userDataCRUDServices.dart';
import 'package:baligny/model/userAddressModel.dart';

class ProfileProvider extends ChangeNotifier {
  List<UserAddressModel> addresses = [];

  fetchUserAddress() async {
    addresses = await UserDataCRUDServices.fetchAddresses();
    notifyListeners();
  }
}
