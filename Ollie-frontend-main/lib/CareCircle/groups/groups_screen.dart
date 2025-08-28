// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/create_new_group.dart';
import 'package:ollie/CareCircle/groups/Create_group_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/request_status.dart';

class Group_Screen extends StatelessWidget {
  Group_Screen({super.key, required this.controller});

  final CareCircleController controller;

  final OneToManyChatController groupChatcontroller = Get.put(OneToManyChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader("Featured", () {
                  Get.to(
                    () => GroupListScreen(
                      title: "Featured",
                      // groups: [
                      //   {'title': 'Tea & Tales', 'image': 'assets/images/Frame 1686560577.png', 'joined': true},
                      //   {'title': 'Memory Lane', 'image': 'assets/images/Frame 73 (2).png', 'joined': false},
                      // ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  if (controller.getOthersGroupsStatus.value == RequestStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (controller.getOthersGroupsStatus.value == RequestStatus.error) {
                    return Center(child: Text("Failed to load groups"));
                  } else if (controller.othersGroups.isEmpty) {
                    return Center(child: Text("No Others groups found"));
                  }
                  final groupsToShow = controller.othersGroups.length > 1 ? controller.othersGroups.sublist(0, 2) : controller.myGroups;

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
                            groupChatcontroller.joinGroupChatRoom(othersGroup.id.toString()).then((value) {
                              Get.to(() => GrouoChatScreen(userName: othersGroup.name ?? ""));
                            });
                            // ;
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
                  final createController = Get.isRegistered<CreateGroupController>()
                      ? Get.find<CreateGroupController>()
                      : Get.put(CreateGroupController());

                  Get.to(
                    () => GroupListScreen(
                      title: "Your Groups",
                      // groups: [
                      //   {
                      //     'title': createController.groupName.value,
                      //     'image': createController.selectedImage.value?.path ?? 'assets/images/Frame 1686560577.png',
                      //     'joined': true,
                      //   },
                      // ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
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
                        final group = controller.myGroups[index];

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _groupCard(
                            group.name ?? "",
                            "${group.memberCount.toString()}+",
                            "View",
                            group.image ?? "",
                            group.participants?.users ?? [],
                            joined: true,
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
                //       _groupCard("Life Stories & Lessons", "4k+", "View", "assets/images/Frame 1686560576.png", joined: true),
                //       const SizedBox(width: 12),
                //       _groupCard("Tea & Tales", "4k+", "View", "assets/images/Frame 1686560577.png", joined: true),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text("ADVERTISEMENT", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                ),

                110.verticalSpace,
              ],
            ),
          ),

          Positioned(
            bottom: 100,
            right: 20,
            child: GestureDetector(
              onTap: () => Get.to(() => Group_Creation_Screen(), transition: Transition.fadeIn),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.add, color: white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAllTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onSeeAllTap,
          child: const Text("See All", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _groupCard(String title, String members, String action, String imagePath, List<Users> membersImages, {required bool joined}) {
    List<String> memberImages = members.isNotEmpty ? membersImages.take(2).map((p) => p.image ?? "").toList() : [];
    return Container(
      width: 195.w,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imagePath,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.grey[700]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 170.w,
            height: 50,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 60,
                  child: Stack(
                    children: [
                      if (memberImages.isNotEmpty)
                        Positioned(left: 0, child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(memberImages[0]))),
                      if (memberImages.length > 1)
                        Positioned(left: 12, child: CircleAvatar(radius: 10, backgroundImage: NetworkImage(memberImages[1]))),
                      if (memberImages.isEmpty)
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey[400],
                            child: Icon(Icons.person, size: 12, color: Colors.white),
                          ),
                        ),
                      // Positioned(left: 0, child: CircleAvatar(radius: 10, backgroundColor: const Color(0xFFD6CCBC))),
                      // Positioned(left: 12, child: CircleAvatar(radius: 10, backgroundColor: const Color(0xFFD6CCBC))),
                      Positioned(
                        left: 24,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: const Color(0xFF3C3129),
                          child: Text(members, style: TextStyle(fontSize: 10, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: joined ? const Color(0xFFF4BD2A) : Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupListScreen extends StatelessWidget {
  final String title;

  const GroupListScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E8),
        elevation: 0,
        centerTitle: false,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            final bottomController = Get.find<Bottomcontroller>();
            bottomController.updateIndex(1);
            Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,

          // children: groups.map((group) {
          //   final isFile = group['image'].toString().startsWith("/data") || group['image'].toString().startsWith("/var");
          //   return Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: Colors.black12),
          //     ),
          //     padding: const EdgeInsets.all(12),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(8),
          //           child: isFile
          //               ? Image.file(File(group['image']), height: 80, width: double.infinity, fit: BoxFit.cover)
          //               : Image.asset(group['image'], height: 80, width: double.infinity, fit: BoxFit.cover),
          //         ),
          //         const SizedBox(height: 8),
          //         Text(group['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
          //         const SizedBox(height: 10),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Row(
          //               children: const [
          //                 CircleAvatar(radius: 8, backgroundColor: Color(0xFFD6CCBC)),
          //                 SizedBox(width: 4),
          //                 CircleAvatar(radius: 8, backgroundColor: Color(0xFFD6CCBC)),
          //                 SizedBox(width: 4),
          //                 CircleAvatar(
          //                   radius: 8,
          //                   backgroundColor: Color(0xFF3C3129),
          //                   child: Text("4k+", style: TextStyle(fontSize: 8, color: Colors.white)),
          //                 ),
          //               ],
          //             ),
          //             Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //               decoration: BoxDecoration(
          //                 color: group['joined'] ? const Color(0xFFF4BD2A) : Colors.orange.shade200,
          //                 borderRadius: BorderRadius.circular(30),
          //               ),
          //               child: Text(group['joined'] ? "View" : "Join", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   );
          // }).toList(),
        ),
      ),
    );
  }
}
