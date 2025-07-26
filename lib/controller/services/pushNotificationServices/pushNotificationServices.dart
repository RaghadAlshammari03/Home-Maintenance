import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationServices {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging() async {
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print(message);
  }

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
  ) async {
    print(message);
    log("Foreground Notification Received: ${message.notification?.title}");
  }

  static Future getToken() async {
    String? token = await firebaseMessaging.getToken();
    log('FCM token: $token');
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(
      'Technician/${auth.currentUser!.uid}/cloudMessagingToken',
    );
    databaseReference.set(token);
  }

  static subscribeToNotification() {
    firebaseMessaging.subscribeToTopic('TECHNICIAN');
  }

  //Firebase cloud messaging
  static initializeFCM() {
    initializeFirebaseMessaging();
    getToken();
    subscribeToNotification();
  }
}
