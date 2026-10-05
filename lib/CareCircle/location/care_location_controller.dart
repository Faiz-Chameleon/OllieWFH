import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Radii offered in Care Circle, in km. The API caps at 100.
const List<double> careRadiusOptions = [2, 5, 10, 25, 50];
const double defaultCareRadiusKm = 10;

/// The place Care Circle lists are centred on: the user's GPS position, or a
/// place they chose to browse.
class CareLocation {
  const CareLocation({
    required this.latitude,
    required this.longitude,
    this.label,
    this.city,
    this.country,
    this.isCurrent = false,
  });

  final double latitude;
  final double longitude;

  /// Short place name for display, e.g. "Gulberg, Lahore".
  final String? label;
  final String? city;
  final String? country;

  /// True when this is the device's own position rather than a chosen place.
  final bool isCurrent;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
    'city': city,
    'country': country,
  };

  static CareLocation? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = double.tryParse(json['latitude']?.toString() ?? '');
    final lng = double.tryParse(json['longitude']?.toString() ?? '');
    if (lat == null || lng == null) return null;
    return CareLocation(
      latitude: lat,
      longitude: lng,
      label: json['label']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
    );
  }
}

/// Place names for a coordinate.
typedef PlaceLookup =
    Future<({String? label, String? city, String? country})> Function(
      double latitude,
      double longitude,
    );

/// The device's position, or an error message for the user.
typedef PositionLookup =
    Future<({double? latitude, double? longitude, String? error})> Function();

enum CareLocationStatus { idle, locating, ready, unavailable }

/// One location and radius for all of Care Circle (assistance, groups, events
/// and the explore map). Lists read [queryParameters]; anything that changes the
/// location bumps [version] so they reload.
class CareLocationController extends GetxController {
  CareLocationController({
    PositionLookup? positionLookup,
    PlaceLookup? placeLookup,
    FlutterSecureStorage? storage,
  }) : _positionLookup = positionLookup ?? _devicePosition,
       _placeLookup = placeLookup ?? _placeNames,
       _storage = storage ?? const FlutterSecureStorage();

  static const String _chosenPlaceKey = 'careCircleChosenPlace';
  static const String _radiusKey = 'careCircleRadiusKm';

  final PositionLookup _positionLookup;
  final PlaceLookup _placeLookup;
  final FlutterSecureStorage _storage;

  final location = Rxn<CareLocation>();
  final radiusKm = defaultCareRadiusKm.obs;
  final status = CareLocationStatus.idle.obs;
  final errorMessage = ''.obs;

  /// Incremented whenever the location or radius changes.
  final version = 0.obs;

  Future<void>? _loading;

  bool get isBrowsingElsewhere => location.value?.isCurrent == false;

  /// The location to use, resolving it on first use: a saved chosen place, else GPS.
  Future<CareLocation?> ensureLocation() async {
    if (location.value != null) return location.value;
    _loading ??= _load();
    await _loading;
    _loading = null;
    return location.value;
  }

  Future<void> _load() async {
    final savedRadius = double.tryParse(await _safeRead(_radiusKey) ?? '');
    if (savedRadius != null && savedRadius > 0) radiusKm.value = savedRadius;

    final saved = await _safeRead(_chosenPlaceKey);
    final chosen = saved == null
        ? null
        : CareLocation.fromJson(_tryDecode(saved));
    if (chosen != null) {
      _set(chosen);
      return;
    }
    await useMyLocation();
  }

  /// Switches back to the device's position.
  Future<void> useMyLocation() async {
    status.value = CareLocationStatus.locating;
    errorMessage.value = '';
    final position = await _positionLookup();
    final lat = position.latitude;
    final lng = position.longitude;
    if (lat == null || lng == null) {
      status.value = CareLocationStatus.unavailable;
      errorMessage.value =
          position.error ??
          'Unable to get your location. Choose a place instead.';
      return;
    }
    await _safeDelete(_chosenPlaceKey);
    final names = await _safePlaceLookup(lat, lng);
    _set(
      CareLocation(
        latitude: lat,
        longitude: lng,
        label: names.label,
        city: names.city,
        country: names.country,
        isCurrent: true,
      ),
    );
  }

  /// Browses around another place. Names are looked up when not given.
  Future<void> choosePlace({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final names = await _safePlaceLookup(latitude, longitude);
    final place = CareLocation(
      latitude: latitude,
      longitude: longitude,
      label: (label?.trim().isNotEmpty ?? false) ? label!.trim() : names.label,
      city: names.city,
      country: names.country,
    );
    await _safeWrite(_chosenPlaceKey, jsonEncode(place.toJson()));
    _set(place);
  }

  Future<void> setRadius(double km) async {
    if (km <= 0 || km == radiusKm.value) return;
    radiusKm.value = km;
    await _safeWrite(_radiusKey, km.toString());
    version.value++;
  }

  /// Query parameters for the API's "near a place" lists, or null with no location.
  Map<String, String>? get queryParameters {
    final place = location.value;
    if (place == null) return null;
    return {
      'latitude': place.latitude.toStringAsFixed(6),
      'longitude': place.longitude.toStringAsFixed(6),
      'radiusKm': _formatKm(radiusKm.value),
      if ((place.city ?? '').isNotEmpty) 'city': place.city!,
      if ((place.country ?? '').isNotEmpty) 'country': place.country!,
    };
  }

  /// e.g. "Near you · Gulberg, Lahore · 10 km" or "Islamabad · 25 km".
  String get summary {
    final place = location.value;
    if (place == null) {
      return status.value == CareLocationStatus.locating
          ? 'Finding your location…'
          : 'Choose a location';
    }
    final name = place.label ?? place.city ?? 'Selected place';
    final km = '${_formatKm(radiusKm.value)} km';
    return place.isCurrent ? 'Near you · $name · $km' : '$name · $km';
  }

  void _set(CareLocation place) {
    location.value = place;
    status.value = CareLocationStatus.ready;
    errorMessage.value = '';
    version.value++;
  }

  static String _formatKm(double km) =>
      km == km.roundToDouble() ? km.toStringAsFixed(0) : km.toStringAsFixed(1);

  Future<({String? label, String? city, String? country})> _safePlaceLookup(
    double lat,
    double lng,
  ) async {
    try {
      return await _placeLookup(lat, lng);
    } catch (_) {
      return (label: null, city: null, country: null);
    }
  }

  Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  static Future<({double? latitude, double? longitude, String? error})>
  _devicePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (
          latitude: null,
          longitude: null,
          error: 'Turn on location services, or choose a place to browse.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (
          latitude: null,
          longitude: null,
          error: 'Allow location access, or choose a place to browse.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 12));
      return (
        latitude: position.latitude,
        longitude: position.longitude,
        error: null,
      );
    } catch (_) {
      return (
        latitude: null,
        longitude: null,
        error: 'Unable to get your location. Choose a place instead.',
      );
    }
  }

  static Future<({String? label, String? city, String? country})> _placeNames(
    double lat,
    double lng,
  ) async {
    final marks = await geocoding.placemarkFromCoordinates(lat, lng);
    if (marks.isEmpty) return (label: null, city: null, country: null);
    final mark = marks.first;
    String? clean(String? value) =>
        (value ?? '').trim().isEmpty ? null : value!.trim();
    final city = clean(mark.locality) ?? clean(mark.subAdministrativeArea);
    final area = clean(mark.subLocality);
    return (
      label: [area, city]
          .whereType<String>()
          .toSet()
          .join(', ')
          .ifEmpty(clean(mark.administrativeArea)),
      city: city,
      country: clean(mark.country),
    );
  }
}

extension on String {
  String? ifEmpty(String? fallback) => isEmpty ? fallback : this;
}

/// The single shared [CareLocationController].
CareLocationController findCareLocation() =>
    Get.isRegistered<CareLocationController>()
    ? Get.find<CareLocationController>()
    : Get.put(CareLocationController(), permanent: true);
