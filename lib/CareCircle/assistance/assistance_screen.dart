import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/assistance_detail_screen.dart';
import 'package:ollie/CareCircle/assistance/select_category_screen.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/Constants.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/volunteers_chat_screen.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/widgets/showdilogbox.dart';

import 'your_requests_screen.dart';

class Assistance_screen extends StatefulWidget {
  const Assistance_screen({super.key, required this.controller});

  final CareCircleController controller;

  @override
  State<Assistance_screen> createState() => _Assistance_screenState();
}

class _Assistance_screenState extends State<Assistance_screen> {
  final OneToOneChatController chatController = Get.find<OneToOneChatController>();

  Future<void> _openNearbyFilterSheet() async {
    await widget.controller.loadAssistanceFilterCurrentLocation();
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AssistanceNearbyFilterSheet(controller: widget.controller),
    );
  }

  String _categoryLabel(dynamic categories) {
    if (categories is List && categories.isNotEmpty) {
      final firstCategory = categories.first;
      final name = firstCategory?.name?.toString().trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return "Errands";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add New Request Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showStyledCreditDialog(
                  context: context,
                  title: "Use Credits?",
                  message: "Sending this request will deduct 1 credit from your balance. Do you want to continue?",
                  continueText: "Continue",
                  cancelText: "Cancel",
                  onContinue: () {
                    Get.to(() => SelectCategoryScreen(), transition: Transition.fadeIn);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ksecondaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "Add New Request",
                style: GoogleFonts.darkerGrotesque(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Advertisement
          // Container(
          //   width: double.infinity,
          //   height: 80,
          //   decoration: BoxDecoration(color: const Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
          //   child: const Center(
          //     child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
          //   ),
          // ),
          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                "Assistance Nearby",
                style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
              const Spacer(),
              Obx(() {
                final isFiltered = widget.controller.assistanceFilterEnabled.value;
                return Row(
                  children: [
                    if (isFiltered)
                      GestureDetector(
                        onTap: widget.controller.clearAssistanceNearbyFilter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF2ECE3), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "Clear",
                            style: GoogleFonts.darkerGrotesque(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (isFiltered) const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openNearbyFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isFiltered ? ksecondaryColor : const Color(0xFFF2ECE3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.filter_alt_outlined, color: Colors.black),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (!widget.controller.assistanceFilterEnabled.value) {
              return const SizedBox.shrink();
            }

            final location = widget.controller.assistanceFilterLocation.value;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF4BD2A)),
              ),
              child: Text(
                location == null
                    ? "Nearby filter active"
                    : "Showing requests within ${widget.controller.assistanceFilterRadiusKm.value.toStringAsFixed(0)} km of ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}",
                style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            );
          }),

          // Volunteer Requests PageView
          Obx(() {
            if (widget.controller.getOthersCrteatedAssistanceStatus.value == RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.controller.othersCreatedAssistance.isEmpty) {
              return const Center(child: Text("No Other's User Request Found"));
            }
            return SizedBox(
              height: 270,
              child: PageView.builder(
                itemCount: widget.controller.othersCreatedAssistance.length,
                onPageChanged: widget.controller.changePage,
                itemBuilder: (context, index) {
                  final otherAssistanceData = widget.controller.othersCreatedAssistance[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => AssistanceDetailScreen(controller: widget.controller, assistance: otherAssistanceData, index: index),
                        transition: Transition.fadeIn,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 12, backgroundColor: grey),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Posted by ${otherAssistanceData.user?.firstName ?? ""}",
                                        style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        widget.controller.formatDateAndTime(otherAssistanceData.scheduledAt.toString()),
                                        style: GoogleFonts.darkerGrotesque(fontSize: 15.sp, color: grey),
                                      ),
                                      if (otherAssistanceData.distanceKm != null)
                                        Text(
                                          "${otherAssistanceData.distanceKm!.toStringAsFixed(1)} km away",
                                          style: GoogleFonts.darkerGrotesque(fontSize: 15.sp, color: const Color(0xFF9C7D4A)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 16, color: Black),
                                  SizedBox(width: 4),
                                  Text(
                                    _categoryLabel(otherAssistanceData.categories),
                                    style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            otherAssistanceData.description ?? "",
                            style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: GoogleMapPreview(
                              latitude: otherAssistanceData.latitude ?? 40.712776,
                              longitude: otherAssistanceData.longitude ?? -74.005974,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // controller.reachedOut.value
                              //     ? ElevatedButton(
                              //         onPressed: () {},
                              //         style: ElevatedButton.styleFrom(
                              //           backgroundColor: const Color(
                              //             0xFFB4E197,
                              //           ),
                              //           shape: RoundedRectangleBorder(
                              //             borderRadius: BorderRadius.circular(
                              //               20,
                              //             ),
                              //           ),
                              //         ),
                              //         child: const Text(
                              //           "Volunteer Request Sent",
                              //           style: TextStyle(color: Colors.black),
                              //         ),
                              //       )
                              //     :
                              Obx(() {
                                return ElevatedButton(
                                  onPressed: () async {
                                    var volunterId;
                                    final userController = Get.put(UserController());
                                    final String loggedInUserId = userController.user.value?.id ?? '';
                                    String targetUserId = loggedInUserId;
                                    String targetStatus = 'ReachOut';

                                    // Get the index of the matching item
                                    int? foundIndex = otherAssistanceData.volunteerRequests!.indexWhere(
                                      (item) => item.volunteerId == targetUserId && item.status == targetStatus,
                                    );

                                    if (foundIndex != -1) {
                                      var foundId = otherAssistanceData.volunteerRequests![foundIndex].id;
                                      volunterId = otherAssistanceData.volunteerRequests![foundIndex].id;

                                      print('Found at index: $foundIndex with ID: $foundId');

                                      // Store the ID wherever you need
                                      // yourStorageVariable = foundId;
                                    } else {
                                      print('No item found with userID $targetUserId and status $targetStatus');
                                    }
                                    widget.controller.postLoadingStatus[index].value = true;
                                    if (otherAssistanceData.status == "NoRequest") {
                                      await widget.controller.reachOutOnAssistance(otherAssistanceData.id ?? "", index);
                                    } else if (otherAssistanceData.status == "ReachOut") {
                                      widget.controller.completeAssistanceByVolunter(volunterId ?? "");
                                    }

                                    widget.controller.postLoadingStatus[index].value = false;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: otherAssistanceData.status == "NoRequest" ? const Color(0xFFF4BD2A) : Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: widget.controller.postLoadingStatus[index].value
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          otherAssistanceData.status == "NoRequest"
                                              ? "Reach Out"
                                              : otherAssistanceData.status == "MarkAsCompleted"
                                              ? "Completed"
                                              : "Volunter Request Sent",
                                          style: GoogleFonts.darkerGrotesque(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w600),
                                        ),
                                );
                              }),
                              GestureDetector(
                                onTap: () async {
                                  var data = {"userId": otherAssistanceData.user?.id.toString() ?? ""};
                                  await chatController.createOneOnOneChat(data).then((value) {
                                    Get.to(
                                      () => ChatScreen(
                                        userName: otherAssistanceData.user?.firstName.toString() ?? "",
                                        userImage: otherAssistanceData.user?.image.toString() ?? "",
                                      ),
                                    );
                                  });
                                },
                                child: Obx(() {
                                  if (chatController.createChatRoomRequestStatus.value == RequestStatus.loading) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  return const Icon(Icons.mark_unread_chat_alt_sharp);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Dots Indicator
          const SizedBox(height: 8),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.controller.othersCreatedAssistance.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.controller.currentPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
                  ),
                );
              }),
            );
          }),

          // Your Requests Title
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Requests",
                style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
              GestureDetector(
                onTap: () => Get.to(() => YourRequestsFullScreen(controller: widget.controller), transition: Transition.fadeIn),
                child: Text("See All", style: GoogleFonts.darkerGrotesque(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Your Requests PageView
          Obx(() {
            if (widget.controller.getCrteatedAssistanceStatus.value == RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.controller.createdAssistance.isEmpty) {
              return const Center(child: Text("No Request Created"));
            }

            return SizedBox(
              height: 270,
              child: PageView.builder(
                itemCount: widget.controller.createdAssistance.length,
                onPageChanged: widget.controller.changeYourRequestPage,
                itemBuilder: (context, index) {
                  final createdAssistanceRequest = widget.controller.createdAssistance[index];

                  // final isCompleted = controller.taskCompleted.value;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Posted by ${createdAssistanceRequest.user?.firstName ?? ""}",
                                      style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      widget.controller.formatDateAndTime(createdAssistanceRequest.scheduledAt.toString()),
                                      style: GoogleFonts.darkerGrotesque(fontSize: 15.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
                                SizedBox(width: 4),
                                Text(
                                  "Errands",
                                  style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          createdAssistanceRequest.description ?? "",
                          style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GoogleMapPreview(
                            latitude: createdAssistanceRequest.latitude ?? 40.712776,
                            longitude: createdAssistanceRequest.longitude ?? -74.005974,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                var volunterId;
                                final userController = Get.put(UserController());

                                String targetStatus = 'MarkAsCompleted';

                                // Get the index of the matching item
                                int? foundIndex = createdAssistanceRequest.volunteerRequests!.indexWhere((item) => item.status == targetStatus);

                                if (foundIndex != -1) {
                                  var foundId = createdAssistanceRequest.volunteerRequests![foundIndex].id;
                                  volunterId = createdAssistanceRequest.volunteerRequests![foundIndex].id;

                                  print('Found at index: $foundIndex with ID: $foundId');

                                  // Store the ID wherever you need
                                  // yourStorageVariable = foundId;
                                } else {
                                  print('No item found with and status $targetStatus');
                                }
                                widget.controller.completeTaskByOwner(volunterId);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: createdAssistanceRequest.status == "NoRequest" ? const Color(0xFFB4E197) : const Color(0xFFF4BD2A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  // isCompleted ?
                                  createdAssistanceRequest.status == "NoRequest"
                                      ? "No Request Received"
                                      : createdAssistanceRequest.status == "VolunteerRequestSent"
                                      ? "Request Received"
                                      : createdAssistanceRequest.status == "TaskCompleted"
                                      ? "Task Completed"
                                      : "Mark As Complete",
                                  //  : "Task Completed",
                                  style: GoogleFonts.darkerGrotesque(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            // PopupMenuButton<String>(
                            //   icon: const Icon(Icons.more_horiz),
                            //   onSelected: (value) {
                            //     if (value == 'delete') {
                            //       // controller.deletePost();
                            //     }
                            //   },
                            //   itemBuilder: (BuildContext context) => [
                            //     const PopupMenuItem<String>(
                            //       value: 'delete',
                            //       child: Text('Delete post', style: TextStyle(color: Colors.red)),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),

          // Dots Indicator
          const SizedBox(height: 5),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.controller.createdAssistance.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.controller.currentYourRequestPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ),
          160.verticalSpace,
        ],
      ),
    );
  }
}

class _AssistanceNearbyFilterSheet extends StatefulWidget {
  const _AssistanceNearbyFilterSheet({required this.controller});

  final CareCircleController controller;

  @override
  State<_AssistanceNearbyFilterSheet> createState() => _AssistanceNearbyFilterSheetState();
}

class _AssistanceNearbyFilterSheetState extends State<_AssistanceNearbyFilterSheet> {
  late double selectedRadiusKm;

  @override
  void initState() {
    super.initState();
    selectedRadiusKm = widget.controller.assistanceFilterRadiusKm.value;
  }

  double _zoomForRadius(double radiusKm) {
    if (radiusKm <= 2) return 13.5;
    if (radiusKm <= 3) return 12.8;
    if (radiusKm <= 5) return 12.0;
    if (radiusKm <= 8) return 11.4;
    return 10.8;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Obx(() {
          final location = widget.controller.assistanceFilterLocation.value;
          final isLoading = widget.controller.assistanceFilterLoading.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Nearby Assistance Filter",
                style: GoogleFonts.darkerGrotesque(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Use your current location to show requests within a few kilometers.",
                style: GoogleFonts.darkerGrotesque(fontSize: 16.sp, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : location == null
                      ? Center(
                          child: Text("Current location unavailable", style: GoogleFonts.darkerGrotesque(fontSize: 18.sp)),
                        )
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(target: location, zoom: _zoomForRadius(selectedRadiusKm)),
                          markers: {Marker(markerId: const MarkerId('current_location'), position: location)},
                          circles: {
                            Circle(
                              circleId: const CircleId('nearby_radius'),
                              center: location,
                              radius: selectedRadiusKm * 1000,
                              fillColor: const Color(0xFFF4BD2A).withValues(alpha: 0.18),
                              strokeColor: const Color(0xFFF4BD2A),
                              strokeWidth: 2,
                            ),
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Radius: ${selectedRadiusKm.toStringAsFixed(0)} km",
                style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              Slider(
                value: selectedRadiusKm,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: ksecondaryColor,
                onChanged: (value) {
                  setState(() {
                    selectedRadiusKm = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await widget.controller.loadAssistanceFilterCurrentLocation();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFF4BD2A)),
                      ),
                      child: Text(
                        "Refresh Location",
                        style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: location == null
                          ? null
                          : () async {
                              await widget.controller.applyAssistanceNearbyFilter(radiusKm: selectedRadiusKm);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ksecondaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Apply Filter",
                        style: GoogleFonts.darkerGrotesque(fontSize: 18.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class GoogleMapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final double? height;

  const GoogleMapPreview({
    Key? key,
    this.latitude, // Optional latitude, if passed by the user
    this.longitude, // Optional longitude, if passed by the user
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use passed latitude and longitude if available, otherwise fall back to static coordinates
    final double lat = latitude ?? 37.4219999; // Default latitude if null
    final double lng = longitude ?? -122.0840575; // Default longitude if null

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        key: const ValueKey('AIzaSyCsgi7wgsqtBYQCBErgKJpn6AtCmtGdFxE'),
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng), // Use dynamic lat/lng values
          zoom: 14,
        ),
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('selected_location'),
            position: LatLng(lat, lng), // Marker at the dynamic position
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        liteModeEnabled: true,
      ),
    );

    return SizedBox(height: height, width: double.infinity, child: map);
  }
}

// var headers = {
//   'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImZlMmY5NWE3LWQyNmEtNGU1Mi1hNzkzLTgzYWZkYjAwY2FkNSIsInVzZXJUeXBlIjoiQURNSU4iLCJpYXQiOjE3NTcwMDA0MjUsImV4cCI6MTc1NzA4NjgyNX0.lP3OXwfwSDqL99L7H13rtByOYSo9VkQjmWTiqA25rBc',
//   'Content-Type': 'application/json'
// };
// var request = http.Request('POST', Uri.parse('http://localhost:3000/api/v1/user/auth/submitFeedBack'));
// request.body = json.encode({
//   "email": "squeeze1@yopmail.com",
//   "message": "world hasjdhajdasjdhassadasdasdasdasdada"
// });
// request.headers.addAll(headers);

// http.StreamedResponse response = await request.send();

// if (response.statusCode == 200) {
//   print(await response.stream.bytesToString());
// }
// else {
//   print(response.reasonPhrase);
// }
