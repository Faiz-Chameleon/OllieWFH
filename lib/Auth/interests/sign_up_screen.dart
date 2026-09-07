// ignore_for_file: avoid_print, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/interests/sign_up_controller.dart';
import 'package:ollie/Auth/login/login_screen.dart';
import 'package:ollie/common/common.dart';

import 'package:ollie/request_status.dart';

// ignore: camel_case_types
class Sign_Up_Screen extends StatelessWidget {
  final SignUpController controller = Get.put(SignUpController());
  final _formKey = GlobalKey<FormState>();

  Sign_Up_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(color: BGcolor),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
              ),
            ),

            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      110.verticalSpace,
                      Row(
                        children: [
                          SizedBox(
                            width: 380.w,
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.darkerGrotesque(
                                color: HeadingColor,
                                fontSize: responsiveFontSize(34, min: 28, max: 38),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      30.verticalSpace,

                      CustomTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          // Simple email regex
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null; // validation passed
                        },
                        controller: controller.emailController,
                        hintText: "Enter your email",
                        labelText: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      20.verticalSpace,

                      Obx(
                        () => CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null; // validation passed
                          },
                          controller: controller.passwordController,
                          hintText: "Enter your password",
                          labelText: "Password",
                          obscureText: !controller.isPasswordVisible.value,
                          keyboardType: TextInputType.text,
                          suffixIcon: controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                          onSuffixTap: controller.togglePasswordVisibility,
                        ),
                      ),
                      20.verticalSpace,

                      Obx(
                        () => CustomTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != controller.passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null; // means validation passed
                          },
                          controller: controller.confirmPasswordController,
                          hintText: "Enter Confirm Password",
                          labelText: "Confirm Password",
                          obscureText: !controller.isConfirmPasswordVisible.value,
                          keyboardType: TextInputType.text,
                          suffixIcon: controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                          onSuffixTap: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),

                      50.verticalSpace,
                      Obx(() {
                        if (controller.registerStatus.value == RequestStatus.loading) {
                          return CircularProgressIndicator();
                        }
                        return CustomButton(
                          text: "Continue",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.registerUser(controller.emailController.text.trim());
                            } else {
                              print("Validation failed");
                            }
                          },
                          width: 390.w,
                          // height: 50.h,
                          color: buttonColor,
                          textColor: Colors.white,
                          fontSize: 20,
                        );
                      }),

                      20.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: responsiveFontSize(18, min: 16, max: 22),
                              color: buttonColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Sign Up is pushed from Login, so pop back to it when we can
                              // and only build a fresh Login route if this is the root screen.
                              if (Navigator.of(context).canPop()) {
                                Get.back();
                              } else {
                                Get.off(() => Login_Screen(), transition: Transition.fadeIn);
                              }
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.darkerGrotesque(
                                fontSize: responsiveFontSize(16, min: 15, max: 20),
                                color: txtColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      80.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
            // Back navigation (hides itself when there is nothing to pop)
            const AuthBackButton(),
          ],
        ),
      ),
    );
  }
}
