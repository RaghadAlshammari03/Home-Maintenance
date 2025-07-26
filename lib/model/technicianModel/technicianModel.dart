import 'dart:convert';

class TechnicianModel {
  String? name;
  String? mobileNumber;
  String? technicianID;
  String? activeDeliveryRequestID;
  String? technicianStatus;
  String? cloudMessagingToken;
  String? major; 

  TechnicianModel({
    this.name,
    this.mobileNumber,
    this.technicianID,
    this.activeDeliveryRequestID,
    this.technicianStatus,
    this.cloudMessagingToken,
    this.major,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'mobileNumber': mobileNumber,
      'technicianID': technicianID,
      'activeDeliveryRequestID': activeDeliveryRequestID,
      'technicianStatus': technicianStatus,
      'cloudMessagingToken': cloudMessagingToken,
      'major': major,
    };
  }

  factory TechnicianModel.fromMap(Map<String, dynamic> map) {
    return TechnicianModel(
      name: map['name'] != null ? map['name'] as String : null,
      mobileNumber:
          map['mobileNumber'] != null ? map['mobileNumber'] as String : null,
      technicianID: map['technicianID'] != null ? map['technicianID'] as String : null,
      activeDeliveryRequestID: map['activeDeliveryRequestID'] != null
          ? map['activeDeliveryRequestID'] as String
          : null,
      technicianStatus:
          map['technicianStatus'] != null ? map['technicianStatus'] as String : null,
      cloudMessagingToken: map['cloudMessagingToken'] != null
          ? map['cloudMessagingToken'] as String
          : null,
      major: map['major'] != null
          ? map['major'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TechnicianModel.fromJson(String source) =>
      TechnicianModel.fromMap(json.decode(source) as Map<String, dynamic>);
}