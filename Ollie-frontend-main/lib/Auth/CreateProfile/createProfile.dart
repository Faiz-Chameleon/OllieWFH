import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ollie/Auth/CreateProfile/create_profile_controller.dart';

import 'package:ollie/Auth/interests/wellcome_sreen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Constants/constants.dart' as Colors;
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

class CreateProfileScreen extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());
  CreateProfileScreen({super.key});

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
                          "Create Profile",
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
                    controller: controller.firstNameController,
                    hintText: "Enter your First Name",
                    labelText: "First Name",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  20.verticalSpace,

                  CustomTextField(
                    controller: controller.lastNameController,
                    hintText: "Enter your Last Name",
                    labelText: "Last Name",
                    keyboardType: TextInputType.name,
                  ),
                  20.verticalSpace,
                  Obx(
                    () => DropdownButtonFormField2<String>(
                      isExpanded: true,
                      decoration: customInputDecoration(labelText: "").copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      hint: Text(
                        'Select Gender',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        textAlign: TextAlign.left,
                      ),
                      value: controller.selectedGender.value.isEmpty
                          ? null
                          : controller.selectedGender.value,
                      items: ["Male", "Female", "Other"]
                          .map(
                            (gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  gender,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        controller.selectedGender.value = value ?? '';
                      },
                      dropdownStyleData: DropdownStyleData(
                        direction: DropdownDirection.textDirection,
                        elevation: 3,
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kprimaryColor,
                        ),
                      ),
                    ),
                  ),

                  20.verticalSpace,

                  Obx(
                    () => InkWell(
                      onTap: () => controller.pickDate(context),
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 60,
                        child: InputDecorator(
                          decoration: customInputDecoration(
                            hintText: "Select date",
                            labelText: "",
                            suffixIcon: Icon(
                              Icons.calendar_month,
                              color: Colors.grey,
                              size: 25.sp,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.selectedDate.value == null
                                  ? "Select date"
                                  : "${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: controller.selectedDate.value == null
                                    ? Colors.grey
                                    : Colors.Black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  IntlPhoneField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter your phone number",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.only(
                        left: 30,
                        bottom: 15,
                        top: 15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color(0xff463C3380),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),

                        borderSide: const BorderSide(
                          color: Color(0xff463C3380),
                        ),
                      ),
                    ),
                    initialCountryCode: 'CA',
                    onChanged: (phone) {
                      controller.phoneController.text = phone.completeNumber;
                    },
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  50.verticalSpace,

                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      // Add validation here if needed
                      Get.to(
                        () => Well_Come_Screen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    width: 390.w,
                    height: 50.h,
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),

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
