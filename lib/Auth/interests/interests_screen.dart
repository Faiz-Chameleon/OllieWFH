// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ollie/Auth/interests/emergency_contact_screen.dart';
import 'package:ollie/Auth/interests/Interests_controller.dart';
import 'package:ollie/Constants/constants.dart';

import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';

class Interests_screen extends StatelessWidget {
  Interests_screen({super.key}) {
    Future.microtask(() => controller.loadInterests());
  }

  final controller = Get.put(InterestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(color: BGcolor),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset("assets/images/Group 1000000919.png", fit: BoxFit.cover, width: double.infinity, height: 400.h),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  140.verticalSpace,
                  Text(
                    "I’ll suggest things you’ll love!",
                    style: GoogleFonts.darkerGrotesque(color: HeadingColor, fontSize: 26.sp, fontWeight: FontWeight.w700),
                  ),
                  10.verticalSpace,
                  Text(
                    "Tell us about your interests",
                    style: GoogleFonts.darkerGrotesque(color: HeadingColor, fontSize: 55.sp, fontWeight: FontWeight.w700),
                  ),
                  18.verticalSpace,
                  TextFormField(
                    controller: controller.interestSearchController,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: controller.updateInterestSearch,
                    onFieldSubmitted: controller.addCustomInterest,
                    decoration: InputDecoration(
                      hintText: "Search or add your own interest",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: Obx(
                        () => IconButton(
                          onPressed: controller.canAddCustomInterest ? () => controller.addCustomInterest() : null,
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
                        borderSide: BorderSide(color: ksecondaryColor, width: 1.4),
                      ),
                    ),
                  ),
                  12.verticalSpace,
                  Obx(() {
                    final suggestions = controller.suggestedInterests;
                    if (suggestions.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trending now",
                          style: GoogleFonts.darkerGrotesque(fontSize: 22.sp, fontWeight: FontWeight.w700, color: HeadingColor),
                        ),
                        10.verticalSpace,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: suggestions
                              .map(
                                (interest) => ActionChip(
                                  label: Text(
                                    interest.name,
                                    style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  backgroundColor: ksecondaryColor,
                                  onPressed: () => controller.addMatchedInterest(interest),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  }),
                  16.verticalSpace,
                  Obx(() {
                    final matchedInterest = controller.matchedInterest;
                    if (matchedInterest == null) return const SizedBox.shrink();

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
                              "Match found: ${matchedInterest.name}",
                              style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w600, color: HeadingColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.addMatchedInterest(matchedInterest),
                            child: Text(
                              "Add",
                              style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w700, color: ksecondaryColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  10.verticalSpace,
                  Obx(
                    () => controller.customInterests.isEmpty
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.customInterests
                                .map(
                                  (interest) => Chip(
                                    label: Text(
                                      interest,
                                      style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    backgroundColor: ksecondaryColor,
                                    deleteIconColor: Colors.white,
                                    onDeleted: () => controller.removeCustomInterest(interest),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  12.verticalSpace,
                  Obx(() {
                    final selectedBuiltInInterests = controller.interests.where((item) => item.isSelected).toList();
                    if (selectedBuiltInInterests.isEmpty) return const SizedBox.shrink();

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedBuiltInInterests
                          .map(
                            (interest) => Chip(
                              label: Text(
                                interest.name,
                                style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              backgroundColor: ksecondaryColor,
                              deleteIconColor: Colors.white,
                              onDeleted: () {
                                final index = controller.interests.indexWhere((item) => item.interestId == interest.interestId);
                                if (index != -1) {
                                  controller.toggleInterest(index);
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  }),
                  16.verticalSpace,

                  // Obx(() {
                  //   if (controller.getInterestStatus.value == RequestStatus.loading) {
                  //     return const Center(child: CircularProgressIndicator());
                  //   }
                  //   if (controller.interests.isEmpty) {
                  //     return Padding(
                  //       padding: const EdgeInsets.only(top: 50),
                  //       child: Center(
                  //         child: Text(
                  //           "No interests available.",
                  //           style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                  //         ),
                  //       ),
                  //     );
                  //   }
                  //   return GridView.builder(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: controller.interests.length,
                  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //       crossAxisCount: 3,
                  //       crossAxisSpacing: 10,
                  //       mainAxisSpacing: 10,
                  //       childAspectRatio: 3,
                  //     ),
                  //     itemBuilder: (context, index) {
                  //       final item = controller.interests[index];
                  //       final isSelected = item.isSelected;

                  //       return GestureDetector(
                  //         onTap: () {
                  //           final realIndex = controller.interests.indexWhere((element) => element.interestId == item.interestId);
                  //           if (realIndex != -1) {
                  //             controller.toggleInterest(realIndex);
                  //           }
                  //         },
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             color: isSelected ? ksecondaryColor : Colors.white,
                  //             borderRadius: BorderRadius.circular(50),
                  //             border: Border.all(color: isSelected ? Colors.transparent : Colors.grey, width: 1),
                  //           ),
                  //           child: Center(
                  //             child: Text(
                  //               item.name,
                  //               style: GoogleFonts.darkerGrotesque(
                  //                 fontSize: 18.sp,
                  //                 color: isSelected ? Colors.white : Colors.grey,
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   );
                  // }),
                  30.verticalSpace,
                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      if (!controller.hasAnyInterestSelection) {
                        appSnackbar(
                          "Select an Interest",
                          "Please choose or add at least one interest to continue.",
                          backgroundColor: Colors.white,
                          colorText: HeadingColor,
                        );
                        return;
                      }

                      Get.to(() => EmergencyContactScreen(), transition: Transition.fadeIn);
                    },
                    width: 390.w,
                    height: 50,
                    color: buttonColor,
                    textColor: Colors.white,
                    fontSize: 18,
                  ),
                  100.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
