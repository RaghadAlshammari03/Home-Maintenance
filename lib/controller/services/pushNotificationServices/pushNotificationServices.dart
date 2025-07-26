import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/APIsKeys/firebaseToken.dart';
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

  Future<void> sendNotificationToTechnician({
    required String technicianToken,
    required String serviceTitle,
    required String serviceDescription,
  }) async {
    final accessToken = await AccessTokenFirebase().getAccessToken();

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/baligny-6cec8/messages:send',
    );

    final message = {
      "message": {
        "token": technicianToken,
        "notification": {
          "title": "طلب جديد: $serviceTitle",
          "body": serviceDescription,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "type": "technician_request",
        },
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
      print("✅ Notification sent successfully");
    } else {
      print("❌ Notification failed: ${response.statusCode}");
      print(response.body);
    }
  }
}
