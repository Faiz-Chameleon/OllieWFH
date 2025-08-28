// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/assistance/add_task_description_screen.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

class ChooseDateTimeScreen extends StatefulWidget {
  const ChooseDateTimeScreen({super.key});

  @override
  State<ChooseDateTimeScreen> createState() => _ChooseDateTimeScreenState();
}

class _ChooseDateTimeScreenState extends State<ChooseDateTimeScreen> {
  final Assistance_Controller controller = Get.put(Assistance_Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  40.verticalSpace,
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "When do you need help?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Choose a\ndate and time",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Yellow Dropdown Header
                  Obx(
                    () => GestureDetector(
                      onTap: controller.toggleExpanded,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDC87E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Date and Time",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Icon(
                              controller.isExpanded.value
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Obx(() {
                    if (!controller.isExpanded.value)
                      return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Date"),
                            OutlinedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.selectedDate.value,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  controller.setDate(picked);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Obx(() => Text(controller.formattedDate)),
                            ),
                            const Text("Time"),
                            OutlinedButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: controller.selectedTime.value,
                                );
                                if (picked != null) {
                                  final selectedDate =
                                      controller.selectedDate.value;
                                  if (selectedDate.year == now.year &&
                                      selectedDate.month == now.month &&
                                      selectedDate.day == now.day) {
                                    if (picked.hour < now.hour ||
                                        (picked.hour == now.hour &&
                                            picked.minute < now.minute)) {
                                      Get.snackbar(
                                        "Error",
                                        "You cannot select a past time.",
                                      );
                                      return;
                                    }
                                  }
                                  controller.setTime(picked);
                                  controller.updateDateAndTime();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Obx(() => Text(controller.formattedTime)),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  20.verticalSpace,
                  // NEXT Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.formattedDate.isEmpty ||
                            controller.formattedTime.isEmpty) {
                          // If date or time is not selected, show an error
                          Get.snackbar(
                            "Error",
                            "Please select both date and time.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        print("Selected Date: ${controller.formattedDate}");
                        print("Selected Time: ${controller.formattedTime}");
                        Get.to(
                          () => AddTaskDescriptionScreen(),
                          transition: Transition.fadeIn,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F362E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  100.verticalSpace,
                ],
              ),
            ),
          ),

          // Bottom Emoji
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Group 1000000919.png",
              height: 280.h,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
