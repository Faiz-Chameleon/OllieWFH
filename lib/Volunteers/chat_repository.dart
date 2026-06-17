import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';
import 'dart:convert';

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

  Future<Map<String, dynamic>> leaveGroupChatRoom(String chatRoomId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.leaveGroupChatRoom}/$chatRoomId";
    _log('POST ${ApiUrls.baseUrl}$endpoint');

    final response = await ApiService.postMethod(endpoint, {}, token: requiredToken);

    _log('leaveGroupChatRoom response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }

  Future<Map<String, dynamic>> getGroupJoinRequests(String chatRoomId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.groupJoinRequests}/$chatRoomId";
    _log('GET ${ApiUrls.baseUrl}$endpoint');

    final response = await ApiService.getMethod(endpoint, token: requiredToken);

    _log('getGroupJoinRequests response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }

  Future<Map<String, dynamic>> reviewGroupJoinRequest(String requestId, String action) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final endpoint = "${ApiUrls.groupJoinRequests}/$requestId/review";
    _log('PUT ${ApiUrls.baseUrl}$endpoint action=$action');

    final response = await ApiService.putMethod(endpoint, data: {'action': action}, token: requiredToken);

    _log('reviewGroupJoinRequest response: success=${response['success']}, message=${response['message']}, data=${response['data']}');
    return response;
  }

  Future<Map<String, dynamic>> getGroupSharedMedia(String chatRoomId, {int page = 1, int limit = 20, String? attachmentType}) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (attachmentType != null && attachmentType.isNotEmpty) 'attachmentType': attachmentType,
    };
    final uri = Uri.parse('${ApiUrls.baseUrl}${ApiUrls.groupSharedMedia}/$chatRoomId').replace(queryParameters: queryParameters);
    _log('GET $uri');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', if (requiredToken != null) 'Authorization': 'Bearer $requiredToken'},
      );
      final parsed = json.decode(response.body);
      if (response.statusCode == 200) {
        final result = {'success': true, 'data': parsed['data'], 'message': parsed['message'] ?? ''};
        _log('getGroupSharedMedia response: success=true');
        return result;
      }

      final result = {'success': false, 'message': parsed['message'] ?? 'Unable to load shared media'};
      _log('getGroupSharedMedia response: success=false, message=${result['message']}');
      return result;
    } catch (e) {
      _log('getGroupSharedMedia failed: $e');
      return {'success': false, 'message': e.toString()};
    }
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
