// ignore_for_file: unused_element, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/groups/group_members_screen.dart';
import 'package:ollie/CareCircle/groups/one_to_many_chat_controller.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/request_status.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';

class GrouoChatScreen extends StatefulWidget {
  final String userName;
  final dynamic groupDetails;

  const GrouoChatScreen({
    super.key,
    required this.userName,
    required this.groupDetails,
  });

  @override
  State<GrouoChatScreen> createState() => _GrouoChatScreenState();
}

class _GrouoChatScreenState extends State<GrouoChatScreen> {
  final SocketController socketController = Get.find<SocketController>();
  final OneToManyChatController groupChatController =
      Get.find<OneToManyChatController>();
  final userController = Get.find<UserController>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();

  final RxBool isSelected = false.obs;
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText speech;
  Worker? _messagesWorker;
  Worker? _removedWorker;
  Worker? _blockedWorker;
  final canSendMessage = true.obs;
  bool isListening = false;

  void _log(String message) {
    debugPrint('[GroupChatScreen] $message');
  }

  void _removeGroupFromLocalList(String chatRoomId) {
    final rawChatRoomId = _rawChatRoomId(chatRoomId);
    try {
      final cc = Get.find<CareCircleController>();
      cc.myGroups.removeWhere((g) => g.id?.toString() == rawChatRoomId);
      cc.othersGroups.removeWhere((g) => g.id?.toString() == rawChatRoomId);
    } catch (_) {}
  }

  void _decrementMemberCount(String chatRoomId) {
    final rawChatRoomId = _rawChatRoomId(chatRoomId);
    try {
      final cc = Get.find<CareCircleController>();
      final idx = cc.myGroups.indexWhere(
        (g) => g.id?.toString() == rawChatRoomId,
      );
      if (idx != -1) {
        final group = cc.myGroups[idx];
        final current = group.memberCount ?? 1;
        if (current > 0) group.memberCount = current - 1;
        cc.myGroups.refresh();
      }
    } catch (_) {}
  }

  String _rawChatRoomId(String chatRoomId) {
    final trimmed = chatRoomId.trim();
    return trimmed.startsWith('chat:') ? trimmed.substring(5) : trimmed;
  }

  @override
  void initState() {
    super.initState();
    _messagesWorker = ever(groupChatController.messages, (_) {
      _scrollToLatestMessage();
    });

    final currentUserId = userController.user.value?.id ?? '';

    _removedWorker = ever(groupChatController.userRemovedEvent, (event) {
      if (event == null) return;
      groupChatController.userRemovedEvent.value = null;
      final chatRoomId = event['chatRoomId']?.toString() ?? '';
      final removedUserId = event['removedUserId']?.toString() ?? '';
      if (removedUserId == currentUserId) {
        if (!mounted) return;
        _removeGroupFromLocalList(chatRoomId);
        appSnackbar('Removed', 'You have been removed from this group');
        Get.until((route) => route.isFirst);
      } else {
        _decrementMemberCount(chatRoomId);
      }
    });

    _blockedWorker = ever(groupChatController.userBlockedEvent, (event) {
      if (event == null) return;
      groupChatController.userBlockedEvent.value = null;
      final chatRoomId = event['chatRoomId']?.toString() ?? '';
      final blockedUserId = event['blockedUserId']?.toString() ?? '';
      if (blockedUserId == currentUserId) {
        canSendMessage.value = false;
        appSnackbar('Blocked', 'You have been blocked in this group');
      } else {
        groupChatController.fetchBlockedUsers(chatRoomId);
      }
    });
    _log(
      'Opening group chat screen: groupName=${widget.userName}, groupId=${widget.groupDetails.id}, currentConversationId=${groupChatController.groupConversationId.value}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _log(
        'Post frame joinGroupRoom call with conversationId=${groupChatController.groupConversationId.value}',
      );
      final conversationId = groupChatController.groupConversationId.value
          .toString();
      await groupChatController.fetchGroupMessages(
        conversationId,
        showError: false,
      );
      await groupChatController.joinGroupRoom(conversationId);
      speech = stt.SpeechToText();
      _scrollToLatestMessage(jump: true);
    });
  }

  void _scrollToLatestMessage({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesScrollController.hasClients) {
        return;
      }

      final maxScrollExtent =
          _messagesScrollController.position.maxScrollExtent;
      if (jump) {
        _messagesScrollController.jumpTo(maxScrollExtent);
      } else {
        _messagesScrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Images and keyboard inset changes can update layout after the first frame.
    // Schedule a second pass so opening chat lands on the actual latest message.
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || !_messagesScrollController.hasClients) return;
      final maxScrollExtent =
          _messagesScrollController.position.maxScrollExtent;
      if (jump) {
        _messagesScrollController.jumpTo(maxScrollExtent);
      } else {
        _messagesScrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from Library'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final data = {"attachmentType": "image"};
                final files = await _picker.pickMultiImage();
                if (files.isEmpty) return;

                _log(
                  'Gallery images selected for upload: count=${files.length}',
                );
                final batchId =
                    'batch_${DateTime.now().microsecondsSinceEpoch}';
                for (var i = 0; i < files.length; i++) {
                  final file = files[i];
                  _log('Uploading selected gallery image: path=${file.path}');
                  await groupChatController.sendAttachementInChat(
                    data,
                    file,
                    groupChatController.groupConversationId.value.toString(),
                    localAttachmentBatchId: files.length > 1 ? batchId : null,
                    showSnackbar: i == files.length - 1,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Picture'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final data = {"attachmentType": "image"};
                final XFile? file = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (file != null) {
                  _log('Camera image selected for upload: path=${file.path}');
                  await groupChatController.sendAttachementInChat(
                    data,
                    file,
                    groupChatController.groupConversationId.value.toString(),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Upload Video'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final data = {"attachmentType": "video"};
                final XFile? file = await _picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  _log('Gallery video selected for upload: path=${file.path}');
                  await groupChatController.sendAttachementInChat(
                    data,
                    file,
                    groupChatController.groupConversationId.value.toString(),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final data = {"attachmentType": "video"};
                final XFile? file = await _picker.pickVideo(
                  source: ImageSource.camera,
                );
                if (file != null) {
                  _log('Camera video selected for upload: path=${file.path}');
                  await groupChatController.sendAttachementInChat(
                    data,
                    file,
                    groupChatController.groupConversationId.value.toString(),
                  );
                }
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
      _log(
        'Sending message from UI: conversationId=${groupChatController.groupConversationId.value}, textLength=${text.length}, text=$text',
      );
      groupChatController.sendMessageInGroupRoom(
        groupChatController.groupConversationId.value.toString(),
        text,
      );
      messageController.clear();
    }
  }

  Future<void> _refreshMessages() async {
    await groupChatController.refreshCurrentGroupRoom();
  }

  String _messageId(dynamic message) {
    if (message is! Map) return '';
    return message['id']?.toString() ?? '';
  }

  bool _canDeleteMessage(dynamic message, bool isCurrentUser) {
    if (isCurrentUser) return true;
    final currentUserId = userController.user.value?.id;
    final details = widget.groupDetails;
    final isCreator =
        details.creatorId?.toString() == currentUserId ||
        details.isCurrentUserCreator == true;
    final isAdmin =
        details.participants?.admins?.any(
          (admin) => admin.id == currentUserId,
        ) ==
        true;
    return isCreator || isAdmin;
  }

  Future<void> _showMessageActions(dynamic message, bool isCurrentUser) async {
    final messageId = _messageId(message);
    if (messageId.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['👍', '❤️', '😂', '😮', '😢', '👏'].map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        groupChatController.reactToMessage(messageId, emoji);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Replies'),
                onTap: () {
                  Get.back();
                  _showRepliesSheet(messageId);
                },
              ),
              if (_canDeleteMessage(message, isCurrentUser))
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete message',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Get.back();
                    groupChatController.deleteMessage(messageId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRepliesSheet(String messageId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _RepliesSheet(
        messageId: messageId,
        groupChatController: groupChatController,
        userController: userController,
      ),
    );
  }

  void _stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  bool _isCurrentUserMessage(Map message, String loggedInUserId) {
    return message["senderId"]?.toString() == loggedInUserId;
  }

  bool _isImageOnlyMessage(dynamic message) {
    if (message is! Map) return false;
    final content = message["content"]?.toString().trim() ?? '';
    return _isImageAttachment(message) && content.isEmpty;
  }

  bool _isImageAttachment(Map message) {
    final type = message["attachmentType"]?.toString().toLowerCase() ?? '';
    final attachmentUrl =
        message["attachmentUrl"]?.toString().trim().toLowerCase() ?? '';
    return attachmentUrl.isNotEmpty &&
        attachmentUrl != 'null' &&
        (type.contains('image') ||
            attachmentUrl.endsWith('.jpg') ||
            attachmentUrl.endsWith('.jpeg') ||
            attachmentUrl.endsWith('.png') ||
            attachmentUrl.endsWith('.webp') ||
            attachmentUrl.endsWith('.heic'));
  }

  bool _isVideoAttachment(Map message) {
    final type = message["attachmentType"]?.toString().toLowerCase() ?? '';
    final attachmentUrl =
        message["attachmentUrl"]?.toString().trim().toLowerCase() ?? '';
    return attachmentUrl.isNotEmpty &&
        attachmentUrl != 'null' &&
        (type.contains('video') ||
            attachmentUrl.endsWith('.mp4') ||
            attachmentUrl.endsWith('.mov') ||
            attachmentUrl.endsWith('.m4v') ||
            attachmentUrl.endsWith('.webm') ||
            attachmentUrl.endsWith('.avi'));
  }

  bool _canGroupImageMessages(
    Map<String, dynamic> first,
    Map<String, dynamic> candidate,
  ) {
    if (!_isImageOnlyMessage(candidate)) return false;
    final firstBatch = first['localAttachmentBatchId']?.toString() ?? '';
    final candidateBatch =
        candidate['localAttachmentBatchId']?.toString() ?? '';
    if (firstBatch.isNotEmpty && firstBatch == candidateBatch) return true;

    final firstSender = first['senderId']?.toString() ?? '';
    final candidateSender = candidate['senderId']?.toString() ?? '';
    if (firstSender.isEmpty || firstSender != candidateSender) return false;

    final firstTime = DateTime.tryParse(first['createdAt']?.toString() ?? '');
    final candidateTime = DateTime.tryParse(
      candidate['createdAt']?.toString() ?? '',
    );
    if (firstTime == null || candidateTime == null) return false;

    return candidateTime.difference(firstTime).inSeconds.abs() <= 45;
  }

  List<Map<String, dynamic>> _displayMessages(List<dynamic> rawMessages) {
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < rawMessages.length; i++) {
      final rawMessage = rawMessages[i];
      if (rawMessage is! Map) continue;
      final message = Map<String, dynamic>.from(rawMessage);
      if (!_isImageOnlyMessage(message)) {
        result.add(message);
        continue;
      }

      final groupedUrls = <String>[];
      final groupedMessages = <Map<String, dynamic>>[];
      var j = i;
      while (j < rawMessages.length) {
        final candidateRaw = rawMessages[j];
        if (candidateRaw is! Map) break;
        final candidate = Map<String, dynamic>.from(candidateRaw);
        if (!_canGroupImageMessages(message, candidate)) {
          break;
        }
        groupedMessages.add(candidate);
        groupedUrls.add(candidate['attachmentUrl'].toString());
        j++;
      }

      if (groupedUrls.length > 1) {
        result.add({
          ...message,
          'groupedAttachmentUrls': groupedUrls,
          'groupedMessages': groupedMessages,
          'isUploading': groupedMessages.any((m) => m['isUploading'] == true),
          'uploadFailed': groupedMessages.any((m) => m['uploadFailed'] == true),
        });
        i = j - 1;
      } else {
        result.add(message);
      }
    }
    return result;
  }

  ImageProvider _buildAvatarImage(String? imageUrl) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      return NetworkImage(trimmedUrl);
    }
    return const AssetImage('assets/icons/Frame 1686560557.png');
  }

  Map<String, dynamic>? _extractSenderMap(Map message) {
    final sender = message["sender"] ?? message["user"] ?? message["createdBy"];
    if (sender is Map) {
      return Map<String, dynamic>.from(sender);
    }
    return null;
  }

  String _extractSenderName(Map message, {required bool isCurrentUser}) {
    if (isCurrentUser) {
      final currentUser = userController.user.value;
      final fullName = [
        currentUser?.firstName?.trim(),
        currentUser?.lastName?.trim(),
      ].where((part) => (part ?? '').isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        return fullName;
      }
      return 'You';
    }

    final senderMap = _extractSenderMap(message);
    if (senderMap != null) {
      final senderFullName = [
        senderMap["firstName"]?.toString().trim(),
        senderMap["lastName"]?.toString().trim(),
      ].where((part) => (part ?? '').isNotEmpty).join(' ');
      if (senderFullName.isNotEmpty) {
        return senderFullName;
      }

      for (final key in [
        "name",
        "userName",
        "username",
        "displayName",
        "fullName",
      ]) {
        final value = senderMap[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    for (final key in [
      "senderName",
      "userName",
      "username",
      "displayName",
      "fullName",
      "name",
    ]) {
      final value = message[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return 'Unknown User';
  }

  String? _extractSenderImage(Map message, {required bool isCurrentUser}) {
    if (isCurrentUser) {
      return userController.user.value?.image;
    }

    final senderMap = _extractSenderMap(message);
    if (senderMap != null) {
      for (final key in ["image", "avatar", "profileImage", "userImage"]) {
        final value = senderMap[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    for (final key in [
      "senderImage",
      "image",
      "avatar",
      "profileImage",
      "userImage",
    ]) {
      final value = message[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _removedWorker?.dispose();
    _blockedWorker?.dispose();
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
                backgroundImage:
                    widget.groupDetails.image != null &&
                        widget.groupDetails.image!.isNotEmpty
                    ? NetworkImage(widget.groupDetails.image!)
                    : AssetImage('assets/icons/Group 1000000907 (1).png')
                          as ImageProvider,
              ),
              const SizedBox(width: 8),
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
                return RefreshIndicator(
                  onRefresh: _refreshMessages,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 360),
                      Center(child: Text("No messages yet.")),
                    ],
                  ),
                );
              }
              final displayMessages = _displayMessages(
                groupChatController.messages,
              );
              return RefreshIndicator(
                onRefresh: _refreshMessages,
                child: ListView.builder(
                  controller: _messagesScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final message = displayMessages[index];

                    final String loggedInUserId =
                        userController.user.value?.id ?? '';
                    final bool isCurrentUser = _isCurrentUserMessage(
                      message,
                      loggedInUserId,
                    );
                    final String senderName = _extractSenderName(
                      message,
                      isCurrentUser: isCurrentUser,
                    );
                    final String? senderImage = _extractSenderImage(
                      message,
                      isCurrentUser: isCurrentUser,
                    );
                    return GestureDetector(
                      onLongPress: () =>
                          _showMessageActions(message, isCurrentUser),
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCurrentUser) ...[
                                  Text(
                                    senderName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: _buildAvatarImage(
                                      senderImage,
                                    ),
                                  ),
                                ] else ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: _buildAvatarImage(
                                      senderImage,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    senderName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 260),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color(0xFFF4BD2A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _GroupMessageBody(message: message),
                            ),
                            Text(
                              groupChatController.getReadableDateTime(
                                message["createdAt"]?.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            _MessageMetaRow(message: message),
                            _InlineRepliesPreview(
                              message: message,
                              isCurrentUser: isCurrentUser,
                            ),
                          ],
                        ),
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
                ),
              );
            }),
          ),
          Obx(() {
            if (!canSendMessage.value) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'You have been blocked in this group',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: TextFormField(
                          controller: messageController,
                          minLines: 1,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF1E2D4A),
                            fontSize: 17,
                            height: 1.2,
                          ),
                          strutStyle: const StrutStyle(
                            fontSize: 17,
                            height: 1.2,
                            forceStrutHeight: true,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.send,
                          scrollPadding: EdgeInsets.zero,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter your message',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.45),
                              fontSize: 17,
                              height: 1.2,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            icon: GestureDetector(
                              onTap: () => _showMediaPicker(context),
                              child: const Icon(
                                Icons.attach_file,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            );
          }),
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
    if (message["deletedForEveryone"] == true) {
      return const Text(
        "This message was deleted",
        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
      );
    }

    final groupedUrls = message["groupedAttachmentUrls"] is List
        ? message["groupedAttachmentUrls"] as List
        : const [];
    if (groupedUrls.isNotEmpty) {
      final groupedMessages = message["groupedMessages"] is List
          ? message["groupedMessages"] as List
          : const [];
      return _GroupedAttachmentGrid(
        urls: groupedUrls.map((url) => url.toString()).toList(),
        messages: groupedMessages,
        isUploading: message["isUploading"] == true,
        uploadFailed: message["uploadFailed"] == true,
      );
    }

    final attachmentUrl = message["attachmentUrl"]?.toString();
    final hasAttachment =
        attachmentUrl != null &&
        attachmentUrl.isNotEmpty &&
        attachmentUrl.toLowerCase() != 'null';

    if (hasAttachment) {
      final isLocalFile = message["isLocalFile"] == true;
      final isUploading = message["isUploading"] == true;
      final uploadFailed = message["uploadFailed"] == true;
      final isVideo = message is Map && _isVideoMessage(message);

      if (isVideo) {
        return _VideoAttachmentPreview(
          url: attachmentUrl,
          isLocalFile: isLocalFile,
          isUploading: isUploading,
          uploadFailed: uploadFailed,
        );
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => _openImagePreview(
              context,
              urls: [attachmentUrl],
              isLocalFiles: [isLocalFile],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isLocalFile
                  ? Image.file(File(attachmentUrl), fit: BoxFit.cover)
                  : Image.network(attachmentUrl, fit: BoxFit.cover),
            ),
          ),
          if (isUploading)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          if (uploadFailed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Upload failed",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      );
    }

    return Text(
      message["content"].toString(),
      style: const TextStyle(
        color: Color(0xFF1E2D4A),
        fontSize: 16,
        height: 1.35,
      ),
    );
  }
}

bool _isVideoMessage(Map message) {
  final type = message["attachmentType"]?.toString().toLowerCase() ?? '';
  final attachmentUrl =
      message["attachmentUrl"]?.toString().trim().toLowerCase() ?? '';
  return type.contains('video') ||
      attachmentUrl.endsWith('.mp4') ||
      attachmentUrl.endsWith('.mov') ||
      attachmentUrl.endsWith('.m4v') ||
      attachmentUrl.endsWith('.webm') ||
      attachmentUrl.endsWith('.avi');
}

void _openImagePreview(
  BuildContext context, {
  required List<String> urls,
  required List<bool> isLocalFiles,
  int initialIndex = 0,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ImagePreviewScreen(
        urls: urls,
        isLocalFiles: isLocalFiles,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _VideoAttachmentPreview extends StatelessWidget {
  const _VideoAttachmentPreview({
    required this.url,
    required this.isLocalFile,
    required this.isUploading,
    required this.uploadFailed,
  });

  final String url;
  final bool isLocalFile;
  final bool isUploading;
  final bool uploadFailed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      _VideoPreviewScreen(url: url, isLocalFile: isLocalFile),
                ),
              );
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 236,
              height: 170,
              color: Colors.black,
              child: const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 58,
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Video',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          if (isUploading)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          if (uploadFailed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Upload failed",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoPreviewScreen extends StatefulWidget {
  const _VideoPreviewScreen({required this.url, required this.isLocalFile});

  final String url;
  final bool isLocalFile;

  @override
  State<_VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<_VideoPreviewScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = widget.isLocalFile
          ? VideoPlayerController.file(File(widget.url))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await controller.initialize();
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null || controller == null
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Unable to play video',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    _VideoControlsOverlay(controller: controller),
                  ],
                ),
              ),
      ),
    );
  }
}

class _VideoControlsOverlay extends StatefulWidget {
  const _VideoControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<_VideoControlsOverlay> {
  bool _isSeeking = false;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final hours = totalSeconds ~/ 3600;
    if (hours > 0) {
      final remainingMinutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
        2,
        '0',
      );
      return '$hours:$remainingMinutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _seekBy(Duration offset) async {
    final value = widget.controller.value;
    final duration = value.duration;
    final target = value.position + offset;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : target > duration
        ? duration
        : target;
    await widget.controller.seekTo(safeTarget);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final isPlaying = value.isPlaying;
    final duration = value.duration;
    final position = value.position > duration ? duration : value.position;
    final maxSeconds = duration.inMilliseconds.toDouble();
    final sliderValue =
        _dragValue ?? position.inMilliseconds.toDouble().clamp(0, maxSeconds);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: const Color(0xFFF4BD2A),
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      min: 0,
                      max: maxSeconds <= 0 ? 1 : maxSeconds,
                      value: sliderValue.toDouble(),
                      onChangeStart: (_) => setState(() => _isSeeking = true),
                      onChanged: (value) {
                        setState(() => _dragValue = value);
                      },
                      onChangeEnd: (value) async {
                        await widget.controller.seekTo(
                          Duration(milliseconds: value.round()),
                        );
                        if (mounted) {
                          setState(() {
                            _isSeeking = false;
                            _dragValue = null;
                          });
                        }
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDuration(
                          Duration(
                            milliseconds:
                                (_isSeeking
                                        ? sliderValue
                                        : position.inMilliseconds)
                                    .round(),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _seekBy(const Duration(seconds: -10)),
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            widget.controller.pause();
                          } else {
                            widget.controller.play();
                          }
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _seekBy(const Duration(seconds: 10)),
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

class _GroupedAttachmentGrid extends StatelessWidget {
  const _GroupedAttachmentGrid({
    required this.urls,
    required this.messages,
    required this.isUploading,
    required this.uploadFailed,
  });

  final List<String> urls;
  final List<dynamic> messages;
  final bool isUploading;
  final bool uploadFailed;

  @override
  Widget build(BuildContext context) {
    final visibleUrls = urls.take(4).toList();
    final extraCount = urls.length - visibleUrls.length;
    final isLocalFiles = urls.asMap().entries.map((entry) {
      final message = entry.key < messages.length ? messages[entry.key] : null;
      return message is Map && message["isLocalFile"] == true;
    }).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 236,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: visibleUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final url = visibleUrls[index];
              final message = index < messages.length ? messages[index] : null;
              final isLocalFile =
                  message is Map && message["isLocalFile"] == true;

              return GestureDetector(
                onTap: () => _openImagePreview(
                  context,
                  urls: urls,
                  isLocalFiles: isLocalFiles,
                  initialIndex: index,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      isLocalFile
                          ? Image.file(File(url), fit: BoxFit.cover)
                          : Image.network(url, fit: BoxFit.cover),
                      if (index == visibleUrls.length - 1 && extraCount > 0)
                        Container(
                          color: Colors.black45,
                          alignment: Alignment.center,
                          child: Text(
                            '+$extraCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (isUploading)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        if (uploadFailed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Upload failed",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _ImagePreviewScreen extends StatefulWidget {
  const _ImagePreviewScreen({
    required this.urls,
    required this.isLocalFiles,
    required this.initialIndex,
  });

  final List<String> urls;
  final List<bool> isLocalFiles;
  final int initialIndex;

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.urls.length > 1
            ? Text('${_currentIndex + 1}/${widget.urls.length}')
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.urls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final url = widget.urls[index];
          final isLocalFile =
              index < widget.isLocalFiles.length && widget.isLocalFiles[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: isLocalFile
                  ? Image.file(File(url), fit: BoxFit.contain)
                  : Image.network(url, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}

class _MessageMetaRow extends StatelessWidget {
  const _MessageMetaRow({required this.message});

  final dynamic message;

  @override
  Widget build(BuildContext context) {
    if (message is! Map) return const SizedBox.shrink();

    final reactions = message['reactions'] is List
        ? message['reactions'] as List
        : const [];
    final replyCount =
        int.tryParse(
          (message['replyCount'] ?? message['replies']?.length ?? '')
              .toString(),
        ) ??
        0;
    final isSending = message['isSending'] == true;

    if (reactions.isEmpty && replyCount == 0 && !isSending) {
      return const SizedBox.shrink();
    }

    final reactionText = reactions
        .map((item) {
          if (item is Map) return item['emoji']?.toString();
          return item?.toString();
        })
        .whereType<String>()
        .where((emoji) => emoji.isNotEmpty)
        .map(_displayReactionEmoji)
        .take(1)
        .join(' ');

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Text(
        [
          if (reactionText.isNotEmpty) reactionText,
          if (replyCount > 0) '$replyCount replies',
          if (isSending) 'Sending...',
        ].join('  '),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  String _displayReactionEmoji(String emoji) {
    switch (emoji) {
      case ':+1:':
        return '👍';
      case ':heart:':
        return '❤️';
      case ':joy:':
        return '😂';
      case ':open_mouth:':
        return '😮';
      case ':cry:':
        return '😢';
      case ':clap:':
        return '👏';
      default:
        return emoji;
    }
  }
}

class _InlineRepliesPreview extends StatelessWidget {
  const _InlineRepliesPreview({
    required this.message,
    required this.isCurrentUser,
  });

  final dynamic message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    if (message is! Map || message['replies'] is! List) {
      return const SizedBox.shrink();
    }

    final replies = (message['replies'] as List).whereType<Map>().toList();
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleReplies = replies.length > 2
        ? replies.sublist(replies.length - 2)
        : replies;

    return Container(
      width: 230,
      margin: EdgeInsets.only(
        top: 4,
        bottom: 8,
        left: isCurrentUser ? 0 : 28,
        right: isCurrentUser ? 28 : 0,
      ),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isCurrentUser
                ? const Color(0xFFB9870F)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final reply in visibleReplies)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                reply['content']?.toString() ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (replies.length > visibleReplies.length)
            Text(
              '${replies.length - visibleReplies.length} more replies',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class _RepliesSheet extends StatefulWidget {
  final String messageId;
  final OneToManyChatController groupChatController;
  final UserController userController;

  const _RepliesSheet({
    required this.messageId,
    required this.groupChatController,
    required this.userController,
  });

  @override
  State<_RepliesSheet> createState() => _RepliesSheetState();
}

class _RepliesSheetState extends State<_RepliesSheet> {
  final TextEditingController _replyInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.groupChatController.fetchMessageReplies(widget.messageId);
  }

  @override
  void dispose() {
    _replyInput.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyInput.text.trim();
    if (text.isEmpty) return;
    _replyInput.clear();
    await widget.groupChatController.replyToMessage(widget.messageId, text);
  }

  String _formatTime(String? dateStr) {
    final parsed = DateTime.tryParse(dateStr ?? '');
    if (parsed == null) return '';
    return DateFormat('hh:mm a').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Replies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                final msgIndex = widget.groupChatController.messages.indexWhere(
                  (item) =>
                      item is Map && item['id']?.toString() == widget.messageId,
                );

                final isLoading =
                    widget.groupChatController.messageActionStatus.value ==
                    RequestStatus.loading;

                if (msgIndex == -1) {
                  return Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('No replies yet'),
                  );
                }

                final message = widget.groupChatController.messages[msgIndex];
                final replies = message is Map && message['replies'] is List
                    ? message['replies'] as List
                    : const [];

                if (replies.isEmpty) {
                  return Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('No replies yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    if (reply is! Map) return const SizedBox.shrink();

                    final senderId = reply['senderId']?.toString() ?? '';
                    final currentUserId =
                        widget.userController.user.value?.id ?? '';
                    final isCurrentUser = senderId == currentUserId;

                    String senderName;
                    if (isCurrentUser) {
                      final u = widget.userController.user.value;
                      senderName = [
                        u?.firstName?.trim(),
                        u?.lastName?.trim(),
                      ].where((p) => p?.isNotEmpty == true).join(' ');
                      if (senderName.isEmpty) senderName = 'You';
                    } else {
                      final sender = reply['sender'];
                      if (sender is Map) {
                        senderName = [
                          sender['firstName']?.toString().trim(),
                          sender['lastName']?.toString().trim(),
                        ].where((p) => p?.isNotEmpty == true).join(' ');
                      } else {
                        senderName = 'Unknown';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFFF4BD2A),
                            child: Text(
                              senderName.isNotEmpty
                                  ? senderName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      senderName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(
                                        reply['createdAt']?.toString(),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? const Color(0xFFF4BD2A)
                                        : const Color(0xFFF0E8D8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    reply['content']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyInput,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendReply(),
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        filled: true,
                        fillColor: const Color(0xFFF0E8D8),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final isLoading =
                        widget.groupChatController.messageActionStatus.value ==
                        RequestStatus.loading;
                    return CircleAvatar(
                      backgroundColor: Colors.black,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendReply,
                            ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
