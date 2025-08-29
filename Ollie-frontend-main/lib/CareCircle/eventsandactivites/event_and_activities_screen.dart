// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/nearest_event_model.dart';
import 'package:ollie/request_status.dart';

import 'event_details_screen.dart';
import 'events_near_you_screen.dart';

class EventsAndActivitiesScreen extends StatefulWidget {
  final CareCircleController controller;
  const EventsAndActivitiesScreen({super.key, required this.controller});

  @override
  State<EventsAndActivitiesScreen> createState() => _EventsAndActivitiesScreenState();
}

class _EventsAndActivitiesScreenState extends State<EventsAndActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.verticalSpace,

              /// Advertisement
              Container(
                height: 80.h,
                decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text("ADVERTISEMENT", style: TextStyle(color: Colors.grey)),
              ),

              20.verticalSpace,

              Obx(() {
                if (widget.controller.getLatestEventStatus.value == RequestStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (widget.controller.latestEvent.value.eventName == null || widget.controller.latestEvent.value.eventName == "") {
                  return const Center(child: Text("No event available or you're not marked as participating."));
                }
                return GestureDetector(
                  onTap: () {
                    Get.to(() => EventDetailsScreen(careCirclecontroller: widget.controller), transition: Transition.fadeIn);
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 260.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.controller.latestEvent.value.image ?? "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg",
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              widget.controller.latestEvent.value.image = "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg";
                            },
                          ),
                        ),
                      ),

                      // Gradient Overlay
                      Container(
                        height: 260.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [white, white, Colors.transparent],
                            stops: [0.0, 0.3, 0.6],
                          ),
                        ),
                      ),

                      // Content Layer
                      Container(
                        height: 260.h,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("TALENT SHOW", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text(
                                      widget.controller.latestEvent.value.eventName ?? "",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${widget.controller.latestEvent.value.eventParticipant} Participants Going",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(10)),
                                      child: Text(
                                        widget.controller.formatDate(widget.controller.latestEvent.value.eventDateAndTime.toString()),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("${widget.controller.latestEvent.value.eventParticipant}", style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              30.verticalSpace,

              /// Events Near You
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Events Near You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => EventsNearYouScreen(controller: widget.controller), transition: Transition.fadeIn);
                    },

                    child: Text("See All", style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              10.verticalSpace,
              SizedBox(
                height: 240.h,
                child: Obx(() {
                  if (widget.controller.getEventNearYouStatus.value == RequestStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.controller.nearestEvents.isEmpty) {
                    return const Center(child: Text("No events found"));
                  }

                  List<NearestEventsData> eventsToDisplay = widget.controller.nearestEvents.take(2).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: eventsToDisplay.length,
                    itemBuilder: (context, index) {
                      final event = eventsToDisplay[index];

                      return eventCard(
                        image: event.image ?? "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg",
                        title: event.eventName ?? "",
                        day: widget.controller.formatDate(event.eventDateAndTime.toString()),
                        month: '',
                        dateTime: widget.controller.formatDateAndTime(event.eventDateAndTime.toString()),
                        location: "${event.eventAddress} ${event.eventCity} ${event.eventCountry}",
                      );
                    },
                  );
                }),
              ),

              150.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget eventCard({
    required String image,
    required String title,
    required String day,
    required String month,
    required String dateTime,
    required String location,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => EventDetailsScreen(careCirclecontroller: widget.controller), transition: Transition.fadeIn); // Navigate on tap
      },
      child: Container(
        width: 240.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    image,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120.h,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(10)),
                    child: Text('$day\n$month', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(dateTime, style: const TextStyle(fontSize: 12)),
                  Text(location, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
