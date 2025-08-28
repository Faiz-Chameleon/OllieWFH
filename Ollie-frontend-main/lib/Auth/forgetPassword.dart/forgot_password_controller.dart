import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/Otp/otp_screen.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/request_status.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  // ignore: non_constant_identifier_names
  final TextEditingController ForgotemailController = TextEditingController();

  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  var forgotPasswordStatus = RequestStatus.idle.obs;

  void forgotPassword(String email) async {
    try {
      forgotPasswordStatus.value = RequestStatus.loading;
      final result = await authRepository.forgotPassword({"userEmail": email});
      if (result['success'] == true) {
        forgotPasswordStatus.value = RequestStatus.success;
        Get.to(
          () => Otp_Screen(comesFromWhere: "fromForgotPassword"),
          transition: Transition.fadeIn,
        );
        Get.snackbar("Success", result['message'] ?? 'User registered');
      } else {
        forgotPasswordStatus.value = RequestStatus.success;

        Get.snackbar("Error", result['message'] ?? "Registration failed");
      }
    } catch (e) {
      forgotPasswordStatus.value = RequestStatus.error;
      Get.snackbar("Error", e.toString());
    }
  }

  var resetPasswordStatus = RequestStatus.idle.obs;
  void resetPassword(data) async {
    try {
      resetPasswordStatus.value = RequestStatus.loading;
      final result = await authRepository.resetPasswordMethod(data);
      if (result['success'] == true) {
        resetPasswordStatus.value = RequestStatus.success;
        Get.offAll(() => Login_Screen(), transition: Transition.fadeIn);
        Get.snackbar("Success", result['message'] ?? 'User registered');
      } else {
        resetPasswordStatus.value = RequestStatus.success;

        Get.snackbar("Error", result['message'] ?? "Registration failed");
      }
    } catch (e) {
      forgotPasswordStatus.value = RequestStatus.error;
      Get.snackbar("Error", e.toString());
    }
  }
}
