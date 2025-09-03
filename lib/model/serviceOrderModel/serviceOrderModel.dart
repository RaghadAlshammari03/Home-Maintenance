import 'dart:convert';

import 'package:baligny_technician/model/servicesModel/servicesModel.dart';
import 'package:baligny_technician/model/technicianModel/technicianModel.dart';
import 'package:baligny_technician/model/userAddressModel/userAddressModel.dart';
import 'package:baligny_technician/model/userModel/userModel.dart';

class ServiceOrderModel {
  ServiceModel servicedetail;
  // support multiple services
  List<ServiceModel>? services;
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

  // New optional fields from user app
  String? problemDescription;
  List<String>? attachedImages;

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
    this.orderDeliveredAt,
    this.serviceCharges,
    this.addedToCartAt,
    this.problemDescription,
    this.attachedImages,
  });

  // Helper getters to treat single-service and multi-service uniformly
  List<ServiceModel> get servicesOrPrimary {
    if (services != null && services!.isNotEmpty) return services!;
    return [servicedetail];
  }

  ServiceModel get primaryService => servicesOrPrimary.first;

  Map<String, dynamic> toMap() {
    return {
      'servicedetail': servicedetail.toMap(),
      'services': services != null
          ? services!.map((s) => s.toMap()).toList()
          : null,
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
      'problemDescription': problemDescription,
      'attachedImages': attachedImages,
    };
  }

  factory ServiceOrderModel.fromMap(Map<String, dynamic> map) {
    final missingFields = [];

    if (map['servicedetail'] == null && map['services'] == null)
      missingFields.add('servicedetail/services');
    if (map['userAddress'] == null) missingFields.add('userAddress');
    if (map['userData'] == null) missingFields.add('userData');
    if (map['orderID'] == null) missingFields.add('orderID');
    if (map['orderStatus'] == null) missingFields.add('orderStatus');
    if (map['userUID'] == null) missingFields.add('userUID');
    if (map['orderPlacedAt'] == null) missingFields.add('orderPlacedAt');

    if (missingFields.isNotEmpty) {
      throw Exception(
        'Missing required fields in ServiceOrderModel: ${missingFields.join(", ")}\n${jsonEncode(map)}',
      );
    }

    // Parse services list if present (backwards compatible)
    List<ServiceModel>? parsedServices;
    ServiceModel primary;
    try {
      if (map['services'] != null) {
        final rawList = map['services'];
        if (rawList is List) {
          parsedServices = rawList
              .where((e) => e != null)
              .map((e) => ServiceModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      if (parsedServices != null && parsedServices.isNotEmpty) {
        primary = parsedServices.first;
      } else {
        primary = ServiceModel.fromMap(
          Map<String, dynamic>.from(map['servicedetail']),
        );
      }
    } catch (e) {
      throw Exception('Service parsing error: $e');
    }

    // Parse optional attachedImages safely
    List<String>? attached;
    try {
      if (map['attachedImages'] != null) {
        final raw = map['attachedImages'];
        if (raw is List) {
          attached = raw
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      attached = null;
    }

    return ServiceOrderModel(
      servicedetail: primary,
      services: parsedServices,
      userAddress: UserAddressModel.fromMap(
        Map<String, dynamic>.from(map['userAddress']),
      ),
      userData: UserModel.fromMap(Map<String, dynamic>.from(map['userData'])),
      technicianData: map['technicianData'] != null
          ? TechnicianModel.fromMap(
              Map<String, dynamic>.from(map['technicianData']),
            )
          : null,
      technicianUID: map['technicianUID']?.toString(),
      orderID: map['orderID']?.toString(),
      orderStatus: map['orderStatus']?.toString(),
      userUID: map['userUID']?.toString(),
      orderPlacedAt: map['orderPlacedAt'] != null
          ? DateTime.tryParse(map['orderPlacedAt'].toString())
          : null,
      orderDeliveredAt: map['orderDeliveredAt'] != null
          ? DateTime.tryParse(map['orderDeliveredAt'].toString())
          : null,
      serviceCharges: map['serviceCharges'] is int
          ? map['serviceCharges']
          : int.tryParse(map['serviceCharges']?.toString() ?? ''),
      addedToCartAt: map['addedToCartAt'] != null
          ? DateTime.tryParse(map['addedToCartAt'].toString())
          : null,
      problemDescription: map['problemDescription']?.toString(),
      attachedImages: attached,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceOrderModel.fromJson(String source) =>
      ServiceOrderModel.fromMap(json.decode(source));
}
