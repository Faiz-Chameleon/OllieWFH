import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  late IO.Socket socket;
  var isConnected = false.obs;
  var userToken = "".obs;
  var messages = <String>[].obs;

  Future<void> connectSocket() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    socket = IO.io(
      'http://3.96.202.108',
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({'Authorization': 'Bearer $requiredToken'}).build(),
    );

    socket.on('connect', (_) {
      print('Connected to the socket server');
      isConnected.value = true;
      // receivedMessages();
    });

    socket.on('disconnect', (_) {
      print('Disconnected from the socket server');
      isConnected.value = false;
    });

    socket.on('error', (error) {
      print('Socket error: $error');
    });
  }

  void sendMessage(String message) {
    messages.add(message);

    socket.emit('message', message);
  }

  // void receivedMessages() {
  //   socket.on('message', (data) {
  //     try {
  //       // Log the incoming data for debugging
  //       print('Received data: $data');

  //       // Add the message to the list if data is valid
  //       if (data != null && data is String) {
  //         messages.add(data);
  //         print('New message added: $data');
  //       } else if (data is Map) {
  //         print('Received map data: $data');
  //         messages.add(data.toString());
  //       } else {
  //         print('Received invalid data: $data');
  //       }
  //     } catch (e, stackTrace) {
  //       // Log the error and stack trace
  //       print('Error receiving message: $e');
  //       print('Stack Trace: $stackTrace');
  //     }
  //   });
  // }

  void listenToEvent(String event, void Function(dynamic) callback) {
    socket.on(event, callback);
  }

  // Disconnect the socket
  void disconnectSocket() {
    socket.disconnect();
    isConnected.value = false;
    print('Socket disconnected');
  }

  joinroom() {
    socket.emit('joinRoom', {});
  }

  getRoom() {}
  //sendMessage(){}
  message() {}
}
