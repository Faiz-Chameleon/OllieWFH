// ignore_for_file: unused_import, camel_case_types, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/create_new_group.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/group_card_widget.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/CareCircle/groups/only_my_groups.dart';
import 'package:ollie/CareCircle/groups/see_all_groups.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class Group_Screen extends StatelessWidget {
  Group_Screen({super.key, required this.controller});

  final CareCircleController controller;

  final OneToManyChatController groupChatcontroller =
      Get.find<OneToManyChatController>();

  void _log(String message) {
    debugPrint('[GroupScreen] $message');
  }

  void _openJoinedGroupChat(MyGroupsData group) {
    final chatRoomId = group.id?.trim().isNotEmpty == true
        ? group.id!.trim()
        : group.lastMessage?.chatRoomId?.trim() ?? '';

    if (chatRoomId.isEmpty) {
      appSnackbar("Error", "No chat room found for this group.");
      return;
    }

    groupChatcontroller.groupConversationId.value = chatRoomId;
    _log(
      'Opening joined group chat directly: groupId=${group.id}, chatRoomId=$chatRoomId',
    );
    Get.to(
      () => GrouoChatScreen(userName: group.name ?? "", groupDetails: group),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Nearby Groups", () {
              Get.to(
                () => GroupListScreen(
                  title: "Nearby Groups",
                  controller: controller,
                  // groups: [
                  //   {'title': 'Tea & Tales', 'image': 'assets/images/Frame 1686560577.png', 'joined': true},
                  //   {'title': 'Memory Lane', 'image': 'assets/images/Frame 73 (2).png', 'joined': false},
                  // ],
                ),
              );
            }),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.getOthersGroupsStatus.value ==
                  RequestStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.getOthersGroupsStatus.value ==
                  RequestStatus.error) {
                return Center(
                  child: Text(
                    controller.groupLocationErrorMessage.value.isEmpty
                        ? "Unable to load nearby groups"
                        : controller.groupLocationErrorMessage.value,
                  ),
                );
              } else if (controller.othersGroups.isEmpty) {
                return Center(child: Text("No nearby groups found"));
              }
              final groupsToShow = controller.othersGroups.take(2).toList();

              return SizedBox(
                height: 230.h,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,

                  itemCount: groupsToShow.length,

                  itemBuilder: (context, index) {
                    final othersGroup = groupsToShow[index];

                    return GestureDetector(
                      onTap: () {
                        _log(
                          'Featured group tapped: groupId=${othersGroup.id}, name=${othersGroup.name}, memberCount=${othersGroup.memberCount}',
                        );
                        groupChatcontroller
                            .joinGroupChatRoom(othersGroup.id.toString())
                            .then((joined) {
                              if (!joined) return;
                              _log(
                                'Navigation to group chat after join API: groupId=${othersGroup.id}, conversationId=${groupChatcontroller.groupConversationId.value}, status=${groupChatcontroller.joinGrouoChatRoomRequestStatus.value}',
                              );
                              Get.to(
                                () => GrouoChatScreen(
                                  userName: othersGroup.name ?? "",
                                  groupDetails: othersGroup,
                                ),
                              );
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: GroupCardWidget(
                          title: othersGroup.name ?? "",
                          members: "${othersGroup.memberCount.toString()}+",
                          action:
                              othersGroup.groupPrivacy?.toUpperCase() ==
                                  "PRIVATE"
                              ? "Request"
                              : "Join",
                          imagePath: othersGroup.image ?? "",
                          membersImages: othersGroup.participants?.users ?? [],
                          joined: false,
                          width: 210.w,
                          distanceKm: othersGroup.distanceKm,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // SizedBox(
            //   height: 220.w,
            //   child: ListView(
            //     scrollDirection: Axis.horizontal,
            //     children: [
            //       _groupCard("Tea & Tales", "4k+", "View", "assets/images/Frame 1686560577.png", joined: true),
            //       const SizedBox(width: 12),
            //       _groupCard("Memory Lane", "4k+", "Join", "assets/images/Frame 73 (2).png", joined: false),
            //     ],
            //   ),
            // ),
            SizedBox(height: 20.h),

            _sectionHeader("Your Groups", () {
              if (!Get.isRegistered<CreateGroupController>()) {
                Get.put(CreateGroupController());
              }

              Get.to(
                () => OnlyYourGroups(
                  title: "Your Groups",
                  controller: controller,
                ),
              );
            }),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.getYourGroupsStatus.value ==
                  RequestStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.getYourGroupsStatus.value ==
                  RequestStatus.error) {
                return Center(child: Text("Failed to load groups"));
              } else if (controller.myGroups.isEmpty) {
                return Center(child: Text("No groups found"));
              }
              final groupsToShow = controller.myGroups.length > 2
                  ? controller.myGroups.sublist(0, 2)
                  : controller.myGroups;

              return SizedBox(
                height: 230.h,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,

                  itemCount: groupsToShow.length,

                  itemBuilder: (context, index) {
                    final group = groupsToShow[index];

                    return GestureDetector(
                      onTap: () {
                        _log(
                          'Your group tapped: groupId=${group.id}, name=${group.name}, memberCount=${group.memberCount}',
                        );
                        _openJoinedGroupChat(group);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: GroupCardWidget(
                          title: group.name ?? "",
                          members: "${group.memberCount.toString()}+",
                          action: "View",
                          imagePath: group.image ?? "",
                          membersImages: group.participants?.users ?? [],
                          joined: true,
                          width: 210.w,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            SizedBox(height: 20.h),

            170.verticalSpace,
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 145.h),
        child: GestureDetector(
          onTap: () => Get.to(
            () => Group_Creation_Screen(),
            transition: Transition.fadeIn,
          ),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: white),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAllTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsiveFontSize(20, min: 18, max: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text(
            "See All",
            style: TextStyle(
              color: Colors.grey,
              fontSize: responsiveFontSize(16, min: 14, max: 18),
            ),
          ),
        ),
      ],
    );
  }
}
