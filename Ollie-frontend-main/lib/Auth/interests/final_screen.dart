import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/CreateProfile/create_profile_controller.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

class FinalScreen extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());
  final interestController = Get.put(InterestController());
  FinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/2094.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(), // Pushes content to bottom

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "That’s it! Ollie’s\ngot your back.\nLet’s begin!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 55.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    30.verticalSpace,
                    Obx(() {
                      if (controller.createProfileStatus.value ==
                          RequestStatus.loading) {
                        return CircularProgressIndicator();
                      }
                      return CustomButton(
                        text: "Next",
                        onPressed: () {
                          var data = {
                            "userPhoneNumber":
                                controller.phoneController.value.text,
                            "userFirstName":
                                controller.firstNameController.value.text,
                            "userLastName":
                                controller.lastNameController.value.text,
                            "userDateOfBirth": controller
                                .formattedDateString
                                .value
                                .toString(),
                            "userGender": controller.selectedGender.value
                                .toUpperCase(),
                            "interest": interestController.selectedInterestIds
                                .toList(),
                            "userDeviceToken": "test",
                            "userDeviceType": Platform.isAndroid
                                ? "ANDROID"
                                : "IOS",
                            "emergencyContactNumber":
                                interestController.selectedPhoneNumber.value,
                            "wantDailyActivities":
                                interestController.selectedAnswer.value,
                            "wantDailySupplement":
                                interestController.dailyActivityAnswer.value,
                            "userCity": "SanFrancisco",
                            "userStates": "California",
                            "userCountry": "USA",
                          };
                          print(data);
                          controller.userProfile(data);
                          // Get.to(() => Login_Screen(), transition: Transition.fadeIn);
                        },
                        width: 390.w,
                        height: 50.h,
                        color: buttonColor,
                        textColor: Colors.white,
                        fontSize: 18,
                      );
                    }),
                    60.verticalSpace,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




//  width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/2094.png"),
//             fit: BoxFit.cover,
//           ),
//         ),