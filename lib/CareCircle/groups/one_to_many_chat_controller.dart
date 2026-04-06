import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Volunteers/chat_repository.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/request_status.dart';

class OneToManyChatController extends GetxController {
  final SocketController socketController = Get.find<SocketController>();

  RxString groupConversationId = "".obs;

  final ChatRepository groupChatRepository = ChatRepository();

  bool _listenersRegistered = false;

  var messages = [].obs;
  var removeParticipantRequestStatus = RequestStatus.idle.obs;

  void _log(String message) {
    debugPrint('[GroupChatController] $message');
  }

  @override
  void onClose() {
    // Clean up listeners when controller is disposed
    _removeListeners();
    // Leave the room if we're in one
    if (groupConversationId.value.isNotEmpty) {
      socketController.socket.emit('leaveRoom', {
        'chatRoom': groupConversationId.value,
      });
    }
    super.onClose();
  }

  void _removeListeners() {
    if (_listenersRegistered) {
      socketController.socket.off('getRoom');
      socketController.socket.off('message');
      _listenersRegistered = false;
      _log('Socket listeners removed');
    }
  }

  void _setupListenersOnGroup() {
    if (!_listenersRegistered) {
      // Set up getRoom listener
      socketController.socket.on('getRoom', (data) {
        messages.clear();
        _log('Socket event getRoom received: $data');
        if (data != null &&
            data['data'] != null &&
            data['data']['messages'] != null) {
          List messagesData = data['data']['messages'] ?? [];
          if (messagesData.isNotEmpty) {
            messages.addAll(messagesData);
            _log('Messages updated from getRoom: count=${messagesData.length}');
          } else {
            _log('No messages found in getRoom payload');
          }
        } else {
          _log('getRoom payload missing expected data/messages fields');
        }
      });

      // Set up message listener
      socketController.socket.on('message', (data) {
        try {
          _log('Socket event message received: $data');
          if (data is Map) {
            final messageContent = data['data'];
            messages.add(messageContent);
          } else {
            _log('Received invalid message payload: $data');
          }
        } catch (e, stackTrace) {
          _log('Error receiving socket message: $e');
          _log('Socket message stack trace: $stackTrace');
        }
      });

      _listenersRegistered = true;
      _log('Socket listeners registered');
    }
  }

  void joinGroupRoom(String conversationID) {
    if (conversationID.isNotEmpty) {
      // Leave current room if we're in one
      if (groupConversationId.value.isNotEmpty &&
          groupConversationId.value != conversationID) {
        socketController.socket.emit('leaveRoom', {
          'chatRoom': groupConversationId.value,
        });
      }

      // Update conversation ID
      groupConversationId.value = conversationID;

      // Remove existing listeners before setting up new ones
      _removeListeners();

      // Set up listeners
      _setupListenersOnGroup();

      // Join the room
      _log('Emitting joinRoom for chatRoom=$conversationID');
      socketController.socket.emit('joinRoom', {'chatRoom': conversationID});
      _log('Joined chat room with ID: $conversationID');
    } else {
      Get.snackbar("Error", "No conversation ID found");
    }
  }

  void sendMessageInGroupRoom(String conversationID, text) {
    if (conversationID.isNotEmpty) {
      _log(
        'Emitting sendMessage for chatRoom=$conversationID, textLength=${text.toString().length}, text=$text',
      );
      socketController.socket.emit('sendMessage', {
        'chatroom': conversationID,
        "message": text,
      });
    } else {
      Get.snackbar("Error", "No conversation ID found");
    }
  }

  void _addOrReplacePendingMessage(Map<String, dynamic> message) {
    final localId = message['localId'];
    if (localId == null) {
      messages.add(message);
      return;
    }

    final existingIndex = messages.indexWhere(
      (item) => item is Map && item['localId'] == localId,
    );
    if (existingIndex == -1) {
      messages.add(message);
    } else {
      messages[existingIndex] = message;
    }
    messages.refresh();
  }

  String getReadableDateTime(String? dateTimeStr) {
    final normalizedDate = dateTimeStr?.trim();
    if (normalizedDate == null ||
        normalizedDate.isEmpty ||
        normalizedDate.toLowerCase() == 'null') {
      return '';
    }

    final parsedDate = DateTime.tryParse(normalizedDate);
    if (parsedDate == null) {
      return '';
    }

    final currentDate = DateTime.now();
    final difference = currentDate.difference(parsedDate);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm:ss a').format(parsedDate);
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('hh:mm:ss a').format(parsedDate)}';
    } else {
      return DateFormat('yyyy-MM-dd hh:mm:ss a').format(parsedDate);
    }
  }

  var sendAttachementRequestStatus = RequestStatus.idle.obs;
  Future<void> sendAttachementInChat(data, file, String conversationID) async {
    final targetConversationId = conversationID.isNotEmpty
        ? conversationID
        : groupConversationId.value;
    if (targetConversationId.isEmpty) {
      Get.snackbar("Error", "No conversation ID found");
      return;
    }

    _log(
      'Preparing attachment upload: targetConversationId=$targetConversationId, fields=$data, filePath=${file?.path}',
    );

    final localId =
        'local_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
    final pendingMessage = {
      'localId': localId,
      'chatRoomId': targetConversationId,
      'attachmentUrl': file.path,
      'content': '',
      'createdAt': DateTime.now().toIso8601String(),
      'isLocalFile': true,
      'isUploading': true,
    };
    _addOrReplacePendingMessage(pendingMessage);

    sendAttachementRequestStatus.value = RequestStatus.loading;
    final fileToSend = File(file.path);
    final result = await groupChatRepository.sendAttachementOnOneToOneChatRoom(
      data,
      fileToSend,
      targetConversationId,
    );
    _log(
      'Attachment upload completed: success=${result['success']}, message=${result['message']}',
    );
    if (result['success'] == true) {
      final responseData = result['data'];
      if (responseData is Map) {
        final serverMessage = Map<String, dynamic>.from(responseData);
        serverMessage['localId'] = localId;
        serverMessage['isLocalFile'] = false;
        serverMessage['isUploading'] = false;
        if ((serverMessage['attachmentUrl']?.toString().isEmpty ?? true) &&
            responseData['url'] != null) {
          serverMessage['attachmentUrl'] = responseData['url'];
        }
        _addOrReplacePendingMessage(serverMessage);
      } else {
        _addOrReplacePendingMessage({...pendingMessage, 'isUploading': false});
        socketController.socket.emit('joinRoom', {
          'chatRoom': targetConversationId,
        });
      }
      sendAttachementRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['data'] ?? "");
    } else {
      _addOrReplacePendingMessage({
        ...pendingMessage,
        'isUploading': false,
        'uploadFailed': true,
      });
      sendAttachementRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var joinGrouoChatRoomRequestStatus = RequestStatus.idle.obs;
  Future<void> joinGroupChatRoom(String gropupId) async {
    _log('joinGroupChatRoom started for groupId=$gropupId');
    joinGrouoChatRoomRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.joinGroupChatRoom(gropupId);
    _log(
      'joinGroupChatRoom finished: success=${result['success']}, rawMessage=${result['message']}, data=${result['data']}',
    );
    if (result['success'] == true) {
      groupConversationId.value = result["message"]["chatRoomId"];
      _log(
        'Resolved groupConversationId=${groupConversationId.value} for groupId=$gropupId',
      );

      joinGrouoChatRoomRequestStatus.value = RequestStatus.success;
    } else {
      joinGrouoChatRoomRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  Future<bool> removeParticipantFromGroupChatRoom(
    String chatRoomId,
    String memberId, {
    String memberType = 'USER',
  }) async {
    if (chatRoomId.isEmpty) {
      Get.snackbar("Error", "No conversation ID found");
      return false;
    }

    removeParticipantRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.removeParticipantFromGroupChatRoom(
      chatRoomId,
      {
        'memberId': memberId,
        'memberType': memberType,
      },
    );

    if (result['success'] == true) {
      removeParticipantRequestStatus.value = RequestStatus.success;
      socketController.socket.emit('joinRoom', {'chatRoom': chatRoomId});
      Get.snackbar("Success", result['message'] ?? "Member removed successfully");
      return true;
    }

    removeParticipantRequestStatus.value = RequestStatus.error;
    Get.snackbar("Error", result['message'] ?? "Something went wrong");
    return false;
  }
}

//userReportPost/id?
