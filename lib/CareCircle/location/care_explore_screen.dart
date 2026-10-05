import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/care_circle_repository.dart';
import 'package:ollie/CareCircle/location/care_location_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/services/google_places_service.dart';

enum CarePinType { assistance, group, event }

/// One item on the explore map.
class CarePin {
  const CarePin({
    required this.type,
    required this.id,
    required this.title,
    required this.position,
    this.subtitle,
    this.distanceKm,
  });

  final CarePinType type;
  final String id;
  final String title;
  final String? subtitle;
  final LatLng position;
  final double? distanceKm;

  /// Parses the explore endpoint's `data` into pins.
  static List<CarePin> fromExplore(Map<String, dynamic> data) {
    final pins = <CarePin>[];
    double? num_(Object? v) => (v as num?)?.toDouble();
    String when(Object? iso) {
      final date = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();
      return date == null ? '' : DateFormat('EEE d MMM, h:mm a').format(date);
    }

    void add(String key, CarePinType type, CarePin? Function(Map item) build) {
      final list = data[key];
      if (list is! List) return;
      for (final item in list.whereType<Map>()) {
        final pin = build(item);
        if (pin != null) pins.add(pin);
      }
    }

    LatLng? at(Map item) {
      final lat = num_(item['latitude']);
      final lng = num_(item['longitude']);
      return lat == null || lng == null ? null : LatLng(lat, lng);
    }

    add('assistance', CarePinType.assistance, (item) {
      final position = at(item);
      if (position == null) return null;
      return CarePin(
        type: CarePinType.assistance,
        id: item['id'].toString(),
        title: item['title']?.toString() ?? 'Help request',
        subtitle: when(item['scheduledAt']),
        position: position,
        distanceKm: num_(item['distanceKm']),
      );
    });
    add('groups', CarePinType.group, (item) {
      final position = at(item);
      if (position == null) return null;
      final members = item['memberCount'];
      return CarePin(
        type: CarePinType.group,
        id: item['id'].toString(),
        title: item['name']?.toString() ?? 'Group',
        subtitle: members == null ? null : '$members members',
        position: position,
        distanceKm: num_(item['distanceKm']),
      );
    });
    add('events', CarePinType.event, (item) {
      final position = at(item);
      if (position == null) return null;
      return CarePin(
        type: CarePinType.event,
        id: item['id'].toString(),
        title: item['eventName']?.toString() ?? 'Event',
        subtitle: when(item['eventDateAndTime']),
        position: position,
        distanceKm: num_(item['distanceKm']),
      );
    });
    return pins;
  }
}

/// Map for choosing where Care Circle's lists are centred: search a place or move
/// the map, pick a radius, and see what's there before applying it.
class CareExploreScreen extends StatefulWidget {
  const CareExploreScreen({super.key, this.repository, this.places});

  final CareCircleRepository? repository;
  final GooglePlacesService? places;

  @override
  State<CareExploreScreen> createState() => _CareExploreScreenState();
}

class _CareExploreScreenState extends State<CareExploreScreen> {
  final CareLocationController location = findCareLocation();
  late final CareCircleRepository _repository =
      widget.repository ?? CareCircleRepository();
  late final GooglePlacesService _places =
      widget.places ?? GooglePlacesService();
  final _searchController = TextEditingController();

  GoogleMapController? _map;
  LatLng? _center;
  String? _label;
  bool _isMyLocation = false;
  late double _radiusKm = location.radiusKm.value;

  List<CarePin> _pins = [];
  CarePin? _selected;
  bool _loadingPins = false;
  String? _pinError;
  Timer? _pinDebounce;
  int _pinRequest = 0;

  List<GooglePlacePrediction> _suggestions = [];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final current = await location.ensureLocation();
    if (!mounted || current == null) return;
    setState(() {
      _center = LatLng(current.latitude, current.longitude);
      _label = current.label;
      _isMyLocation = current.isCurrent;
    });
    _map?.moveCamera(CameraUpdate.newLatLngZoom(_center!, _zoomFor(_radiusKm)));
    _loadPins();
  }

  @override
  void dispose() {
    _pinDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// A zoom that fits the radius circle on a phone screen.
  static double _zoomFor(double km) => switch (km) {
    <= 2 => 13.5,
    <= 5 => 12.3,
    <= 10 => 11.3,
    <= 25 => 10,
    _ => 9,
  };

  Future<void> _loadPins() async {
    final center = _center;
    if (center == null) return;
    final request = ++_pinRequest;
    setState(() {
      _loadingPins = true;
      _pinError = null;
    });
    final result = await _repository.exploreCareCircle(
      location: {
        'latitude': center.latitude.toStringAsFixed(6),
        'longitude': center.longitude.toStringAsFixed(6),
        'radiusKm': _radiusKm.toStringAsFixed(0),
      },
    );
    if (!mounted || request != _pinRequest) return;
    setState(() {
      _loadingPins = false;
      if (result['success'] == true && result['data'] is Map) {
        _pins = CarePin.fromExplore(
          (result['data'] as Map).map((k, v) => MapEntry(k.toString(), v)),
        );
        if (_selected != null && !_pins.any((p) => p.id == _selected!.id)) {
          _selected = null;
        }
      } else {
        _pinError = result['message']?.toString() ?? "Couldn't load the map";
      }
    });
  }

  void _scheduleLoadPins() {
    _pinDebounce?.cancel();
    _pinDebounce = Timer(const Duration(milliseconds: 500), _loadPins);
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    if (text.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await _places.autocomplete(text);
        if (mounted) setState(() => _suggestions = results);
      } catch (_) {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _pickSuggestion(GooglePlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = []);
    try {
      final details = await _places.details(prediction.placeId);
      if (details == null || !mounted) return;
      _searchController.text = prediction.mainText;
      _moveTo(details.latLng, label: prediction.mainText, isMyLocation: false);
    } catch (_) {
      appSnackbar("Error", "Couldn't find that place. Try another search.");
    }
  }

  Future<void> _goToMyLocation() async {
    await location.useMyLocation();
    final current = location.location.value;
    if (!mounted) return;
    if (current == null || !current.isCurrent) {
      appSnackbar("Location", location.errorMessage.value);
      return;
    }
    _searchController.clear();
    _moveTo(
      LatLng(current.latitude, current.longitude),
      label: current.label,
      isMyLocation: true,
    );
  }

  void _moveTo(LatLng target, {String? label, required bool isMyLocation}) {
    setState(() {
      _center = target;
      _label = label;
      _isMyLocation = isMyLocation;
      _selected = null;
    });
    _map?.animateCamera(
      CameraUpdate.newLatLngZoom(target, _zoomFor(_radiusKm)),
    );
    _scheduleLoadPins();
  }

  void _setRadius(double km) {
    setState(() => _radiusKm = km);
    if (_center != null) {
      _map?.animateCamera(CameraUpdate.newLatLngZoom(_center!, _zoomFor(km)));
    }
    _scheduleLoadPins();
  }

  /// Makes this place and radius the one Care Circle's lists use. With [tab],
  /// also switches Care Circle to that tab.
  Future<void> _apply({int? tab}) async {
    final center = _center;
    if (center == null) return;
    await location.setRadius(_radiusKm);
    final current = location.location.value;
    final unchanged =
        current != null &&
        current.latitude == center.latitude &&
        current.longitude == center.longitude;
    if (!unchanged) {
      if (_isMyLocation) {
        await location.useMyLocation();
      } else {
        await location.choosePlace(
          latitude: center.latitude,
          longitude: center.longitude,
          label: _label,
        );
      }
    }
    if (tab != null && Get.isRegistered<CareCircleController>()) {
      Get.find<CareCircleController>().changeTab(tab);
    }
    if (mounted) Navigator.of(context).pop();
  }

  static double _hue(CarePinType type) => switch (type) {
    CarePinType.assistance => BitmapDescriptor.hueOrange,
    CarePinType.group => BitmapDescriptor.hueAzure,
    CarePinType.event => BitmapDescriptor.hueGreen,
  };

  static String _typeLabel(CarePinType type) => switch (type) {
    CarePinType.assistance => 'Help request',
    CarePinType.group => 'Group',
    CarePinType.event => 'Event',
  };

  static int _tabFor(CarePinType type) => switch (type) {
    CarePinType.assistance => 0,
    CarePinType.group => 1,
    CarePinType.event => 3,
  };

  TextStyle _style(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = Black,
  }) => GoogleFonts.darkerGrotesque(
    fontSize: responsiveFontSize(size, min: size - 2, max: size + 3),
    fontWeight: weight,
    color: color,
  );

  @override
  Widget build(BuildContext context) {
    final center = _center;
    final counts = {
      for (final type in CarePinType.values)
        type: _pins.where((p) => p.type == type).length,
    };

    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        backgroundColor: BGcolor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Black),
        title: Text(
          'Explore nearby',
          style: _style(24, weight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search a city or area',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              constraints: BoxConstraints(maxHeight: 220.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final s in _suggestions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(s.mainText, style: _style(18)),
                      subtitle: s.secondaryText.isEmpty
                          ? null
                          : Text(
                              s.secondaryText,
                              style: _style(15, color: Colors.black54),
                            ),
                      onTap: () => _pickSuggestion(s),
                    ),
                ],
              ),
            ),
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              children: [
                for (final km in careRadiusOptions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${km.toStringAsFixed(0)} km',
                        style: _style(16, weight: FontWeight.w700),
                      ),
                      selected: _radiusKm == km,
                      selectedColor: ksecondaryColor,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      onSelected: (_) => _setRadius(km),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: center ?? const LatLng(20, 0),
                    zoom: center == null ? 1.5 : _zoomFor(_radiusKm),
                  ),
                  onMapCreated: (controller) {
                    _map = controller;
                    if (_center != null) {
                      controller.moveCamera(
                        CameraUpdate.newLatLngZoom(
                          _center!,
                          _zoomFor(_radiusKm),
                        ),
                      );
                    }
                  },
                  onCameraMove: (position) {
                    _center = position.target;
                    _isMyLocation = false;
                    _label = null;
                  },
                  onCameraIdle: () {
                    if (_center != null) {
                      setState(() {});
                      _scheduleLoadPins();
                    }
                  },
                  onTap: (_) => setState(() => _selected = null),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  circles: {
                    if (center != null)
                      Circle(
                        circleId: const CircleId('radius'),
                        center: center,
                        radius: _radiusKm * 1000,
                        strokeWidth: 2,
                        strokeColor: buttonColor,
                        fillColor: ksecondaryColor.withValues(alpha: 0.15),
                      ),
                  },
                  markers: {
                    for (final pin in _pins)
                      Marker(
                        markerId: MarkerId('${pin.type.name}-${pin.id}'),
                        position: pin.position,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          _hue(pin.type),
                        ),
                        onTap: () => setState(() => _selected = pin),
                      ),
                  },
                ),
                // The centre of the search.
                if (center != null)
                  const IgnorePointer(
                    child: Center(
                      child: Icon(Icons.add, size: 28, color: buttonColor),
                    ),
                  ),
                if (center == null)
                  Center(
                    child: Container(
                      margin: EdgeInsets.all(24.w),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Search for a place, or use your location.',
                        textAlign: TextAlign.center,
                        style: _style(18),
                      ),
                    ),
                  ),
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: FloatingActionButton.small(
                    heroTag: 'careExploreMyLocation',
                    backgroundColor: Colors.white,
                    tooltip: 'Use my location',
                    onPressed: _goToMyLocation,
                    child: const Icon(Icons.my_location, color: Black),
                  ),
                ),
                if (_loadingPins)
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                if (_selected != null)
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _PinCard(
                      pin: _selected!,
                      typeLabel: _typeLabel(_selected!.type),
                      onShow: () => _apply(tab: _tabFor(_selected!.type)),
                      style: _style,
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _pinError ??
                        (center == null
                            ? ' '
                            : '${counts[CarePinType.assistance]} help requests · '
                                  '${counts[CarePinType.group]} groups · '
                                  '${counts[CarePinType.event]} events on the map'),
                    textAlign: TextAlign.center,
                    style: _style(
                      16,
                      color: _pinError == null ? Colors.black54 : Colors.red,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: center == null ? null : () => _apply(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Show Care Circle here',
                      style: _style(
                        19,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinCard extends StatelessWidget {
  const _PinCard({
    required this.pin,
    required this.typeLabel,
    required this.onShow,
    required this.style,
  });

  final CarePin pin;
  final String typeLabel;
  final VoidCallback onShow;
  final TextStyle Function(double, {FontWeight weight, Color color}) style;

  @override
  Widget build(BuildContext context) {
    final details = [
      if ((pin.subtitle ?? '').isNotEmpty) pin.subtitle!,
      if (pin.distanceKm != null)
        '${pin.distanceKm!.toStringAsFixed(1)} km away',
    ].join(' · ');

    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(typeLabel, style: style(14, color: Colors.black54)),
                  Text(
                    pin.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style(19, weight: FontWeight.w700),
                  ),
                  if (details.isNotEmpty)
                    Text(details, style: style(15, color: Colors.black54)),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onShow,
              child: Text(
                'Show in list',
                style: style(16, weight: FontWeight.w700, color: buttonColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
