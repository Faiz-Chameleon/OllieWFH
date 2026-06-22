import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Auth/login/user_controller.dart';
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
  var messageActionStatus = RequestStatus.idle.obs;
  var groupMessagesStatus = RequestStatus.idle.obs;
  var blockedUsersStatus = RequestStatus.idle.obs;
  var groupJoinRequests = <Map<String, dynamic>>[].obs;
  var blockedUsers = <Map<String, dynamic>>[].obs;
  var groupMessagesPage = 1.obs;
  var groupMessagesHasMore = false.obs;
  static const List<String> _messageEventNames = [
    'message',
    'newMessage',
    'messageSent',
    'groupMessage',
  ];

  // Null = no pending event; non-null = event payload the UI must act on.
  // Screens should reset to null after handling so re-entering the same group
  // doesn't trigger stale navigation.
  final userRemovedEvent = Rx<Map<String, dynamic>?>(null);
  final userBlockedEvent = Rx<Map<String, dynamic>?>(null);
  final membersRefreshEvent = Rx<Map<String, dynamic>?>(null);

  void _log(String message) {
    debugPrint('[GroupChatController] $message');
  }

  @override
  void onClose() {
    // Clean up listeners when controller is disposed
    _removeListeners();
    // Leave the room if we're in one
    if (groupConversationId.value.isNotEmpty) {
      final rawRoomId = _rawChatRoomId(groupConversationId.value);
      socketController.emitEvent('leaveRoom', {
        'chatroom': rawRoomId,
        'chatRoom': rawRoomId,
      });
    }
    super.onClose();
  }

  void _removeListeners() {
    if (_listenersRegistered) {
      socketController.offEvent('getRoom');
      for (final eventName in _messageEventNames) {
        socketController.offEvent(eventName);
      }
      socketController.offEvent('userRemovedFromGroup');
      socketController.offEvent('userBlockedFromGroup');
      socketController.offEvent('reactionAdded');
      socketController.offEvent('reactionRemoved');
      socketController.offEvent('newReply');
      socketController.offEvent('messageDeleted');
      _listenersRegistered = false;
      _log('Socket listeners removed');
    }
  }

  void _setupListenersOnGroup() {
    if (!_listenersRegistered) {
      // Set up getRoom listener
      socketController.onEvent('getRoom', (data) {
        _log('Socket event getRoom received: $data');
        final messagesData = _extractMessagesList(data);
        if (messagesData != null) {
          final normalized = messagesData
              .map(_normalizeMessage)
              .where((m) => m.isNotEmpty)
              .toList();
          messages
            ..clear()
            ..addAll(normalized);
          messages.refresh();
          _log('Messages updated from getRoom: count=${normalized.length}');
        } else {
          _log('getRoom payload missing expected data/messages fields');
        }
      });

      void handleIncomingMessage(dynamic data, String eventName) {
        try {
          _log(
            'Socket event $eventName received: type=${data.runtimeType}, data=$data',
          );
          final messageContent = _extractMessageMap(data);
          if (messageContent != null && messageContent.isNotEmpty) {
            final messageRoomId = messageContent['chatRoomId']?.toString();
            if (messageRoomId != null &&
                messageRoomId.isNotEmpty &&
                !_isCurrentGroupRoom(messageRoomId)) {
              _log(
                'Ignoring $eventName for room $messageRoomId while active room is ${groupConversationId.value}',
              );
              return;
            }

            _log(
              'Adding message from socket: id=${messageContent['id']}, sender=${messageContent['senderId']}, content=${messageContent['content']}',
            );
            _addOrReplaceIncomingMessage(messageContent);
          } else {
            _log(
              'Received invalid or empty message payload: type=${data.runtimeType}',
            );
          }
        } catch (e, stackTrace) {
          _log('Error receiving socket message: $e');
          _log('Socket message stack trace: $stackTrace');
        }
      }

      for (final eventName in _messageEventNames) {
        socketController.onEvent(eventName, (data) {
          handleIncomingMessage(data, eventName);
        });
      }

      // ── userRemovedFromGroup ──────────────────────────────────────────────
      socketController.onEvent('userRemovedFromGroup', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final chatRoomId = d['chatRoomId']?.toString() ?? '';
        final removedUserId = d['removedUserId']?.toString() ?? '';
        _log(
          'userRemovedFromGroup: chatRoomId=$chatRoomId removedUserId=$removedUserId',
        );
        if (!_isCurrentGroupRoom(chatRoomId)) return;
        userRemovedEvent.value = {
          'chatRoomId': chatRoomId,
          'removedUserId': removedUserId,
          'removedBy': d['removedBy']?.toString() ?? '',
        };
        if (removedUserId != _currentUserId) {
          membersRefreshEvent.value = {'chatRoomId': chatRoomId};
        }
      });

      // ── userBlockedFromGroup ──────────────────────────────────────────────
      socketController.onEvent('userBlockedFromGroup', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final chatRoomId = d['chatRoomId']?.toString() ?? '';
        final blockedUserId = d['blockedUserId']?.toString() ?? '';
        _log(
          'userBlockedFromGroup: chatRoomId=$chatRoomId blockedUserId=$blockedUserId',
        );
        if (!_isCurrentGroupRoom(chatRoomId)) return;
        userBlockedEvent.value = {
          'chatRoomId': chatRoomId,
          'blockedUserId': blockedUserId,
          'blockedBy': d['blockedBy']?.toString() ?? '',
        };
        membersRefreshEvent.value = {'chatRoomId': chatRoomId};
      });

      // ── reactionAdded ─────────────────────────────────────────────────────
      socketController.onEvent('reactionAdded', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final messageId = d['messageId']?.toString() ?? '';
        final reactionRaw = d['reaction'];
        if (messageId.isEmpty || reactionRaw is! Map) return;
        _log('reactionAdded: messageId=$messageId');

        final reaction = reactionRaw.map((k, v) => MapEntry(k.toString(), v));
        _upsertReaction(messageId, reaction);
      });

      // ── reactionRemoved ───────────────────────────────────────────────────
      socketController.onEvent('reactionRemoved', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final messageId = d['messageId']?.toString() ?? '';
        final userId = d['userId']?.toString() ?? '';
        final emoji = d['emoji']?.toString() ?? '';
        if (messageId.isEmpty) return;
        _log(
          'reactionRemoved: messageId=$messageId userId=$userId emoji=$emoji',
        );

        _removeReactionFromMessage(messageId, userId, emoji);
      });

      // ── newReply ──────────────────────────────────────────────────────────
      socketController.onEvent('newReply', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final parentMessageId = d['parentMessageId']?.toString() ?? '';
        final replyRaw = d['reply'];
        if (parentMessageId.isEmpty || replyRaw is! Map) return;
        _log('newReply: parentMessageId=$parentMessageId');

        final reply = replyRaw.map((k, v) => MapEntry(k.toString(), v));
        _upsertReply(parentMessageId, reply);
      });

      // ── messageDeleted ────────────────────────────────────────────────────
      socketController.onEvent('messageDeleted', (data) {
        final d = _unwrap(data);
        if (d == null) return;
        final messageId = d['messageId']?.toString() ?? '';
        if (messageId.isEmpty) return;
        _log('messageDeleted: messageId=$messageId');
        _patchMessage(messageId, {'deletedForEveryone': true, 'content': ''});
      });

      _listenersRegistered = true;
      _log('Socket listeners registered');
    }
  }

  List<dynamic>? _extractMessagesList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is! Map) return null;

    final data = payload['data'];
    if (data is Map && data['messages'] is List) {
      return data['messages'] as List;
    }
    if (data is List) return data;
    if (payload['messages'] is List) {
      return payload['messages'] as List;
    }
    return null;
  }

  Map<String, dynamic>? _unwrap(dynamic data) {
    final raw = (data is List && data.isNotEmpty) ? data.first : data;
    if (raw is! Map) return null;
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }

  String _rawChatRoomId(String chatRoomId) {
    final trimmed = chatRoomId.trim();
    return trimmed.startsWith('chat:') ? trimmed.substring(5) : trimmed;
  }

  bool _isCurrentGroupRoom(String chatRoomId) {
    return _rawChatRoomId(chatRoomId) ==
        _rawChatRoomId(groupConversationId.value);
  }

  Map<String, dynamic> _normalizeMessage(dynamic rawMsg) {
    if (rawMsg is! Map) return {};
    final mapped = Map<String, dynamic>.fromEntries(
      rawMsg.entries.map((e) => MapEntry(e.key.toString(), e.value)),
    );
    // Normalize MongoDB _id → id
    mapped['id'] ??= mapped['_id'];
    // Guarantee reactions and replies are always lists so the UI can read them
    if (mapped['reactions'] is! List) mapped['reactions'] = <dynamic>[];
    if (mapped['replies'] is! List) mapped['replies'] = <dynamic>[];
    return mapped;
  }

  Map<String, dynamic>? _extractMessageMap(dynamic payload) {
    // socket_io_client wraps single-arg events in a List on some versions
    final unwrapped = (payload is List && payload.isNotEmpty)
        ? payload.first
        : payload;
    if (unwrapped is! Map) {
      _log(
        '_extractMessageMap: unexpected payload type=${payload.runtimeType}, raw=$payload',
      );
      return null;
    }

    final data = unwrapped['data'];
    final rawMessage = data is Map
        ? data
        : unwrapped['message'] is Map
        ? unwrapped['message']
        : unwrapped;

    return _normalizeMessage(rawMessage);
  }

  void _addOrReplaceIncomingMessage(Map<String, dynamic> serverMessage) {
    serverMessage['reactions'] ??= <dynamic>[];
    serverMessage['replies'] ??= <dynamic>[];
    final serverId = serverMessage['id']?.toString();
    final localId = serverMessage['localId']?.toString();

    if ((serverId == null || serverId.isEmpty) &&
        (localId == null || localId.isEmpty)) {
      _log(
        '_addOrReplaceIncomingMessage: skipping message with no id/localId, content=${serverMessage['content']}',
      );
      return;
    }

    final existingIndex = messages.indexWhere((item) {
      if (item is! Map) return false;
      return (serverId != null && item['id']?.toString() == serverId) ||
          (localId != null && item['localId']?.toString() == localId);
    });

    final fallbackPendingIndex = existingIndex == -1
        ? messages.indexWhere((item) {
            if (item is! Map || item['isSending'] != true) return false;
            final sameRoom =
                _rawChatRoomId(item['chatRoomId']?.toString() ?? '') ==
                _rawChatRoomId(serverMessage['chatRoomId']?.toString() ?? '');
            final sameSender =
                item['senderId']?.toString() ==
                serverMessage['senderId']?.toString();
            final sameContent =
                item['content']?.toString() ==
                serverMessage['content']?.toString();
            return sameRoom && sameSender && sameContent;
          })
        : -1;

    if (existingIndex == -1 && fallbackPendingIndex == -1) {
      messages.add(serverMessage);
    } else {
      final replaceIndex = existingIndex != -1
          ? existingIndex
          : fallbackPendingIndex;
      messages[replaceIndex] = {
        ...Map<String, dynamic>.from(messages[replaceIndex]),
        ...serverMessage,
        'isSending': false,
      };
    }
    messages.refresh();
  }

  int _messageIndexById(String messageId) {
    return messages.indexWhere(
      (item) => item is Map && item['id']?.toString() == messageId,
    );
  }

  void _patchMessage(String messageId, Map<String, dynamic> patch) {
    final index = _messageIndexById(messageId);
    if (index == -1 || messages[index] is! Map) return;
    messages[index] = {...Map<String, dynamic>.from(messages[index]), ...patch};
    messages.refresh();
  }

  void _upsertReaction(String messageId, Map<String, dynamic> reaction) {
    final index = _messageIndexById(messageId);
    if (index == -1 || messages[index] is! Map) {
      _log(
        'Unable to upsert reaction; message not found. messageId=$messageId, currentMessageIds=${messages.whereType<Map>().map((item) => item['id']).toList()}',
      );
      return;
    }
    final userId =
        reaction['userId']?.toString() ??
        (reaction['user'] is Map
            ? (reaction['user'] as Map)['id']?.toString()
            : null) ??
        _currentUserId;
    final emoji = _backendEmoji(reaction['emoji']?.toString() ?? '');
    reaction['userId'] = userId;
    reaction['emoji'] = emoji;
    final reactions = <dynamic>[reaction];
    _log(
      'Reaction upserted locally: messageId=$messageId emoji=$emoji userId=$userId count=${reactions.length}',
    );
    _patchMessage(messageId, {'reactions': reactions});
  }

  void _removeReactionFromMessage(
    String messageId,
    String userId,
    String emoji,
  ) {
    final index = _messageIndexById(messageId);
    if (index == -1 || messages[index] is! Map) return;
    final backendEmoji = _backendEmoji(emoji);
    final message = Map<String, dynamic>.from(messages[index]);
    final reactions = List<dynamic>.from(message['reactions'] ?? []);
    final hasExactUserMatch = reactions.any(
      (item) =>
          item is Map &&
          item['userId']?.toString() == userId &&
          _backendEmoji(item['emoji']?.toString() ?? '') == backendEmoji,
    );
    reactions.removeWhere(
      (item) =>
          item is Map &&
          (hasExactUserMatch ? item['userId']?.toString() == userId : true) &&
          _backendEmoji(item['emoji']?.toString() ?? '') == backendEmoji,
    );
    _patchMessage(messageId, {'reactions': reactions});
  }

  bool _hasVisibleReaction(String messageId, String emoji) {
    final index = _messageIndexById(messageId);
    if (index == -1 || messages[index] is! Map) {
      return false;
    }
    final backendEmoji = _backendEmoji(emoji);
    final message = Map<String, dynamic>.from(messages[index]);
    final reactions = List<dynamic>.from(message['reactions'] ?? []);
    return reactions.any(
      (item) =>
          item is Map &&
          _backendEmoji(item['emoji']?.toString() ?? '') == backendEmoji,
    );
  }

  Map<String, dynamic> _localReaction(String messageId, String emoji) {
    final backendEmoji = _backendEmoji(emoji);
    return {
      'id': 'local_reaction_${messageId}_${_currentUserId}_$backendEmoji',
      'messageId': messageId,
      'userId': _currentUserId,
      'emoji': backendEmoji,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  String _backendEmoji(String emoji) {
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

  void _upsertReply(String parentMessageId, Map<String, dynamic> reply) {
    final index = _messageIndexById(parentMessageId);
    if (index == -1 || messages[index] is! Map) return;
    final message = Map<String, dynamic>.from(messages[index]);
    final replies = List<dynamic>.from(message['replies'] ?? []);
    final replyId = reply['id']?.toString();
    final existingIndex = replies.indexWhere(
      (item) => item is Map && item['id']?.toString() == replyId,
    );
    if (existingIndex == -1) {
      replies.add(reply);
    } else {
      replies[existingIndex] = reply;
    }
    _patchMessage(parentMessageId, {
      'replies': replies,
      'replyCount': replies.length,
    });
  }

  Future<void> joinGroupRoom(String conversationID) async {
    if (conversationID.isNotEmpty) {
      await _ensureSocketConnected();
      // Leave current room if we're in one
      if (groupConversationId.value.isNotEmpty &&
          groupConversationId.value != conversationID) {
        final rawPreviousRoomId = _rawChatRoomId(groupConversationId.value);
        socketController.emitEvent('leaveRoom', {
          'chatroom': rawPreviousRoomId,
          'chatRoom': rawPreviousRoomId,
        });
      }

      // Update conversation ID
      final rawConversationId = _rawChatRoomId(conversationID);
      groupConversationId.value = rawConversationId;

      // Remove existing listeners before setting up new ones
      _removeListeners();

      // Set up listeners
      _setupListenersOnGroup();

      // Join the room
      _log('Emitting joinRoom for raw chatRoom=$rawConversationId');
      socketController.emitEvent('joinRoom', {
        'chatroom': rawConversationId,
        'chatRoom': rawConversationId,
      });
      _log('Joined group room with raw chatRoomId=$rawConversationId');
    } else {
      appSnackbar("Error", "No conversation ID found");
    }
  }

  Future<void> sendMessageInGroupRoom(String conversationID, text) async {
    if (conversationID.isNotEmpty) {
      await _ensureSocketConnected();
      final rawConversationId = _rawChatRoomId(conversationID);
      final localId =
          'local_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
      final localMessage = {
        'localId': localId,
        'chatRoomId': rawConversationId,
        'content': text.toString(),
        'createdAt': DateTime.now().toIso8601String(),
        'senderId': _currentUserId,
        'isSending': true,
      };
      _addOrReplacePendingMessage(localMessage);
      _log(
        'Emitting sendMessage for raw chatRoomId=$rawConversationId, textLength=${text.toString().length}, text=$text',
      );
      final payload = {
        'chatroom': rawConversationId,
        'chatRoom': rawConversationId,
        "message": text,
      };
      Timer(const Duration(seconds: 8), () {
        final pendingIndex = messages.indexWhere(
          (item) =>
              item is Map &&
              item['localId'] == localId &&
              item['isSending'] == true,
        );
        if (pendingIndex == -1) return;
        _log(
          'No message broadcast received for localId=$localId; clearing pending state',
        );
        _addOrReplacePendingMessage({...localMessage, 'isSending': false});
      });
      socketController.emitEvent('sendMessage', payload);
    } else {
      appSnackbar("Error", "No conversation ID found");
    }
  }

  Future<void> refreshCurrentGroupRoom() async {
    final chatRoomId = groupConversationId.value.trim();
    if (chatRoomId.isEmpty) return;
    await fetchGroupMessages(chatRoomId);
    await joinGroupRoom(chatRoomId);
  }

  Future<void> fetchGroupMessages(
    String chatRoomId, {
    int page = 1,
    int limit = 50,
    bool appendOlder = false,
    bool showError = true,
  }) async {
    final rawChatRoomId = _rawChatRoomId(chatRoomId);
    if (rawChatRoomId.isEmpty) return;

    groupMessagesStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.getChatMessages(
      rawChatRoomId,
      page: page,
      limit: limit,
    );

    if (result['success'] == true) {
      final data = result['data'];
      final messagesData = _extractMessagesList(data) ?? const [];
      final normalized = messagesData
          .map(_normalizeMessage)
          .where((m) => m.isNotEmpty)
          .toList();

      if (appendOlder) {
        final existingIds = messages
            .whereType<Map>()
            .map((item) => item['id']?.toString())
            .whereType<String>()
            .toSet();
        final olderMessages = normalized
            .where((item) => !existingIds.contains(item['id']?.toString()))
            .toList();
        messages.insertAll(0, olderMessages);
      } else {
        messages
          ..clear()
          ..addAll(normalized);
      }
      messages.refresh();

      final pagination = data is Map ? data['pagination'] : null;
      if (pagination is Map) {
        groupMessagesPage.value =
            int.tryParse(pagination['page']?.toString() ?? '') ?? page;
        groupMessagesHasMore.value = pagination['hasMore'] == true;
      } else {
        groupMessagesPage.value = page;
        groupMessagesHasMore.value = false;
      }
      groupMessagesStatus.value = RequestStatus.success;
      _log(
        'Messages updated from REST history: count=${normalized.length}, page=$page',
      );
      return;
    }

    groupMessagesStatus.value = RequestStatus.error;
    if (showError) {
      appSnackbar("Error", result['message'] ?? "Unable to load messages");
    }
  }

  Future<void> _ensureSocketConnected() async {
    if (socketController.canEmit) return;
    _log('Socket not connected; attempting connect before group socket action');
    await socketController.connectSocket();
    for (var attempt = 0; attempt < 20; attempt++) {
      if (socketController.canEmit) return;
      await Future.delayed(const Duration(milliseconds: 150));
    }
    _log('Socket still not connected after waiting');
  }

  String? get _currentUserId {
    try {
      return Get.find<UserController>().user.value?.id?.toString();
    } catch (_) {
      return null;
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
  Future<void> sendAttachementInChat(
    data,
    file,
    String conversationID, {
    String? localAttachmentBatchId,
    bool showSnackbar = true,
  }) async {
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
    final currentUser = Get.find<UserController>().user.value;
    final pendingMessage = {
      'localId': localId,
      'chatRoomId': targetConversationId,
      'attachmentUrl': file.path,
      'attachmentType': data is Map ? data['attachmentType'] : null,
      'content': '',
      'createdAt': DateTime.now().toIso8601String(),
      'senderId': _currentUserId,
      'sender': {
        'id': _currentUserId,
        'firstName': currentUser?.firstName,
        'lastName': currentUser?.lastName,
        'image': currentUser?.image,
      },
      if (localAttachmentBatchId?.isNotEmpty == true)
        'localAttachmentBatchId': localAttachmentBatchId,
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
        serverMessage['senderId'] ??= pendingMessage['senderId'];
        serverMessage['sender'] ??= pendingMessage['sender'];
        serverMessage['attachmentType'] ??= pendingMessage['attachmentType'];
        if (localAttachmentBatchId?.isNotEmpty == true) {
          serverMessage['localAttachmentBatchId'] = localAttachmentBatchId;
        }
        serverMessage['isLocalFile'] = false;
        serverMessage['isUploading'] = false;
        if ((serverMessage['attachmentUrl']?.toString().isEmpty ?? true) &&
            responseData['url'] != null) {
          serverMessage['attachmentUrl'] = responseData['url'];
        }
        _addOrReplacePendingMessage(serverMessage);
      } else {
        _addOrReplacePendingMessage({...pendingMessage, 'isUploading': false});
        final rawTargetConversationId = _rawChatRoomId(targetConversationId);
        socketController.emitEvent('joinRoom', {
          'chatroom': rawTargetConversationId,
          'chatRoom': rawTargetConversationId,
        });
      }
      sendAttachementRequestStatus.value = RequestStatus.success;
      if (showSnackbar) {
        appSnackbar("Success", result['message'] ?? "Attachment sent");
      }
    } else {
      _addOrReplacePendingMessage({
        ...pendingMessage,
        'isUploading': false,
        'uploadFailed': true,
      });
      sendAttachementRequestStatus.value = RequestStatus.error;
      if (showSnackbar) {
        appSnackbar("Error", result['message'] ?? "Something went wrong");
      }
    }
  }

  var joinGrouoChatRoomRequestStatus = RequestStatus.idle.obs;
  Future<bool> joinGroupChatRoom(String chatRoomId) async {
    _log('joinGroupChatRoom started for chatRoomId=$chatRoomId');
    joinGrouoChatRoomRequestStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.joinGroupChatRoom(chatRoomId);
    _log(
      'joinGroupChatRoom finished: success=${result['success']}, rawMessage=${result['message']}, data=${result['data']}',
    );
    if (result['success'] == true) {
      final resolvedChatRoomId = _extractChatRoomId(result) ?? chatRoomId;
      if (_isJoinRequestPending(result)) {
        joinGrouoChatRoomRequestStatus.value = RequestStatus.success;
        appSnackbar("Request Sent", _joinGroupSuccessMessage(result));
        return false;
      }

      if (resolvedChatRoomId.isEmpty) {
        joinGrouoChatRoomRequestStatus.value = RequestStatus.error;
        appSnackbar("Error", "No chat room found for this group.");
        return false;
      }

      groupConversationId.value = resolvedChatRoomId;
      _log(
        'Resolved groupConversationId=$resolvedChatRoomId for chatRoomId=$chatRoomId',
      );
      joinGrouoChatRoomRequestStatus.value = RequestStatus.success;
      return true;
    } else {
      joinGrouoChatRoomRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
      return false;
    }
  }

  bool _isJoinRequestPending(Map<String, dynamic> result) {
    final data = result['data'];
    if (data is Map) {
      final joined = data['joined'];
      final status = data['requestStatus']?.toString().toUpperCase();
      return joined == false || status == 'PENDING';
    }
    return false;
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

  Future<List<Map<String, dynamic>>> fetchGroupMembers(
    String chatRoomId,
  ) async {
    if (chatRoomId.isEmpty) return const [];
    final result = await groupChatRepository.getGroupMembers(chatRoomId);
    if (result['success'] != true) {
      appSnackbar("Error", result['message'] ?? "Unable to load members");
      return const [];
    }

    final data = result['data'];
    if (data is! Map) return const [];
    final members = <Map<String, dynamic>>[];
    for (final admin
        in (data['admins'] is List ? data['admins'] as List : const [])) {
      if (admin is Map) {
        members.add({
          ...admin.map((key, value) => MapEntry(key.toString(), value)),
          'memberType': 'ADMIN',
        });
      }
    }
    for (final user
        in (data['users'] is List ? data['users'] as List : const [])) {
      if (user is Map) {
        final mapped = user.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        if (!members.any(
          (member) => member['id']?.toString() == mapped['id']?.toString(),
        )) {
          members.add({...mapped, 'memberType': 'USER'});
        }
      }
    }
    return members;
  }

  Future<bool> blockUserFromGroup(String chatRoomId, String userId) async {
    if (chatRoomId.isEmpty || userId.isEmpty) return false;
    blockedUsersStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.blockUserFromGroup(
      chatRoomId,
      userId,
    );
    if (result['success'] == true) {
      blockedUsersStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "User blocked");
      return true;
    }
    blockedUsersStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Unable to block user");
    return false;
  }

  Future<bool> unblockUserFromGroup(String chatRoomId, String userId) async {
    if (chatRoomId.isEmpty || userId.isEmpty) return false;
    blockedUsersStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.unblockUserFromGroup(
      chatRoomId,
      userId,
    );
    if (result['success'] == true) {
      blockedUsers.removeWhere(
        (item) =>
            item['userId']?.toString() == userId ||
            item['user']?['id']?.toString() == userId,
      );
      blockedUsersStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "User unblocked");
      return true;
    }
    blockedUsersStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Unable to unblock user");
    return false;
  }

  Future<void> fetchBlockedUsers(String chatRoomId) async {
    if (chatRoomId.isEmpty) return;
    blockedUsersStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.getBlockedUsers(chatRoomId);
    if (result['success'] == true) {
      final data = result['data'];
      final rawList = data is List ? data : const [];
      blockedUsers.assignAll(
        rawList.whereType<Map>().map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
      blockedUsersStatus.value = RequestStatus.success;
      return;
    }
    blockedUsersStatus.value = RequestStatus.error;
  }

  Future<void> reactToMessage(String messageId, String emoji) async {
    if (messageId.isEmpty || emoji.isEmpty) return;
    final backendEmoji = _backendEmoji(emoji);
    final hadReaction = _hasVisibleReaction(messageId, backendEmoji);
    if (hadReaction) {
      _removeReactionFromMessage(messageId, _currentUserId ?? '', backendEmoji);
      await removeReaction(messageId, backendEmoji, showError: false);
      return;
    } else {
      _upsertReaction(messageId, _localReaction(messageId, backendEmoji));
    }

    messageActionStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.reactToMessage(
      messageId,
      backendEmoji,
    );
    if (result['success'] == true) {
      final data = result['data'];
      if (data is Map) {
        _upsertReaction(
          messageId,
          data.map((key, value) => MapEntry(key.toString(), value)),
        );
      } else if (!hadReaction) {
        _upsertReaction(messageId, _localReaction(messageId, backendEmoji));
      }
      unawaited(fetchMessageReactions(messageId));
      messageActionStatus.value = RequestStatus.success;
      return;
    }
    if (hadReaction) {
      _upsertReaction(messageId, _localReaction(messageId, backendEmoji));
    } else {
      _removeReactionFromMessage(messageId, _currentUserId ?? '', backendEmoji);
    }
    messageActionStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Unable to react");
  }

  Future<void> removeReaction(
    String messageId,
    String emoji, {
    bool showError = true,
  }) async {
    if (messageId.isEmpty || emoji.isEmpty) return;
    final backendEmoji = _backendEmoji(emoji);
    _removeReactionFromMessage(messageId, _currentUserId ?? '', backendEmoji);
    messageActionStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.removeReaction(
      messageId,
      backendEmoji,
    );
    if (result['success'] == true) {
      _removeReactionFromMessage(messageId, _currentUserId ?? '', backendEmoji);
      messageActionStatus.value = RequestStatus.success;
      return;
    }
    _upsertReaction(messageId, _localReaction(messageId, backendEmoji));
    messageActionStatus.value = RequestStatus.error;
    if (showError) {
      appSnackbar("Error", result['message'] ?? "Unable to remove reaction");
    }
  }

  Future<void> fetchMessageReactions(String messageId) async {
    if (messageId.isEmpty) return;
    final result = await groupChatRepository.getMessageReactions(messageId);
    if (result['success'] == true) {
      final data = result['data'];
      final dynamic rawReactions = data is List
          ? data
          : data is Map && data['reactions'] is List
          ? data['reactions']
          : data is Map && data['data'] is List
          ? data['data']
          : null;

      if (rawReactions is! List) {
        _log(
          'Skipping reaction refresh; unexpected response shape for messageId=$messageId data=$data',
        );
        return;
      }

      final normalizedReactions = rawReactions.whereType<Map>().map((item) {
        final mapped = item.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        mapped['emoji'] = _backendEmoji(mapped['emoji']?.toString() ?? '');
        mapped['userId'] ??= mapped['user'] is Map
            ? (mapped['user'] as Map)['id']?.toString()
            : null;
        return mapped;
      }).toList();
      final reactions = normalizedReactions.isEmpty
          ? <Map<String, dynamic>>[]
          : <Map<String, dynamic>>[normalizedReactions.last];
      _log(
        'Reaction refresh applied: messageId=$messageId count=${reactions.length}',
      );
      _patchMessage(messageId, {'reactions': reactions});
    }
  }

  Future<void> replyToMessage(String messageId, String content) async {
    if (messageId.isEmpty || content.trim().isEmpty) return;
    messageActionStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.replyToMessage(
      messageId,
      content.trim(),
    );
    if (result['success'] == true) {
      final data = result['data'];
      if (data is Map) {
        _upsertReply(
          messageId,
          data.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
      unawaited(fetchMessageReplies(messageId));
      messageActionStatus.value = RequestStatus.success;
      return;
    }
    messageActionStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Unable to send reply");
  }

  Future<void> fetchMessageReplies(String messageId) async {
    if (messageId.isEmpty) return;
    final result = await groupChatRepository.getMessageReplies(messageId);
    if (result['success'] == true) {
      final data = result['data'];
      final replies = data is Map && data['replies'] is List
          ? data['replies'] as List
          : const [];
      final total = data is Map ? data['total'] : replies.length;
      _patchMessage(messageId, {'replies': replies, 'replyCount': total});
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (messageId.isEmpty) return;
    messageActionStatus.value = RequestStatus.loading;
    final result = await groupChatRepository.deleteMessage(messageId);
    if (result['success'] == true) {
      _patchMessage(messageId, {'deletedForEveryone': true, 'content': ''});
      messageActionStatus.value = RequestStatus.success;
      return;
    }
    messageActionStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Unable to delete message");
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
      membersRefreshEvent.value = {'chatRoomId': chatRoomId};
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
