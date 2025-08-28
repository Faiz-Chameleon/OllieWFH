// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/bottomController.dart';

// ignore: must_be_immutable
class ConvexStyledBarScreen extends StatelessWidget {
  ConvexStyledBarScreen({super.key});

  Bottomcontroller controller = Get.put(Bottomcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: GetBuilder<Bottomcontroller>(builder: (controller) => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 0.060.sh),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(color: Color(0xFF3C3129), borderRadius: BorderRadius.circular(25)),
            width: 0.87.sw,
            height: 0.08.sh,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.updateIndex(0);
                      },
                      icon: Obx(
                        () => Icon(
                          Icons.home_filled,
                          size: 40,
                          color: controller.selectedIndex.value == 0 ? ksecondaryColor : kprimaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.updateIndex(1);
                      },
                      icon: Obx(
                        () => Icon(
                          Icons.groups,
                          size: 50,
                          color: controller.selectedIndex.value == 1 ? ksecondaryColor : kprimaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    70.horizontalSpace,
                    IconButton(
                      onPressed: () {
                        controller.updateIndex(3);
                      },
                      icon: Obx(
                        () => Icon(
                          Icons.bookmarks,
                          size: 40,
                          color: controller.selectedIndex.value == 3 ? ksecondaryColor : kprimaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.updateIndex(4);
                      },
                      icon: Obx(
                        () => Icon(
                          FontAwesomeIcons.diceFive,
                          size: 40,
                          color: controller.selectedIndex.value == 4 ? ksecondaryColor : kprimaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -40,
                  child: IconButton(
                    onPressed: () {
                      controller.updateIndex(2);
                    },
                    icon: Container(
                      width: 100.w,
                      height: 90.h,
                      decoration: ShapeDecoration(
                        shape: OvalBorder(
                          // borderRadius: BorderRadiusGeometry.circular(12),
                          side: BorderSide(color: Color(0xFF3C3129), width: 10),
                        ),
                        color: const Color(0xFF3C3129),
                      ),
                      child: Center(
                        child: Image.asset('assets/icons/Group 1000000907 (1).png', height: 55.h, width: 55.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
