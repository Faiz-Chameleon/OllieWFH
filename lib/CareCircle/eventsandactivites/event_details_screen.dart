// ignore_for_file: dead_null_aware_expression

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Models/nearest_event_model.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';
import 'event_gallery_widgets.dart';

class EventDetailsScreen extends StatelessWidget {
  final CareCircleController careCirclecontroller;
  final NearestEventsData? event;
  const EventDetailsScreen({
    super.key,
    required this.careCirclecontroller,
    this.event,
  });

  String? get _eventId =>
      event?.id ?? careCirclecontroller.latestEvent.value.id;
  String get _eventName =>
      event?.eventName ??
      careCirclecontroller.latestEvent.value.eventName ??
      "";
  String get _eventDescription =>
      event?.eventDescription ??
      careCirclecontroller.latestEvent.value.eventDescription ??
      "";
  String? get _eventDateAndTime =>
      event?.eventDateAndTime ??
      careCirclecontroller.latestEvent.value.eventDateAndTime;
  int? get _eventParticipant =>
      event?.eventParticipant ??
      careCirclecontroller.latestEvent.value.eventParticipant;
  bool get _isMarked =>
      event?.isMark ?? careCirclecontroller.latestEvent.value.isMark ?? false;
  List<String> get _galleryUrls =>
      event?.galleryUrls ?? careCirclecontroller.latestEvent.value.galleryUrls;

  String get _eventLocation {
    final parts = [
      event?.eventAddress ??
          careCirclecontroller.latestEvent.value.eventAddress,
      event?.eventCity ?? careCirclecontroller.latestEvent.value.eventCity,
      event?.eventCountry ??
          careCirclecontroller.latestEvent.value.eventCountry,
    ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();

    return parts.join(" ");
  }

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
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 330.h,
                    child: EventGalleryImageView(
                      imageUrls: _galleryUrls,
                      height: 330.h,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 330.h,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: const BackButton(color: Colors.white),
                  ),
                ),

                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          careCirclecontroller.formatDate(
                            _eventDateAndTime.toString(),
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
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
                const Text(
                  "TALENT SHOW",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _eventName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "${_eventParticipant ?? 0}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  "${_eventParticipant ?? 0} Participants Going",
                  style: TextStyle(color: Colors.black54, fontSize: 18.sp),
                ),

                const SizedBox(height: 24),
                Text(
                  "Event Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _eventLocation,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 8),
                    Text(
                      careCirclecontroller.formatDateAndTime(
                        _eventDateAndTime.toString(),
                      ),
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _eventDescription,
                  style: TextStyle(fontSize: 18.sp, height: 1.5),
                ),

                const SizedBox(height: 40),

                Obx(() {
                  if (careCirclecontroller.markAsGoingOnEventStatus.value ==
                      RequestStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      final eventId = _eventId;
                      if (eventId == null || eventId.isEmpty) return;
                      careCirclecontroller.markAsGoingOnEvents(eventId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isMarked
                          ? Colors
                                .transparent // Transparent when not going
                          : const Color(0xFFFFC766), // Filled when going
                      elevation: 0,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Fully rounded like image
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      _isMarked ? "Marked as Going" : "Mark as Going",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.sp,
                      ),
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
