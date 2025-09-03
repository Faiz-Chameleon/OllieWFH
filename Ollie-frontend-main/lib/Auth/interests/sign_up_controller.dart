import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/Otp/otp_screen.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/request_status.dart';

class SignUpController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  RxString selectedGender = ''.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  final RxString selectedRole = ''.obs;

  final List<String> roleOptions = ['Mom', 'Dad', 'Auntie', 'Uncle', 'Grandma', 'Grandpa', 'Nanny', 'Other'];

  void selectRole(String role) {
    selectedRole.value = role;
  }

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
    }
  }

  var registerStatus = RequestStatus.idle.obs;
  RxString receivedOTPFromAPI = "".obs;
  void registerUser(String email) async {
    registerStatus.value = RequestStatus.loading;

    final result = await authRepository.signUp({"userEmail": email});

    if (result['success'] == true) {
      registerStatus.value = RequestStatus.success;

      Get.to(() => Otp_Screen(comesFromWhere: "fromSignUp"), transition: Transition.fadeIn);

      Get.snackbar("Success", result['message'] ?? "User registered");
    } else {
      registerStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "Registration failed");
    }
  }
  //   resendOtp

  // body

  // email
}
