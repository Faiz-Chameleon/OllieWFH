import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/forgetPassword.dart/forgot_password_controller.dart';

import 'package:ollie/Auth/forgetPassword.dart/reset_password_screen.dart';
import 'package:ollie/Auth/interests/sign_up_controller.dart';
import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/Otp/otp_controller.dart';
import 'package:ollie/common/common.dart';

// ignore: camel_case_types
class Otp_Screen extends StatelessWidget {
  final String comesFromWhere;
  final OtpController controller = Get.put(OtpController());
  final SignUpController userRegisterController = Get.put(SignUpController());
  final ForgotPasswordController forgotPasswordcontroller = Get.put(
    ForgotPasswordController(),
  );

  Otp_Screen({super.key, required this.comesFromWhere});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: BGcolor),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Group 1000000919.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 400.h,
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  140.verticalSpace,
                  Row(
                    children: [
                      SizedBox(
                        width: 380.w,
                        child: Text(
                          "Enter Your OTP",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  50.verticalSpace,

                  OtpTextField(
                    textStyle: TextStyle(fontSize: 20),
                    numberOfFields: 6,
                    borderColor: Colors.black,
                    showFieldAsBox: true,
                    borderRadius: BorderRadius.circular(12),
                    fieldWidth: 55.w,
                    onSubmit: (String verificationCode) {
                      controller.enteredOtp.value = verificationCode;
                      // controller.verifyOtp(
                      //   verificationCode,
                      // ); // Optional if you want to store or verify OTP
                      // Get.to(
                      //   () => Reset_Password_Screen(),
                      //   transition: Transition.fadeIn,
                      // );
                    },
                  ),

                  40.verticalSpace,

                  Obx(() {
                    return controller.isResendEnabled.value
                        ? TextButton(
                            onPressed: () {
                              controller.resendOtp(
                                userRegisterController.emailController.text,
                              );
                            },
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 130.w,
                                      height: 130.h,
                                      child: CircularProgressIndicator(
                                        value: controller.timer.value / 30,
                                        strokeWidth: 8,
                                        color: kprimaryColor,
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 55,
                                      backgroundColor: ksecondaryColor,
                                      child: Text(
                                        "${controller.timer.value}s",
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              10.verticalSpace,
                              Text(
                                "Please wait to resend OTP",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                  }),

                  80.verticalSpace,
                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      final code = controller.enteredOtp.value;
                      if (code.length < 6) {
                        Get.snackbar(
                          "Invalid OTP",
                          "Please enter a valid 6-digit OTP",
                        );
                        return;
                      }
                      // else if (userRegisterController
                      //         .receivedOTPFromAPI
                      //         .value !=
                      //     controller.enteredOtp.value) {
                      //   Get.snackbar("Wrong OTP", "You have entered wrong otp");
                      //   return;
                      // }
                      var verifyAtForgotPassword = {
                        "userEmail":
                            forgotPasswordcontroller.ForgotemailController.text,
                        "otp": controller.enteredOtp.value,
                      };
                      var data = {
                        "userEmail":
                            userRegisterController.emailController.text,
                        "otp": controller.enteredOtp.value,
                        "userPassword": userRegisterController
                            .passwordController
                            .text
                            .trim(),
                      };
                      controller.verifyUserOTP(
                        comesFromWhere == "fromSignUp"
                            ? data
                            : verifyAtForgotPassword,
                        route: comesFromWhere,
                      );
                      // Get.to(
                      //   () => Well_Come_Screen(),
                      //   transition: Transition.fadeIn,
                      // );
                      // Get.to(
                      //   () => Reset_Password_Screen(),
                      //   transition: Transition.fadeIn,
                      // );
                    },
                    width: 390.w,

                    height: 50.h,
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
