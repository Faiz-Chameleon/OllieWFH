// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/assistance/chose_datetime_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

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
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  "Select a\ncategory",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 55.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: controller.categorySearchController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.updateCategorySearch,
                  onFieldSubmitted: controller.addNewCategory,
                  decoration: InputDecoration(
                    hintText: "Search or add a category",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Obx(
                      () => IconButton(
                        onPressed: controller.canAddNewCategory
                            ? () => controller.addNewCategory()
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: ksecondaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                14.verticalSpace,
                Obx(() {
                  if (controller.getReasonsForAssistanceStatus.value ==
                      RequestStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // Show loading spinner while fetching data
                  }

                  final suggestions = controller.suggestedCategories;
                  if (controller.getReasonsForAssistanceStatus.value ==
                          RequestStatus.error &&
                      controller.categoryFeedMessage.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        controller.categoryFeedMessage.value,
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: HeadingColor,
                        ),
                      ),
                    );
                  }

                  if (suggestions.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: suggestions.map((cat) {
                      return Obx(() {
                        final selected = controller.isSelected(cat);
                        return GestureDetector(
                          onTap: () => controller.addMatchedCategory(cat),
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
                                  cat.name ?? 'Category',
                                  style: GoogleFonts.darkerGrotesque(
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
                12.verticalSpace,
                Obx(() {
                  final matchedCategory = controller.matchedCategory;
                  if (matchedCategory == null) return const SizedBox.shrink();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Match found: ${matchedCategory.name ?? 'Category'}",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: HeadingColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.addMatchedCategory(matchedCategory),
                          child: Text(
                            "Add",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: ksecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                10.verticalSpace,
                Obx(() {
                  final selectedBuiltIn = controller.categories
                      .where((item) => controller.isSelected(item))
                      .toList();
                  final newCategories = controller.newCategories.toList();
                  if (selectedBuiltIn.isEmpty && newCategories.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...selectedBuiltIn.map(
                        (category) => Chip(
                          label: Text(
                            category.name ?? 'Category',
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: ksecondaryColor,
                          deleteIconColor: Colors.white,
                          onDeleted: () => controller.selectCategory(category),
                        ),
                      ),
                      ...newCategories.map(
                        (category) => Chip(
                          label: Text(
                            category,
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: ksecondaryColor,
                          deleteIconColor: Colors.white,
                          onDeleted: () =>
                              controller.removeNewCategory(category),
                        ),
                      ),
                    ],
                  );
                }),
                15.verticalSpace,

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.hasAnyCategorySelection) {
                        Get.to(
                          () => ChooseDateTimeScreen(),
                          transition: Transition.fadeIn,
                        );
                        print(
                          "Selected category: ${controller.selectedCategory.value?.name}",
                        );
                      } else {
                        appSnackbar(
                          "Error",
                          "Please select or add a category to proceed",
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
