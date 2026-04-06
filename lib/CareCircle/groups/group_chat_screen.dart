// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/groups/group_members_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
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
  final ScrollController _messagesScrollController = ScrollController();

  final RxBool isSelected = false.obs;
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText speech;
  Worker? _messagesWorker;
  bool isListening = false;

  void _log(String message) {
    debugPrint('[GroupChatScreen] $message');
  }

  @override
  void initState() {
    super.initState();
    _messagesWorker = ever(groupChatController.messages, (_) {
      _scrollToLatestMessage();
    });
    _log(
      'Opening group chat screen: groupName=${widget.userName}, groupId=${widget.groupDetails.id}, currentConversationId=${groupChatController.groupConversationId.value}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('Post frame joinGroupRoom call with conversationId=${groupChatController.groupConversationId.value}');
      groupChatController.joinGroupRoom(groupChatController.groupConversationId.value.toString());
      speech = stt.SpeechToText();
    });
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesScrollController.hasClients) {
        return;
      }

      final maxScrollExtent = _messagesScrollController.position.maxScrollExtent;
      _messagesScrollController.animateTo(maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
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
                  _log('Gallery image selected for upload: path=${file.path}');
                  await groupChatController.sendAttachementInChat(data, file, groupChatController.groupConversationId.value.toString());
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Picture'),
              onTap: () async {
                var data = {"attachmentType": "image"};
                final XFile? file = await _picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  _log('Camera image selected for upload: path=${file.path}');
                  await groupChatController.sendAttachementInChat(data, file, groupChatController.groupConversationId.value.toString());
                }
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
      _log('Sending message from UI: conversationId=${groupChatController.groupConversationId.value}, textLength=${text.length}, text=$text');
      groupChatController.sendMessageInGroupRoom(groupChatController.groupConversationId.value.toString(), text);
      messageController.clear();
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _messagesScrollController.dispose();
    messageController.dispose();
    super.dispose();
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
            Get.to(
              () => GroupInfoScreen(
                groupDetails: widget.groupDetails,
                chatRoomId: groupChatController.groupConversationId.value,
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: widget.groupDetails.image != null && widget.groupDetails.image!.isNotEmpty
                    ? NetworkImage(widget.groupDetails.image!)
                    : AssetImage('assets/icons/Group 1000000907 (1).png') as ImageProvider,
              ),
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
                controller: _messagesScrollController,
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
                          child: _GroupMessageBody(message: message),
                        ),
                        Text(
                          groupChatController.getReadableDateTime(message["createdAt"]?.toString()),
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

class _GroupMessageBody extends StatelessWidget {
  const _GroupMessageBody({required this.message});

  final dynamic message;

  @override
  Widget build(BuildContext context) {
    final attachmentUrl = message["attachmentUrl"]?.toString();
    final hasAttachment = attachmentUrl != null && attachmentUrl.isNotEmpty && attachmentUrl.toLowerCase() != 'null';

    if (hasAttachment) {
      final isLocalFile = message["isLocalFile"] == true;
      final isUploading = message["isUploading"] == true;
      final uploadFailed = message["uploadFailed"] == true;

      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isLocalFile ? Image.file(File(attachmentUrl), fit: BoxFit.cover) : Image.network(attachmentUrl, fit: BoxFit.cover),
          ),
          if (isUploading)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
          if (uploadFailed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text("Upload failed", style: TextStyle(color: Colors.white)),
            ),
        ],
      );
    }

    return Text(message["content"].toString(), style: const TextStyle(fontSize: 15));
  }
}
