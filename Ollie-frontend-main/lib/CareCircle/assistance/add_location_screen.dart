import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/assistance/map_location_dialog.dart';
import 'package:ollie/CareCircle/assistance/review_post_screen.dart';

class AddLocationScreen extends StatelessWidget {
  AddLocationScreen({super.key});
  final Assistance_Controller controller = Get.put(Assistance_Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Let us know your exact location.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Please add\nyour location",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),

              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedAddress.isNotEmpty
                              ? controller.selectedAddress.value
                              : "Add Location",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: controller.selectedAddress.isNotEmpty
                                ? Colors.black
                                : Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => MapLocationDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.selectedAddress.isNotEmpty
                        ? () {
                            Get.to(
                              () => ReviewPostScreen(),
                              transition: Transition.fadeIn,
                            );

                            // Navigate or handle next
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedAddress.isNotEmpty
                          ? const Color(0xFF3F362E)
                          : Colors.grey.shade400,
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
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
