import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Volunteers/chat_repository.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/request_status.dart';

class OneToOneChatController extends GetxController {
  final SocketController socketController = Get.find<SocketController>();
  final ChatRepository chatRepository = ChatRepository();
  RxString oneOnOneConversationId = "".obs;
  var createChatRoomRequestStatus = RequestStatus.idle.obs;
  String? _pendingJoinRoomId;

  // Track if listeners are already registered
  bool _listenersRegistered = false;

  @override
  void onClose() {
    // Clean up listeners when controller is disposed
    _removeListeners();
    // Leave the room if we're in one
    if (oneOnOneConversationId.value.isNotEmpty) {
      socketController.socket.emit('leaveRoom', {'chatRoom': oneOnOneConversationId.value});
    }
    super.onClose();
  }

  void _removeListeners() {
    if (_listenersRegistered) {
      socketController.socket.off('getRoom');
      socketController.socket.off('message');
      _listenersRegistered = false;
      print('Socket listeners removed');
    }
  }

  void _setupListeners() {
    if (!_listenersRegistered) {
      // Set up getRoom listener
      socketController.socket.on('getRoom', (data) {
        print('Received data from getRoom: $data');
        if (data is! Map) {
          print('Ignoring getRoom payload: not a map');
          return;
        }

        final roomData = data['data'];
        if (roomData is! Map) {
          print('Ignoring getRoom payload: missing room data');
          return;
        }

        final incomingRoomId = roomData['id']?.toString() ?? '';
        if (incomingRoomId.isEmpty) {
          print('Ignoring getRoom payload: empty room id');
          return;
        }

        final currentRoomId = oneOnOneConversationId.value;
        final pendingRoomId = _pendingJoinRoomId;

        if (currentRoomId.isNotEmpty && incomingRoomId != currentRoomId) {
          final shouldAdoptIncoming = pendingRoomId != null && pendingRoomId.isNotEmpty && currentRoomId == pendingRoomId;
          if (shouldAdoptIncoming) {
            print('Updating active room id from $currentRoomId to $incomingRoomId based on getRoom payload');
            oneOnOneConversationId.value = incomingRoomId;
            _pendingJoinRoomId = null;
          } else {
            print('Ignoring getRoom for non-active room $incomingRoomId');
            return;
          }
        } else {
          // We've confirmed the payload is for the active room
          _pendingJoinRoomId = null;
          if (currentRoomId.isEmpty) {
            oneOnOneConversationId.value = incomingRoomId;
          }
        }

        final messagesData = roomData['messages'];
        messages.clear();
        if (messagesData is List) {
          messages.addAll(messagesData);
          print('Messages updated: $messagesData');
        } else {
          print('No messages found in the received data');
        }
      });

      // Set up message listener
      socketController.socket.on('message', (data) {
        try {
          print('Received data: $data');
          if (data is Map) {
            final messageContent = data['data'];
            if (messageContent is Map) {
              final messageRoomId = messageContent['chatRoomId']?.toString();
              final activeRoomId = oneOnOneConversationId.value;

              if (messageRoomId != null && messageRoomId.isNotEmpty && activeRoomId.isNotEmpty && messageRoomId != activeRoomId) {
                print('Ignoring message for room $messageRoomId while active room is $activeRoomId');
                return;
              }

              if (messageRoomId != null && (activeRoomId.isEmpty || messageRoomId != activeRoomId) && _pendingJoinRoomId != null) {
                print('Adopting room id $messageRoomId from incoming message payload');
                oneOnOneConversationId.value = messageRoomId;
                _pendingJoinRoomId = null;
              }

              messages.add(messageContent);
            } else {
              print('Received message payload is not a map: $messageContent');
            }
          } else {
            print('Received invalid data: $data');
          }
        } catch (e, stackTrace) {
          print('Error receiving message: $e');
          print('Stack Trace: $stackTrace');
        }
      });

      _listenersRegistered = true;
      print('Socket listeners registered');
    }
  }

  Future<void> createOneOnOneChat(data) async {
    createChatRoomRequestStatus.value = RequestStatus.loading;
    final result = await chatRepository.createChatRoomOneToOne(data);
    if (result['success'] == true) {
      final conversationId = _extractChatRoomId(result['data']);
      if (conversationId != null && conversationId.isNotEmpty) {
        oneOnOneConversationId.value = conversationId;
      } else {
        print('Warning: Unable to resolve chat room id from response: ${result['data']}');
      }

      createChatRoomRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
    } else {
      createChatRoomRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var messages = [].obs;

  void joinRoom(String conversationID) {
    if (conversationID.isNotEmpty) {
      // Leave current room if we're in one
      if (oneOnOneConversationId.value.isNotEmpty && oneOnOneConversationId.value != conversationID) {
        socketController.socket.emit('leaveRoom', {'chatRoom': oneOnOneConversationId.value});
      }

      // Update conversation ID
      oneOnOneConversationId.value = conversationID;
      _pendingJoinRoomId = conversationID;

      // Remove existing listeners before setting up new ones
      _removeListeners();

      // Set up listeners
      _setupListeners();

      // Join the room
      socketController.socket.emit('joinRoom', {'chatRoom': conversationID});
      print("Joined chat room with ID: ${conversationID}");
      // socketController.socket.on('getRoom', (data) {
      //   print(data);
      // });
    } else {
      Get.snackbar("Error", "No conversation ID found");
    }
  }

  void sendMessageInRoom(String conversationID, text) {
    final targetConversationId = conversationID.isNotEmpty ? conversationID : oneOnOneConversationId.value;
    if (targetConversationId.isNotEmpty) {
      final payload = {'chatroom': targetConversationId, "message": text};
      print('Emitting sendMessage with payload: $payload');
      socketController.socket.emitWithAck(
        'sendMessage',
        payload,
        ack: (ack) {
          print('sendMessage ack: $ack');
        },
      );
    } else {
      Get.snackbar("Error", "No conversation ID found");
    }
  }

  String getReadableDateTime(String dateTimeStr) {
    DateTime parsedDate = DateTime.parse(dateTimeStr);

    DateTime currentDate = DateTime.now();

    Duration difference = currentDate.difference(parsedDate);

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
    sendAttachementRequestStatus.value = RequestStatus.loading;
    final fileToSend = File(file.path);
    final result = await chatRepository.sendAttachementOnOneToOneChatRoom(data, fileToSend, conversationID);
    if (result['success'] == true) {
      sendAttachementRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['data'] ?? "");
    } else {
      sendAttachementRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  String? _extractChatRoomId(dynamic payload) {
    if (payload is! Map) return null;

    final chatRoom = payload['chatRoom'];
    if (chatRoom is String && chatRoom.isNotEmpty) {
      return chatRoom;
    }
    if (chatRoom is Map && chatRoom['id'] != null) {
      return chatRoom['id']?.toString();
    }

    final chatRoomId = payload['chatRoomId'];
    if (chatRoomId != null && chatRoomId.toString().isNotEmpty) {
      return chatRoomId.toString();
    }

    final chatRoomParticipants = payload['chatRoomParticipants'];
    if (chatRoomParticipants is List && chatRoomParticipants.isNotEmpty) {
      for (final participant in chatRoomParticipants) {
        if (participant is Map && participant['chatRoomId'] != null) {
          final participantRoomId = participant['chatRoomId']?.toString();
          if (participantRoomId != null && participantRoomId.isNotEmpty) {
            return participantRoomId;
          }
        }
      }
    }

    final data = payload['data'];
    if (data is Map) {
      return _extractChatRoomId(data);
    }

    return null;
  }
}
