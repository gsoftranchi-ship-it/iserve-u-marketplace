import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    const AndroidInitializationSettings
    androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
    settings =
    InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
    );

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token =
    await _messaging.getToken();

    if (kDebugMode) {
      debugPrint('FCM TOKEN = $token');
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'fcmToken': token,
        },
        SetOptions(
          merge: true,
        ),
      );


      if (kDebugMode) {
        debugPrint('FCM TOKEN = $token');
      }
    }

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {

        await _localNotifications.show(
          0,

          message.notification?.title ??
              'iServe-U',

          message.notification?.body ??
              '',

          const NotificationDetails(

            android:
            AndroidNotificationDetails(

              'high_importance_channel',

              'High Importance Notifications',

              importance:
              Importance.max,

              priority:
              Priority.high,

              playSound: true,
            ),
          ),
        );
      },
    );
  }
}