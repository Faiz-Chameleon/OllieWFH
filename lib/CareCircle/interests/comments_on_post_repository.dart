import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class CommentsOnPostRepository {
  Future<Map<String, dynamic>> commentsOnPost(Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.commentsOnPost, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> getCommentsOnPost(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.getCommentsOnPost, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> likeAndReplyOnPost(String commentId, Map<String, dynamic> data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.likeAndReplyOnPostComment, data, token: requiredToken);
  }
}
