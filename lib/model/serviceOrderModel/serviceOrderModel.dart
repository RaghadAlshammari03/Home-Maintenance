import 'dart:convert';

import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';
import 'package:baligny/model/userModel/userModel.dart';

class Serviceordermodel {
  ServiceModel servicedetail;
  UserAddressModel userAddress;
  UserModel userData;
  TechnicianModel? technicianData;
  String orderID;
  String orderStatus;
  DateTime orderPlacedAt;
  DateTime? orderDeliveredAt;
  int deliveryCharges;
  String userUID;
  DateTime? addedTocartAt;

  Serviceordermodel({
    required this.servicedetail,
    required this.userAddress,
    required this.userData,
    this.technicianData,
    required this.orderID,
    required this.orderStatus,
    required this.orderPlacedAt,
    this.orderDeliveredAt,
    required this.deliveryCharges,
    required this.userUID,
    this.addedTocartAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'servicedetail': servicedetail.toMap(),
      'userAddress': userAddress.toMap(),
      'userData': userData.toMap(),
      'technicianData': technicianData?.toMap(),
      'orderID': orderID,
      'orderStatus': orderStatus,
      'orderPlacedAt': orderPlacedAt.millisecondsSinceEpoch,
      'orderDeliveredAt': orderDeliveredAt?.millisecondsSinceEpoch,
      'deliveryCharges': deliveryCharges,
      'userUID': userUID,
      'addedTocartAt': addedTocartAt?.millisecondsSinceEpoch,
    };
  }

  factory Serviceordermodel.fromMap(Map<String, dynamic> map) {
    if (map['userAddress'] == null ||
        map['userData'] == null ||
        map['orderID'] == null ||
        map['orderStatus'] == null ||
        map['orderPlacedAt'] == null ||
        map['userUID'] == null) {
      throw Exception('Missing required fields in Serviceordermodel');
    }

    return Serviceordermodel(
      servicedetail: ServiceModel.fromMap(map['servicedetail']),
      userAddress: UserAddressModel.fromMap(map['userAddress']),
      userData: UserModel.fromMap(map['userData']),
      technicianData: map['technicianData'] != null
          ? TechnicianModel.fromMap(map['technicianData'])
          : null,
      orderID: map['orderID'] as String,
      orderStatus: map['orderStatus'] as String,
      orderPlacedAt: DateTime.fromMillisecondsSinceEpoch(map['orderPlacedAt']),
      orderDeliveredAt: map['orderDeliveredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['orderDeliveredAt'])
          : null,
      deliveryCharges: map['deliveryCharges'] as int,
      userUID: map['userUID'] as String,
      addedTocartAt: map['addedTocartAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedTocartAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Serviceordermodel.fromJson(String source) =>
      Serviceordermodel.fromMap(json.decode(source));
}
