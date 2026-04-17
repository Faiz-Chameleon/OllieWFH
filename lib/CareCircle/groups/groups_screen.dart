// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

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

  final OneToManyChatController groupChatcontroller = Get.put(OneToManyChatController());

  void _log(String message) {
    debugPrint('[GroupScreen] $message');
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
            _sectionHeader("Featured", () {
              Get.to(
                () => GroupListScreen(
                  title: "Featured",
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
              if (controller.getOthersGroupsStatus.value == RequestStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.getOthersGroupsStatus.value == RequestStatus.error) {
                return Center(child: Text("Failed to load groups"));
              } else if (controller.othersGroups.isEmpty) {
                return Center(child: Text("No Others groups found"));
              }
              final groupsToShow = controller.othersGroups.isNotEmpty ? controller.othersGroups.take(2).toList() : controller.myGroups;

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
                        final othersGroup = controller.othersGroups[index];
                        _log('Featured group tapped: groupId=${othersGroup.id}, name=${othersGroup.name}, memberCount=${othersGroup.memberCount}');
                        groupChatcontroller.joinGroupChatRoom(othersGroup.id.toString()).then((value) {
                          _log(
                            'Navigation to group chat after join API: groupId=${othersGroup.id}, conversationId=${groupChatcontroller.groupConversationId.value}, status=${groupChatcontroller.joinGrouoChatRoomRequestStatus.value}',
                          );
                          Get.to(() => GrouoChatScreen(userName: othersGroup.name ?? "", groupDetails: othersGroup));
                        });
                      },
                        child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: GroupCardWidget(
                          title: othersGroup.name ?? "",
                          members: "${othersGroup.memberCount.toString()}+",
                          action: "Join",
                          imagePath: othersGroup.image ?? "",
                          membersImages: othersGroup.participants?.users ?? [],
                          joined: true,
                          width: 210.w,
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

              Get.to(() => OnlyYourGroups(title: "Your Groups", controller: controller));
            }),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.getYourGroupsStatus.value == RequestStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.getYourGroupsStatus.value == RequestStatus.error) {
                return Center(child: Text("Failed to load groups"));
              } else if (controller.myGroups.isEmpty) {
                return Center(child: Text("No groups found"));
              }
              final groupsToShow = controller.myGroups.length > 2 ? controller.myGroups.sublist(0, 2) : controller.myGroups;

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
                        final group = controller.myGroups[index];
                        _log('Your group tapped: groupId=${group.id}, name=${group.name}, memberCount=${group.memberCount}');
                        groupChatcontroller.joinGroupChatRoom(group.id.toString()).then((value) {
                          _log(
                            'Navigation to group chat after join API: groupId=${group.id}, conversationId=${groupChatcontroller.groupConversationId.value}, status=${groupChatcontroller.joinGrouoChatRoomRequestStatus.value}',
                          );
                          Get.to(() => GrouoChatScreen(userName: group.name ?? "", groupDetails: group));
                        });
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

            110.verticalSpace,
          ],
        ),
      ),
      floatingActionButton: SafeArea(
        child: GestureDetector(
          onTap: () => Get.to(() => Group_Creation_Screen(), transition: Transition.fadeIn),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
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
          style: TextStyle(fontSize: responsiveFontSize(20, min: 18, max: 24), fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text("See All", style: TextStyle(color: Colors.grey, fontSize: responsiveFontSize(16, min: 14, max: 18))),
        ),
      ],
    );
  }
}
