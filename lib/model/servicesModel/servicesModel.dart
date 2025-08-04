import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String id;
  String name;
  String detail;
  String major;
  String type;
  int? quantity;
  DateTime? addedToCartAt;
  String? orderID;

  ServiceModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.major,
    required this.type,
    this.quantity,
    this.addedToCartAt,
    this.orderID,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'detail': detail,
    'major': major,
    'type': type,
    'quantity': quantity,
    'addedToCartAt': addedToCartAt?.toIso8601String(),
    'orderID': orderID,
  };

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
    id: map['id'],
    name: map['name'],
    detail: map['detail'],
    major: map['major'],
    type: map['type'],
    quantity: map['quantity'],
    addedToCartAt: map['addedToCartAt'] != null
        ? (map['addedToCartAt'] is Timestamp
              ? (map['addedToCartAt'] as Timestamp).toDate()
              : DateTime.parse(map['addedToCartAt']))
        : null,
    orderID: map['orderID'],
  );
}
