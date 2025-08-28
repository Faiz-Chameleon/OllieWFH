import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';

import 'package:ollie/CareCircle/groups/group_description_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

class GroupDisplayPictureScreen extends StatelessWidget {
  GroupDisplayPictureScreen({super.key});

  final CreateGroupController imageController = Get.put(CreateGroupController());

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageController.selectedImage.value = File(picked.path);
    }
  }

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
                        "Add a display\npicture",
                        style: TextStyle(color: HeadingColor, fontSize: 34.sp, fontWeight: FontWeight.bold),
                      ),
                      30.verticalSpace,

                      Obx(() {
                        final file = imageController.selectedImage.value;
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: file != null
                                      ? FileImage(file)
                                      : const AssetImage("assets/images/Frame 1686560577.png") as ImageProvider,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(file != null ? "01 image selected" : "Add Photo", style: const TextStyle(fontSize: 14))),
                                const Icon(Icons.image_outlined),
                              ],
                            ),
                          ),
                        );
                      }),

                      20.verticalSpace,

                      Obx(
                        () => CustomButton(
                          text: "Next",
                          onPressed: imageController.selectedImage.value != null
                              ? () {
                                  // Navigate to description screen
                                  Get.to(() => GroupDescriptionScreen(), transition: Transition.fadeIn);
                                }
                              : null,
                          height: 50.h,
                          color: imageController.selectedImage.value != null ? buttonColor : const Color(0xFFD6CCBC),
                          textColor: imageController.selectedImage.value != null ? Colors.white : Colors.grey,
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

          Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
        ],
      ),
    );
  }
}
