// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/pushNotificationServices/pushNotificationDialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationServices {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging(BuildContext context) async {
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log(message.toMap().toString());
        /* log('The message data is:');
        log(message.data.toString()); */
        firebaseMessagingForegroundHandler(message, context);
      }
    });
  }

  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print(message);
  }

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
    BuildContext context,
  ) async {
    log('The message data is:');
    log("Foreground Notification Received: ${message.notification?.title}");
    log(message.data.toString());
    log(message.data['serviceOrderID']);
    PushNotificationDialogue.serviceRequestDialogue(message.data['serviceOrderID'], context);
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
  static initializeFCM(BuildContext context) {
    initializeFirebaseMessaging(context);
    getToken();
    subscribeToNotification();
  }
}
