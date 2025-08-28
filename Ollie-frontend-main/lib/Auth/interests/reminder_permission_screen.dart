import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';

import 'package:ollie/Auth/interests/final_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

// ignore: camel_case_types
class Reminder_Permission_Screen extends StatelessWidget {
  final controller = Get.put(InterestController());
  Reminder_Permission_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(color: BGcolor),

          // Bottom decoration
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

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  140.verticalSpace,
                  Text(
                    "Stay on track with reminders.",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    "We will remind\nyou for your\ndaily activities.",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  40.verticalSpace,

                  // Allow Button
                  CustomButton(
                    text: "Allow",
                    onPressed: () {
                      controller.dailyActivityselectAnswer(true);
                      Get.to(
                        () => FinalScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                    height: 55.h,
                  ),
                  20.verticalSpace,

                  // Cancel Button
                  CustomButton(
                    text: "Cancel",
                    onPressed: () {
                      controller.dailyActivityselectAnswer(false);
                      Get.to(
                        () => FinalScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    color: Colors.grey.shade300,
                    textColor: Colors.grey,
                    fontSize: 18,
                    height: 55.h,
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
