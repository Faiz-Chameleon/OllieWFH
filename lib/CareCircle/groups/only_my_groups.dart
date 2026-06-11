// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/group_card_widget.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/Models/my_groups_model.dart';

class OnlyYourGroups extends StatefulWidget {
  final CareCircleController controller;
  final String title;
  const OnlyYourGroups({super.key, required this.title, required this.controller});

  @override
  State<OnlyYourGroups> createState() => _OnlyYourGroupsState();
}

class _OnlyYourGroupsState extends State<OnlyYourGroups> {
  final OneToManyChatController groupChatcontroller = Get.put(OneToManyChatController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E8),
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.title,
          style: GoogleFonts.darkerGrotesque(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.96,

          children: List.generate(widget.controller.myGroups.length, (index) {
            final group = widget.controller.myGroups[index];

            return GestureDetector(
              onTap: () {
                final group = widget.controller.myGroups[index];
                groupChatcontroller.joinGroupChatRoom(group.id.toString()).then((value) {
                  Get.to(() => GrouoChatScreen(userName: group.name ?? "", groupDetails: group));
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: GroupCardWidget(
                  title: group.name ?? "",
                  members: "${group.memberCount.toString()}+",
                  action: "View",
                  imagePath: group.image ?? "",
                  membersImages: group.participants?.users ?? [],
                  joined: true,
                  width: double.infinity,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
