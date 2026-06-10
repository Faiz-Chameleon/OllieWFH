import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();
  static const String tokenUnavailableMessage =
      'Unable to get a valid FCM token. On iOS, APNs must be available first; use a real device with Push Notifications/APNs configured.';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _listenersAttached = false;
  bool _tokenRefreshListenerAttached = false;
  DateTime? _lastApnsUnavailableAt;

  static const Duration _apnsRetryCooldown = Duration(seconds: 30);

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
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'Ollie';
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

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: message.data.toString(),
    );
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

  void _attachTokenRefreshListener() {
    if (_tokenRefreshListenerAttached) return;
    _tokenRefreshListenerAttached = true;

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed');
      debugPrint('[FCM] New token: $newToken');
      await _storage.write(key: 'fcmToken', value: newToken);
    });
  }

  Future<String?> _waitForApnsToken(
    FirebaseMessaging messaging, {
    required bool wait,
    bool logResult = true,
  }) async {
    String? apnsToken = await messaging.getAPNSToken();

    for (var attempt = 0; wait && apnsToken == null && attempt < 6; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      apnsToken = await messaging.getAPNSToken();
    }

    if (logResult) {
      debugPrint('[FCM] APNs token: ${apnsToken ?? "null"}');
    }
    return apnsToken;
  }

  bool _shouldSkipApnsRetry(bool waitForApnsToken) {
    final lastUnavailableAt = _lastApnsUnavailableAt;
    if (!waitForApnsToken || lastUnavailableAt == null) {
      return false;
    }

    return DateTime.now().difference(lastUnavailableAt) < _apnsRetryCooldown;
  }

  Future<String?> _fetchAndCacheFcmToken({
    bool waitForApnsToken = true,
    bool logMissingApns = true,
  }) async {
    try {
      final messaging = FirebaseMessaging.instance;

      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        if (_shouldSkipApnsRetry(waitForApnsToken)) {
          return null;
        }

        final apnsToken = await _waitForApnsToken(
          messaging,
          wait: waitForApnsToken,
          logResult: logMissingApns,
        );
        if (apnsToken == null) {
          if (waitForApnsToken) {
            _lastApnsUnavailableAt = DateTime.now();
          }
          if (logMissingApns) {
            debugPrint(
              '[FCM] APNs token is not available yet. FCM token cannot be generated on iOS until APNs is ready.',
            );
          }
          return null;
        }
      }

      final token = await messaging.getToken();
      debugPrint('[FCM] Token: ${token ?? "null"}');
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: 'fcmToken', value: token);
        return token;
      }

      debugPrint('[FCM] Token is empty or null');
    } catch (e) {
      debugPrint('[FCM] Failed to fetch FCM token: $e');
    }

    return null;
  }

  Future<String> _getOrCreateFallbackDeviceToken() async {
    const fallbackTokenKey = 'fallbackDeviceToken';
    final cachedToken = await _storage.read(key: fallbackTokenKey);
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return cachedToken;
    }

    final generatedToken =
        'fallback-${defaultTargetPlatform.name}-${DateTime.now().microsecondsSinceEpoch}';
    await _storage.write(key: fallbackTokenKey, value: generatedToken);
    debugPrint(
      '[FCM] Using fallback device token because FCM token is unavailable',
    );
    return generatedToken;
  }

  bool _isUsableFcmToken(String? token) {
    final value = token?.trim() ?? '';
    return value.isNotEmpty &&
        value != 'test' &&
        !value.startsWith('fallback-');
  }

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await _initLocalNotifications();
      _attachFirebaseListeners();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      final settings = await messaging.getNotificationSettings();
      debugPrint(
        '[FCM] iOS authorization status: ${settings.authorizationStatus}',
      );
      debugPrint('[FCM] Firebase initialized successfully');
      await _fetchAndCacheFcmToken(
        waitForApnsToken: false,
        logMissingApns: false,
      );
      _attachTokenRefreshListener();

      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('[FCM] Firebase init failed: $e');
      return false;
    }
  }

  Future<String> getDeviceToken() async {
    final cachedToken = await _storage.read(key: 'fcmToken');
    if (_isUsableFcmToken(cachedToken)) {
      return cachedToken!;
    }

    final initialized = await initialize();
    if (!initialized) {
      return _getOrCreateFallbackDeviceToken();
    }

    final token = await _fetchAndCacheFcmToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }

    return _getOrCreateFallbackDeviceToken();
  }

  Future<String?> getRealDeviceToken({bool waitForApnsToken = true}) async {
    final cachedToken = await _storage.read(key: 'fcmToken');
    if (_isUsableFcmToken(cachedToken)) {
      return cachedToken;
    }

    final initialized = await initialize();
    if (!initialized) {
      return null;
    }

    final token = await _fetchAndCacheFcmToken(
      waitForApnsToken: waitForApnsToken,
    );
    return _isUsableFcmToken(token) ? token : null;
  }
}
