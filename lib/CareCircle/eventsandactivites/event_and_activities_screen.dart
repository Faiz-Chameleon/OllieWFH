// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/nearest_event_model.dart';
import 'package:ollie/request_status.dart';

import 'event_details_screen.dart';
import 'event_gallery_widgets.dart';
import 'events_near_you_screen.dart';

class EventsAndActivitiesScreen extends StatefulWidget {
  final CareCircleController controller;
  const EventsAndActivitiesScreen({super.key, required this.controller});

  @override
  State<EventsAndActivitiesScreen> createState() =>
      _EventsAndActivitiesScreenState();
}

class _EventsAndActivitiesScreenState extends State<EventsAndActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final eventsLaneHeight = (screenHeight * 0.31)
        .clamp(236.0, 270.0)
        .toDouble();
    final bottomSpacing = (bottomInset + 80).clamp(80.0, 120.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 0, 15, bottomSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.verticalSpace,

              /// Advertisement
              // Container(
              //   height: 80.h,
              //   decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(10)),
              //   alignment: Alignment.center,
              //   child: const Text("ADVERTISEMENT", style: TextStyle(color: Colors.grey)),
              // ),

              // 20.verticalSpace,
              Obx(() {
                if (widget.controller.getLatestEventStatus.value ==
                    RequestStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (widget.controller.latestEvent.value.eventName == null ||
                    widget.controller.latestEvent.value.eventName == "") {
                  return const Center(
                    child: Text(
                      "No event available or you're not marked as participating.",
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => EventDetailsScreen(
                        careCirclecontroller: widget.controller,
                      ),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 260.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: EventGalleryImageView(
                          imageUrls:
                              widget.controller.latestEvent.value.galleryUrls,
                          height: 260.h,
                          borderRadius: BorderRadius.circular(16),
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
                                    Text(
                                      "TALENT SHOW",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      widget
                                              .controller
                                              .latestEvent
                                              .value
                                              .eventName ??
                                          "",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE38E),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        widget.controller.formatDate(
                                          widget
                                              .controller
                                              .latestEvent
                                              .value
                                              .eventDateAndTime
                                              .toString(),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${widget.controller.latestEvent.value.eventParticipant}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                  Text(
                    "Events Near You",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () =>
                            EventsNearYouScreen(controller: widget.controller),
                        transition: Transition.fadeIn,
                      );
                    },

                    child: Text(
                      "See All",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              SizedBox(
                height: (eventsLaneHeight + 8).clamp(228.0, 258.0).toDouble(),
                child: Obx(() {
                  if (widget.controller.getEventNearYouStatus.value ==
                      RequestStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.controller.nearestEvents.isEmpty) {
                    return const Center(child: Text("No events found"));
                  }

                  List<NearestEventsData> eventsToDisplay = widget
                      .controller
                      .nearestEvents
                      .take(2)
                      .toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(right: 20.w),
                    itemCount: eventsToDisplay.length,
                    itemBuilder: (context, index) {
                      final event = eventsToDisplay[index];

                      return Padding(
                        padding: EdgeInsets.only(right: 14.w),
                        child: eventCard(
                          event: event,
                          imageUrls: event.galleryUrls,
                          title: event.eventName ?? "",
                          day: widget.controller.formatDate(
                            event.eventDateAndTime.toString(),
                          ),
                          month: '',
                          dateTime: widget.controller.formatDateAndTime(
                            event.eventDateAndTime.toString(),
                          ),
                          location:
                              "${event.eventAddress} ${event.eventCity} ${event.eventCountry}",
                        ),
                      );
                    },
                  );
                }),
              ),

              110.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget eventCard({
    required NearestEventsData event,
    required List<String> imageUrls,
    required String title,
    required String day,
    required String month,
    required String dateTime,
    required String location,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => EventDetailsScreen(
            careCirclecontroller: widget.controller,
            event: event,
          ),
          transition: Transition.fadeIn,
        ); // Navigate on tap
      },
      child: Container(
        width: 220.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: SizedBox(
                    height: 140.h,
                    width: double.infinity,
                    child: EventGalleryImageView(
                      imageUrls: imageUrls,
                      height: 140.h,
                      enableSwipe: false,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE38E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      month.isEmpty ? day : '$day\n$month',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 7, 11, 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.verticalSpace,
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Color(0xFF8A6A2A),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateTime,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4A22),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.1,
                            color: Color(0xFF6A6A6A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
