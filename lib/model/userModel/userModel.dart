import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String userID;
  String? cloudMessagingToken;
  UserModel({
    required this.userID,
    this.cloudMessagingToken,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'cloudMessagingToken': cloudMessagingToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] as String,
      cloudMessagingToken: map['cloudMessagingToken'] != null ? map['cloudMessagingToken'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}