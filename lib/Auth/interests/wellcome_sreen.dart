// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/CreateProfile/create_profile_controller.dart';

import 'package:ollie/Auth/interests/interests_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/interests/sign_up_controller.dart';
import 'package:ollie/common/common.dart';

// ignore: camel_case_types
class Well_Come_Screen extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());
  Well_Come_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/2092.png"),
              ),
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
                      Container(
                        width: 380.w,
                        child: Text(
                          "Hi ${controller.firstNameController.text} !",
                          style: TextStyle(
                            color: HeadingColor,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Get.to(
                          //   () => Sign_Up_Screen(),
                          //   transition: Transition.fadeIn,
                          // );
                        },
                        child: Container(
                          width: 320.w,
                          child: Text(
                            "I’m Ollie, your helping hand. Let’s set things up just for you!",
                            style: TextStyle(
                              fontSize: 24.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  40.verticalSpace,
                  CustomButton(
                    text: "Next",
                    onPressed: () {
                      Get.to(
                        () => Interests_screen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    width: 390.w,

                    height: 50.h,
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),

                  100.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
