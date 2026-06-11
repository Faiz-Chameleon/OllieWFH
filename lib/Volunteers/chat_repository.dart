import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class ChatRepository {
  void _log(String message) {
    debugPrint('[GroupChatRepository] $message');
  }

  Future<Map<String, dynamic>> createChatRoomOneToOne(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.createChatRoom, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> joinGroupChatRoom(String conversationId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.joinGroupChatRoom}/$conversationId";
    _log('POST ${ApiUrls.baseUrl}$endpoint');
    _log('joinGroupChatRoom request: groupId=$conversationId, hasToken=${requiredToken?.isNotEmpty == true}');

    final response = await ApiService.postMethod(endpoint, {}, token: requiredToken);

    _log('joinGroupChatRoom response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }

  Future<Map<String, dynamic>> removeParticipantFromGroupChatRoom(String chatRoomId, Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.removeParticipantFromGroupChatRoom}/$chatRoomId";
    _log('POST ${ApiUrls.baseUrl}$endpoint');
    _log('removeParticipantFromGroupChatRoom request: chatRoomId=$chatRoomId, data=$data, hasToken=${requiredToken?.isNotEmpty == true}');

    final response = await ApiService.postMethod(endpoint, data, token: requiredToken);

    _log('removeParticipantFromGroupChatRoom response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }

  Future<Map<String, dynamic>> sendAttachementOnOneToOneChatRoom(data, file, String conversationId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.sendAttachementOnChatRoom}/$conversationId";
    _log('POST multipart ${ApiUrls.baseUrl}$endpoint');
    _log('sendAttachment request: chatRoomId=$conversationId, fields=$data, filePath=${file?.path}, hasToken=${requiredToken?.isNotEmpty == true}');

    final response = await ApiService.postMultipart(endpoint, data, file, token: requiredToken);

    _log('sendAttachment response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }
}
