// // ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ollie/CareCircle/assistance/select_category_screen.dart';
// import 'package:ollie/CareCircle/care_circle_controller.dart';
// import 'package:ollie/Constants/Constants.dart';
// import 'package:ollie/widgets/showdilogbox.dart';

// import 'your_requests_screen.dart';

// class Assistance_screen extends StatelessWidget {
//   const Assistance_screen({super.key, required this.controller});

//   final CareCircleController controller;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 showStyledCreditDialog(
//                   context: context,
//                   title: "Use Credits?",
//                   message: "Sending this request will deduct 1 credit from your balance. Do you want to continue?",
//                   continueText: "Continue",
//                   cancelText: "Cancel",
//                   onContinue: () {
//                     Get.to(() => SelectCategoryScreen(), transition: Transition.fadeIn);
//                   },
//                   onCancel: () {
//                     // Optional: handle cancel
//                   },
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ksecondaryColor,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               child: Text(
//                 "Add New Request",
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Advertisement placeholder
//           Container(
//             width: double.infinity,
//             height: 80,
//             decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
//             child: const Center(
//               child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // PageView with Volunteer Requests
//           SizedBox(
//             height: 300,
//             child: PageView.builder(
//               itemCount: 3,
//               onPageChanged: controller.changePage,
//               itemBuilder: (context, index) {
//                 return Obx(
//                   () => Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Row(
//                               children: [
//                                 CircleAvatar(radius: 12, backgroundColor: grey),
//                                 SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Posted by Shelley", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                                     Text("11:30 AM", style: TextStyle(fontSize: 10, color: grey)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: const [
//                                 Icon(Icons.shopping_bag_outlined, size: 16, color: Black),
//                                 SizedBox(width: 4),
//                                 Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),

//                         const Text("I need help with groceries, is anyone available?", style: TextStyle(fontSize: 13)),
//                         const SizedBox(height: 10),

//                         SizedBox(
//                           height: 120.h,
//                           width: double.infinity,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: GoogleMap(
//                               initialCameraPosition: const CameraPosition(target: LatLng(37.4219999, -122.0840575), zoom: 14),
//                               zoomControlsEnabled: false, // disables zoom +/- buttons
//                               myLocationButtonEnabled: false, // disables the target button you showed
//                               markers: const <Marker>{},
//                               liteModeEnabled: true,
//                               zoomGesturesEnabled: false,
//                               scrollGesturesEnabled: false,
//                               rotateGesturesEnabled: false,
//                               tiltGesturesEnabled: false,
//                               onMapCreated: (GoogleMapController controller) {},
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 10),

//                         // Reach Out / Sent Button
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             controller.reachedOut.value
//                                 ? ElevatedButton(
//                                     onPressed: () {},
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFB4E197),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                     ),
//                                     child: const Text("Volunteer Request Sent", style: TextStyle(color: Colors.black)),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: controller.reachOut,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFF4BD2A),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                     ),
//                                     child: const Text("Reach Out", style: TextStyle(color: Colors.black)),
//                                   ),
//                             const Icon(Icons.mark_unread_chat_alt_sharp),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Page Indicator
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(3, (index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: controller.currentPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
//                   ),
//                 );
//               }),
//             ),
//           ),

//           const SizedBox(height: 20),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Your Requests",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Get.to(() => YourRequestsFullScreen(), transition: Transition.fadeIn);
//                 },

//                 child: Text("See All", style: TextStyle(color: Colors.grey)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           SizedBox(
//             height: 290,
//             child: PageView.builder(
//               itemCount: 3,
//               onPageChanged: controller.changeYourRequestPage,
//               itemBuilder: (context, index) {
//                 return Obx(() {
//                   final isCompleted = controller.taskCompleted.value;
//                   return Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Row(
//                               children: [
//                                 CircleAvatar(radius: 12, backgroundColor: Colors.grey),
//                                 SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Posted by You", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                                     Text("11:30 AM", style: TextStyle(fontSize: 10, color: Colors.grey)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const Row(
//                               children: [
//                                 Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
//                                 SizedBox(width: 4),
//                                 Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("I need help with groceries, is anyone available?", style: TextStyle(fontSize: 13)),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 120.h,
//                           width: double.infinity,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: GoogleMap(
//                               initialCameraPosition: const CameraPosition(target: LatLng(37.4219999, -122.0840575), zoom: 14),
//                               zoomControlsEnabled: false,
//                               myLocationButtonEnabled: false,
//                               markers: const <Marker>{},
//                               liteModeEnabled: false,
//                               zoomGesturesEnabled: false,
//                               scrollGesturesEnabled: false,
//                               rotateGesturesEnabled: false,
//                               tiltGesturesEnabled: false,
//                               onMapCreated: (GoogleMapController controller) {},
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             GestureDetector(
//                               onTap: controller.completeTask,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: isCompleted ? const Color(0xFFB4E197) : const Color(0xFFF4BD2A),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   isCompleted ? "Task Completed" : "Mark as Completed",
//                                   style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                             PopupMenuButton<String>(
//                               icon: const Icon(Icons.more_horiz),
//                               onSelected: (value) {
//                                 if (value == 'delete') {
//                                   // Call your delete function here
//                                   // controller.deletePost(); // Make sure this exists in your controller
//                                 }
//                               },
//                               itemBuilder: (BuildContext context) => [
//                                 const PopupMenuItem<String>(
//                                   value: 'delete',
//                                   child: Text('Delete post', style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 10),
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(3, (index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: controller.currentYourRequestPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
//                   ),
//                 );
//               }),
//             ),
//           ),
//           150.verticalSpace,
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:ollie/CareCircle/assistance/select_category_screen.dart';
// import 'package:ollie/CareCircle/care_circle_controller.dart';
// import 'package:ollie/Constants/Constants.dart';
// import 'package:ollie/widgets/showdilogbox.dart';

// import 'your_requests_screen.dart';

// class Assistance_screen extends StatelessWidget {
//   const Assistance_screen({super.key, required this.controller});

//   final CareCircleController controller;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 showStyledCreditDialog(
//                   context: context,
//                   title: "Use Credits?",
//                   message: "Sending this request will deduct 1 credit from your balance. Do you want to continue?",
//                   continueText: "Continue",
//                   cancelText: "Cancel",
//                   onContinue: () {
//                     Get.to(() => SelectCategoryScreen(), transition: Transition.fadeIn);
//                   },
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ksecondaryColor,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               child: Text(
//                 "Add New Request",
//                 style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             width: double.infinity,
//             height: 80,
//             decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
//             child: const Center(
//               child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
//             ),
//           ),
//           const SizedBox(height: 20),

//           // Volunteer Requests
//           SizedBox(
//             height: 300,
//             child: PageView.builder(
//               itemCount: 3,
//               onPageChanged: controller.changePage,
//               itemBuilder: (context, index) {
//                 return Obx(
//                   () => Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Row(
//                               children: [
//                                 CircleAvatar(radius: 12, backgroundColor: grey),
//                                 SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Posted by Shelley", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                                     Text("11:30 AM", style: TextStyle(fontSize: 10, color: grey)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: const [
//                                 Icon(Icons.shopping_bag_outlined, size: 16, color: Black),
//                                 SizedBox(width: 4),
//                                 Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("I need help with groceries, is anyone available?", style: TextStyle(fontSize: 13)),
//                         const SizedBox(height: 10),
//                         const GoogleMapPreview(),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             controller.reachedOut.value
//                                 ? ElevatedButton(
//                                     onPressed: () {},
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFB4E197),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                     ),
//                                     child: const Text("Volunteer Request Sent", style: TextStyle(color: Colors.black)),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: controller.reachOut,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFFF4BD2A),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                     ),
//                                     child: const Text("Reach Out", style: TextStyle(color: Colors.black)),
//                                   ),
//                             const Icon(Icons.mark_unread_chat_alt_sharp),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 8),
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(3, (index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: controller.currentPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
//                   ),
//                 );
//               }),
//             ),
//           ),

//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Your Requests",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
//               ),
//               GestureDetector(
//                 onTap: () => Get.to(() => YourRequestsFullScreen(), transition: Transition.fadeIn),
//                 child: Text("See All", style: TextStyle(color: Colors.grey)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Your Requests
//           SizedBox(
//             height: 290,
//             child: PageView.builder(
//               itemCount: 3,
//               onPageChanged: controller.changeYourRequestPage,
//               itemBuilder: (context, index) {
//                 return Obx(() {
//                   final isCompleted = controller.taskCompleted.value;
//                   return Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Row(
//                               children: [
//                                 CircleAvatar(radius: 12, backgroundColor: Colors.grey),
//                                 SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Posted by You", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                                     Text("11:30 AM", style: TextStyle(fontSize: 10, color: Colors.grey)),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const Row(
//                               children: [
//                                 Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
//                                 SizedBox(width: 4),
//                                 Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("I need help with groceries, is anyone available?", style: TextStyle(fontSize: 13)),
//                         const SizedBox(height: 10),
//                         const GoogleMapPreview(),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             GestureDetector(
//                               onTap: controller.completeTask,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: isCompleted ? const Color(0xFFB4E197) : const Color(0xFFF4BD2A),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   isCompleted ? "Task Completed" : "Mark as Completed",
//                                   style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                             PopupMenuButton<String>(
//                               icon: const Icon(Icons.more_horiz),
//                               onSelected: (value) {
//                                 if (value == 'delete') {
//                                   // controller.deletePost();
//                                 }
//                               },
//                               itemBuilder: (BuildContext context) => [
//                                 const PopupMenuItem<String>(
//                                   value: 'delete',
//                                   child: Text('Delete post', style: TextStyle(color: Colors.red)),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 });
//               },
//             ),
//           ),
//           const SizedBox(height: 10),
//           Obx(
//             () => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(3, (index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: controller.currentYourRequestPage.value == index ? const Color(0xFF3C3129) : Colors.grey.shade400,
//                   ),
//                 );
//               }),
//             ),
//           ),
//           150.verticalSpace,
//         ],
//       ),
//     );
//   }
// }

// // GoogleMapPreview widget (can also be in a separate file)
// class GoogleMapPreview extends StatelessWidget {
//   const GoogleMapPreview({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 120.h,
//       width: double.infinity,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: const GoogleMap(
//           initialCameraPosition: CameraPosition(target: LatLng(37.4219999, -122.0840575), zoom: 14),
//           markers: <Marker>{},
//           zoomControlsEnabled: false,
//           myLocationButtonEnabled: false,
//           zoomGesturesEnabled: false,
//           scrollGesturesEnabled: false,
//           rotateGesturesEnabled: false,
//           tiltGesturesEnabled: false,
//           liteModeEnabled: true,
//         ),
//       ),
//     );
//   }
// }
// ignore: duplicate_ignore
// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/Auth/login/user_controller.dart';
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
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Advertisement
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: const Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
            ),
          ),
          const SizedBox(height: 20),

          // Volunteer Requests PageView
          Obx(() {
            if (widget.controller.getOthersCrteatedAssistanceStatus.value == RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.controller.othersCreatedAssistance.isEmpty) {
              return const Center(child: Text("No Other's User Request Found"));
            }
            return SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: widget.controller.othersCreatedAssistance.length,
                onPageChanged: widget.controller.changePage,
                itemBuilder: (context, index) {
                  final otherAssistanceData = widget.controller.othersCreatedAssistance[index];
                  return Container(
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
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      widget.controller.formatDateAndTime(otherAssistanceData.scheduledAt.toString()),
                                      style: TextStyle(fontSize: 10, color: grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Icon(Icons.shopping_bag_outlined, size: 16, color: Black),
                                SizedBox(width: 4),
                                Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          otherAssistanceData.description ?? "",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        GoogleMapPreview(latitude: otherAssistanceData.latitude ?? 40.712776, longitude: otherAssistanceData.longitude ?? -74.005974),
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
                                        style: TextStyle(color: Colors.black),
                                      ),
                              );
                            }),
                            GestureDetector(
                              onTap: () async {
                                var data = {"userId": otherAssistanceData.user?.id.toString() ?? ""};
                                await chatController.createOneOnOneChat(data).then((value) {
                                  Get.to(() => ChatScreen(userName: '', userImage: ''));
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
              GestureDetector(
                onTap: () => Get.to(() => YourRequestsFullScreen(controller: widget.controller), transition: Transition.fadeIn),
                child: const Text("See All", style: TextStyle(color: Colors.grey)),
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
              height: 290,
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
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      widget.controller.formatDateAndTime(createdAssistanceRequest.scheduledAt.toString()),
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
                                SizedBox(width: 4),
                                Text("Errands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          createdAssistanceRequest.description ?? "",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        GoogleMapPreview(
                          latitude: createdAssistanceRequest.latitude ?? 40.712776,
                          longitude: createdAssistanceRequest.longitude ?? -74.005974,
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
                                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
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

class GoogleMapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const GoogleMapPreview({
    Key? key,
    this.latitude, // Optional latitude, if passed by the user
    this.longitude, // Optional longitude, if passed by the user
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use passed latitude and longitude if available, otherwise fall back to static coordinates
    final double lat = latitude ?? 37.4219999; // Default latitude if null
    final double lng = longitude ?? -122.0840575; // Default longitude if null

    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          key: ValueKey('map_preview'),
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng), // Use dynamic lat/lng values
            zoom: 14,
          ),
          markers: <Marker>{
            Marker(
              markerId: MarkerId('selected_location'),
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
      ),
    );
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
