import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ollie/Auth/interests/getreminder_screen.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class EmergencyContactScreen extends StatefulWidget {
  EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final controller = Get.put(InterestController());

  // final FlutterNativeContactPicker _contactPicker =
  //     FlutterNativeContactPicker();

  // List<Contact>? _contacts;

  // String? _selectedPhoneNumber;
  // Future<void> _pickContact() async {
  //   try {
  //     final contact = await _contactPicker.selectPhoneNumber();
  //     setState(() {
  //       _contacts = contact == null ? null : [contact];
  //       _selectedPhoneNumber = contact?.selectedPhoneNumber;
  //     });
  //   } catch (e) {
  //     print('Error picking contact: $e');
  //   }
  // }
  // Future<void> _pickContact() async {
  //   // Step 1: Check permission
  //   PermissionStatus status = await Permission.contacts.status;

  //   if (status.isPermanentlyDenied) {
  //     Get.snackbar(
  //       "Permission Required",
  //       "Please allow contacts access from settings.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.redAccent,
  //       colorText: Colors.white,
  //       mainButton: TextButton(
  //         onPressed: () => openAppSettings(),
  //         child: const Text(
  //           "Open Settings",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   // Step 2: Request permission if not already granted
  //   if (status != PermissionStatus.granted) {
  //     status = await Permission.contacts.request();

  //     if (status != PermissionStatus.granted) {
  //       Get.snackbar(
  //         "Permission Denied",
  //         "We need access to your contacts to continue.",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return;
  //     }
  //   }

  //   // Step 3: Pick contact
  //   final contact = await _contactPicker.selectContact();

  //   if (contact != null &&
  //       contact.fullName != null &&
  //       contact.selectedPhoneNumber != null &&
  //       contact.selectedPhoneNumber!.isNotEmpty) {
  //     controller.selectContact(contact.fullName!, contact.selectedPhoneNumber!);
  //   } else {
  //     Get.snackbar(
  //       "No Number Found",
  //       "Please select a contact with a valid phone number.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.orange,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF1DE),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                "assets/images/Group 1000000919.png",
                fit: BoxFit.cover,
                height: 400.h,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 180.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 140.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Save an emergency contact.",
                    style: TextStyle(
                      color: HeadingColor,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    "Who should I\ncall if you need\nhelp?",
                    style: TextStyle(
                      color: HeadingColor,
                      fontSize: 58.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  40.verticalSpace,
                  Obx(
                    () => Container(
                      height: 60.h,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedPhoneNumber == null
                                  ? "Select from contacts"
                                  : controller.selectedPhoneNumber.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: controller.selectedContact.value.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              controller.pickContact();
                            },
                            // _pickContact,
                            icon: Icon(
                              Icons.contact_emergency,
                              color: Colors.grey,
                              size: 26.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  40.verticalSpace,
                  // Obx(
                  //   () => CustomButton(
                  //     text: "Next",
                  //     onPressed: controller.isContactSelected
                  //         ? () {
                  //             Get.to(() => Reminder_Screen(), transition: Transition.fadeIn);
                  //           }
                  //         : null,
                  //     width: 390.w,
                  //     height: 50,
                  //     color: controller.isContactSelected ? buttonColor : Colors.grey.shade300,
                  //     textColor: controller.isContactSelected ? Colors.white : Colors.grey,
                  //     fontSize: 18,
                  //   ),
                  // ),
                  CustomButton(
                    text: "Next",
                    onPressed: () {
                      print(controller.selectedPhoneNumber.toString());
                      Get.to(
                        () => Reminder_Screen(),
                        transition: Transition.fadeIn,
                      );
                    },
                    width: 390.w,
                    height: 50,
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
