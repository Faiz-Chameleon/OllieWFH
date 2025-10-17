import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';

import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';

class EditGroupScreen extends StatelessWidget {
  EditGroupScreen({super.key});

  final CreateGroupController controller = Get.find<CreateGroupController>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      controller.selectedImage.value = File(picked.path);
    }
  }

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
                            Text("Edit group", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      30.verticalSpace,

                      // Image Preview + Edit Photo
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Obx(
                            () => Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: controller.selectedImage.value != null
                                      ? Image.file(controller.selectedImage.value!, width: 100, height: 100, fit: BoxFit.cover)
                                      : Image.asset("assets/images/Frame 1686560577.png", width: 100, height: 100),
                                ),
                                const SizedBox(height: 6),
                                const Text("Edit Photo", style: TextStyle(fontSize: 13, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ),
                      ),

                      30.verticalSpace,

                      // Group Name Field
                      TextField(
                        controller: controller.groupNameController,
                        onChanged: (val) => controller.groupName.value = val,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Group Name",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        ),
                      ),

                      30.verticalSpace,

                      // Save Button
                      Obx(() {
                        final isValid = controller.groupName.value.trim().isNotEmpty;
                        return CustomButton(
                          text: "Next",
                          onPressed: isValid
                              ? () {
                                  controller.groupName.value = controller.groupNameController.text.trim();
                                  Get.back(); // Return to review screen
                                }
                              : null,
                          height: 50.h,
                          color: isValid ? buttonColor : const Color(0xFFD6CCBC),
                          textColor: isValid ? Colors.white : Colors.grey,
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

          // Bottom smile
          Image.asset("assets/images/Group 1000000919.png", width: double.infinity, height: 400.h, fit: BoxFit.cover),
        ],
      ),
    );
  }
}
