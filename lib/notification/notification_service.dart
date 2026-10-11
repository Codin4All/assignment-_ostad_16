
import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static String? currentToken;

  static Future<void> initialize() async {
    if (!kIsWeb) return;

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      debugPrint('Notification permission denied.');
      return;
    }

    const vapidKey = 'PASTE_YOUR_WEB_PUSH_VAPID_KEY_HERE';

    if (!vapidKey.startsWith('PASTE_')) {
      try {
        currentToken = await messaging.getToken(
          vapidKey: vapidKey,
        );

        debugPrint('FCM Token: $currentToken');
      } catch (e) {
        debugPrint('FCM token error: $e');
      }
    } else {
      debugPrint('Add your Web Push VAPID key.');
    }

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          'New Task';

      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          'You have a task update.';

      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      }

      debugPrint('Foreground notification: $title');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification clicked: ${message.data}');
    });
  }
}