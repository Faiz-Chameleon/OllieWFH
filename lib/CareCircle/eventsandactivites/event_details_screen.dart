import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';

class EventDetailsScreen extends StatelessWidget {
  final CareCircleController careCirclecontroller;
  const EventDetailsScreen({super.key, required this.careCirclecontroller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  child: Image.network(
                    careCirclecontroller.latestEvent.value.image ?? "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg",
                    width: double.infinity,
                    height: 330.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle image load error
                      return Container(
                        height: 120.h,
                        width: double.infinity,
                        color: Colors.grey[200], // Placeholder background color
                        child: Icon(
                          Icons.error,
                          color: Colors.red, // Show an error icon
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  height: 330.h,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFFFFF7E9)],
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: const BackButton(color: Colors.white),
                  ),
                ),

                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text(
                          careCirclecontroller.formatDate(careCirclecontroller.latestEvent.value.eventDateAndTime.toString()),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("TALENT SHOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(careCirclecontroller.latestEvent.value.eventName ?? "", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                      child: Text("${careCirclecontroller.latestEvent.value.eventParticipant}", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text("${careCirclecontroller.latestEvent.value.eventParticipant} Participants Going", style: TextStyle(color: Colors.black54)),

                const SizedBox(height: 24),
                Text("Event Details", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "${careCirclecontroller.latestEvent.value.eventAddress} ${careCirclecontroller.latestEvent.value.eventCity} ${careCirclecontroller.latestEvent.value.eventCountry}" ??
                          "",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 8),
                    Text(careCirclecontroller.formatDateAndTime(careCirclecontroller.latestEvent.value.eventDateAndTime.toString())),
                  ],
                ),

                const SizedBox(height: 24),
                const Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(careCirclecontroller.latestEvent.value.eventDescription ?? "", style: TextStyle(fontSize: 14, height: 1.5)),

                const SizedBox(height: 40),

                Obx(() {
                  if (careCirclecontroller.markAsGoingOnEventStatus.value == RequestStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      careCirclecontroller.markAsGoingOnEvents(careCirclecontroller.latestEvent.value.id.toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: careCirclecontroller.latestEvent.value.isMark == false
                          ? Colors
                                .transparent // Transparent when not going
                          : const Color(0xFFFFC766), // Filled when going
                      elevation: 0,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Fully rounded like image
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      careCirclecontroller.latestEvent.value.isMark == true ? "Marked as Going" : "Mark as Going",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
