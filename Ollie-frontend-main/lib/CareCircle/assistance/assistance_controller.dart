// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:ollie/CareCircle/assistance/assistance_repository.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Models/assistance_reasons_model.dart';
import 'package:ollie/request_status.dart';

class Assistance_Controller extends GetxController {
  final AssistanceRepository createAssistanceRepository =
      AssistanceRepository();

  final TextEditingController descriptionController = TextEditingController();
  final RxBool isExpanded = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  final RxString selectedAddress = ''.obs;
  final Rx<LatLng?> selectedLatLng = Rxn<LatLng>();
  RxDouble selectedLatitude = 0.0.obs;
  RxDouble selectedLongitude = 0.0.obs;

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
  void setDate(DateTime date) => selectedDate.value = date;
  void setTime(TimeOfDay time) => selectedTime.value = time;

  void updateDateAndTime() {
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

    print("dateAndTime: $formattedDateAndTime");
  }

  RxString formattedDateAndTime = "".obs;

  String get formattedDate =>
      DateFormat('dd-MMM-yyyy').format(selectedDate.value);

  String get formattedTime {
    final time = selectedTime.value;
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  Future<void> setLocationFromLatLng(LatLng latLng) async {
    selectedLatLng.value = latLng;
    final placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      selectedAddress.value =
          "${p.street}, ${p.locality}, ${p.administrativeArea} ${p.postalCode}";
    }
  }

  var createAssistanceStatus = RequestStatus.idle.obs;

  void createAssistanceByUser(data) async {
    createAssistanceStatus.value = RequestStatus.loading;

    final result = await createAssistanceRepository.userCreateAssistance(data);

    if (result['success'] == true) {
      createAssistanceStatus.value = RequestStatus.success;
      final bottomController = Get.find<Bottomcontroller>();
      bottomController.updateIndex(4);
      Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
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
      categories = (result['data'] as List)
          .map((data) => AssistanceReasonsData.fromJson(data))
          .toList();
      getReasonsForAssistanceStatus.value = RequestStatus.success;
    } else {
      getReasonsForAssistanceStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
    }
  }
}
