import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';
import 'dart:io';

class CareCircleRepository {
  Future<Map<String, dynamic>> saveAndUnsavePost(id) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.saveBlog}/$id", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> likeOrUnlikePost(data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(ApiUrls.postLikeOrUnlike, data, token: requiredToken);
  }

  Future<Map<String, dynamic>> interestBasePostForUser(String interestId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod("${ApiUrls.interestBaseMultiplePost}/$interestId", token: requiredToken);
  }

  Future<Map<String, dynamic>> createdPostByUser() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.onlyYourPost, token: requiredToken);
  }

  Future<Map<String, dynamic>> getYourPostAsPerYourInterest() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.postOnYourInteres, token: requiredToken);
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
    return ApiService.getMethod(ApiUrls.getYourInterestedTopics, token: requiredToken);
  }

  Future<Map<String, dynamic>> getOthersGroups() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getOthersGroup, token: requiredToken);
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
    return ApiService.putMethod("${ApiUrls.markAsGoingOnEvent}/$eventId", data: {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> getNearesEvent() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getNearesEvent, token: requiredToken);
  }

  Future<Map<String, dynamic>> getCreatedAssistance() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getcreatedAssistance, token: requiredToken);
  }

  Future<Map<String, dynamic>> getOthersCreatedAssistance() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getOthersCreatedAssistance, token: requiredToken);
  }

  Future<Map<String, dynamic>> reachOutOnAssistanceRequest(assistanceId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.reachOnOthersCreatedAssistance}/$assistanceId", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> assistanceRequestCompleteByVolunter(assistanceId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.volunterCompletedCreatedAssistance}/$assistanceId", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> postYourFavouriteTopic(topicId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.markTopicAsFavourite}/$topicId", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> acceptRequestOnAssistance(assistanceId, data) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.acceptVoluntersRequest}/$assistanceId", data, token: requiredToken);
  }

  Future<Map<String, dynamic>> getVoluntersRequests() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(ApiUrls.getRequestOfVolunteers, token: requiredToken);
  }

  Future<Map<String, dynamic>> completeAssistanceFromOwner(assistanceId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod("${ApiUrls.completeAssistanceByOwner}/$assistanceId", {}, token: requiredToken);
  }

  Future<Map<String, dynamic>> userReportPost(postId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.putMethod("${ApiUrls.reportPost}/$postId", token: requiredToken);
  }

  Future<Map<String, dynamic>> createUserPost(String interestId, Map<String, dynamic> data, File? imageFile, File? videoFile) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.postMultipartWithFiles("${ApiUrls.createUserPost}/$interestId", data, imageFile, videoFile, token: requiredToken);
  }
}
