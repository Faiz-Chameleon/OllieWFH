import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/Constants.dart';
import 'package:ollie/Models/others_created_assistance_model.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/volunteers_chat_screen.dart';
import 'package:ollie/request_status.dart';

class AssistanceDetailScreen extends StatefulWidget {
  const AssistanceDetailScreen({
    super.key,
    required this.controller,
    required this.assistance,
    required this.index,
  });

  final CareCircleController controller;
  final OthersCreatedAssistance assistance;
  final int index;

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
  late final Future<String> _addressFuture;
  final OneToOneChatController chatController =
      Get.find<OneToOneChatController>();

  @override
  void initState() {
    super.initState();
    _addressFuture = _loadAddress();
  }

  Future<String> _loadAddress() async {
    final lat = widget.assistance.latitude;
    final lng = widget.assistance.longitude;
    if (lat == null || lng == null) {
      return "Address not available";
    }

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return "Address not available";
      }

      final p = placemarks.first;
      final parts =
          [
                p.street,
                p.subLocality,
                p.locality,
                p.administrativeArea,
                p.postalCode,
                p.country,
              ]
              .where((part) => part != null && part.trim().isNotEmpty)
              .cast<String>()
              .toList();

      return parts.isEmpty ? "Address not available" : parts.join(", ");
    } catch (_) {
      return "Address not available";
    }
  }

  Future<void> _openChat() async {
    final data = {"userId": widget.assistance.user?.id.toString() ?? ""};
    await chatController.createOneOnOneChat(data);
    if (!mounted) return;
    Get.to(
      () => ChatScreen(
        userName: widget.assistance.user?.firstName.toString() ?? "",
        userImage: widget.assistance.user?.image.toString() ?? "",
      ),
    );
  }

  Future<void> _handleReachOut() async {
    final userController = Get.put(UserController());
    final String loggedInUserId = userController.user.value?.id ?? '';
    final volunteerRequests = widget.assistance.volunteerRequests ?? [];
    String requestId = "";
    for (final volunteerRequest in volunteerRequests) {
      if (volunteerRequest.volunteerId == loggedInUserId) {
        requestId = volunteerRequest.id ?? "";
        break;
      }
    }

    widget.controller.postLoadingStatus[widget.index].value = true;
    if (widget.assistance.status == "NoRequest") {
      await widget.controller.reachOutOnAssistance(
        widget.assistance.id ?? "",
        widget.index,
      );
    } else if (widget.controller.canVolunteerComplete(
          widget.assistance.status,
        ) &&
        requestId.isNotEmpty) {
      await widget.controller.completeAssistanceByVolunter(requestId);
    }
    widget.controller.postLoadingStatus[widget.index].value = false;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.assistance;
    final lat = data.latitude ?? 40.712776;
    final lng = data.longitude ?? -74.005974;
    final categoryText = (data.categories ?? [])
        .map((e) => e.name)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(", ");
    final posterName =
        "Posted by ${data.user?.firstName ?? ""} ${data.user?.lastName ?? ""}"
            .trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Request Details",
          style: GoogleFonts.darkerGrotesque(
            color: Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: grey,
                    backgroundImage:
                        data.user?.image != null && data.user!.image!.isNotEmpty
                        ? NetworkImage(data.user!.image!)
                        : null,
                    child: data.user?.image == null || data.user!.image!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          posterName.trim().isEmpty
                              ? "Posted by User"
                              : posterName,
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.controller.formatDateAndTime(
                            data.scheduledAt.toString(),
                          ),
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 16.sp,
                            color: grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionLabel(title: "Category"),
              Text(
                categoryText.isEmpty ? "Errands" : categoryText,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const _SectionLabel(title: "Description"),
              Text(
                (data.description ?? "").isEmpty
                    ? "No description available"
                    : data.description!,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const _SectionLabel(title: "Address"),
              FutureBuilder<String>(
                future: _addressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return Text(
                    snapshot.data ?? "Address not available",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel(title: "Location"),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('assistance_location'),
                        position: LatLng(lat, lng),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    liteModeEnabled: true,
                    scrollGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed:
                            widget
                                    .controller
                                    .postLoadingStatus[widget.index]
                                    .value ||
                                !(data.status == "NoRequest" ||
                                    widget.controller.canVolunteerComplete(
                                      data.status,
                                    ))
                            ? null
                            : _handleReachOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: data.status == "NoRequest"
                              ? const Color(0xFFF4BD2A)
                              : Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            widget
                                .controller
                                .postLoadingStatus[widget.index]
                                .value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                data.status == "ReachOut"
                                    ? "Mark as Completed"
                                    : widget.controller
                                          .statusLabelForOtherAssistance(
                                            data.status,
                                          ),
                                style: GoogleFonts.darkerGrotesque(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Obx(() {
                    if (chatController.createChatRoomRequestStatus.value ==
                        RequestStatus.loading) {
                      return const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return InkWell(
                      onTap: _openChat,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4BD2A),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.mark_unread_chat_alt_sharp,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.darkerGrotesque(
          fontSize: 16.sp,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
