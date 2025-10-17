// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/assistance/assistance_screen.dart';
import 'package:ollie/CareCircle/eventsandactivites/event_and_activities_screen.dart';
import 'package:ollie/CareCircle/groups/groups_screen.dart';
import 'package:ollie/CareCircle/interests/interests_screen.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/home/notifications/notificatins_screen.dart';

class Care_Circle_screen extends StatefulWidget {
  Care_Circle_screen({super.key});

  @override
  State<Care_Circle_screen> createState() => _Care_Circle_screenState();
}

class _Care_Circle_screenState extends State<Care_Circle_screen> {
  final CareCircleController careControllercontroller = Get.put(CareCircleController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      careControllercontroller.changeTab(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: BGcolor,
        elevation: 0,
        title: const Text(
          "Care Circle",
          style: TextStyle(color: Black, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset("assets/icons/MagnifyingGlass.png", scale: 4),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(() => NotificationsScreen(), transition: Transition.fadeIn);
                  },
                  child: Image.asset("assets/icons/Vector (2).png", scale: 4),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Image.asset("assets/icons/Vector (1).png", scale: 4),
                        const SizedBox(width: 5),
                        const Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 45,
            child: Obx(() {
              final tabs = careControllercontroller.tabs;
              final selectedIndex = careControllercontroller.selectedTabIndex.value;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () => careControllercontroller.changeTab(index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected ? Black : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Obx(() {
              final index = careControllercontroller.selectedTabIndex.value;
              switch (index) {
                case 0:
                  return Assistance_screen(controller: careControllercontroller);

                case 1:
                  return Group_Screen(controller: careControllercontroller);
                case 2:
                  return InterestsScreen();

                case 3:
                  return EventsAndActivitiesScreen(controller: careControllercontroller);

                default:
                  return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }
}
