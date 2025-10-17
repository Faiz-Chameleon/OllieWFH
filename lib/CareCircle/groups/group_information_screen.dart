import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/edit_group_screen.dart';
import 'package:ollie/CareCircle/groups/groups_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

class GroupReviewScreen extends StatelessWidget {
  GroupReviewScreen({super.key});

  final CreateGroupController controller = Get.find<CreateGroupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  100.verticalSpace,
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black),
                        SizedBox(width: 8),
                        Text("Create new group", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  30.verticalSpace,
                  Text(
                    "Review group\ninformation",
                    style: TextStyle(color: HeadingColor, fontSize: 34.sp, fontWeight: FontWeight.bold),
                  ),
                  30.verticalSpace,

                  // Group name + image
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: controller.selectedImage.value != null
                                ? FileImage(controller.selectedImage.value!)
                                : const AssetImage("assets/images/Frame 1686560577.png") as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(controller.groupName.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: () => Get.to(() => EditGroupScreen()), // 👈 Navigate to edit
                          ),
                        ],
                      ),
                    ),
                  ),

                  20.verticalSpace,

                  // Group description
                  Obx(
                    () => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFFF4EAD5), borderRadius: BorderRadius.circular(16)),
                      child: Text(controller.description.value, style: const TextStyle(fontSize: 14)),
                    ),
                  ),

                  30.verticalSpace,

                  // Create button
                  Obx(() {
                    if (controller.createGrouptRequestStatus.value == RequestStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CustomButton(
                      text: "Create Group",
                      onPressed: () {
                        var data = {"name": controller.groupName.value, "description": controller.description.value};
                        controller.createGroupsForChat(data, controller.selectedImage.value);
                        // Show success toast/snackbar if needed
                        // Get.snackbar(
                        //   "Success",
                        //   "Group has been created successfully!",
                        //   backgroundColor: const Color(0xFFF4BD2A),
                        //   colorText: Colors.black,
                        //   margin: const EdgeInsets.all(16),
                        //   snackPosition: SnackPosition.BOTTOM,
                        // );

                        // Navigate to the Your Groups screen
                        // Get.to(
                        //   () => GroupListScreen(
                        //     title: "Your Groups",
                        //     groups: [
                        //       {
                        //         'title': controller.groupName.value,
                        //         'image': controller.selectedImage.value?.path ?? 'assets/images/Frame 1686560577.png',
                        //         'joined': true,
                        //       },
                        //     ],
                        //   ),
                        //   transition: Transition.fadeIn,
                        // );
                      },
                      height: 50.h,
                      color: buttonColor,
                      textColor: Colors.white,
                      width: double.infinity,
                    );
                  }),

                  42.verticalSpace,
                ],
              ),
            ),

            Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
          ],
        ),
      ),
    );
  }
}
