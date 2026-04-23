import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _listenersAttached = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ollie_high_importance',
    'Ollie Notifications',
    description: 'Notifications for Ollie app updates and reminders',
    importance: Importance.high,
  );

  void _logFcm(String message, {RemoteMessage? remoteMessage}) {
    if (remoteMessage == null) {
      debugPrint('[FCM] $message');
      return;
    }

    final notification = remoteMessage.notification;
    debugPrint(
      '[FCM] $message | '
      'id=${remoteMessage.messageId ?? "null"} | '
      'title=${notification?.title ?? remoteMessage.data['title']?.toString() ?? "null"} | '
      'body=${notification?.body ?? remoteMessage.data['body']?.toString() ?? "null"} | '
      'data=${remoteMessage.data}',
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(initSettings);

    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'Ollie';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';

    _logFcm('Showing local notification', remoteMessage: message);

    const androidDetails = AndroidNotificationDetails(
      'ollie_high_importance',
      'Ollie Notifications',
      channelDescription: 'Notifications for Ollie app updates and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(message.hashCode, title, body, notificationDetails, payload: message.data.toString());
  }

  Future<void> showIncomingNotification(RemoteMessage message) async {
    await _showLocalNotification(message);
  }

  void _attachFirebaseListeners() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    FirebaseMessaging.onMessage.listen((message) {
      _logFcm('Foreground message received', remoteMessage: message);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logFcm('Notification tapped', remoteMessage: message);
    });
  }

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await _initLocalNotifications();
      _attachFirebaseListeners();
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      final settings = await messaging.getNotificationSettings();
      debugPrint('[FCM] iOS authorization status: ${settings.authorizationStatus}');
      final apnsToken = await messaging.getAPNSToken();
      debugPrint('[FCM] APNs token: ${apnsToken ?? "null"}');

      final token = await messaging.getToken();
      debugPrint('[FCM] Firebase initialized successfully');
      debugPrint('[FCM] Token: ${token ?? "null"}');
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: 'fcmToken', value: token);
      } else {
        debugPrint('[FCM] Token is empty or null');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Token refreshed');
        debugPrint('[FCM] New token: $newToken');
        await _storage.write(key: 'fcmToken', value: newToken);
      });

      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('[FCM] Firebase init failed: $e');
      return false;
    }
  }

  Future<String> getDeviceToken() async {
    final cachedToken = await _storage.read(key: 'fcmToken');
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return cachedToken;
    }

    final initialized = await initialize();
    if (!initialized) {
      return '';
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: 'fcmToken', value: token);
      return token;
    }

    return '';
  }
}
