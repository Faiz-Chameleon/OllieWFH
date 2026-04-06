// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Volunteers/one_to_one_chat_controller.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  const ChatScreen({super.key, required this.userName, required this.userImage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketController socketController = Get.find<SocketController>();
  final OneToOneChatController chatController = Get.find<OneToOneChatController>();
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
      chatController.joinRoom(chatController.oneOnOneConversationId.value.toString());
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
                  await chatController.sendAttachementInChat(data, file, chatController.oneOnOneConversationId.value.toString());
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
                  await chatController.sendAttachementInChat(data, file, chatController.oneOnOneConversationId.value.toString());
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
      chatController.sendMessageInRoom(chatController.oneOnOneConversationId.value.toString(), text);
      messageController.clear();
    }
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  bool _isCurrentUserMessage(Map message, String loggedInUserId) {
    return message["senderId"]?.toString() == loggedInUserId;
  }

  ImageProvider _buildAvatarImage(String? imageUrl) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      return NetworkImage(trimmedUrl);
    }
    return const AssetImage('assets/icons/Group 1000000907 (1).png');
  }

  String? _extractSenderImage(Map message, String loggedInUserId) {
    if (_isCurrentUserMessage(message, loggedInUserId)) {
      return userController.user.value?.image;
    }

    final sender = message["sender"];
    if (sender is Map) {
      for (final key in ["image", "avatar", "profileImage", "userImage"]) {
        final value = sender[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    for (final key in ["senderImage", "image", "avatar", "profileImage", "userImage"]) {
      final value = message[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return widget.userImage;
  }

  String _extractSenderName(Map message, String loggedInUserId) {
    if (_isCurrentUserMessage(message, loggedInUserId)) {
      final currentUser = userController.user.value;
      final fullName = [currentUser?.firstName?.trim(), currentUser?.lastName?.trim()].where((part) => (part ?? '').isNotEmpty).join(' ');

      if (fullName.isNotEmpty) {
        return fullName;
      }

      return 'You';
    }

    final sender = message["sender"];
    if (sender is Map) {
      final senderFullName = [
        sender["firstName"]?.toString().trim(),
        sender["lastName"]?.toString().trim(),
      ].where((part) => (part ?? '').isNotEmpty).join(' ');

      if (senderFullName.isNotEmpty) {
        return senderFullName;
      }

      final fallbackKeys = ["name", "userName", "username", "displayName", "fullName"];
      for (final key in fallbackKeys) {
        final value = sender[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    final directKeys = ["senderName", "userName", "username", "displayName", "fullName", "name"];
    for (final key in directKeys) {
      final value = message[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return widget.userName.trim().isNotEmpty ? widget.userName.trim() : 'Unknown User';
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
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: _buildAvatarImage(widget.userImage)),
            const SizedBox(width: 8),
            Text(
              widget.userName,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            // const Spacer(),
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
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return Center(child: Text("No messages yet."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];

                  final String loggedInUserId = userController.user.value?.id ?? '';
                  final bool isCurrentUser = _isCurrentUserMessage(message, loggedInUserId);
                  final String senderName = _extractSenderName(message, loggedInUserId);
                  final String? senderImage = _extractSenderImage(message, loggedInUserId);
                  return Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCurrentUser) ...[CircleAvatar(radius: 16, backgroundImage: _buildAvatarImage(senderImage)), const SizedBox(width: 8)],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                senderName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 260),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? const Color(0xFFF4BD2A) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: _MessageBody(message: message),
                              ),
                              Text(
                                chatController.getReadableDateTime(message["createdAt"]?.toString()),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentUser) ...[const SizedBox(width: 8), CircleAvatar(radius: 16, backgroundImage: _buildAvatarImage(senderImage))],
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

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message});

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
