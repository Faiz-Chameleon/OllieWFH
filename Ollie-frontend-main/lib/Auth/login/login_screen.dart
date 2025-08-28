import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/forgetPassword.dart/forgot_Password_screen.dart';
import 'package:ollie/Auth/interests/sign_up_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/login/login_controller.dart';

import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

// ignore: camel_case_types
class Login_Screen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  Login_Screen({super.key});

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

            Positioned(
              bottom: 55,
              left: 0,
              right: 0,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "By continuing, you agree to our",
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      // ignore: avoid_print
                      print("Terms & Conditions tapped");
                    },
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => Sign_Up_Screen(),
                            transition: Transition.fadeIn,
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: txtColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    140.verticalSpace,

                    // Auto-login loading indicator
                    Obx(
                      () => controller.isAutoLoggingIn.value
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: buttonColor,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Logging you in...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: buttonColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ),

                    Row(
                      children: [
                        Text(
                          "Login here",
                          style: TextStyle(
                            color: HeadingColor,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    20.verticalSpace,
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => Sign_Up_Screen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: Text(
                            "Sign Up here",
                            style: TextStyle(
                              fontSize: 30.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    50.verticalSpace,
                    CustomTextField(
                      controller: controller.emailController,
                      hintText: "Enter your email",
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Email required' : null,
                    ),
                    20.verticalSpace,
                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        hintText: "Enter your Password",
                        labelText: "Password",
                        obscureText: !controller.isPasswordVisible.value,
                        keyboardType: TextInputType.text,
                        suffixIcon: controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onSuffixTap: controller.togglePasswordVisibility,
                        validator: (value) =>
                            value!.isEmpty ? 'Password required' : null,
                      ),
                    ),

                    // Show indicator when credentials are auto-filled
                    20.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => GestureDetector(
                            onTap: () {
                              controller.toggleRememberMe(
                                !controller.rememberMe.value,
                              );
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged: controller.toggleRememberMe,
                                  activeColor: buttonColor,
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(
                              () => Forgot_Password_Screen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: buttonColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    20.verticalSpace,

                    Obx(() {
                      if (controller.loginStatus.value ==
                          RequestStatus.loading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                        text: "Login",
                        onPressed: () async {
                          var data = {
                            "userEmail": controller.emailController.text,
                            "userPassword": controller.passwordController.text,
                          };
                          if (_formKey.currentState!.validate()) {
                            controller.userLogin(data);
                          }

                          // final bottomController = Get.find<Bottomcontroller>();
                          // bottomController.updateIndex(0);
                          // Get.to(
                          //   () => ConvexStyledBarScreen(),
                          //   transition: Transition.fadeIn,
                          // );
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
