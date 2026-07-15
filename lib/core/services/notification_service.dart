import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase (wrapped in try-catch to prevent crash if google-services.json is missing)
      await Firebase.initializeApp();
      
      final messaging = FirebaseMessaging.instance;

      // Request notification permission
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('User granted permission: ${settings.authorizationStatus}');

      // Enable foreground notification banners (so user receives notification when app is open)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Fetch FCM Token (useful for server target messaging)
      final token = await messaging.getToken();
      developer.log("FCM Registration Token: $token");

      // Handle background message handling
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Received foreground message: ${message.notification?.title}');
        // Here, in production, we could display a local in-app alert or banner
      });

      // Handle notification clicks when the app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('Notification clicked: ${message.data}');
      });

      _initialized = true;
    } catch (e) {
      developer.log('Firebase Cloud Messaging failed to initialize: $e');
      // Gracefully continue so application launches even without Firebase configs configured yet
    }
  }

  // Static background message handler required by FCM
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Make sure firebase is initialized in the background isolates
    await Firebase.initializeApp();
    developer.log("Handling background message: ${message.messageId}");
  }
}
