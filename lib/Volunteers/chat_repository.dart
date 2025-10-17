import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class ChatRepository {
  Future<Map<String, dynamic>> createChatRoomOneToOne(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.createChatRoom, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> joinGroupChatRoom(String conversationId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.joinGroupChatRoom}/$conversationId", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> sendAttachementOnOneToOneChatRoom(data, file, String conversationId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMultipart("${ApiUrls.sendAttachementOnChatRoom}/$conversationId", data, file, token: requiredToken);
  }
}
