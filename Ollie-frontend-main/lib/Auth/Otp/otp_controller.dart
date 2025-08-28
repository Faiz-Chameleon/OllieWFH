// ignore: file_names
// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/CreateProfile/createProfile.dart';
import 'package:ollie/Auth/auth_repository.dart';
import 'package:ollie/Auth/forgetPassword.dart/reset_password_screen.dart';
import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/request_status.dart';

class OtpController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  RxInt timer = 30.obs;
  RxBool isResendEnabled = false.obs;
  Timer? _countdownTimer;
  RxString enteredOtp = ''.obs;

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  void startTimer() {
    timer.value = 30;
    isResendEnabled.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer.value == 0) {
        isResendEnabled.value = true;
        timer.cancel();
      } else {
        this.timer.value--;
      }
    });
  }

  resendOtp(String email) {
    startTimer();
    resendOTPAPI({"email": email});
  }

  void verifyOtp(String otp) {
    enteredOtp.value = otp;
    print("Entered OTP: $otp");
    // Call verification API here
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  var registerStatus = RequestStatus.idle.obs;
  void verifyUserOTP(Map<String, dynamic> data, {required String route}) async {
    try {
      registerStatus.value = RequestStatus.loading;
      final result = await authRepository.verifyOtp(data);
      registerStatus.value = RequestStatus.success;
      final token =
          result['data']['userToken']; // adjust based on your API structure
      final storage = FlutterSecureStorage();
      await storage.write(key: 'userToken', value: token);
      if (route == "fromSignUp") {
        Get.to(() => CreateProfileScreen(), transition: Transition.fadeIn);
      } else {
        Get.to(() => Reset_Password_Screen(), transition: Transition.fadeIn);
      }

      Get.snackbar("Success", result['message'] ?? 'User registered');
    } catch (e) {
      registerStatus.value = RequestStatus.error;
      Get.snackbar("Error", e.toString());
    }
  }

  void resendOTPAPI(Map<String, dynamic> data) async {
    try {
      registerStatus.value = RequestStatus.loading;
      final result = await authRepository.resendOtpMethod(data);

      registerStatus.value = RequestStatus.success;

      Get.snackbar("Success", result['message'] ?? 'User registered');
    } catch (e) {
      registerStatus.value = RequestStatus.error;
      Get.snackbar("Error", e.toString());
    }
  }
}
