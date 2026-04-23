import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class DeviceTimeZoneService {
  static const MethodChannel _channel = MethodChannel('com.shahwaiz.meditrace/time_zone');

  static Future<String> getIanaTimeZone() async {
    try {
      final String? timeZone = await _channel.invokeMethod<String>('getIanaTimeZone');
      if (timeZone != null && _isIanaTimeZoneName(timeZone)) {
        return timeZone.trim();
      }
    } catch (_) {}

    final localeTimeZone = _timeZoneFromLocaleCountry(ui.PlatformDispatcher.instance.locale.countryCode);
    if (localeTimeZone != null) {
      return localeTimeZone;
    }

    return 'UTC';
  }

  static Future<Map<String, dynamic>> requestBodyWithDeviceTimeZone(dynamic body) async {
    final Map<String, dynamic> requestBody = _decodeRequestBodyMap(body);
    requestBody['timeZone'] = await getIanaTimeZone();
    return requestBody;
  }

  static Map<String, dynamic> _decodeRequestBodyMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return Map<String, dynamic>.from(body);
    }

    if (body is Map) {
      return body.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{};
  }

  static String? _timeZoneFromLocaleCountry(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'PK':
        return 'Asia/Karachi';
      case 'CA':
        return 'America/Toronto';
      case 'GB':
        return 'Europe/London';
      case 'US':
        return 'America/New_York';
      case 'IN':
        return 'Asia/Kolkata';
      case 'AE':
        return 'Asia/Dubai';
      case 'AU':
        return 'Australia/Sydney';
      default:
        return null;
    }
  }

  static bool _isIanaTimeZoneName(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return false;
    if (trimmedValue.startsWith('GMT')) return false;
    if (trimmedValue.startsWith('UTC+') || trimmedValue.startsWith('UTC-')) return false;
    return trimmedValue == 'UTC' || trimmedValue.contains('/');
  }
}
