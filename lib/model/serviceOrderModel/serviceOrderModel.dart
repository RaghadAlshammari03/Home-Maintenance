import 'dart:convert';

import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';
import 'package:baligny/model/userModel/userModel.dart';

class ServiceOrderModel {
  ServiceModel servicedetail;
  UserAddressModel? userAddress;
  UserModel? userData;
  TechnicianModel? technicianData;
  String? technicianUID;
  String? orderID;
  String? orderStatus;
  String? userUID;
  DateTime? orderPlacedAt;
  DateTime? orderDeliveredAt;
  int? serviceCharges;
  DateTime? addedToCartAt;

  ServiceOrderModel({
    required this.servicedetail,
    this.userAddress,
    this.userData,
    this.technicianData,
    this.technicianUID,
    this.orderID,
    this.orderStatus,
    this.userUID,
    this.orderPlacedAt,
    this.orderDeliveredAt,
    this.serviceCharges,
    this.addedToCartAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'servicedetail': servicedetail.toMap(),
      'userAddress': userAddress?.toMap(),
      'userData': userData?.toMap(),
      'technicianData': technicianData?.toMap(),
      'technicianUID': technicianUID,
      'orderID': orderID,
      'orderStatus': orderStatus,
      'orderPlacedAt': orderPlacedAt?.toIso8601String(),
      'orderDeliveredAt': orderDeliveredAt?.toIso8601String(),
      'serviceCharges': serviceCharges,
      'addedToCartAt': addedToCartAt?.toIso8601String(),
      'userUID': userUID,
    };
  }

  factory ServiceOrderModel.fromMap(Map<String, dynamic> map) {
    if (map['userAddress'] == null ||
        map['userData'] == null ||
        map['orderID'] == null ||
        map['orderStatus'] == null ||
        map['userUID'] == null ||
        map['orderPlacedAt'] == null) {
      throw Exception('Missing required fields in Serviceordermodel');
    }

    return ServiceOrderModel(
      servicedetail: ServiceModel.fromMap(map['servicedetail']),
      userAddress: UserAddressModel.fromMap(map['userAddress']),
      userData: UserModel.fromMap(map['userData']),
      technicianData: map['technicianData'] != null
          ? TechnicianModel.fromMap(map['technicianData'])
          : null,
      technicianUID: map['technicianUID'] as String?,
      orderID: map['orderID'] as String,
      orderStatus: map['orderStatus'] as String,
      userUID: map['userUID'] as String,
      orderPlacedAt: DateTime.parse(map['orderPlacedAt']),
      orderDeliveredAt: map['orderDeliveredAt'] != null
          ? DateTime.parse(map['orderDeliveredAt'])
          : null,
      serviceCharges: map['serviceCharges'] as int?,

      addedToCartAt: map['addedToCartAt'] != null
          ? DateTime.parse(map['addedToCartAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceOrderModel.fromJson(String source) =>
      ServiceOrderModel.fromMap(json.decode(source));
}
