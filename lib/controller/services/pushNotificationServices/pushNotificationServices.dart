// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:baligny_technician/constants/constant.dart';
import 'package:baligny_technician/controller/services/pushNotificationServices/pushNotificationDialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:baligny_technician/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Must re-initialize Firebase in background isolate
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // already initialized
  }
  log('[BG] FCM message: ${message.messageId} data=${message.data}');
}

class PushNotificationServices {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseMessaging(BuildContext context) async {
    await firebaseMessaging.requestPermission();

    // Ensure iOS displays notifications when app is foreground (no-op on Android)
    try {
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    // Background handler (top-level)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log('[FG] FCM notification received');
        _handleForeground(message, context);
      } else {
        log('[FG] FCM data-only message: ${message.data}');
        _handleForeground(message, context);
      }
    });

    // App opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('[TAP] onMessageOpenedApp messageId=${message.messageId}');
      _handleNotificationTap(message, context);
    });

    // App launched (terminated) via notification tap
    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log('[LAUNCH] getInitialMessage messageId=${initialMessage.messageId}');
      // Delay to ensure first frame & providers ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage, context);
      });
    }
  }

  static void _handleForeground(RemoteMessage message, BuildContext context) {
    log('The message data is:');
    log(message.data.toString());
    final orderID = message.data['serviceOrderID'];
    if (orderID == null) {
      log('No serviceOrderID in foreground message; skipping dialog');
      return;
    }
    // Show dialog immediately (foreground). Attempt multiple context fallbacks and retry briefly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Helper to resolve a usable BuildContext
      BuildContext? resolveContext() {
        return navigatorKey.currentContext ??
            context ??
            navigatorKey.currentState?.overlay?.context;
      }

      final ctx = resolveContext();
      if (ctx != null) {
        PushNotificationDialogue.serviceRequestDialogue(orderID, ctx);
        return;
      }

      // If context not ready (rare during cold start), retry a few times with short delay
      int attempts = 0;
      const maxAttempts = 10;
      final timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
        attempts++;
        final ctx2 = resolveContext();
        if (ctx2 != null) {
          PushNotificationDialogue.serviceRequestDialogue(orderID, ctx2);
          t.cancel();
        } else if (attempts >= maxAttempts) {
          t.cancel();
          log(
            'Could not obtain context to show notification dialog for order $orderID after retries',
          );
        }
      });
      // Note: timer will auto-cancel after success or max attempts
    });
  }

  static void _handleNotificationTap(
    RemoteMessage message,
    BuildContext context,
  ) {
    final orderID = message.data['serviceOrderID'];
    log('Notification tap with orderID=$orderID');
    if (orderID == null) return;
    // Use a post-frame to ensure context is ready (after navigation stack restored)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext ?? context;
      if (ctx != null) {
        PushNotificationDialogue.serviceRequestDialogue(orderID, ctx);
      } else {
        log(
          'No valid context available to show notification dialog for tapped order $orderID',
        );
      }
    });
  }

  static Future<void> firebaseMessagingForegroundHandler(
    RemoteMessage message,
    BuildContext context,
  ) async {
    // Deprecated in favor of _handleForeground
    _handleForeground(message, context);
  }

  static Future getToken() async {
    String? token = await firebaseMessaging.getToken();
    log('FCM token: $token');
    if (auth.currentUser == null) return;
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
