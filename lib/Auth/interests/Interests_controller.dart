// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/request_status.dart';

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
        Get.snackbar("No Contact", "Please select a valid contact.");
      }
    } catch (e) {
      print('Error picking contact: $e');
    }
  }

  bool get isContactSelected =>
      selectedContact.value.isNotEmpty &&
      selectedContactNumber.value.isNotEmpty;

  bool get hasSelection => interests.any((e) => e.isSelected);

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
        Get.snackbar("Failed to Load Interests", result['message']);
      }
    } catch (e) {
      getInterestStatus.value = RequestStatus.error;
      Get.snackbar("Error", e.toString());
    }
  }

  RxList<String> selectedInterestIds = <String>[].obs;
}
