import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollie/api_service.dart';
import 'package:ollie/app_urls.dart';
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

  Future<Map<String, dynamic>> voteOnPoll(String pollOptionId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.postMethod(
      "${ApiUrls.voteOnPoll}/$pollOptionId",
      {},
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getPollResults(String postId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(
      "${ApiUrls.getPollResults}/$postId",
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

  /// Groups near [location] (CareLocationController.queryParameters) that the
  /// user hasn't joined.
  Future<Map<String, dynamic>> getOthersGroups({
    required Map<String, String> location,
    int page = 1,
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    final queryParameters = <String, String>{
      ...location,
      'page': '$page',
      'limit': '$limit',
      'excludeJoined': 'true',
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

  /// The next upcoming event near [location].
  Future<Map<String, dynamic>> getLatesEvent({
    Map<String, String>? location,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final query = location == null
        ? ''
        : '?${Uri(queryParameters: location).query}';

    return ApiService.getMethod(
      '${ApiUrls.getLatestEvent}$query',
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> unmarkGoingOnEvent(String eventId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.deleteMethod(
      "${ApiUrls.unmarkGoingOnEvent}/$eventId",
      token: requiredToken,
    );
  }

  /// Pins for the explore map around [location].
  Future<Map<String, dynamic>> exploreCareCircle({
    required Map<String, String> location,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.getMethod(
      '${ApiUrls.careCircleExplore}?${Uri(queryParameters: location).query}',
      token: requiredToken,
    );
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

  /// Upcoming events near [location], soonest first.
  Future<Map<String, dynamic>> getNearesEvent({
    Map<String, String>? location,
    int page = 1,
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    final query = Uri(
      queryParameters: {...?location, 'page': '$page', 'limit': '$limit'},
    ).query;

    return ApiService.getMethod(
      '${ApiUrls.getNearesEvent}?$query',
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> getCreatedAssistance() async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.getMethod(
      ApiUrls.getcreatedAssistance,
      token: requiredToken,
    );
  }

  /// Help requests near [location], nearest first.
  Future<Map<String, dynamic>> getOthersCreatedAssistance({
    required Map<String, String> location,
    int page = 1,
    int limit = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    final queryParameters = <String, String>{
      ...location,
      'page': page.toString(),
      'limit': limit.toString(),
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

  Future<Map<String, dynamic>> deleteUserPost(String postId) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');
    return ApiService.deleteMethod(
      "${ApiUrls.deleteUserPost}/$postId",
      token: requiredToken,
    );
  }

  Future<Map<String, dynamic>> createUserPost(
    Map<String, dynamic> data,
    List<XFile> images,
    XFile? videoFile,
  ) async {
    final storage = FlutterSecureStorage();
    final requiredToken = await storage.read(key: 'userToken');

    return ApiService.postMultipartCreateUserPost(
      ApiUrls.createUserPost,
      data,
      images: images,
      video: videoFile,
      token: requiredToken,
    );
  }
}
