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

class Assistance_Controller extends GetxController {
  final AssistanceRepository createAssistanceRepository =
      AssistanceRepository();
  final GooglePlacesService _googlePlacesService = GooglePlacesService();

  final TextEditingController descriptionController = TextEditingController();
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
  final RxList<GooglePlacePrediction> locationPredictions =
      <GooglePlacePrediction>[].obs;
  Timer? _locationSearchDebounce;

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
      final predictions = await _googlePlacesService.autocomplete(
        normalizedQuery,
      );
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
    descriptionController.dispose();
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
    selectedCategories.clear();
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
      if (message.toLowerCase().contains('not a valid fcm')) {
        appSnackbar(
          "Push Token Error",
          "The saved notification token is invalid. Log out and log in again on a real device so the backend receives a valid FCM token.",
        );
        return;
      }

      appSnackbar("Error", message);
    }
  }

  var selectedCategory = Rx<AssistanceReasonsData?>(null);

  void selectCategory(AssistanceReasonsData category) {
    var id = category.id ?? -1;
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

  var categories = <AssistanceReasonsData>[];
  var getReasonsForAssistanceStatus = RequestStatus.idle.obs;
  Future<void> getCategoriesForAssistance() async {
    getReasonsForAssistanceStatus.value = RequestStatus.loading;

    final result = await createAssistanceRepository.getEachAssistanceReasons();

    if (result['success'] == true) {
      categories = (result['data'] as List)
          .map((data) => AssistanceReasonsData.fromJson(data))
          .toList();
      getReasonsForAssistanceStatus.value = RequestStatus.success;
    } else {
      getReasonsForAssistanceStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "Registration failed");
    }
  }
}
