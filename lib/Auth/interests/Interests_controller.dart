// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class InterestModel {
  final String name;
  final String interestId;
  bool isSelected;

  InterestModel({
    required this.name,
    required this.interestId,
    this.isSelected = false,
  });
}

class InterestController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  var interests = <InterestModel>[].obs;
  final TextEditingController interestSearchController =
      TextEditingController();
  final RxList<String> customInterests = <String>[].obs;
  final RxString interestSearchQuery = ''.obs;
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  var contacts = <Contact>[].obs;
  var selectedPhoneNumber = ''.obs;

  RxString selectedContact = ''.obs;
  RxString selectedContactNumber = ''.obs;

  void selectContact(String name, String number) {
    selectedContact.value = name;
    selectedContactNumber.value = number;
  }

  Future<void> pickContact() async {
    try {
      final contact = await _contactPicker.selectPhoneNumber();

      if (contact != null && contact.selectedPhoneNumber != null) {
        contacts.value = [contact];
        selectedPhoneNumber.value = contact.selectedPhoneNumber!;
      } else {
        appSnackbar("No Contact", "Please select a valid contact.");
      }
    } catch (e) {
      print('Error picking contact: $e');
    }
  }

  bool get isContactSelected =>
      selectedContact.value.isNotEmpty &&
      selectedContactNumber.value.isNotEmpty;

  bool get hasSelection => interests.any((e) => e.isSelected);

  bool get hasAnyInterestSelection =>
      hasSelection || customInterests.isNotEmpty;

  List<InterestModel> get filteredInterests {
    final query = interestSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return interests;
    return interests.where((item) {
      return item.name.toLowerCase().contains(query);
    }).toList();
  }

  List<InterestModel> get suggestedInterests {
    final selectedIds = selectedInterestIds.toSet();
    return interests
        .where((item) => !selectedIds.contains(item.interestId))
        .take(6)
        .toList();
  }

  bool get canAddCustomInterest {
    final value = interestSearchQuery.value.trim();
    if (value.isEmpty) return false;

    final normalized = value.toLowerCase();
    final existsInBuiltIn = interests.any((item) => item.name.toLowerCase() == normalized);
    final existsInCustom = customInterests.any((item) => item.toLowerCase() == normalized);
    return !existsInBuiltIn && !existsInCustom;
  }

  InterestModel? get matchedInterest {
    final query = interestSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return null;

    for (final item in interests) {
      if (item.name.toLowerCase().contains(query)) {
        return item;
      }
    }
    return null;
  }

  bool get hasMatchedInterest => matchedInterest != null;

  void updateInterestSearch(String value) {
    interestSearchQuery.value = value;
  }

  void addCustomInterest([String? value]) {
    final rawValue = (value ?? interestSearchController.text).trim();
    if (rawValue.isEmpty) return;

    final normalized = rawValue.toLowerCase();
    final existsInBuiltIn = interests.any((item) => item.name.toLowerCase() == normalized);
    final existsInCustom = customInterests.any((item) => item.toLowerCase() == normalized);
    if (existsInBuiltIn || existsInCustom) {
      interestSearchController.clear();
      interestSearchQuery.value = '';
      return;
    }

    customInterests.add(rawValue);
    interestSearchController.clear();
    interestSearchQuery.value = '';
  }

  void addMatchedInterest(InterestModel item) {
    final index = interests.indexWhere((interest) => interest.interestId == item.interestId);
    if (index == -1) return;

    if (!interests[index].isSelected) {
      toggleInterest(index);
    }

    interestSearchController.clear();
    interestSearchQuery.value = '';
  }

  void removeCustomInterest(String value) {
    customInterests.remove(value);
  }

  void toggleInterest(int index) {
    interests[index].isSelected = !interests[index].isSelected;
    final interest = interests[index];
    if (interest.isSelected) {
      selectedInterestIds.add(interest.interestId);
    } else {
      selectedInterestIds.remove(interest.interestId);
    }
    interests.refresh();
  }

  RxBool selectedAnswer = false.obs;
  RxBool dailyActivityAnswer = false.obs;

  void dailyActivityselectAnswer(answer) {
    dailyActivityAnswer.value = answer;
  }

  void selectAnswer(answer) {
    selectedAnswer.value = answer;
  }

  var getInterestStatus = RequestStatus.idle.obs;
  void loadInterests() async {
    try {
      getInterestStatus.value = RequestStatus.loading;
      final result = await authRepository.getInterest();
      if (result['success'] == true) {
        getInterestStatus.value = RequestStatus.success;

        final rawList = result['data']["data"] as List;
        interests.value = rawList
            .map(
              (e) => InterestModel(
                name: e['name'] ?? 'Unnamed',
                interestId: e["id"],
              ),
            )
            .toList();
      } else {
        appSnackbar("Failed to Load Interests", result['message']);
      }
    } catch (e) {
      getInterestStatus.value = RequestStatus.error;
      appSnackbar("Error", e.toString());
    }
  }

  RxList<String> selectedInterestIds = <String>[].obs;

  @override
  void onClose() {
    interestSearchController.dispose();
    super.onClose();
  }
}
