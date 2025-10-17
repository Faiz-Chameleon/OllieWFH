import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class CommentsRepository {
  Future<Map<String, dynamic>> commentsOnBlogs(
    Map<String, dynamic> data,
    String blogId,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.commentsOnBlog}/$blogId",
      data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getCommentsOnBlog(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(
      "${ApiUrls.getCommentsOnBlog}/$id",
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> likeAndReplyOnComment(
    String commentId,
    Map<String, dynamic> data,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.likeAndReplyOnComment}/$commentId",
      data,
      token: requiredToken,
    );
  }
}
