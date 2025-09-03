import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String? serviceID;
  String? name;
  String? detail;
  String? major;
  String? type;
  int? quantity;
  DateTime? addedToCartAt;
  String? orderID;

  ServiceModel({
    required this.serviceID,
    required this.name,
    required this.detail,
    required this.major,
    required this.type,
    this.quantity,
    this.addedToCartAt,
    this.orderID,
  });

  Map<String, dynamic> toMap() => {
    'serviceID': serviceID,
    'name': name,
    'detail': detail,
    'major': major,
    'type': type,
    'quantity': quantity,
    'addedToCartAt': addedToCartAt?.toIso8601String(),
    'orderID': orderID,
  };

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    if (map['serviceID'] == null ||
        map['name'] == null ||
        map['detail'] == null ||
        map['major'] == null ||
        map['type'] == null) {
      throw Exception('Missing required ServiceModel field');
    }

    return ServiceModel(
      serviceID: map['serviceID'] as String,
      name: map['name'] as String,
      detail: map['detail'] as String,
      major: map['major'] as String,
      type: map['type'] as String,
      quantity: map['quantity'],
      addedToCartAt: map['addedToCartAt'] != null
          ? (map['addedToCartAt'] is Timestamp
                ? (map['addedToCartAt'] as Timestamp).toDate()
                : DateTime.parse(map['addedToCartAt']))
          : null,
      orderID: map['orderID'],
    );
  }
}
