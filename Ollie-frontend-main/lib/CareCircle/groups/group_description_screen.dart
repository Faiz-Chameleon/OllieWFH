// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/group_information_screen.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

class GroupDescriptionScreen extends StatelessWidget {
  GroupDescriptionScreen({super.key});

  final CreateGroupController controller = Get.put(CreateGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      40.verticalSpace,
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, color: Colors.black),
                            SizedBox(width: 8),
                            Text("Create new group", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      30.verticalSpace,
                      Text(
                        "Add group\ndescription",
                        style: TextStyle(color: HeadingColor, fontSize: 34.sp, fontWeight: FontWeight.bold),
                      ),
                      30.verticalSpace,
                      TextField(
                        controller: controller.descriptionController,
                        onChanged: (val) => controller.description.value = val,
                        maxLines: 5,
                        minLines: 4,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Add a description",
                          filled: true,
                          fillColor: const Color(0xFFF4EAD5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      20.verticalSpace,
                      Obx(() {
                        final isActive = controller.description.value.trim().isNotEmpty;
                        return CustomButton(
                          text: "Next",
                          onPressed: isActive
                              ? () {
                                  print("Description: ${controller.description.value}");
                                  Get.to(() => GroupReviewScreen(), transition: Transition.fadeIn);
                                }
                              : null,
                          height: 50.h,
                          color: isActive ? buttonColor : const Color(0xFFD6CCBC),
                          textColor: isActive ? Colors.white : Colors.grey,
                          width: double.infinity,
                        );
                      }),
                      50.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom smiley image
          Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
        ],
      ),
    );
  }
}
