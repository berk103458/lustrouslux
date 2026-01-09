import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init(String? uid) async {
    // 1. Request Permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Local Notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // 3. Get Token & Save
    if (uid != null) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(uid, token);
      }
      
      // Listen for Token Refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _saveToken(uid, newToken);
      });
    }

    // 4. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showVipNotification(
          title: notification.title ?? 'New Message',
          body: notification.body ?? '',
        );
      }
    });
  }

  Future<void> showVipNotification({required String title, required String body}) async {
    final androidDetails = AndroidNotificationDetails(
      'lustrous_channel', // id
      'Lustrous Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFD4AF37), // Lustrous Gold
    );
    final details = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  Future<void> _saveToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }
}
