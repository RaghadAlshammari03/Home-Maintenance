import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String userID;
  String? cloudMessagingToken;
  String? mobileNumber;
  UserModel({
    required this.userID,
    this.cloudMessagingToken,
    this.mobileNumber,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'cloudMessagingToken': cloudMessagingToken,
      'mobileNumber': mobileNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] as String,
      cloudMessagingToken: map['cloudMessagingToken'] != null
          ? map['cloudMessagingToken'] as String
          : null,
      mobileNumber: map['mobileNumber'] != null
          ? map['mobileNumber'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
