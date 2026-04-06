import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ollie/CareCircle/assistance/assistance_controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/CareCircle/assistance/map_location_dialog.dart';
import 'package:ollie/CareCircle/assistance/review_post_screen.dart';

class AddLocationScreen extends StatelessWidget {
  AddLocationScreen({super.key});
  final Assistance_Controller controller = Get.isRegistered<Assistance_Controller>()
      ? Get.find<Assistance_Controller>()
      : Get.put(Assistance_Controller());

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
                    child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Let us know your exact location.",
                    style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                "Please add\nyour location",
                style: GoogleFonts.darkerGrotesque(fontSize: 40.sp, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 28),

              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.locationSearchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: controller.searchLocationByText,
                      style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "Search your location",
                        hintStyle: GoogleFonts.darkerGrotesque(color: Colors.grey.shade500, fontSize: 18.sp),
                        prefixIcon: const Icon(Icons.search, color: Colors.black),
                        suffixIcon: controller.isSearchingLocation.value
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.location_on_outlined, color: Colors.black),
                                onPressed: () async {
                                  if (!context.mounted) return;
                                  await showDialog(context: context, builder: (_) => const MapLocationDialog());
                                },
                              ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    if (controller.selectedAddress.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        controller.selectedAddress.value,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.darkerGrotesque(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              12.verticalSpace,
              Obx(() {
                if (controller.selectedAddress.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                return const Text(
                  "Please select a location to continue.",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                );
              }),

              const Spacer(),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.selectedAddress.isNotEmpty
                        ? () {
                            Get.to(() => ReviewPostScreen(), transition: Transition.fadeIn);

                            // Navigate or handle next
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedAddress.isNotEmpty ? const Color(0xFF3F362E) : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Next", style: GoogleFonts.darkerGrotesque(color: Colors.white)),
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
