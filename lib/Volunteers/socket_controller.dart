// ignore_for_file: avoid_print, library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//liveurl https://api.theollie.app

class SocketController extends GetxController {
  late IO.Socket socket;
  bool _socketInitialized = false;
  bool _pollingFallbackStarted = false;
  String? _authToken;
  final Map<String, List<void Function(dynamic)>> _socketListeners = {};
  var isConnected = false.obs;
  var userToken = "".obs;
  var messages = <String>[].obs;

  bool get canEmit => _socketInitialized && socket.connected;

  Future<void> connectSocket() async {
    if (_socketInitialized) {
      if (!socket.connected) {
        print('Socket already initialized; reconnecting');
        socket.connect();
      }
      return;
    }

    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    _authToken = requiredToken;
    _createSocket(usePolling: false);
  }

  void _createSocket({required bool usePolling}) {
    if (_socketInitialized) {
      socket.dispose();
    }

    final transports = usePolling ? ['polling'] : ['websocket'];
    socket = IO.io('https://api.theollie.app', {
      'transports': transports,
      'extraHeaders': {
        if (_authToken != null && _authToken!.isNotEmpty)
          'Authorization': 'Bearer $_authToken',
        if (_authToken != null && _authToken!.isNotEmpty)
          'x-access-token': _authToken!,
      },
      'forceNew': true,
      'reconnection': true,
      if (usePolling) 'upgrade': false,
    });
    _socketInitialized = true;

    socket.on('connect', (_) {
      print('Connected to the socket server');
      isConnected.value = true;
      // receivedMessages();
    });

    socket.on('connect_error', (error) {
      print('Socket connect_error: $error');
      isConnected.value = false;
      if (!usePolling) {
        _startPollingFallback();
      }
    });

    socket.on('disconnect', (_) {
      print('Disconnected from the socket server');
      isConnected.value = false;
    });

    socket.on('error', (error) {
      print('Socket error: $error');
    });

    _bindStoredListeners();
  }

  void onEvent(String event, void Function(dynamic) callback) {
    _socketListeners.putIfAbsent(event, () => []).add(callback);
    if (_socketInitialized) {
      socket.on(event, callback);
    }
  }

  void offEvent(String event) {
    _socketListeners.remove(event);
    if (_socketInitialized) {
      socket.off(event);
    }
  }

  void emitEvent(String event, dynamic data) {
    if (canEmit) {
      socket.emit(event, data);
      return;
    }
    print('Socket emit skipped, not connected: event=$event');
  }

  Future<void> _startPollingFallback() async {
    if (_pollingFallbackStarted) return;
    _pollingFallbackStarted = true;
    print('Retrying socket connection via polling fallback');
    _createSocket(usePolling: true);
  }

  void _bindStoredListeners() {
    _socketListeners.forEach((event, callbacks) {
      socket.off(event);
      for (final callback in callbacks) {
        socket.on(event, callback);
      }
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

  // void listenToEvent(String event, void Function(dynamic) callback) {
  //   socket.on(event, callback);
  // }

  // Disconnect the socket
  // void disconnectSocket() {
  //   socket.disconnect();
  //   isConnected.value = false;
  //   print('Socket disconnected');
  // }

  // joinroom() {
  //   socket.emit('joinRoom', {});
  // }

  getRoom() {}
  //sendMessage(){}
  message() {}
}
