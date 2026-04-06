// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/create_new_group.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/CareCircle/groups/only_my_groups.dart';
import 'package:ollie/CareCircle/groups/see_all_groups.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/request_status.dart';

class Group_Screen extends StatelessWidget {
  Group_Screen({super.key, required this.controller});

  final CareCircleController controller;

  final OneToManyChatController groupChatcontroller = Get.put(
    OneToManyChatController(),
  );

  void _log(String message) {
    debugPrint('[GroupScreen] $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            const SizedBox(height: 10),
            Obx(() {
              if (controller.getOthersGroupsStatus.value ==
                  RequestStatus.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.getOthersGroupsStatus.value ==
                  RequestStatus.error) {
                return Center(child: Text("Failed to load groups"));
              } else if (controller.othersGroups.isEmpty) {
                return Center(child: Text("No Others groups found"));
              }
              final groupsToShow = controller.othersGroups.isNotEmpty
                  ? controller.othersGroups.take(2).toList()
                  : controller.myGroups;

              return SizedBox(
                height: 230.h,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,

                  itemCount: groupsToShow.length,

                  itemBuilder: (context, index) {
                    final othersGroup = controller.othersGroups[index];

                    return GestureDetector(
                      onTap: () {
                        final othersGroup = controller.othersGroups[index];
                        _log(
                          'Featured group tapped: groupId=${othersGroup.id}, name=${othersGroup.name}, memberCount=${othersGroup.memberCount}',
                        );
                        groupChatcontroller
                            .joinGroupChatRoom(othersGroup.id.toString())
                            .then((value) {
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
                        padding: const EdgeInsets.all(5.0),
                        child: _groupCard(
                          othersGroup.name ?? "",
                          "${othersGroup.memberCount.toString()}+",
                          "Join",
                          othersGroup.image ?? "",
                          othersGroup.participants?.users ?? [],
                          joined: true,
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
            const SizedBox(height: 20),

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
            const SizedBox(height: 10),
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
                    final group = controller.myGroups[index];

                    return GestureDetector(
                      onTap: () {
                        final group = controller.myGroups[index];
                        _log(
                          'Your group tapped: groupId=${group.id}, name=${group.name}, memberCount=${group.memberCount}',
                        );
                        groupChatcontroller
                            .joinGroupChatRoom(group.id.toString())
                            .then((value) {
                              _log(
                                'Navigation to group chat after join API: groupId=${group.id}, conversationId=${groupChatcontroller.groupConversationId.value}, status=${groupChatcontroller.joinGrouoChatRoomRequestStatus.value}',
                              );
                              Get.to(
                                () => GrouoChatScreen(
                                  userName: group.name ?? "",
                                  groupDetails: group,
                                ),
                              );
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _groupCard(
                          group.name ?? "",
                          "${group.memberCount.toString()}+",
                          "View",
                          group.image ?? "",
                          group.participants?.users ?? [],
                          joined: true,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 20),

            110.verticalSpace,
          ],
        ),
      ),
      floatingActionButton: SafeArea(
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: const Text("See All", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _groupCard(
    String title,
    String members,
    String action,
    String imagePath,
    List<Users> membersImages, {
    required bool joined,
  }) {
    List<String> memberImages = members.isNotEmpty
        ? membersImages.take(2).map((p) => p.image ?? "").toList()
        : [];
    final validMemberImages = memberImages.where((image) => image.trim().isNotEmpty).toList();
    return Container(
      width: 210.w,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8D8BB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 104.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: const LinearGradient(
                colors: [Color(0xFFF6D58C), Color(0xFFECA95F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF4E4C3),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.groups_rounded,
                          size: 42,
                          color: Colors.brown.shade400,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      colors: [Color(0x12000000), Color(0x9A000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xE6FFF4D7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          action,
                          style: TextStyle(
                            color: const Color(0xFF4B3510),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  joined ? 'Already active in this circle' : 'Discover and connect with this circle',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF6E6256),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E8C9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 22,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (validMemberImages.isNotEmpty)
                              Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(validMemberImages[0]),
                                  ),
                              )
                            else
                              const Positioned(
                                left: 0,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Color(0xFFD8C6A6),
                                    child: Icon(Icons.person, size: 14, color: Colors.white),
                                  ),
                              ),
                            if (validMemberImages.length > 1)
                              Positioned(
                                  left: 16,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(validMemberImages[1]),
                                  ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$members members',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF2F241B),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: joined ? const Color(0xFF7BB662) : const Color(0xFFE59A48),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
