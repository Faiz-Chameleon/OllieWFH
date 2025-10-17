import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/group_chat_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
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
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,

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
                child: _groupCard(
                  group.name ?? "",
                  "${group.memberCount.toString()}+",
                  "View",
                  group.image ?? "",
                  group.participants?.users ?? [],
                  joined: true,
                  // index: index, // Pass index if needed
                ),
              ),
            );
          }),
        ),
      ),
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
