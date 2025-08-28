// ignore_for_file: use_full_hex_values_for_flutter_colors, avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/home/notifications/notificatins_screen.dart';
import 'package:ollie/widgets/showdilogbox.dart';

import '../../Volunteers/volunteers_scnreen.dart';

class YourPostsScreen extends StatelessWidget {
  YourPostsScreen({super.key});
  final Assistance_Controller controller = Get.put(Assistance_Controller());
  final CareCircleController careControllercontroller = Get.put(
    CareCircleController(),
  );
  final RxBool taskCompleted = false.obs;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments == true) {
        Get.snackbar(
          "Success",
          "Your post has been created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFD680),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: BGcolor,
        elevation: 0,
        title: const Text(
          "Your Posts",
          style: TextStyle(
            color: Black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Image.asset("assets/icons/MagnifyingGlass.png", scale: 4),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => NotificationsScreen(),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Image.asset("assets/icons/Vector (2).png", scale: 4),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => CreditsSubscriptionScreen(),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/icons/Vector (1).png", scale: 4),
                        const SizedBox(width: 5),
                        const Text(
                          "0",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Obx(
                  //   () => _buildPostCard(
                  //     context,
                  //     userName: "You",
                  //     time: controller.formattedTime,
                  //     category: controller.selectedCategory.value,
                  //     message: "I need help with groceries, is anyone available?",
                  //     latLng: controller.selectedLatLng.value,
                  //     completed: taskCompleted.value,
                  //     onTapComplete: () => taskCompleted.value = true,
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Container(
                    height: 70.h,
                    color: Color(0xff1e18180d),
                    alignment: Alignment.center,
                    child: const Text(
                      "ADVERTISEMENT",
                      style: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context, {
    required String userName,
    required String time,
    required String category,
    required String message,
    required LatLng? latLng,
    required bool completed,
    required VoidCallback onTapComplete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff1e18180d),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  "assets/icons/Frame 1686560584.png",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Posted by $userName",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EAD6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: latLng != null
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: latLng,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: latLng,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      liteModeEnabled: true,
                    )
                  : const Center(child: Text("No Location Available")),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: completed
                    ? () {}
                    : onTapComplete, // Keep it enabled but no-op if completed
                style: ElevatedButton.styleFrom(
                  backgroundColor: completed
                      ? const Color(0xFF7FDE90)
                      : const Color(0xFFF4BD2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  completed ? "Task Completed" : "Mark as Completed",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => VolunteersScreen(
                            controller: careControllercontroller,
                            assistanceId: "",
                          ),
                          transition: Transition.fadeIn,
                        );
                      },
                      child: Image.asset(
                        "assets/icons/HandHeart.png",
                        scale: 3,
                      ),
                    ),

                    GestureDetector(
                      onTapDown: (details) {
                        // ignore: unused_local_variable
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject()
                                as RenderBox;

                        // Adjust the position: move menu slightly down from the icon
                        final Offset position = details.globalPosition;
                        const double menuWidth = 130;
                        const double menuHeight = 30;

                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            position.dx -
                                (menuWidth / 2), // center horizontally
                            position.dy +
                                20, // push menu 20px down from tap point
                            position.dx + (menuWidth / 2),
                            position.dy + menuHeight,
                          ),
                          color: white,
                          shape:
                              TooltipShapeBorder(), // 👈 your custom shape with center notch
                          items: [
                            PopupMenuItem(
                              value: 0,
                              height: 25,

                              child: Text(
                                "Delete Post",
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ).then((value) {
                          if (value == 0) {
                            print("Delete Post");
                          }
                        });
                      },
                      child: Image.asset(
                        "assets/icons/DotsThree.png",
                        scale: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
