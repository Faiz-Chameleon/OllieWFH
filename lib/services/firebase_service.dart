import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String _supplementDismissAction = 'supplement_dismiss';
const String _supplementSnoozeAction = 'supplement_snooze';
const String _supplementTakenAction = 'supplement_taken';
const String _supplementCategory = 'supplement_reminder';
const String _supplementAlarmChannelId = 'ollie_supplement_alarm_v5';
const String _supplementTakenStoragePrefix = 'supplementTakenDate';

@pragma('vm:entry-point')
void supplementNotificationTapBackground(NotificationResponse response) async {
  if (response.actionId == _supplementSnoozeAction) {
    await _scheduleSupplementSnooze(response);
  } else if (response.actionId == _supplementTakenAction) {
    await _markSupplementTakenFromNotification(response);
  }
}

Future<void> _prepareTimezoneForNotificationAction() async {
  tz_data.initializeTimeZones();
  try {
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));
  } catch (_) {}
}

Map<String, dynamic> _decodeSupplementPayload(String? payload) {
  if (payload == null || payload.trim().isEmpty) return const {};
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}

  if (payload.startsWith('supplement:')) {
    return {'id': payload.substring('supplement:'.length)};
  }
  return const {};
}

int _supplementNotificationIdFor(String supplementId) {
  return 700000 + supplementId.hashCode.abs() % 200000;
}

String _todayIsoDate() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _supplementTakenStorageKey(String supplementId) {
  return '$_supplementTakenStoragePrefix:$supplementId';
}

Future<void> _writeSupplementTakenToday(String supplementId) async {
  final cleanId = supplementId.trim();
  if (cleanId.isEmpty) return;
  await const FlutterSecureStorage().write(
    key: _supplementTakenStorageKey(cleanId),
    value: _todayIsoDate(),
  );
}

TimeOfDay? _parseSupplementReminderTime(String? value) {
  final parts = value?.trim().split(':') ?? const [];
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }

  return TimeOfDay(hour: hour, minute: minute);
}

tz.TZDateTime _nextSupplementReminder(
  TimeOfDay time, {
  bool skipToday = false,
}) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  if (skipToday || !scheduled.isAfter(now)) {
    final isCurrentMinute =
        scheduled.year == now.year &&
        scheduled.month == now.month &&
        scheduled.day == now.day &&
        scheduled.hour == now.hour &&
        scheduled.minute == now.minute;
    if (!skipToday && isCurrentMinute) {
      return now.add(const Duration(seconds: 10));
    }
    scheduled = scheduled.add(const Duration(days: 1));
  }

  return scheduled;
}

NotificationDetails _supplementAlarmNotificationDetails() {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      _supplementAlarmChannelId,
      'Supplement Alarms',
      channelDescription: 'Daily supplement reminders with alarm sound',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      onlyAlertOnce: false,
      showWhen: true,
      ticker: 'Supplement reminder',
      channelShowBadge: true,
      fullScreenIntent: false,
      additionalFlags: Int32List.fromList([4]),
      actions: const [
        AndroidNotificationAction(
          _supplementTakenAction,
          'Taken',
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _supplementDismissAction,
          'Dismiss',
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _supplementSnoozeAction,
          'Remind in 2 min',
          cancelNotification: true,
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: _supplementCategory,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );
}

Future<void> _scheduleSupplementSnooze(NotificationResponse response) async {
  final payload = _decodeSupplementPayload(response.payload);
  final supplementId = payload['id']?.toString() ?? 'unknown';
  final name = payload['name']?.toString() ?? 'your supplement';
  final dosage = payload['dosage']?.toString() ?? '';
  final title = 'Supplement time';
  final body =
      'Reminder: take $name${dosage.trim().isEmpty ? "" : " - ${dosage.trim()}"}';
  final snoozeId = 900000 + supplementId.hashCode.abs() % 90000;

  await _prepareTimezoneForNotificationAction();
  final scheduledAt = tz.TZDateTime.now(
    tz.local,
  ).add(const Duration(minutes: 2));

  await FlutterLocalNotificationsPlugin().zonedSchedule(
    snoozeId,
    title,
    body,
    scheduledAt,
    _supplementAlarmNotificationDetails(),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: jsonEncode(payload),
  );
}

Future<void> _markSupplementTakenFromNotification(
  NotificationResponse response,
) async {
  final payload = _decodeSupplementPayload(response.payload);
  final supplementId = payload['id']?.toString().trim() ?? '';
  if (supplementId.isEmpty) return;

  await _prepareTimezoneForNotificationAction();
  await _writeSupplementTakenToday(supplementId);

  final reminderTime = _parseSupplementReminderTime(
    payload['reminderTime']?.toString(),
  );
  if (reminderTime == null) return;

  final name = payload['name']?.toString() ?? 'your supplement';
  final dosage = payload['dosage']?.toString() ?? '';
  final body =
      'It is time to take $name${dosage.trim().isEmpty ? "" : " - ${dosage.trim()}"}';
  final notificationId = _supplementNotificationIdFor(supplementId);

  await FlutterLocalNotificationsPlugin().zonedSchedule(
    notificationId,
    'Supplement time',
    body,
    _nextSupplementReminder(reminderTime, skipToday: true),
    _supplementAlarmNotificationDetails(),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: jsonEncode(payload),
  );
}

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
  bool _timezoneInitialized = false;
  DateTime? _lastApnsUnavailableAt;
  final List<Future<void> Function(RemoteMessage message)> _messageHandlers =
      [];

  static const Duration _apnsRetryCooldown = Duration(seconds: 30);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ollie_high_importance',
    'Ollie Notifications',
    description: 'Notifications for Ollie app updates and reminders',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _supplementAlarmChannel =
      AndroidNotificationChannel(
        _supplementAlarmChannelId,
        'Supplement Alarms',
        description: 'Daily supplement reminders with alarm sound',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static const String _scheduledSupplementIdsKey =
      'scheduledSupplementAlarmIds';

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
    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_stat_ollie_notification',
    );
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          _supplementCategory,
          actions: [
            DarwinNotificationAction.plain(_supplementDismissAction, 'Dismiss'),
            DarwinNotificationAction.plain(_supplementTakenAction, 'Taken'),
            DarwinNotificationAction.plain(
              _supplementSnoozeAction,
              'Remind in 2 min',
            ),
          ],
        ),
      ],
    );
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleSupplementNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          supplementNotificationTapBackground,
    );

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
    await androidPlugin?.createNotificationChannel(_supplementAlarmChannel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestFullScreenIntentPermission();
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

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> _handleSupplementNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.actionId == _supplementSnoozeAction) {
      await _scheduleSupplementSnooze(response);
    } else if (response.actionId == _supplementTakenAction) {
      await _markSupplementTakenFromNotification(response);
    }
  }

  Future<void> _initTimezone() async {
    if (_timezoneInitialized) return;

    tz_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone));
      debugPrint('[FCM] Local timezone for reminders: $localTimezone');
    } catch (e) {
      debugPrint(
        '[FCM] Failed to resolve local timezone, using device local default: $e',
      );
    }

    _timezoneInitialized = true;
  }

  int _supplementNotificationId(String supplementId) {
    return _supplementNotificationIdFor(supplementId);
  }

  TimeOfDay? _parseReminderTime(String? value) {
    return _parseSupplementReminderTime(value);
  }

  tz.TZDateTime _nextDailyReminder(TimeOfDay time, {bool skipToday = false}) {
    return _nextSupplementReminder(time, skipToday: skipToday);
  }

  Future<List<int>> _readScheduledSupplementIds() async {
    final raw = await _storage.read(key: _scheduledSupplementIdsKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => int.tryParse(item.toString()))
            .whereType<int>()
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> _writeScheduledSupplementIds(List<int> ids) async {
    await _storage.write(
      key: _scheduledSupplementIdsKey,
      value: jsonEncode(ids.toSet().toList()),
    );
  }

  Future<void> cancelSupplementAlarm(String supplementId) async {
    if (supplementId.trim().isEmpty) return;
    final notificationId = _supplementNotificationId(supplementId);
    await _localNotifications.cancel(notificationId);

    final scheduledIds = await _readScheduledSupplementIds();
    scheduledIds.remove(notificationId);
    await _writeScheduledSupplementIds(scheduledIds);
    debugPrint('[FCM] Cancelled supplement alarm id=$notificationId');
  }

  Future<bool> isSupplementTakenToday(String supplementId) async {
    final cleanId = supplementId.trim();
    if (cleanId.isEmpty) return false;
    final stored = await _storage.read(
      key: _supplementTakenStorageKey(cleanId),
    );
    return stored == _todayIsoDate();
  }

  Future<void> markSupplementTakenToday(String supplementId) async {
    final cleanId = supplementId.trim();
    if (cleanId.isEmpty) return;
    await _writeSupplementTakenToday(cleanId);
    await cancelSupplementAlarm(cleanId);
  }

  Future<void> syncSupplementAlarms(List<SupplementData> supplements) async {
    await initialize();
    await _initTimezone();

    final oldIds = await _readScheduledSupplementIds();
    for (final id in oldIds) {
      await _localNotifications.cancel(id);
    }

    final activeIds = <int>[];
    for (final supplement in supplements) {
      if (!supplement.reminderEnabled) continue;

      final supplementId = supplement.id?.trim();
      final reminderTime = _parseReminderTime(supplement.reminderTime);
      if (supplementId == null ||
          supplementId.isEmpty ||
          reminderTime == null) {
        continue;
      }

      final notificationId = _supplementNotificationId(supplementId);
      final takenToday = await isSupplementTakenToday(supplementId);
      final title = 'Supplement time';
      final body =
          'It is time to take ${supplement.name ?? "your supplement"}'
          '${(supplement.dosage ?? "").trim().isEmpty ? "" : " - ${supplement.dosage!.trim()}"}';
      final scheduledAt = _nextDailyReminder(
        reminderTime,
        skipToday: takenToday,
      );

      final notificationDetails = _supplementAlarmNotificationDetails();
      final payload = jsonEncode({
        'type': 'supplement',
        'id': supplementId,
        'name': supplement.name ?? 'your supplement',
        'dosage': supplement.dosage ?? '',
        'reminderTime': supplement.reminderTime ?? '',
      });

      try {
        await _localNotifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledAt,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (e) {
        debugPrint(
          '[FCM] Exact supplement alarm failed, using inexact schedule: $e',
        );
        await _localNotifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledAt,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      }

      activeIds.add(notificationId);
      debugPrint(
        '[FCM] Scheduled supplement alarm id=$notificationId at $scheduledAt',
      );
    }

    await _writeScheduledSupplementIds(activeIds);
  }

  void addMessageHandler(Future<void> Function(RemoteMessage message) handler) {
    if (!_messageHandlers.contains(handler)) {
      _messageHandlers.add(handler);
    }
  }

  void removeMessageHandler(
    Future<void> Function(RemoteMessage message) handler,
  ) {
    _messageHandlers.remove(handler);
  }

  Future<void> _notifyMessageHandlers(RemoteMessage message) async {
    for (final handler
        in List<Future<void> Function(RemoteMessage message)>.from(
          _messageHandlers,
        )) {
      try {
        await handler(message);
      } catch (e) {
        debugPrint('[FCM] Message handler failed: $e');
      }
    }
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
      _notifyMessageHandlers(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logFcm('Notification tapped', remoteMessage: message);
      _notifyMessageHandlers(message);
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
    debugPrint(
      '[FCM] No valid FCM token available; skipping device token payload',
    );
    return '';
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
        '[FCM] ${defaultTargetPlatform.name} authorization status: ${settings.authorizationStatus}',
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

    final token = await _fetchAndCacheFcmToken(
      waitForApnsToken: false,
      logMissingApns: false,
    );
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

  Future<Map<String, String>> getDeviceRegistrationPayload({
    bool waitForApnsToken = true,
  }) async {
    final token = await getRealDeviceToken(waitForApnsToken: waitForApnsToken);
    final deviceType = defaultTargetPlatform == TargetPlatform.android
        ? 'ANDROID'
        : 'IOS';
    if (token == null || token.isEmpty) {
      return {
        'userDeviceToken': '${deviceType.toLowerCase()}-simulator-token',
        'userDeviceType': deviceType,
      };
    }

    return {'userDeviceToken': token, 'userDeviceType': deviceType};
  }
}
