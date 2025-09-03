import 'dart:convert';

import 'package:baligny/model/servicesModel/servicesModel.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:baligny/model/userAddressModel/userAddressModel.dart';
import 'package:baligny/model/userModel/userModel.dart';

class ServiceOrderModel {
  ServiceModel servicedetail;
  List<ServiceModel>? services;
  UserAddressModel? userAddress;
  UserModel? userData;
  TechnicianModel? technicianData;
  String? technicianUID;
  String? orderID;
  String? orderStatus;
  String? userUID;
  DateTime? orderPlacedAt;
  // New fields: optional problem description and attached image URLs
  String? problemDescription;
  List<String>? attachedImages;
  DateTime? orderDeliveredAt;
  int? serviceCharges;
  DateTime? addedToCartAt;

  ServiceOrderModel({
    required this.servicedetail,
    this.services,
    this.userAddress,
    this.userData,
    this.technicianData,
    this.technicianUID,
    this.orderID,
    this.orderStatus,
    this.userUID,
    this.orderPlacedAt,
    this.problemDescription,
    this.attachedImages,
    this.orderDeliveredAt,
    this.serviceCharges,
    this.addedToCartAt,
  });

  // Helper getters for (single service) + (multi service) structure
  ServiceModel get primaryService => (services != null && services!.isNotEmpty)
      ? services!.first
      : servicedetail;
  List<ServiceModel> get servicesOrPrimary =>
      (services != null && services!.isNotEmpty) ? services! : [servicedetail];
  List<ServiceModel> allServices() => servicesOrPrimary;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['servicedetail'] = servicedetail.toMap();

    if (services != null) {
      map['services'] = services!.map((s) => s.toMap()).toList();
    }
    if (userAddress != null) map['userAddress'] = userAddress!.toMap();
    if (userData != null) map['userData'] = userData!.toMap();
    if (technicianData != null) map['technicianData'] = technicianData!.toMap();

    map['technicianUID'] = technicianUID;
    map['orderID'] = orderID;
    map['orderStatus'] = orderStatus;
    if (problemDescription != null)
      map['problemDescription'] = problemDescription;
    if (attachedImages != null) map['attachedImages'] = attachedImages;
    map['orderPlacedAt'] = orderPlacedAt?.toIso8601String();
    map['orderDeliveredAt'] = orderDeliveredAt?.toIso8601String();
    map['serviceCharges'] = serviceCharges;
    map['addedToCartAt'] = addedToCartAt?.toIso8601String();
    map['userUID'] = userUID;

    return map;
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

    // Support legacy single service or new multi-service structure
    List<ServiceModel>? servicesList;
    ServiceModel primaryService;
    try {
      if (map['services'] != null) {
        servicesList = List<Map<String, dynamic>>.from(
          map['services'],
        ).map((m) => ServiceModel.fromMap(m)).toList();
        primaryService = servicesList.isNotEmpty
            ? servicesList.first
            : ServiceModel.fromMap(map['servicedetail']);
      } else {
        primaryService = ServiceModel.fromMap(map['servicedetail']);
      }
    } catch (e) {
      throw Exception('Service parsing error: $e');
    }

    final problemDesc = map['problemDescription']?.toString();
    List<String>? attached;
    try {
      if (map['attachedImages'] != null) {
        attached = List<String>.from(map['attachedImages']);
      }
    } catch (_) {}

    return ServiceOrderModel(
      servicedetail: primaryService,
      services: servicesList,
      userAddress: UserAddressModel.fromMap(map['userAddress']),
      userData: UserModel.fromMap(map['userData']),
      technicianData: map['technicianData'] != null
          ? TechnicianModel.fromMap(map['technicianData'])
          : null,
      technicianUID: map['technicianUID'] as String?,
      orderID: map['orderID']?.toString() ?? '',
      orderStatus: map['orderStatus']?.toString() ?? '',
      userUID: map['userUID']?.toString() ?? '',
      orderPlacedAt: DateTime.parse(map['orderPlacedAt']),
      problemDescription: problemDesc,
      attachedImages: attached,
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
