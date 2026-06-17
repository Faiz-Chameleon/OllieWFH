import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/group_card_widget.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/request_status.dart';

class GroupListScreen extends StatefulWidget {
  final CareCircleController controller;
  final String title;

  const GroupListScreen({
    super.key,
    required this.title,
    required this.controller,
  });

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final OneToManyChatController groupChatcontroller = Get.put(
    OneToManyChatController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E8),
        elevation: 0,
        centerTitle: false,
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (widget.controller.getOthersGroupsStatus.value ==
              RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.controller.getOthersGroupsStatus.value ==
              RequestStatus.error) {
            return Center(
              child: Text(
                widget.controller.groupLocationErrorMessage.value.isEmpty
                    ? "Unable to load nearby groups"
                    : widget.controller.groupLocationErrorMessage.value,
              ),
            );
          }
          if (widget.controller.othersGroups.isEmpty) {
            return const Center(child: Text("No nearby groups found"));
          }

          return GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.96,
            children: List.generate(widget.controller.othersGroups.length, (
              index,
            ) {
              final group = widget.controller.othersGroups[index];

              return GestureDetector(
                onTap: () {
                  groupChatcontroller
                      .joinGroupChatRoom(group.id.toString())
                      .then((joined) {
                        if (!joined) return;
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
                  child: GroupCardWidget(
                    title: group.name ?? "",
                    members: "${group.memberCount.toString()}+",
                    action: group.groupPrivacy?.toUpperCase() == "PRIVATE"
                        ? "Request"
                        : "Join",
                    imagePath: group.image ?? "",
                    membersImages: group.participants?.users ?? [],
                    joined: false,
                    distanceKm: group.distanceKm,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
