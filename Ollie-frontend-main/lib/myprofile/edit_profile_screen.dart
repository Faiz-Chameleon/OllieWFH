import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Constants/constants.dart';

import 'my_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserController userController = Get.find<UserController>();

  final ProfileController controller = Get.put(ProfileController());

  final genderOptions = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.user.value != null) {
        controller.firstNameController.text = userController.user.value!.firstName ?? '';
        controller.lastNameController.text = userController.user.value!.lastName ?? '';
        controller.emailController.text = userController.user.value!.email ?? '';
        controller.phoneController.text = userController.user.value!.phoneNumber ?? '';
        controller.dateOfBirth.value = userController.user.value!.dateOfBirth ?? "";
        controller.gender.value = userController.user.value!.gender ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF2D9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Obx(
              () => CircleAvatar(
                radius: 48,
                backgroundImage: controller.profileImage.value != null
                    ? FileImage(controller.profileImage.value!) // If a new image is selected, display it
                    : (userController.user.value?.image != null
                          ? NetworkImage(userController.user.value!.image!) // If no new image, use the one from UserModel
                          : const AssetImage("assets/icons/Frame 1686560584.png") as ImageProvider), // Default image
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: const Text(
                "Edit Photo",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            buildTextField("First name", controller.firstNameController),
            buildTextField("Last name", controller.lastNameController),
            buildTextField("Email Address", controller.emailController),
            buildTextField("Phone Number", controller.phoneController),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Date of Birth", style: labelStyle),
            ),

            // GestureDetector(
            //   onTap: controller.toggleCalendar,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            //     decoration: boxDecoration,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Obx(
            //           () => Text(
            //             controller.selectedDate.isEmpty ? 'Select Date' : controller.selectedDate.value,
            //             style: TextStyle(color: controller.selectedDate.isEmpty ? Colors.grey : Colors.black),
            //           ),
            //         ),
            //         const Icon(Icons.calendar_month_outlined),
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () => controller.selectDateNew(context), // Trigger date picker
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: boxDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.dateOfBirth.isEmpty ? 'Select Date' : controller.dateOfBirth.value, // Display the selected date or default text
                        style: TextStyle(color: controller.dateOfBirth.isEmpty ? Colors.grey : Colors.black),
                      ),
                    ),
                    const Icon(Icons.calendar_month_outlined),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Gender", style: labelStyle),
            ),
            GestureDetector(
              onTap: controller.toggleGenderDropdown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: boxDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.gender.isEmpty ? 'Select Option' : controller.gender.value,
                        style: TextStyle(color: controller.gender.isEmpty ? Colors.grey : Colors.black),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),

            Obx(
              () => controller.showGenderDropdown.value
                  ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: genderOptions.map((option) {
                          return ListTile(
                            title: Text(option),
                            onTap: () {
                              controller.selectGender(option);
                              controller.showGenderDropdown.value = false;
                            },
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox(),
            ),

            const SizedBox(height: 70), // space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.saveProfile(), // Disable button while loading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C3226),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white) // Show loader when isLoading is true
                : const Text("Save", style: TextStyle(color: Colors.white)), // Show text when not loading
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // Bind controller here
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF2D9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload from Library'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromGallery();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Picture'),
              onTap: () {
                Navigator.pop(context);
                controller.captureImageWithCamera();
              },
            ),
          ],
        );
      },
    );
  }

  final labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Black);

  final boxDecoration = BoxDecoration(color: white, borderRadius: BorderRadius.circular(30));
}
