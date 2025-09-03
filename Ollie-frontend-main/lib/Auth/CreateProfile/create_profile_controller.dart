import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:ollie/request_status.dart';

class CreateProfileController extends GetxController {
  RxString countryValue = "".obs;
  RxString stateValue = "".obs;
  RxString cityValue = "".obs;
  final AuthRepository authRepository = AuthRepository();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  RxString selectedGender = ''.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final phoneController = TextEditingController();
  final formattedDateString = ''.obs;

  void pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kprimaryColor, onPrimary: Colors.white, onSurface: Colors.black),
            // ignore: deprecated_member_use
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kprimaryColor)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;

      // Format as dd-MM-yyyy
      String formatted = DateFormat('dd-MM-yyyy').format(picked);
      print("Formatted Date: $formatted");

      // You can also store it in a variable or observable
      formattedDateString.value = formatted;
      selectedDate.value = picked;
    }
  }

  var createProfileStatus = RequestStatus.idle.obs;

  clearFields() {
    final interestController = Get.put(InterestController());

    firstNameController.clear();
    lastNameController.clear();
    formattedDateString.value = "";
    selectedGender.value = "";
    cityValue.value = "";
    stateValue.value = "";
    countryValue.value = "";

    interestController.selectedPhoneNumber.value = "";
    interestController.selectedAnswer.value = false;
    interestController.dailyActivityAnswer.value = false;
  }

  void userProfile(data) async {
    createProfileStatus.value = RequestStatus.loading;

    final result = await authRepository.createProfile(data);

    if (result['success'] == true) {
      clearFields();
      final userModel = UserModel.fromJson(result);
      final userController = Get.put(UserController());
      if (userModel.data != null) {
        userController.setUser(userModel.data!);
      }
      final storage = FlutterSecureStorage();
      await storage.write(key: 'userToken', value: userModel.data?.userToken);
      createProfileStatus.value = RequestStatus.success;
      final bottomController = Get.put(Bottomcontroller());
      bottomController.updateIndex(0);
      Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);

      Get.snackbar("Success", result['message'] ?? "User registered");
    } else {
      createProfileStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
    }
  }
}
