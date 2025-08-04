import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/APIsKeys/firebaseToken.dart';
import 'package:baligny/model/serviceOrderModel/serviceOrderModel.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class PushNotificationServices {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging() async {
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {}

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
  ) async {
    log(message.toMap().toString());
  }

  static Future getToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      if (token != null) {
        log('FCM token: $token');
        await firestore.collection('User').doc(auth.currentUser!.uid).update({
          'cloudMessagingToken': token,
        });
      } else {
        log('FCM token is null');
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  static subscribeToNotification() {
    firebaseMessaging.subscribeToTopic('USER');
  }

  //Firebase cloud messaging
  static initializeFCM() async {
    initializeFirebaseMessaging();
    getToken();
    subscribeToNotification();
  }

  static Future<void> sendNotificationToTechnicianByMajor({
    required ServiceOrderModel serviceOrderData,
  }) async {
    final major = serviceOrderData.servicedetail.major;
    final serviceTitle = serviceOrderData.servicedetail.name;
    final serviceDescription = serviceOrderData.servicedetail.detail;

    try {
      final techSnapshot = await FirebaseDatabase.instance
          .ref('Technician')
          .get();

      if (!techSnapshot.exists) {
        log('No technicians found in Firebase.');
        return;
      }

      final techMap = Map<String, dynamic>.from(
        techSnapshot.value as Map<dynamic, dynamic>,
      );

      final allTechnicians = techMap.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value);
        map['technicianID'] = entry.key;
        return TechnicianModel.fromMap(map);
      }).toList();

      final filteredTechnicians = allTechnicians.where((tech) {
        final techMajor = tech.major?.trim();
        return techMajor != null && techMajor == major.trim();
      }).toList();

      log('Found ${filteredTechnicians.length} matching technicians');

      if (filteredTechnicians.isEmpty) {
        log('No matching technicians to notify.');
        return;
      }

      final accessToken = await AccessTokenFirebase().getAccessToken();

      for (var technician in filteredTechnicians) {
        final token = technician.cloudMessagingToken;
        if (token != null && token.isNotEmpty) {
          final url = Uri.parse(
            'https://fcm.googleapis.com/v1/projects/baligny-6cec8/messages:send',
          );

          final message = {
            "message": {
              "token": token,
              "notification": {
                "title": "طلب جديد: $serviceTitle",
                "body": serviceDescription,
              },
              "data": {"serviceOrderID": serviceOrderData.orderID}
            },
          };

          final response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(message),
          );

          if (response.statusCode == 200) {
            log("Notification sent to ${technician.name}");
          } else {
            log("Failed to send to ${technician.name}: ${response.statusCode}");
            log(response.body);
          }
        }
      }
    } catch (e, stack) {
      log("Error sending technician notifications: $e\n$stack");
    }
  }
}
