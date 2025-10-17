// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
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

class Assistance_Controller extends GetxController {
  final AssistanceRepository createAssistanceRepository = AssistanceRepository();

  final TextEditingController descriptionController = TextEditingController();
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
      Get.snackbar("Location Disabled", "Please enable location services to continue.");
      hasLocationPermission.value = false;
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission Required",
        "Location permission is permanently denied. Please enable it from settings to continue.",
      );
      hasLocationPermission.value = false;
      return false;
    }

    if (permission == LocationPermission.denied) {
      Get.snackbar("Permission Required", "Please allow location access to pick your address.");
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

    formattedDateAndTime.value = combinedDateTime.toUtc().toIso8601String().toString();

    print("dateAndTime: $formattedDateAndTime");
  }

  RxString formattedDateAndTime = "".obs;

  void _updateCombinedDateTimeIfReady() {
    if (hasSelectedDate.value && hasSelectedTime.value) {
      updateDateAndTime();
    } else {
      formattedDateAndTime.value = '';
    }
  }

  String get formattedDate => hasSelectedDate.value ? DateFormat('dd-MMM-yyyy').format(selectedDate.value) : '';

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
    final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      selectedAddress.value = "${p.street}, ${p.locality}, ${p.administrativeArea} ${p.postalCode}";
    }
  }

  clearAssistanceData() {
    descriptionController.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
    hasSelectedDate.value = false;
    hasSelectedTime.value = false;
    selectedAddress.value = '';
    selectedLatLng.value = null;
    selectedLatitude.value = 0.0;
    selectedLongitude.value = 0.0;
    selectedCategories.clear();
    selectedVolunteer.value = '';
    formattedDateAndTime.value = '';
    hasLocationPermission.value = false;
  }

  var createAssistanceStatus = RequestStatus.idle.obs;

  void createAssistanceByUser(data) async {
    createAssistanceStatus.value = RequestStatus.loading;

    final result = await createAssistanceRepository.userCreateAssistance(data);

    if (result['success'] == true) {
      clearAssistanceData();
      createAssistanceStatus.value = RequestStatus.success;
      final bottomController = Get.find<Bottomcontroller>();
      bottomController.updateIndex(1);
      Get.offAll(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
    } else {
      createAssistanceStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
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
      categories = (result['data'] as List).map((data) => AssistanceReasonsData.fromJson(data)).toList();
      getReasonsForAssistanceStatus.value = RequestStatus.success;
    } else {
      getReasonsForAssistanceStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
    }
  }
}
