import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Stream controller to notify the UI when a new order or cancellation FCM notification arrives
  static final StreamController<Map<String, dynamic>> _notificationStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;

  // Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other services inside the background handler, ensure Firebase is initialized first
    await Firebase.initializeApp();
    if (kDebugMode) {
      print("Handling background message: ${message.messageId}");
      print("Payload: ${message.data}");
    }
    _notificationStreamController.add(message.data);
  }

  // Initialize Firebase and FCM
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      
      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print("FCM Registration Token: $token");
      }

      // Handle token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print("FCM Token refreshed: $newToken");
        }
        // Here you would upload the new token to Laravel REST API
      });

      // Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Received foreground message: ${message.notification?.title}");
          print("Payload: ${message.data}");
        }
        
        // Pass payload to stream for app-wide reactive state updates (e.g. refreshing order dashboard)
        _notificationStreamController.add(message.data);
      });

      // Handle message clicks when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("App opened via notification: ${message.data}");
        }
        _notificationStreamController.add(message.data);
      });

    } catch (e) {
      if (kDebugMode) {
        print("Firebase/FCM initialization skipped or failed: $e");
        print("This is normal if google-services.json / GoogleService-Info.plist are not yet added to the native folders.");
      }
    }
  }

  // Retrieve current token
  static Future<String?> getFcmToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (_) {
      return null;
    }
  }
}
