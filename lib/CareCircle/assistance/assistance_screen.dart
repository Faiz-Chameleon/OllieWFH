// ignore_for_file: use_super_parameters, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/assistance_detail_screen.dart';
import 'package:ollie/CareCircle/assistance/assistance_media_widgets.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:ollie/CareCircle/assistance/select_category_screen.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/Constants/Constants.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/volunteers_chat_screen.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/widgets/showdilogbox.dart';
import 'package:ollie/common/common.dart';

import 'your_requests_screen.dart';

class Assistance_screen extends StatefulWidget {
  const Assistance_screen({super.key, required this.controller});

  final CareCircleController controller;

  @override
  State<Assistance_screen> createState() => _Assistance_screenState();
}

class _Assistance_screenState extends State<Assistance_screen> {
  final OneToOneChatController chatController =
      Get.find<OneToOneChatController>();
  final Assistance_Controller assistanceController = Get.put(
    Assistance_Controller(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assistanceController.getCategoriesForAssistance();
    });
  }

  String _categoryLabel(dynamic categories) {
    if (categories is List && categories.isNotEmpty) {
      final names = categories
          .map((category) => category?.name?.toString().trim())
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names.join(", ");
    }
    return "Errands";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: buttonColor,
      onRefresh: () => widget.controller.refreshTab(0),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    message:
                        "Sending this request will deduct 1 credit from your balance. Do you want to continue?",
                    continueText: "Continue",
                    cancelText: "Cancel",
                    onContinue: () {
                      Get.to(
                        () => SelectCategoryScreen(),
                        transition: Transition.fadeIn,
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ksecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  "Add New Request",
                  style: GoogleFonts.darkerGrotesque(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveFontSize(20, min: 18, max: 24),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Advertisement
            // Container(
            //   width: double.infinity,
            //   height: 80,
            //   decoration: BoxDecoration(color: const Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
            //   child: const Center(
            //     child: Text("ADVERTISEMENT", style: TextStyle(color: Black)),
            //   ),
            // ),
            SizedBox(height: 20.h),

            Row(
              children: [
                Text(
                  "Assistance Nearby",
                  style: GoogleFonts.darkerGrotesque(
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveFontSize(22, min: 20, max: 26),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Volunteer Requests PageView
            Obx(() {
              if (widget.controller.getOthersCrteatedAssistanceStatus.value ==
                  RequestStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              Widget emptyNearbyMessage(String message) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 18.h,
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: responsiveFontSize(18, min: 16, max: 22),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }

              if (widget.controller.getOthersCrteatedAssistanceStatus.value ==
                      RequestStatus.error &&
                  widget
                      .controller
                      .assistanceLocationErrorMessage
                      .value
                      .isNotEmpty) {
                return emptyNearbyMessage(
                  widget.controller.assistanceLocationErrorMessage.value,
                );
              }
              if (widget.controller.othersCreatedAssistance.isEmpty) {
                return emptyNearbyMessage(
                  "No nearby assistance requests found.",
                );
              }
              return SizedBox(
                height: 340,
                child: PageView.builder(
                  itemCount: widget.controller.othersCreatedAssistance.length,
                  onPageChanged: (index) {
                    widget.controller.changePage(index);
                    // Fetch the next page a few cards before the end.
                    if (index >=
                        widget.controller.othersCreatedAssistance.length - 3) {
                      widget.controller.userFetchOthersCreatedAssitance(
                        loadMore: true,
                      );
                    }
                  },
                  itemBuilder: (context, index) {
                    final otherAssistanceData =
                        widget.controller.othersCreatedAssistance[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => AssistanceDetailScreen(
                            controller: widget.controller,
                            assistance: otherAssistanceData,
                            index: index,
                          ),
                          transition: Transition.fadeIn,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: grey,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Posted by ${otherAssistanceData.user?.firstName ?? ""}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.darkerGrotesque(
                                                    fontSize:
                                                        responsiveFontSize(
                                                          19,
                                                          min: 17,
                                                          max: 24,
                                                        ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            Text(
                                              widget.controller
                                                  .formatDateAndTime(
                                                    otherAssistanceData
                                                        .scheduledAt
                                                        .toString(),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.darkerGrotesque(
                                                    fontSize:
                                                        responsiveFontSize(
                                                          17,
                                                          min: 15,
                                                          max: 20,
                                                        ),
                                                    color: grey,
                                                  ),
                                            ),
                                            if (otherAssistanceData
                                                    .distanceKm !=
                                                null)
                                              Text(
                                                "${otherAssistanceData.distanceKm!.toStringAsFixed(1)} km away",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.darkerGrotesque(
                                                      fontSize:
                                                          responsiveFontSize(
                                                            17,
                                                            min: 15,
                                                            max: 20,
                                                          ),
                                                      color: const Color(
                                                        0xFF9C7D4A,
                                                      ),
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 16,
                                        color: Black,
                                      ),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: Text(
                                          _categoryLabel(
                                            otherAssistanceData.categories,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.darkerGrotesque(
                                            fontSize: responsiveFontSize(
                                              19,
                                              min: 17,
                                              max: 24,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              otherAssistanceData.description ?? "",
                              style: GoogleFonts.darkerGrotesque(
                                fontSize: responsiveFontSize(
                                  18,
                                  min: 16,
                                  max: 22,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF9C7D4A),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    otherAssistanceData.displayLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.darkerGrotesque(
                                      fontSize: responsiveFontSize(
                                        17,
                                        min: 15,
                                        max: 20,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9C7D4A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 52,
                              child: GoogleMapPreview(
                                latitude: otherAssistanceData.latitude,
                                longitude: otherAssistanceData.longitude,
                              ),
                            ),
                            if (otherAssistanceData.attachments?.isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 8),
                              AssistanceMediaStrip(
                                attachments: otherAssistanceData.attachments!,
                                height: 46,
                              ),
                            ],
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
                                    onPressed:
                                        !(otherAssistanceData.status ==
                                                "NoRequest" ||
                                            widget.controller
                                                .canVolunteerComplete(
                                                  otherAssistanceData.status,
                                                ))
                                        ? null
                                        : () async {
                                            final userController = Get.put(
                                              UserController(),
                                            );
                                            final String loggedInUserId =
                                                userController.user.value?.id ??
                                                '';
                                            String requestId = "";
                                            for (final volunteerRequest
                                                in (otherAssistanceData
                                                        .volunteerRequests ??
                                                    [])) {
                                              if (volunteerRequest
                                                      .volunteerId ==
                                                  loggedInUserId) {
                                                requestId =
                                                    volunteerRequest.id ?? "";
                                                break;
                                              }
                                            }
                                            widget
                                                    .controller
                                                    .postLoadingStatus[index]
                                                    .value =
                                                true;
                                            if (otherAssistanceData.status ==
                                                "NoRequest") {
                                              await widget.controller
                                                  .reachOutOnAssistance(
                                                    otherAssistanceData.id ??
                                                        "",
                                                    index,
                                                  );
                                            } else if (widget.controller
                                                    .canVolunteerComplete(
                                                      otherAssistanceData
                                                          .status,
                                                    ) &&
                                                requestId.isNotEmpty) {
                                              await widget.controller
                                                  .completeAssistanceByVolunter(
                                                    requestId,
                                                  );
                                            }

                                            widget
                                                    .controller
                                                    .postLoadingStatus[index]
                                                    .value =
                                                false;
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          otherAssistanceData.status ==
                                              "NoRequest"
                                          ? const Color(0xFFF4BD2A)
                                          : Colors.green,
                                      minimumSize: Size(0, 44.h),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 10.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child:
                                        widget
                                            .controller
                                            .postLoadingStatus[index]
                                            .value
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            otherAssistanceData.status ==
                                                    "ReachOut"
                                                ? "Mark as Completed"
                                                : widget.controller
                                                      .statusLabelForOtherAssistance(
                                                        otherAssistanceData
                                                            .status,
                                                      ),
                                            style: GoogleFonts.darkerGrotesque(
                                              color: Colors.black,
                                              fontSize: responsiveFontSize(
                                                17,
                                                min: 15,
                                                max: 21,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  );
                                }),
                                GestureDetector(
                                  onTap: () async {
                                    var data = {
                                      "userId":
                                          otherAssistanceData.user?.id
                                              .toString() ??
                                          "",
                                    };
                                    await chatController
                                        .createOneOnOneChat(data)
                                        .then((value) {
                                          Get.to(
                                            () => ChatScreen(
                                              userName:
                                                  otherAssistanceData
                                                      .user
                                                      ?.firstName
                                                      .toString() ??
                                                  "",
                                              userImage:
                                                  otherAssistanceData
                                                      .user
                                                      ?.image
                                                      .toString() ??
                                                  "",
                                            ),
                                          );
                                        });
                                  },
                                  child: Obx(() {
                                    if (chatController
                                            .createChatRoomRequestStatus
                                            .value ==
                                        RequestStatus.loading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return Icon(
                                      Icons.mark_unread_chat_alt_sharp,
                                      size: 28.sp,
                                    );
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
            SizedBox(height: 8.h),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.controller.othersCreatedAssistance.length,
                  (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.controller.currentPage.value == index
                            ? const Color(0xFF3C3129)
                            : Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              );
            }),

            // Your Requests Title
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Requests",
                  style: GoogleFonts.darkerGrotesque(
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveFontSize(22, min: 20, max: 26),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(
                    () => YourRequestsFullScreen(controller: widget.controller),
                    transition: Transition.fadeIn,
                  ),
                  child: Text(
                    "See All",
                    style: GoogleFonts.darkerGrotesque(
                      color: Colors.grey,
                      fontSize: responsiveFontSize(16, min: 14, max: 18),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Your Requests PageView
            Obx(() {
              if (widget.controller.getCrteatedAssistanceStatus.value ==
                  RequestStatus.loading) {
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
                    final createdAssistanceRequest =
                        widget.controller.createdAssistance[index];

                    // final isCompleted = controller.taskCompleted.value;
                    return Container(
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey,
                                  ),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Posted by ${createdAssistanceRequest.user?.firstName ?? ""}",
                                        style: GoogleFonts.darkerGrotesque(
                                          fontSize: responsiveFontSize(
                                            18,
                                            min: 16,
                                            max: 22,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.controller.formatDateAndTime(
                                          createdAssistanceRequest.scheduledAt
                                              .toString(),
                                        ),
                                        style: GoogleFonts.darkerGrotesque(
                                          fontSize: responsiveFontSize(
                                            16,
                                            min: 14,
                                            max: 18,
                                          ),
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _categoryLabel(
                                      createdAssistanceRequest.categories,
                                    ),
                                    style: GoogleFonts.darkerGrotesque(
                                      fontSize: responsiveFontSize(
                                        18,
                                        min: 16,
                                        max: 22,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            createdAssistanceRequest.description ?? "",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: responsiveFontSize(
                                18,
                                min: 16,
                                max: 22,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF9C7D4A),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  createdAssistanceRequest.displayLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.darkerGrotesque(
                                    fontSize: responsiveFontSize(
                                      17,
                                      min: 15,
                                      max: 20,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9C7D4A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: GoogleMapPreview(
                              latitude: createdAssistanceRequest.latitude,
                              longitude: createdAssistanceRequest.longitude,
                            ),
                          ),
                          if (createdAssistanceRequest
                                  .attachments
                                  ?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 8),
                            AssistanceMediaStrip(
                              attachments:
                                  createdAssistanceRequest.attachments!,
                              height: 46,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap:
                                    widget.controller.canOwnerConfirmCompletion(
                                      createdAssistanceRequest.status,
                                    )
                                    ? () {
                                        String requestId = "";
                                        for (final volunteerRequest
                                            in (createdAssistanceRequest
                                                    .volunteerRequests ??
                                                [])) {
                                          if (volunteerRequest.status ==
                                              "MarkAsCompleted") {
                                            requestId =
                                                volunteerRequest.id ?? "";
                                            break;
                                          }
                                        }
                                        if (requestId.isNotEmpty) {
                                          widget.controller.completeTaskByOwner(
                                            requestId,
                                            postId: createdAssistanceRequest.id,
                                          );
                                        }
                                      }
                                    : null,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        createdAssistanceRequest.status ==
                                            "NoRequest"
                                        ? const Color(0xFFB4E197)
                                        : const Color(0xFFF4BD2A),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.controller
                                        .statusLabelForOwnerAssistance(
                                          createdAssistanceRequest.status,
                                        ),
                                    style: GoogleFonts.darkerGrotesque(
                                      color: Colors.black,
                                      fontSize: responsiveFontSize(
                                        16,
                                        min: 14,
                                        max: 20,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
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
                children: List.generate(
                  widget.controller.createdAssistance.length,
                  (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            widget.controller.currentYourRequestPage.value ==
                                index
                            ? const Color(0xFF3C3129)
                            : Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            160.verticalSpace,
          ],
        ),
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
    // No location: say so rather than pinning a made-up place.
    if (latitude == null || longitude == null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2ECE3),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text('Location not set'),
        ),
      );
    }
    final double lat = latitude!;
    final double lng = longitude!;

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
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
