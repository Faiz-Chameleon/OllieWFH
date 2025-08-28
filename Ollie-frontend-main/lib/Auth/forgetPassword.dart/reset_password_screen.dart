import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/forgetPassword.dart/forgot_password_controller.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

// ignore: camel_case_types
class Reset_Password_Screen extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );
  final _formKey = GlobalKey<FormState>();

  Reset_Password_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
          clipBehavior: Clip.none,
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
                        // ignore: sized_box_for_whitespace
                        Container(
                          width: 380.w,
                          child: Text(
                            "Reset Your Password",
                            style: TextStyle(
                              color: HeadingColor,
                              fontSize: 55.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    50.verticalSpace,
                    Obx(
                      () => CustomTextField(
                        controller: controller.newPasswordController,
                        hintText: "Enter new password",
                        labelText: "New Password",
                        obscureText: !controller.isNewPasswordVisible.value,
                        suffixIcon: controller.isNewPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixTap: controller.toggleNewPasswordVisibility,
                        validator: (value) =>
                            value!.isEmpty ? 'New password is required' : null,
                      ),
                    ),

                    20.verticalSpace,

                    Obx(
                      () => CustomTextField(
                        controller: controller.confirmPasswordController,
                        hintText: "Confirm new password",
                        labelText: "Confirm Password",
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        suffixIcon: controller.isConfirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixTap: controller.toggleConfirmPasswordVisibility,
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Please confirm your password';
                          if (value != controller.newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),

                    20.verticalSpace,

                    Obx(() {
                      if (controller.resetPasswordStatus.value ==
                          RequestStatus.loading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                        text: "Continue",
                        onPressed: () {
                          var data = {
                            "userPassword":
                                controller.newPasswordController.text,
                          };
                          if (_formKey.currentState!.validate()) {
                            controller.resetPassword(data);
                          }
                        },
                        width: 390.w,
                        height: 50,
                        color: buttonColor,
                        textColor: Colors.white,
                        fontSize: 18,
                      );
                    }),

                    100.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
