import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';
import 'dart:io';
import 'dart:core';

class CareCircleRepository {
  Future<Map<String, dynamic>> saveAndUnsavePost(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.saveBlog}/$id",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> likeOrUnlikePost(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      ApiUrls.postLikeOrUnlike,
      data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> interestBasePostForUser(
    String interestId,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      "${ApiUrls.interestBaseMultiplePost}/$interestId",
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getSingleUserPost(String postId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      "${ApiUrls.singleUserPost}/$postId",
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> createdPostByUser() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.onlyYourPost, token: requiredToken);
  }

  Future<Map<String, dynamic>> getYourPostAsPerYourInterest() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      ApiUrls.postOnYourInteres,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getBlogsTopics() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.getBlogsTopics, token: requiredToken);
  }

  Future<Map<String, dynamic>> getSavedPosts() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(ApiUrls.getSavePost, token: requiredToken);
  }

  Future<Map<String, dynamic>> getYourInterestedTopics() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(
      ApiUrls.getYourInterestedTopics,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getOthersGroups({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    final queryParameters = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
    };

    final endpoint =
        '${ApiUrls.getOthersGroup}?${Uri(queryParameters: queryParameters).query}';

    return ApiService.getMethod(endpoint, token: requiredToken);
  }

  Future<Map<String, dynamic>> getYourGroups() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getYoursGroup, token: requiredToken);
  }

  Future<Map<String, dynamic>> getLatesEvent() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getLatestEvent, token: requiredToken);
  }

  Future<Map<String, dynamic>> onEventMarkAsGoing(eventId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.putMethod(
      "${ApiUrls.markAsGoingOnEvent}/$eventId",
      data: {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getNearesEvent() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getNearesEvent, token: requiredToken);
  }

  Future<Map<String, dynamic>> getCreatedAssistance() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      ApiUrls.getcreatedAssistance,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getOthersCreatedAssistance({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 20,
    double? radiusKm,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
    };

    final endpoint =
        '${ApiUrls.getOthersCreatedAssistance}?${Uri(queryParameters: queryParameters).query}';

    return ApiService.getMethod(endpoint, token: requiredToken);
  }

  Future<Map<String, dynamic>> reachOutOnAssistanceRequest(assistanceId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.reachOnOthersCreatedAssistance}/$assistanceId",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> assistanceRequestCompleteByVolunter(
    assistanceId,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.volunterCompletedCreatedAssistance}/$assistanceId",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> postYourFavouriteTopic(topicId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.markTopicAsFavourite}/$topicId",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> acceptRequestOnAssistance(
    assistanceId,
    data,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.acceptVoluntersRequest}/$assistanceId",
      data,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getVoluntersRequests() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      ApiUrls.getRequestOfVolunteers,
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> completeAssistanceFromOwner(assistanceId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.completeAssistanceByOwner}/$assistanceId",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> userReportPost(postId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.putMethod(
      "${ApiUrls.reportPost}/$postId",
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> createUserPost(
    String interestId,
    Map<String, dynamic> data,
    File? imageFile,
    XFile? videoFile,
    XFile? documentFile,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final normalizedInterestId = interestId.trim();
    final endpoint = normalizedInterestId.isEmpty
        ? ApiUrls.createUserPost
        : "${ApiUrls.createUserPost}/$normalizedInterestId";

    return ApiService.postMultipartWithFiles(
      endpoint,
      data,
      imageFile,
      videoFile,
      documentFile,
      token: requiredToken,
    );
  }
}
