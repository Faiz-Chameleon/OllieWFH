// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Volunteers/volunteers_scnreen.dart';
import 'package:ollie/request_status.dart';

class YourRequestsFullScreen extends StatelessWidget {
  final CareCircleController controller;
  const YourRequestsFullScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Your Requests",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            width: 390.w,
            decoration: BoxDecoration(
              color: Color(0xff1e18180d),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
            ),
          ),
          Obx(() {
            if (controller.getCrteatedAssistanceStatus.value ==
                RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.createdAssistance.isEmpty) {
              return Column(
                children: [const Center(child: Text("No Request Created"))],
              );
            }
            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.createdAssistance.length, // dynamic count
                itemBuilder: (context, index) {
                  final createdAssistanceRequest =
                      controller.createdAssistance[index];
                  final isCompleted = createdAssistanceRequest.status;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Top Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 16),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Posted by You",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "11:30 AM",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Errands",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        /// Message
                        Text(
                          createdAssistanceRequest.description ?? "",
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 10),

                        /// Google Map
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  createdAssistanceRequest.latitude ??
                                      40.712776,
                                  createdAssistanceRequest.longitude ??
                                      -74.005974,
                                ),
                                zoom: 14,
                              ),
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              markers: const <Marker>{},
                              liteModeEnabled: true,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Bottom Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted == "NoRequest"
                                    ? const Color(0xFFB4E197)
                                    : const Color(0xFFF4BD2A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isCompleted == "NoRequest"
                                    ? "No Action Perform on your request"
                                    : isCompleted == "VolunteerRequestSent"
                                    ? "Volunteer Request Received"
                                    : "Mark as Completed",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => VolunteersScreen(
                                        controller: controller,
                                        assistanceId: createdAssistanceRequest
                                            .id
                                            .toString(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.people_alt_outlined,
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.more_horiz),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
