import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Volunteers/chat_repository.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class OneToManyChatController extends GetxController {
  final SocketController socketController = Get.find<SocketController>();

  RxString groupConversationId = "".obs;

  final ChatRepository groupChatRepository = ChatRepository();

  bool _listenersRegistered = false;

  var messages = [].obs;
  var removeParticipantRequestStatus = RequestStatus.idle.obs;
  var leaveGroupRequestStatus = RequestStatus.idle.obs;
  var groupJoinRequestsStatus = RequestStatus.idle.obs;
  var reviewGroupJoinRequestStatus = RequestStatus.idle.obs;
  var groupJoinRequests = <Map<String, dynamic>>[].obs;

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
      appSnackbar("Error", "No conversation ID found");
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
      appSnackbar("Error", "No conversation ID found");
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
      appSnackbar("Error", "No conversation ID found");
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
      appSnackbar("Success", result['data'] ?? "");
    } else {
      _addOrReplacePendingMessage({
        ...pendingMessage,
        'isUploading': false,
        'uploadFailed': true,
      });
      sendAttachementRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var joinGrouoChatRoomRequestStatus = RequestStatus.idle.obs;
  Future<bool> joinGroupChatRoom(String gropupId) async {
    _log('joinGroupChatRoom started for groupId=$gropupId');
    joinGrouoChatRoomRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.joinGroupChatRoom(gropupId);
    _log(
      'joinGroupChatRoom finished: success=${result['success']}, rawMessage=${result['message']}, data=${result['data']}',
    );
    if (result['success'] == true) {
      final chatRoomId = _extractChatRoomId(result);
      if (chatRoomId == null || chatRoomId.isEmpty) {
        joinGrouoChatRoomRequestStatus.value = RequestStatus.success;
        appSnackbar("Request Sent", _joinGroupSuccessMessage(result));
        return false;
      }

      groupConversationId.value = chatRoomId;
      _log('Resolved groupConversationId=$chatRoomId for groupId=$gropupId');
      joinGrouoChatRoomRequestStatus.value = RequestStatus.success;
      return true;
    } else {
      joinGrouoChatRoomRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
      return false;
    }
  }

  String? _extractChatRoomId(Map<String, dynamic> result) {
    final data = result['data'];
    final message = result['message'];
    if (data is Map && data['chatRoomId'] != null) {
      return data['chatRoomId'].toString();
    }
    if (data is Map && data['id'] != null) {
      return data['id'].toString();
    }
    if (message is Map && message['chatRoomId'] != null) {
      return message['chatRoomId'].toString();
    }
    return null;
  }

  String _joinGroupSuccessMessage(Map<String, dynamic> result) {
    final message = result['message'];
    final data = result['data'];

    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    final source = message is Map
        ? message
        : data is Map
        ? data
        : const {};
    final privacy = source['privacy']?.toString().toUpperCase();
    final joined = source['joined'] == true;

    if (joined) {
      return privacy == 'PRIVATE'
          ? 'Your request is pending approval.'
          : 'You joined the group successfully.';
    }
    return privacy == 'PRIVATE'
        ? 'Your request is pending approval.'
        : 'Group request sent successfully.';
  }

  Future<bool> leaveGroupChatRoom(String chatRoomId) async {
    if (chatRoomId.isEmpty) {
      appSnackbar("Error", "No conversation ID found");
      return false;
    }

    leaveGroupRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.leaveGroupChatRoom(chatRoomId);
    if (result['success'] == true) {
      leaveGroupRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "You left the group");
      return true;
    }

    leaveGroupRequestStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Something went wrong");
    return false;
  }

  Future<void> fetchGroupJoinRequests(String chatRoomId) async {
    if (chatRoomId.isEmpty) return;

    groupJoinRequestsStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.getGroupJoinRequests(chatRoomId);
    if (result['success'] == true) {
      groupJoinRequests.assignAll(_parseRequestList(result['data']));
      groupJoinRequestsStatus.value = RequestStatus.success;
      return;
    }

    groupJoinRequests.clear();
    groupJoinRequestsStatus.value = RequestStatus.error;
  }

  Future<bool> reviewGroupJoinRequest(String requestId, String action) async {
    if (requestId.isEmpty) return false;

    reviewGroupJoinRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.reviewGroupJoinRequest(
      requestId,
      action,
    );
    if (result['success'] == true) {
      groupJoinRequests.removeWhere(
        (request) => request['id']?.toString() == requestId,
      );
      reviewGroupJoinRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Request updated");
      return true;
    }

    reviewGroupJoinRequestStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Something went wrong");
    return false;
  }

  List<Map<String, dynamic>> _parseRequestList(dynamic data) {
    final rawList = data is Map && data['data'] is List
        ? data['data'] as List
        : data is List
        ? data
        : const [];

    return rawList
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Future<bool> removeParticipantFromGroupChatRoom(
    String chatRoomId,
    String memberId, {
    String memberType = 'USER',
  }) async {
    if (chatRoomId.isEmpty) {
      appSnackbar("Error", "No conversation ID found");
      return false;
    }

    removeParticipantRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.removeParticipantFromGroupChatRoom(
      chatRoomId,
      {'memberId': memberId, 'memberType': memberType},
    );

    if (result['success'] == true) {
      removeParticipantRequestStatus.value = RequestStatus.success;
      socketController.socket.emit('joinRoom', {'chatRoom': chatRoomId});
      appSnackbar(
        "Success",
        result['message'] ?? "Member removed successfully",
      );
      return true;
    }

    removeParticipantRequestStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Something went wrong");
    return false;
  }
}

//userReportPost/id?
