import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/models.dart';
import 'services.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void registerNotification(BuildContext context) async {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification =
            PushNotification.fromRemoteMessage(message);

        if (notification != null) {
          // For displaying the notification as an overlay
          UIServices().showPopUpPushNotification(notification, context);
        } else {}
      });
    } else {}
  }

  checkForInitialMessage(BuildContext context) async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification =
          PushNotification.fromRemoteMessage(initialMessage);

      UIServices().showPopUpPushNotification(notification, context);
    } else {}
  }

  onMessageAppListen(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification =
          PushNotification.fromRemoteMessage(message);

      StorageServices().handleClick(
        notification.thingType,
        notification.thingID,
        context,
      );
    });
  }
}
