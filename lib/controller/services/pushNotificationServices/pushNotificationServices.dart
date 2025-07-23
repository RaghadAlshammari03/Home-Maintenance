import 'dart:developer';
import 'package:baligny/constant/constant.dart';
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
  ) async {}

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
  ) async {}

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
}
