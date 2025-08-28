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
        messages.clear();
        print('Received data from getRoom: $data');
        if (data != null && data['data'] != null && data['data']['messages'] != null) {
          List messagesData = data['data']['messages'] ?? [];
          if (messagesData.isNotEmpty) {
            messages.addAll(messagesData);
            print('Messages updated: $messagesData');
          } else {
            print('No messages found in the received data');
          }
        } else {
          print('Data or messages field is null');
        }
      });

      // Set up message listener
      socketController.socket.on('message', (data) {
        try {
          print('Received data: $data');
          if (data is Map) {
            final messageContent = data['data'];
            messages.add(messageContent);
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
      if (result["message"] == "Chat room already exists") {
        oneOnOneConversationId.value = result["data"]["chatRoom"];
      } else {
        oneOnOneConversationId.value = result["data"]["chatRoomParticipants"][0]["chatRoomId"];
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

      // Remove existing listeners before setting up new ones
      _removeListeners();

      // Set up listeners
      _setupListeners();

      // Join the room
      socketController.socket.emit('joinRoom', {'chatRoom': conversationID});
      print("Joined chat room with ID: ${conversationID}");
    } else {
      Get.snackbar("Error", "No conversation ID found");
    }
  }

  void sendMessageInRoom(String conversationID, text) {
    if (conversationID.isNotEmpty) {
      socketController.socket.emit('sendMessage', {'chatroom': conversationID, "message": text});
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
}
