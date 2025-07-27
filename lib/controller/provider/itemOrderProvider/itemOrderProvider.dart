import 'package:baligny/controller/services/serviceOrderServices/serviceOrderServices.dart';
import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:flutter/material.dart';

class ItemOrderProvider extends ChangeNotifier {
  List<ServiceModel> cartItems = [];

  fetchCartItems() async {
    cartItems = await ServiceOrderServices.fetchCartData();
    notifyListeners();
  }
}
