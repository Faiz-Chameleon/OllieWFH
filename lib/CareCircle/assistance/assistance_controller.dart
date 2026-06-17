// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ollie/CareCircle/assistance/assistance_repository.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Models/assistance_reasons_model.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/services/google_places_service.dart';

class LocationSearchResult {
  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;

  String get mainText {
    final parts = displayName.split(',');
    return parts.first.trim().isEmpty ? displayName : parts.first.trim();
  }

  String get secondaryText {
    final commaIndex = displayName.indexOf(',');
    if (commaIndex < 0 || commaIndex + 1 >= displayName.length) {
      return '';
    }
    return displayName.substring(commaIndex + 1).trim();
  }

  LatLng get latLng => LatLng(latitude, longitude);

  static double? _readCoordinate(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    final displayName =
        json['displayName']?.toString() ??
        json['display_name']?.toString() ??
        json['name']?.toString() ??
        json['address']?.toString() ??
        json['formattedAddress']?.toString() ??
        '';
    final latitude = _readCoordinate(json, ['latitude', 'lat']);
    final longitude = _readCoordinate(json, ['longitude', 'lng', 'lon']);

    if (displayName.trim().isEmpty || latitude == null || longitude == null) {
      throw const FormatException('Invalid location search result');
    }

    return LocationSearchResult(
      displayName: displayName.trim(),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class Assistance_Controller extends GetxController {
  final AssistanceRepository createAssistanceRepository =
      AssistanceRepository();
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categorySearchController =
      TextEditingController();
  final TextEditingController locationSearchController =
      TextEditingController();
  final RxBool isExpanded = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final RxBool hasSelectedDate = false.obs;
  final RxBool hasSelectedTime = false.obs;

  final RxString selectedAddress = ''.obs;
  final Rx<LatLng?> selectedLatLng = Rxn<LatLng>();
  RxDouble selectedLatitude = 0.0.obs;
  RxDouble selectedLongitude = 0.0.obs;
  final RxBool hasLocationPermission = false.obs;
  final RxBool isSearchingLocation = false.obs;
  final RxList<XFile> attachments = <XFile>[].obs;
  final RxList<LocationSearchResult> locationPredictions =
      <LocationSearchResult>[].obs;
  Timer? _locationSearchDebounce;
  Timer? _categorySearchDebounce;

  ////////// voucher ////////////
  final RxString selectedVolunteer = ''.obs;

  void selectVolunteer(String name) {
    selectedVolunteer.value = name;
  }

  bool isVolunteerSelected(String name) {
    return selectedVolunteer.value == name;
  }
  ////////// voucher ////////////

  void toggleExpanded() => isExpanded.toggle();
  void setDate(DateTime date) {
    selectedDate.value = date;
    hasSelectedDate.value = true;
    _updateCombinedDateTimeIfReady();
  }

  void setTime(TimeOfDay time) {
    selectedTime.value = time;
    hasSelectedTime.value = true;
    _updateCombinedDateTimeIfReady();
  }

  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      appSnackbar(
        "Location Disabled",
        "Please enable location services to continue.",
      );
      hasLocationPermission.value = false;
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      appSnackbar(
        "Permission Required",
        "Location permission is permanently denied. Please enable it from settings to continue.",
      );
      hasLocationPermission.value = false;
      return false;
    }

    if (permission == LocationPermission.denied) {
      appSnackbar(
        "Permission Required",
        "Please allow location access to pick your address.",
      );
      hasLocationPermission.value = false;
      return false;
    }

    hasLocationPermission.value = true;
    return true;
  }

  void updateDateAndTime() {
    if (!hasSelectedDate.value || !hasSelectedTime.value) {
      formattedDateAndTime.value = '';
      return;
    }
    final combinedDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    formattedDateAndTime.value = combinedDateTime
        .toUtc()
        .toIso8601String()
        .toString();
  }

  RxString formattedDateAndTime = "".obs;

  void _updateCombinedDateTimeIfReady() {
    if (hasSelectedDate.value && hasSelectedTime.value) {
      updateDateAndTime();
    } else {
      formattedDateAndTime.value = '';
    }
  }

  String get formattedDate => hasSelectedDate.value
      ? DateFormat('dd-MMM-yyyy').format(selectedDate.value)
      : '';

  String get formattedTime {
    if (!hasSelectedTime.value) return '';
    final time = selectedTime.value;
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  bool get canProceed => hasSelectedDate.value && hasSelectedTime.value;

  Future<void> setLocationFromLatLng(LatLng latLng) async {
    selectedLatLng.value = latLng;
    selectedLatitude.value = latLng.latitude;
    selectedLongitude.value = latLng.longitude;
    final placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      selectedAddress.value =
          "${p.street}, ${p.locality}, ${p.administrativeArea} ${p.postalCode}";
      locationSearchController.text = selectedAddress.value;
    }
  }

  void onLocationSearchChanged(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery != selectedAddress.value.trim()) {
      _clearSelectedLocation();
    }

    _locationSearchDebounce?.cancel();
    if (normalizedQuery.length < 2) {
      locationPredictions.clear();
      isSearchingLocation.value = false;
      return;
    }

    _locationSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchLocationPredictions(normalizedQuery);
    });
  }

  Future<void> fetchLocationPredictions(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      locationPredictions.clear();
      return;
    }

    try {
      isSearchingLocation.value = true;
      final response = await createAssistanceRepository.searchLocation(
        normalizedQuery,
      );
      final predictions = response['success'] == true
          ? _parseLocationSearchResults(response['data'])
          : <LocationSearchResult>[];
      if (locationSearchController.text.trim() == normalizedQuery) {
        locationPredictions.assignAll(predictions);
      }
    } catch (_) {
      if (locationSearchController.text.trim() == normalizedQuery) {
        locationPredictions.clear();
      }
    } finally {
      if (locationSearchController.text.trim() == normalizedQuery) {
        isSearchingLocation.value = false;
      }
    }
  }

  List<LocationSearchResult> _parseLocationSearchResults(dynamic rawData) {
    final rawList = rawData is List
        ? rawData
        : rawData is Map && rawData['locations'] is List
        ? rawData['locations'] as List
        : rawData is Map && rawData['results'] is List
        ? rawData['results'] as List
        : rawData is Map && rawData['data'] is List
        ? rawData['data'] as List
        : const [];

    final results = <LocationSearchResult>[];
    for (final item in rawList.whereType<Map>()) {
      try {
        results.add(
          LocationSearchResult.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      } catch (_) {}
    }
    return results;
  }

  Future<void> selectLocationSearchResult(LocationSearchResult result) async {
    _setSelectedLocation(result.latLng, result.displayName);
    locationPredictions.clear();
  }

  Future<void> selectGooglePlace(GooglePlacePrediction prediction) async {
    try {
      isSearchingLocation.value = true;
      final details = await _googlePlacesService.details(prediction.placeId);
      if (details == null) {
        appSnackbar("Not found", "No location details found.");
        return;
      }

      _setSelectedLocation(
        details.latLng,
        details.address.isNotEmpty ? details.address : prediction.description,
      );
      locationPredictions.clear();
    } catch (_) {
      appSnackbar("Error", "Unable to select this location.");
    } finally {
      isSearchingLocation.value = false;
    }
  }

  Future<void> searchLocationByText(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      appSnackbar("Location Required", "Please enter an address to search.");
      return;
    }

    try {
      isSearchingLocation.value = true;
      final response = await createAssistanceRepository.searchLocation(
        normalizedQuery,
      );
      if (response['success'] == true) {
        final results = _parseLocationSearchResults(response['data']);
        if (results.isNotEmpty) {
          await selectLocationSearchResult(results.first);
          return;
        }
      }

      GooglePlaceDetails? placeDetails;
      GooglePlacePrediction? firstPrediction;

      try {
        final predictions = await _googlePlacesService.autocomplete(
          normalizedQuery,
        );
        if (predictions.isNotEmpty) {
          firstPrediction = predictions.first;
          placeDetails = await _googlePlacesService.details(
            firstPrediction.placeId,
          );
        }
      } catch (_) {}

      if (placeDetails != null) {
        _setSelectedLocation(
          placeDetails.latLng,
          placeDetails.address.isNotEmpty
              ? placeDetails.address
              : firstPrediction?.description ?? normalizedQuery,
        );
        locationPredictions.clear();
        return;
      }

      final results = await locationFromAddress(normalizedQuery);
      if (results.isEmpty) {
        appSnackbar("Not found", "No location matched your search.");
        return;
      }

      final match = results.first;
      final latLng = LatLng(match.latitude, match.longitude);
      await setLocationFromLatLng(latLng);
      locationPredictions.clear();

      if (selectedAddress.value.isEmpty) {
        selectedAddress.value = normalizedQuery;
        locationSearchController.text = normalizedQuery;
      }
    } catch (_) {
      appSnackbar("Error", "Unable to search this location.");
    } finally {
      isSearchingLocation.value = false;
    }
  }

  void _setSelectedLocation(LatLng latLng, String address) {
    selectedLatLng.value = latLng;
    selectedLatitude.value = latLng.latitude;
    selectedLongitude.value = latLng.longitude;
    selectedAddress.value = address;
    locationSearchController.text = address;
  }

  void _clearSelectedLocation() {
    selectedAddress.value = '';
    selectedLatLng.value = null;
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
  }

  @override
  void onClose() {
    _locationSearchDebounce?.cancel();
    _categorySearchDebounce?.cancel();
    descriptionController.dispose();
    categorySearchController.dispose();
    locationSearchController.dispose();
    super.onClose();
  }

  clearAssistanceData() {
    descriptionController.clear();
    locationSearchController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
    hasSelectedDate.value = false;
    hasSelectedTime.value = false;
    selectedAddress.value = '';
    selectedLatLng.value = null;
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    locationPredictions.clear();
    _locationSearchDebounce?.cancel();
    _categorySearchDebounce?.cancel();
    selectedCategories.clear();
    newCategories.clear();
    categorySearchController.clear();
    categorySearchQuery.value = '';
    attachments.clear();
    selectedVolunteer.value = '';
    formattedDateAndTime.value = '';
    hasLocationPermission.value = false;
  }

  var createAssistanceStatus = RequestStatus.idle.obs;

  bool get canAddMoreAttachments => attachments.length < 10;

  void addAttachments(List<XFile> files) {
    if (files.isEmpty) return;

    final availableSlots = 10 - attachments.length;
    if (availableSlots <= 0) {
      appSnackbar("Limit Reached", "You can attach up to 10 files.");
      return;
    }

    attachments.addAll(files.take(availableSlots));
    if (files.length > availableSlots) {
      appSnackbar("Limit Reached", "Only 10 files can be attached.");
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= attachments.length) return;
    attachments.removeAt(index);
  }

  void createAssistanceByUser(data) async {
    createAssistanceStatus.value = RequestStatus.loading;
    debugPrint(
      '[Assistance] Creating request with ${attachments.length} attachment(s). Fields: ${data.keys.join(', ')}',
    );

    final result = await createAssistanceRepository.userCreateAssistance(
      data,
      attachments.toList(),
    );

    if (result['success'] == true) {
      clearAssistanceData();
      createAssistanceStatus.value = RequestStatus.success;
      final bottomController = Get.find<Bottomcontroller>();
      bottomController.updateIndex(1);
      Get.offAll(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
    } else {
      createAssistanceStatus.value = RequestStatus.error;

      final message = (result['message'] ?? "Registration failed").toString();
      appSnackbar("Error", message);
    }
  }

  var selectedCategory = Rx<AssistanceReasonsData?>(null);

  void selectCategory(AssistanceReasonsData category) {
    final id = category.id;
    if (id == null || id.isEmpty) return;
    if (selectedCategories.contains(id)) {
      selectedCategories.remove(id);
    } else {
      selectedCategories.add(id);
    }
  }

  var selectedCategories = [].obs;
  bool isSelected(AssistanceReasonsData category) {
    return selectedCategories.contains(category.id);
  }

  final RxList<String> newCategories = <String>[].obs;
  final RxString categorySearchQuery = ''.obs;
  var categories = <AssistanceReasonsData>[].obs;
  var getReasonsForAssistanceStatus = RequestStatus.idle.obs;
  final RxString categoryFeedMessage = ''.obs;

  List<AssistanceReasonsData> get suggestedCategories {
    final selectedIds = selectedCategories.toSet();
    final query = categorySearchQuery.value.trim().toLowerCase();
    final source = query.isEmpty
        ? categories
        : categories.where((item) {
            return (item.name ?? '').toLowerCase().contains(query);
          });
    return source
        .where((item) => !selectedIds.contains(item.id))
        .take(8)
        .toList();
  }

  bool get hasAnyCategorySelection =>
      selectedCategories.isNotEmpty || newCategories.isNotEmpty;

  bool get canAddNewCategory {
    final value = categorySearchQuery.value.trim();
    if (value.isEmpty) return false;

    final normalized = value.toLowerCase();
    final existsInCategories = categories.any(
      (item) => (item.name ?? '').toLowerCase() == normalized,
    );
    final existsInNew = newCategories.any(
      (item) => item.toLowerCase() == normalized,
    );
    return !existsInCategories && !existsInNew;
  }

  AssistanceReasonsData? get matchedCategory {
    final query = categorySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return null;

    for (final item in categories) {
      if ((item.name ?? '').toLowerCase().contains(query)) {
        return item;
      }
    }
    return null;
  }

  void updateCategorySearch(String value) {
    categorySearchQuery.value = value;
    _categorySearchDebounce?.cancel();

    final query = value.trim();
    if (query.length < 2) return;

    _categorySearchDebounce = Timer(const Duration(milliseconds: 350), () {
      searchCategoriesForAssistance(query);
    });
  }

  void addNewCategory([String? value]) {
    final rawValue = (value ?? categorySearchController.text).trim();
    if (rawValue.isEmpty) return;

    final normalized = rawValue.toLowerCase();
    final existingCategory = categories.firstWhereOrNull(
      (item) => (item.name ?? '').toLowerCase() == normalized,
    );
    if (existingCategory != null) {
      addMatchedCategory(existingCategory);
      return;
    }

    final existsInNew = newCategories.any(
      (item) => item.toLowerCase() == normalized,
    );
    if (!existsInNew) {
      newCategories.add(rawValue);
    }
    categorySearchController.clear();
    categorySearchQuery.value = '';
  }

  void addMatchedCategory(AssistanceReasonsData category) {
    if (category.id == null || category.id!.isEmpty) return;
    if (!selectedCategories.contains(category.id)) {
      selectedCategories.add(category.id);
    }
    categorySearchController.clear();
    categorySearchQuery.value = '';
  }

  void removeNewCategory(String value) {
    newCategories.remove(value);
  }

  Future<void> getCategoriesForAssistance() async {
    getReasonsForAssistanceStatus.value = RequestStatus.loading;
    categoryFeedMessage.value = '';

    final location = await _getCurrentCategoryFeedLocation();
    if (location == null) {
      categories.clear();
      categoryFeedMessage.value = "Location required to load nearby categories";
      getReasonsForAssistanceStatus.value = RequestStatus.error;
      return;
    }

    final result = await createAssistanceRepository.getCategoryFeed(
      latitude: location.latitude,
      longitude: location.longitude,
      limit: 20,
    );

    if (result['success'] == true) {
      categories.assignAll(_parseCategories(result['data']));
      getReasonsForAssistanceStatus.value = RequestStatus.success;
    } else {
      getReasonsForAssistanceStatus.value = RequestStatus.error;
      categoryFeedMessage.value =
          result['message'] ?? "Unable to load nearby categories";

      appSnackbar("Error", result['message'] ?? "Registration failed");
    }
  }

  Future<LatLng?> _getCurrentCategoryFeedLocation() async {
    if (selectedLatLng.value != null) {
      return selectedLatLng.value;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> searchCategoriesForAssistance(String query) async {
    final result = await createAssistanceRepository.searchAssistanceReasons(
      query,
    );
    if (result['success'] != true) return;

    final searchedCategories = _parseCategories(result['data']);
    for (final category in searchedCategories) {
      final id = category.id;
      if (id == null || id.isEmpty) continue;
      final existingIndex = categories.indexWhere((item) => item.id == id);
      if (existingIndex == -1) {
        categories.add(category);
      }
    }
    categories.refresh();
  }

  List<AssistanceReasonsData> _parseCategories(dynamic data) {
    final rawList = data is Map && data['data'] is List
        ? data['data'] as List
        : data is List
        ? data
        : const [];

    return rawList
        .whereType<Map>()
        .map(
          (item) => AssistanceReasonsData.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }
}
