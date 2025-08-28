// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Auth/interests/emergency_contact_screen.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';
import 'package:ollie/Constants/constants.dart';

import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

class Interests_screen extends StatelessWidget {
  Interests_screen({super.key}) {
    Future.microtask(() => controller.loadInterests());
  }

  final controller = Get.put(InterestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  140.verticalSpace,
                  Text(
                    "I’ll suggest things you’ll love!",
                    style: TextStyle(
                      color: HeadingColor,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    "Tell us about your interests",
                    style: TextStyle(
                      color: HeadingColor,
                      fontSize: 59.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Obx(() {
                    if (controller.getInterestStatus.value ==
                        RequestStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.interests.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            "No interests available.",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.interests.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3,
                          ),
                      itemBuilder: (context, index) {
                        final item = controller.interests[index];
                        final isSelected = item.isSelected;

                        return GestureDetector(
                          onTap: () {
                            print(controller.interests[index].interestId);
                            controller.toggleInterest(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ksecondaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  30.verticalSpace,
                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      print(controller.selectedInterestIds);
                      Get.to(
                        () => EmergencyContactScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    width: 390.w,
                    height: 50,
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
