import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:baligny/constant/constant.dart';
import 'package:baligny/controller/services/APIsKeys/APIs.dart';
import 'package:baligny/controller/services/APIsKeys/keys.dart';
import 'package:baligny/model/technicianModel/technicianModel.dart';
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
    String? token = await firebaseMessaging.getToken();
    log('FCM token: $token');
    await firestore.collection('User').doc(auth.currentUser!.uid).update({
      'cloudMessagingToken': token,
    });
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

  static sendPushNotificationToTechnician(
    List<TechnicianModel> technician,
    String service,
  ) async {
    for (var technician in technician) {
      try {
        final api = Uri.parse(APIs.pushNotificationAPI());
        var body = jsonEncode({
          "to": technician.cloudMessagingToken,
          "notification": {
            "body": "New Service Request",
            "title": "Service Request",
          },
        });
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'key=$fcmServerKey',
        };
        var response = await http
            .post(api, headers: headers, body: body)
            .then((value) {
              log('Successfully Send the Push Notification');
            })
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                log('Connection Timed out');
                throw TimeoutException('Connection Timed out');
              },
            )
            .onError((error, stackTrace) {
              log(error.toString());
              throw Exception(error);
            });
      } catch (error) {
        log(error.toString());
        throw Exception(error);
      }
    }
  }
}
