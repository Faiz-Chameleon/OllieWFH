// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Auth/interests/sign_up_controller.dart';
import 'package:ollie/common/common.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ollie/request_status.dart';

// ignore: camel_case_types
class Sign_Up_Screen extends StatelessWidget {
  final SignUpController controller = Get.put(SignUpController());

  Sign_Up_Screen({super.key});

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
                children: [
                  60.verticalSpace,
                  Row(
                    children: [
                      SizedBox(
                        width: 380.w,
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: HeadingColor,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  30.verticalSpace,

                  CustomTextField(
                    controller: controller.emailController,
                    hintText: "Enter your email",
                    labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  20.verticalSpace,

                  CustomTextField(
                    controller: controller.passwordController,
                    hintText: "Enter Confirm Password",
                    labelText: "Password",
                    keyboardType: TextInputType.name,
                  ),
                  20.verticalSpace,

                  CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: "Enter Confirm Password",
                    labelText: "Confirm Password",
                    keyboardType: TextInputType.name,
                  ),

                  // 20.verticalSpace,

                  // Obx(
                  //   () => DropdownButtonFormField2<String>(
                  //     isExpanded: true,
                  //     decoration: customInputDecoration(labelText: "").copyWith(
                  //       contentPadding: const EdgeInsets.symmetric(
                  //         horizontal: 30,
                  //         vertical: 15,
                  //       ),
                  //     ),
                  //     hint: Text(
                  //       'Select Gender',
                  //       style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  //       textAlign: TextAlign.left,
                  //     ),
                  //     value: controller.selectedGender.value.isEmpty
                  //         ? null
                  //         : controller.selectedGender.value,
                  //     items: ["Male", "Female", "Other"]
                  //         .map(
                  //           (gender) => DropdownMenuItem<String>(
                  //             value: gender,
                  //             child: Align(
                  //               alignment: Alignment.centerLeft,
                  //               child: Text(
                  //                 gender,
                  //                 style: TextStyle(fontSize: 16.sp),
                  //               ),
                  //             ),
                  //           ),
                  //         )
                  //         .toList(),
                  //     onChanged: (value) {
                  //       controller.selectedGender.value = value ?? '';
                  //     },
                  //     dropdownStyleData: DropdownStyleData(
                  //       direction: DropdownDirection.textDirection,
                  //       elevation: 3,
                  //       maxHeight: 200,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10),
                  //         color: kprimaryColor,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // 20.verticalSpace,

                  // Obx(
                  //   () => InkWell(
                  //     onTap: () => controller.pickDate(context),
                  //     borderRadius: BorderRadius.circular(50),
                  //     child: SizedBox(
                  //       height: 60,
                  //       child: InputDecorator(
                  //         decoration: customInputDecoration(
                  //           hintText: "Select date",
                  //           labelText: "",
                  //           suffixIcon: Icon(
                  //             Icons.calendar_month,
                  //             color: Colors.grey,
                  //             size: 25.sp,
                  //           ),
                  //         ),
                  //         child: Align(
                  //           alignment: Alignment.centerLeft,
                  //           child: Text(
                  //             controller.selectedDate.value == null
                  //                 ? "Select date"
                  //                 : "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}",
                  //             style: TextStyle(
                  //               fontSize: 16.sp,
                  //               color: controller.selectedDate.value == null
                  //                   ? Colors.grey
                  //                   : Colors.black,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // 20.verticalSpace,
                  // IntlPhoneField(
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     labelText: "Phone Number",
                  //     hintText: "Enter your phone number",
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     contentPadding: const EdgeInsets.only(
                  //       left: 30,
                  //       bottom: 15,
                  //       top: 15,
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(50),
                  //       borderSide: const BorderSide(
                  //         color: Color(0xff463C3380),
                  //       ),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(50),

                  //       borderSide: const BorderSide(
                  //         color: Color(0xff463C3380),
                  //       ),
                  //     ),
                  //   ),
                  //   initialCountryCode: 'CA',
                  //   onChanged: (phone) {
                  //     controller.phoneController.text = phone.completeNumber;
                  //   },
                  //   style: TextStyle(fontSize: 16.sp),
                  // ),
                  50.verticalSpace,
                  Obx(() {
                    if (controller.registerStatus.value ==
                        RequestStatus.loading) {
                      return CircularProgressIndicator();
                    }
                    return CustomButton(
                      text: "Continue",
                      onPressed: () {
                        controller.registerUser(
                          controller.emailController.value.text.toString(),
                        );
                        // Add validation here if needed
                        // Get.to(
                        //   () => Well_Come_Screen(),
                        //   transition: Transition.fadeIn,
                        // );
                      },
                      width: 390.w,
                      height: 50.h,
                      color: buttonColor,
                      textColor: Colors.white,
                      fontSize: 18,
                    );
                  }),

                  80.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
