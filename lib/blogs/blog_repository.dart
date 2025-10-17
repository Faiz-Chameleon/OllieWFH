import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';

class BlogRepository {
  Future<Map<String, dynamic>> getBlogsWithRespectToCategories(type) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod("${ApiUrls.getBlogsByCategory}?type=$type", token: requiredToken);
  }

  Future<Map<String, dynamic>> getBlogsTopics() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.getBlogsTopics, token: requiredToken);
  }

  Future<Map<String, dynamic>> getLatestBlogsList() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.getLatestBlogs, token: requiredToken);
  }

  Future<Map<String, dynamic>> getBlogsByItsTopic(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod("${ApiUrls.getBlogsByTopics}/$id", token: requiredToken);
  }

  Future<Map<String, dynamic>> getBlogsByItsTopicOnFilter(lable) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod("${ApiUrls.getBlogsByTopicsOnFilter}?type=$lable", token: requiredToken);
  }

  Future<Map<String, dynamic>> getBlogDetails(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod("${ApiUrls.getBlogsDetails}/$id", token: requiredToken);
  }

  Future<Map<String, dynamic>> likeOrUnlikeBlog(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.blogLikeOrUnlike}/$id", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> saveAndUnsaveBlog(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.saveBlog}/$id", {}, token: requiredToken);
  }
}
