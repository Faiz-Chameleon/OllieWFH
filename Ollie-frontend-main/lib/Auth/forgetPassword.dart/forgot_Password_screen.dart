// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/forgetPassword.dart/forgot_password_controller.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

// ignore: camel_case_types
class Forgot_Password_Screen extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );
  final _formKey = GlobalKey<FormState>();

  Forgot_Password_Screen({super.key});

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
                fit: BoxFit.contain,
                width: double.infinity,
                height: 335.h,
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
                            "Enter Your email here",
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
                    CustomTextField(
                      controller: controller.ForgotemailController,
                      hintText: "Enter your email",
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required!';
                        }
                        return null;
                      },
                    ),
                    20.verticalSpace,

                    Obx(() {
                      if (controller.forgotPasswordStatus.value ==
                          RequestStatus.loading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                        text: "Continue",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.forgotPassword(
                              controller.ForgotemailController.text,
                            );
                          }
                          // Get.to(() => Otp_Screen(), transition: Transition.fadeIn);
                        },
                        width: 390.w,

                        height: 50.h,
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
