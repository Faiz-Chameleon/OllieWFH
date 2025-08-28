// ignore_for_file: camel_case_types, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/group_display_screen.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/Constants/constants.dart';

class Group_Creation_Screen extends StatelessWidget {
  Group_Creation_Screen({super.key});

  final CreateGroupController controller = Get.put(CreateGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SafeArea(
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
                        "Pick a name\nfor your group",
                        style: TextStyle(color: HeadingColor, fontSize: 34.sp, fontWeight: FontWeight.bold),
                      ),
                      30.verticalSpace,
                      TextField(
                        controller: controller.groupNameController,
                        onChanged: (value) => controller.groupName.value = value,
                        decoration: InputDecoration(
                          hintText: "Enter group name",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                      ),
                      20.verticalSpace,
                      Obx(
                        () => CustomButton(
                          text: "Next",
                          onPressed: controller.groupName.value.isNotEmpty
                              ? () {
                                  print("Group name: ${controller.groupName.value}");
                                  Get.to(() => GroupDisplayPictureScreen());
                                }
                              : null,
                          height: 50.h,
                          color: controller.groupName.value.isNotEmpty ? buttonColor : const Color(0xFFD6CCBC),
                          textColor: controller.groupName.value.isNotEmpty ? Colors.white : Colors.grey,
                          width: double.infinity,
                        ),
                      ),
                      50.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BOTTOM FIXED IMAGE
          Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
        ],
      ),
    );
  }
}
