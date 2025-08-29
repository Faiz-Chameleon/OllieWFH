// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/groups/group_members_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GrouoChatScreen extends StatefulWidget {
  final String userName;
  final dynamic groupDetails;

  const GrouoChatScreen({super.key, required this.userName, required this.groupDetails});

  @override
  State<GrouoChatScreen> createState() => _GrouoChatScreenState();
}

class _GrouoChatScreenState extends State<GrouoChatScreen> {
  final SocketController socketController = Get.find<SocketController>();
  final OneToManyChatController groupChatController = Get.find<OneToManyChatController>();
  final userController = Get.find<UserController>();

  final TextEditingController messageController = TextEditingController();

  final RxBool isSelected = false.obs;
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupChatController.joinRoom(groupChatController.groupConversationId.value.toString());
      speech = stt.SpeechToText();
    });
  }

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from Library'),
              onTap: () async {
                var data = {"attachmentType": "image"};
                final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  groupChatController.sendAttachementInChat(data, file, groupChatController.groupConversationId.value.toString());
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Picture'),
              onTap: () async {
                final XFile? file = await _picker.pickImage(source: ImageSource.camera);
                if (file != null) groupChatController.messages.add({"from": "me", "image": File(file.path), "time": "10:26 AM"});
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) {
          messageController.text = result.recognizedWords;
        },
      );
    }
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      groupChatController.sendMessageInRoom(groupChatController.groupConversationId.value.toString(), text);
      messageController.clear();
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF2D9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: GestureDetector(
          onTap: () {
            Get.to(() => GroupInfoScreen(groupDetails: widget.groupDetails));
          },
          child: Row(
            children: [
              const CircleAvatar(radius: 16, backgroundImage: AssetImage("assets/icons/Group 1000000907 (1).png")),
              const SizedBox(width: 8),
              Text(
                widget.userName,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // Obx(() {
              //   final selected = isSelected.value;
              //   return GestureDetector(
              //     onTap: () => isSelected.toggle(),
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              //       decoration: BoxDecoration(
              //         color: selected ? const Color(0xFFF4BD2A) : Colors.transparent,
              //         border: Border.all(color: const Color(0xFFF4BD2A)),
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       child: Text(
              //         selected ? "Selected" : "Select",
              //         style: TextStyle(fontWeight: FontWeight.w500, color: selected ? Colors.black : const Color(0xFF9C7D4A), fontSize: 18.sp),
              //       ),
              //     ),
              //   );
              // }),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (groupChatController.messages.isEmpty) {
                return Center(child: Text("No messages yet."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupChatController.messages.length,
                itemBuilder: (context, index) {
                  final message = groupChatController.messages[index];

                  final String loggedInUserId = userController.user.value?.id ?? '';
                  return Align(
                    alignment: message["senderId"] == loggedInUserId ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: message["senderId"] == loggedInUserId ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (message["senderId"] != loggedInUserId)
                          const CircleAvatar(radius: 16, backgroundImage: AssetImage("assets/icons/Frame 1686560584.png")),
                        const SizedBox(height: 4),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 260),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message["senderId"] == loggedInUserId ? const Color(0xFFF4BD2A) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: message["attachmentUrl"] == null
                              ? Text(message["content"].toString(), style: const TextStyle(fontSize: 15))
                              : Image.network(message["attachmentUrl"], fit: BoxFit.cover),
                        ),
                        Text(
                          groupChatController.getReadableDateTime(message["createdAt"].toString()),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                  // Align(
                  //   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  //   child: Column(
                  //     crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  //     children: [
                  //       if (!isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage("assets/icons/Frame 1686560584.png")),
                  //       const SizedBox(height: 4),
                  //       Container(
                  //         constraints: const BoxConstraints(maxWidth: 260),
                  //         margin: const EdgeInsets.symmetric(vertical: 4),
                  //         padding: const EdgeInsets.all(12),
                  //         decoration: BoxDecoration(color: isMe ? const Color(0xFFF4BD2A) : Colors.white, borderRadius: BorderRadius.circular(16)),
                  //         child: msg.containsKey("image")
                  //             ? Image.file(msg["image"], fit: BoxFit.cover)
                  //             : Text(msg["text"], style: const TextStyle(fontSize: 15)),
                  //       ),
                  //       Text(msg["time"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  //     ],
                  //   ),
                  // );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(40)),
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your message",
                        icon: GestureDetector(
                          onTap: () => _showMediaPicker(context),
                          child: const Icon(Icons.attach_file, color: Colors.black45),
                        ),
                      ),
                      onFieldSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Row(
                  children: [
                    // CircleAvatar(
                    //   backgroundColor: Colors.black,
                    //   child: IconButton(
                    //     icon: Icon(isListening ? Icons.stop : Icons.mic, color: Colors.white),
                    //     onPressed: () {
                    //       isListening ? _stopListening() : _startListening();
                    //     },
                    //   ),
                    // ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          50.verticalSpace,
        ],
      ),
    );
  }
}
