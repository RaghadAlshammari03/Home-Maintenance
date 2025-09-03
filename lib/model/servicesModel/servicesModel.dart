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
    // Handle both 'id' and 'serviceID' for backward compatibility
    final serviceID = map['serviceID'] ?? map['id'];
    if (serviceID == null) {
      throw Exception('Missing required field: serviceID or id');
    }
    if (map['name'] == null) {
      throw Exception('Missing required field: name');
    }
    if (map['detail'] == null) {
      throw Exception('Missing required field: detail');
    }
    if (map['major'] == null) {
      throw Exception('Missing required field: major');
    }
    if (map['type'] == null) {
      throw Exception('Missing required field: type');
    }

    return ServiceModel(
      serviceID: serviceID as String,
      name: map['name'] as String,
      detail: map['detail'] as String,
      major: map['major'] as String,
      type: map['type'] as String,
      quantity: map['quantity'] != null ? map['quantity'] as int : null,
      addedToCartAt: map['addedToCartAt'] != null
          ? (map['addedToCartAt'] is Timestamp
                ? (map['addedToCartAt'] as Timestamp).toDate()
                : (map['addedToCartAt'] is String
                      ? DateTime.tryParse(map['addedToCartAt'])
                      : null))
          : null,
      orderID: map['orderID'] != null ? map['orderID'] as String : null,
    );
  }
}
