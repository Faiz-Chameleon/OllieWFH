import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/request_status.dart';

class ReviewPostScreen extends StatelessWidget {
  ReviewPostScreen({super.key});
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
              // Back and Title
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
                    "Review Post",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Post Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Row
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                            "assets/icons/Frame 1686560584.png",
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Julia Michael",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        //   decoration: BoxDecoration(color: const Color(0xFFF4EAD6), borderRadius: BorderRadius.circular(20)),
                        //   child: Obx(
                        //     () => Text(controller.selectedCategory.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description Text
                    Text(
                      controller.descriptionController.value.text,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    // Static Map Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Obx(() {
                          final latLng = controller.selectedLatLng.value;
                          if (latLng == null) {
                            return const Center(
                              child: Text("No location selected"),
                            );
                          }
                          return GoogleMap(
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
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Post Button
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  if (controller.createAssistanceStatus.value ==
                      RequestStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () async {
                      var data = {
                        "dateAndTime": controller.formattedDateAndTime
                            .toString(),
                        "postdescription":
                            controller.descriptionController.value.text,
                        "longitude": controller.selectedLongitude.value,
                        "latitude": controller.selectedLatitude.value,
                        "postRequestCategory": controller.selectedCategories
                            .toList(),
                      };
                      print(data);
                      controller.createAssistanceByUser(data);
                      // final bottomController = Get.find<Bottomcontroller>();
                      // bottomController.updateIndex(4);
                      // Get.to(
                      //   () => ConvexStyledBarScreen(),
                      //   transition: Transition.fadeIn,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F362E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Post",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
