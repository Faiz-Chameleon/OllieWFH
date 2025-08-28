// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/assistance/chose_datetime_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/request_status.dart';

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  final Assistance_Controller controller = Get.put(Assistance_Controller());

  @override
  void initState() {
    super.initState();

    controller.getCategoriesForAssistance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(color: const Color(0xFFFDF3DD)),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                100.verticalSpace,
                // Back Arrow & Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "What do you need help with?",
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
                  "Select a\ncategory",
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Category Pills
                Obx(() {
                  if (controller.getReasonsForAssistanceStatus.value ==
                      RequestStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // Show loading spinner while fetching data
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.categories.map((cat) {
                      return Obx(() {
                        final selected = controller.isSelected(cat);
                        return GestureDetector(
                          onTap: () => controller.selectCategory(cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kprimaryColor
                                  : Colors.transparent,
                              border: Border.all(color: ksecondaryColor),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  cat.name ??
                                      'Category', // Display category name
                                  style: TextStyle(
                                    color: selected ? Colors.black : Black,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),

                                // Optionally display additional information (like ID or Admin ID)
                              ],
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  );
                }),
                50.verticalSpace,

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.selectedCategories.isNotEmpty) {
                        Get.to(
                          () => ChooseDateTimeScreen(),
                          transition: Transition.fadeIn,
                        );
                        print(
                          "Selected category: ${controller.selectedCategory.value?.name}",
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          "Please selct category to proceed",
                        );
                      }
                      print(
                        "Selected category: ${controller.selectedCategories.toList()}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F362E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "Next",
                      style: TextStyle(color: white, fontSize: 18.sp),
                    ),
                  ),
                ),
                SizedBox(height: 180.h), // Leave space for bottom image
              ],
            ),
          ),

          // Bottom Image (Positioned)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Group 1000000919.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: 350.h,
            ),
          ),
        ],
      ),
    );
  }
}
