import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Models/nearest_event_model.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';
import 'event_details_screen.dart'; // Update path as needed

class EventsNearYouScreen extends StatefulWidget {
  final CareCircleController controller;
  const EventsNearYouScreen({super.key, required this.controller});

  @override
  State<EventsNearYouScreen> createState() => _EventsNearYouScreenState();
}

class _EventsNearYouScreenState extends State<EventsNearYouScreen> {
  final CareCircleController controller = Get.put(CareCircleController());

  final List<Map<String, String>> events = [
    {
      "image": "assets/images/Card (1).png",
      "title": "Positive Reflection Campaign",
      "date": "Saturday  02:00PM",
      "location": "124 Brooklyn Street, CA",
      "day": "20",
      "month": "July",
    },
    {
      "image": "assets/images/Card.png",
      "title": "Friendly Outreach Activity",
      "date": "Monday  02:00PM",
      "location": "124 Brooklyn Street, CA",
      "day": "20",
      "month": "July",
    },
    {
      "image": "assets/images/Card (1).png",
      "title": "Plant & Share",
      "date": "Friday  02:00PM",
      "location": "124 Brooklyn Street, CA",
      "day": "20",
      "month": "July",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Events Near You",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Ad Banner Placeholder
            Container(
              height: 80.h,
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                // ignore: use_full_hex_values_for_flutter_colors
                color: const Color(0xff1e18180d),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text("ADVERTISEMENT", style: TextStyle(color: Colors.black54)),
            ),

            Obx(() {
              if (widget.controller.getEventNearYouStatus.value == RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.controller.nearestEvents.isEmpty) {
                return const Center(child: Text("No events found"));
              }

              List<NearestEventsData> eventsToDisplay = widget.controller.nearestEvents.toList();

              return ListView.builder(
                shrinkWrap: true,

                itemCount: widget.controller.nearestEvents.length,
                itemBuilder: (context, index) {
                  final event = eventsToDisplay[index];

                  return GestureDetector(
                    onTap: () => Get.to(() => EventDetailsScreen(careCirclecontroller: controller)), // Navigate to full detail screen
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  event.image ?? "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg",
                                  height: 140.h,
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
                                  child: Text(
                                    widget.controller.formatDate(event.eventDateAndTime.toString()),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(event.eventName ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.controller.formatDateAndTime(event.eventDateAndTime.toString()), style: const TextStyle(fontSize: 12)),
                          Text("${event.eventAddress} ${event.eventCity} ${event.eventCountry}", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                  ;
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, String> event) {
    return GestureDetector(
      onTap: () => Get.to(() => EventDetailsScreen(careCirclecontroller: controller)), // Navigate to full detail screen
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(event["image"]!, height: 140.h, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFFFE38E), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "${event['day']}\n${event['month']}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(event["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(event["date"]!, style: const TextStyle(fontSize: 12)),
            Text(event["location"]!, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
