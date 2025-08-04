import 'package:baligny_technician/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  ServiceOrderModel? orderData;

  updateServiceOrderData(ServiceOrderModel data) {
    orderData = data;
    notifyListeners();
  }

  emptyOrderData() {
    orderData = null;
    notifyListeners();
  }
}
