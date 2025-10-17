import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Auth/interests/Interests_controller.dart';
import 'package:ollie/Auth/interests/reminder_permission_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

// ignore: camel_case_types
class Reminder_Screen extends StatelessWidget {
  Reminder_Screen({super.key});
  final controller = Get.put(InterestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(color: BGcolor),

          // Bottom Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Group 1000000919.png", // same as previous screens
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
                    "Get reminders right on time.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    "Do you take any\ndaily meds or\nsupplements?",
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  40.verticalSpace,

                  // Yes Button
                  Obx(
                    () => CustomButton(
                      text: "Yes",
                      onPressed: () {
                        controller.selectAnswer(true);
                        Get.to(
                          () => Reminder_Permission_Screen(),
                          transition: Transition.fadeIn,
                        );
                      },
                      color: controller.selectedAnswer.value
                          ? buttonColor
                          : Colors.grey.shade300,
                      textColor: controller.selectedAnswer.value
                          ? Colors.white
                          : Colors.grey,
                      fontSize: 18,
                      height: 55.h,
                    ),
                  ),
                  20.verticalSpace,
                  Obx(
                    () => CustomButton(
                      text: "No",
                      onPressed: () {
                        controller.selectAnswer(false);
                        Get.to(
                          () => Reminder_Permission_Screen(),
                          transition: Transition.fadeIn,
                        );
                      },
                      color: !controller.selectedAnswer.value
                          ? buttonColor
                          : Colors.grey.shade300,
                      textColor: !controller.selectedAnswer.value
                          ? Colors.white
                          : Colors.grey,
                      fontSize: 18,
                      height: 55.h,
                    ),
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
