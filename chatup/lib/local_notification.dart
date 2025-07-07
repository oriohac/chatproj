import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  // Instance of Flutternotification plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async{
    // Initialization  setting for android
    const InitializationSettings initializationSettingsAndroid =
        InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic'),
          iOS: DarwinInitializationSettings(),
        );
    await _notificationsPlugin.initialize(
      initializationSettingsAndroid,
      // to handle event when we receive notification
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {
           debugPrint('Notification payload: ${details.payload}');
        }
      },
    );
        // Create a notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'messages_channel', // Same as in your RemoteMessage
      'Messages Channel',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('default'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  

  static Future<void> display(RemoteMessage message) async {
    // To display the notification in device
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "chatup_channel",
          "ChatUp Messages",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          color: Colors.green
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _notificationsPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
