// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:get/get.dart';
// import 'package:ollie/CareCircle/assistance/map_location_dialog.dart';
// import 'package:ollie/CareCircle/assistance/new_location_controller.dart';

// class GoogleMapScreen extends StatelessWidget {
//   GoogleMapScreen({Key? key}) : super(key: key);

//   final MapController mapController = Get.put(
//     MapController(),
//   ); // Initialize GetX Controller

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Google Map Example"),
//         backgroundColor: Colors.green,
//       ),
//       body: Obx(() {
//         if (mapController.currentPosition.value == null) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           ); // Show loading spinner until location is fetched
//         }

//         return Stack(
//           children: [
//             GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: mapController
//                     .currentPosition
//                     .value!, // Center map on user's current location
//                 zoom: 14,
//               ),
//               markers: mapController.markers.value,
//               onMapCreated: (GoogleMapController controller) {
//                 try {
//                   // Optional: Set map style here if needed (remove this line if you don't want a custom style)
//                   controller.setMapStyle(
//                     darkMapStyle,
//                   ); // Apply the dark map style
//                 } catch (e) {
//                   print(
//                     "Error setting map style: $e",
//                   ); // Catch any error if map style is invalid
//                 }
//               },
//               myLocationEnabled:
//                   true, // Show the user's current location on the map
//               myLocationButtonEnabled:
//                   true, // Enable location button to center map on user's location
//               onTap: (LatLng position) {
//                 // When the user taps on the map, add a marker at the tapped position
//                 mapController.addMarker(position);
//               },
//             ),

//             Positioned(
//               top: 20,
//               left: 20,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Example button on top of the map
//                   print("Button pressed!");
//                 },
//                 child: const Text("Top Button"),
//               ),
//             ),
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   if (mapController.currentPosition.value != null) {
//                     // Center the map on the user's current location
//                     final LatLng position =
//                         mapController.currentPosition.value!;
//                     mapController.addMarker(
//                       position,
//                     ); // Add marker at the current location
//                   }
//                 },
//                 child: Icon(Icons.my_location),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
