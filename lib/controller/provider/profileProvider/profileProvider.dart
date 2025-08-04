import 'dart:developer';

import 'package:baligny/model/userModel/userModel.dart';
import 'package:flutter/material.dart';
import 'package:baligny/controller/services/userDataCRUDServices/userDataCRUDServices.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';

class ProfileProvider extends ChangeNotifier {
  List<UserAddressModel> addresses = [];
  UserAddressModel? activeAddress;
  UserModel? userData;

  fetchUserAddress() async {
    addresses = await UserDataCRUDServices.fetchAddresses();
    for (var address in addresses) {
      if (address.isActive) {
        activeAddress = address;
      }
    }
    notifyListeners();
    log(activeAddress!.toMap().toString());
  }

  fetchUserData() async {
    userData = await UserDataCRUDServices.fetchUserData();
    notifyListeners();
    log(userData!.toMap().toString());
  }
}
