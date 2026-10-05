import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/care_circle_repository.dart';
import 'package:ollie/CareCircle/location/care_location_controller.dart';
import 'package:ollie/Models/blog_topics_model.dart';
import 'package:ollie/Models/created_assistance_model.dart';
import 'package:ollie/Models/latest_events_model.dart';
import 'package:ollie/Models/my_groups_model.dart';
import 'package:ollie/Models/nearest_event_model.dart';
import 'package:ollie/Models/others_created_assistance_model.dart';
import 'package:ollie/Models/post_with_interest_model.dart';
import 'package:ollie/Models/volunters_request_model.dart';
import 'package:ollie/Models/your_post_model.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class PostModel {
  final String user;
  final String time;
  final String text;
  final File? image;
  final File? document;
  final List<String>? pollOptions;

  PostModel({
    required this.user,
    required this.time,
    required this.text,
    this.image,
    this.document,
    this.pollOptions,
  });
}

class CareCircleController extends GetxController {
  CareCircleController({CareCircleRepository? repository})
    : careCircleRepository = repository ?? CareCircleRepository();

  final CareCircleRepository careCircleRepository;
  static int? pendingInitialTab;
  final ScrollController interestsScrollController = ScrollController();
  var selectedTabIndex = 0.obs;
  var reachedOut = false.obs;
  var currentPage = 0.obs;
  var taskCompleted = false.obs;
  var currentYourRequestPage = 0.obs;
  var assistanceLocationErrorMessage = ''.obs;
  var groupLocationErrorMessage = ''.obs;
  static const int assistancePageLimit = 20;
  static const int groupsPageLimit = 20;
  static const int eventsPageLimit = 20;

  /// The place and radius every "nearby" list here is centred on.
  final CareLocationController careLocation = findCareLocation();

  // Paging for the location-based lists.
  int _assistancePage = 1;
  int _groupsPage = 1;
  int _eventsPage = 1;
  final assistanceHasMore = false.obs;
  final groupsHasMore = false.obs;
  final eventsHasMore = false.obs;
  final loadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (pendingInitialTab != null) {
      selectedTabIndex.value = pendingInitialTab!;
      pendingInitialTab = null;
    }
    // A new place or radius reloads the nearby lists on the open tab. The first
    // time the location resolves, a fetch is already waiting for it, so that
    // only reloads if an earlier load failed for lack of a location.
    _lastLocationKey = careLocation.queryParameters?.toString();
    ever(careLocation.version, (_) {
      final key = careLocation.queryParameters?.toString();
      final wasMissing = _lastLocationKey == null;
      final changed = key != _lastLocationKey;
      _lastLocationKey = key;
      if (changed && (!wasMissing || _loadFailedForLocation)) {
        _loadFailedForLocation = false;
        reloadNearbyLists();
      }
    });
  }

  String? _lastLocationKey;
  bool _loadFailedForLocation = false;

  /// Reloads the location-based lists for the open tab.
  Future<void> reloadNearbyLists() async {
    switch (selectedTabIndex.value) {
      case 0:
        await userFetchOthersCreatedAssitance();
      case 1:
        await fetchOthersGroups();
      case 3:
        await Future.wait([userFetchLatestEvents(), userFetchNearestEvents()]);
    }
  }

  /// Pull-to-refresh for a tab.
  Future<void> refreshTab(int index) async {
    switch (index) {
      case 0:
        await Future.wait([
          userFetchOthersCreatedAssitance(),
          userFetchCreatedAssitance(),
        ]);
      case 1:
        await Future.wait([fetchOthersGroups(), fetchYourGroups()]);
      case 2:
        await refreshInterestsTab();
      case 3:
        await Future.wait([userFetchLatestEvents(), userFetchNearestEvents()]);
    }
  }

  /// The shared location's query parameters, or null (with [setMessage] told why).
  Future<Map<String, String>?> _nearbyQuery(
    void Function(String) setMessage,
  ) async {
    await careLocation.ensureLocation();
    final query = careLocation.queryParameters;
    if (query == null) {
      _loadFailedForLocation = true;
      setMessage(
        careLocation.errorMessage.value.isNotEmpty
            ? careLocation.errorMessage.value
            : "Choose a location to see what's nearby.",
      );
    }
    return query;
  }

  @override
  void onClose() {
    interestsScrollController.dispose();
    super.onClose();
  }

  final List<String> topics = ['Fitness', 'Wellness', 'Mindfulness'];
  final List<String> images = [
    'assets/images/Frame 73.png',
    'assets/images/Frame 73.png',
    'assets/images/Frame 73.png',
  ];
  final List<String> tabs = [
    'Assistance',
    'Groups',
    'Interests',
    'Events & Activities',
  ];

  var posts = <PostModel>[].obs;

  void addPost(PostModel post) {
    posts.insert(0, post);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    if (selectedTabIndex.value == 0) {
      userFetchOthersCreatedAssitance();
      userFetchCreatedAssitance();
    } else if (selectedTabIndex.value == 1) {
      fetchOthersGroups();
      fetchYourGroups();
    } else if (selectedTabIndex.value == 2) {
      fetchPostAsPerYourInterest().then((value) {
        getInterestForPost().then((value) {
          getYourSavedPost();
        });
      });
    } else if (selectedTabIndex.value == 3) {
      userFetchLatestEvents();
      userFetchNearestEvents();
    }
  }

  Future<void> refreshInterestsTab() async {
    await fetchPostAsPerYourInterest();
    await getInterestForPost();
    await getYourSavedPost();
  }

  RxList<BlogData> blogsTopicNames = <BlogData>[].obs;
  var getBlogTopicsStatus = RequestStatus.idle.obs;
  Future<void> getInterestForPost() async {
    getBlogTopicsStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.getBlogsTopics();
    if (result['success'] == true) {
      blogsTopicNames.clear();
      final topicModel = BlogTopics.fromJson(result);
      blogsTopicNames.assignAll(topicModel.data ?? []);
      getBlogTopicsStatus.value = RequestStatus.success;
    } else {
      getBlogTopicsStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  RxList yourSavePostList = [].obs;
  var getYourSavePostStatus = RequestStatus.idle.obs;
  Future<void> getYourSavedPost() async {
    getYourSavePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.getSavedPosts();
    if (result['success'] == true) {
      yourSavePostList.clear();
      if (result['data'] != null &&
          result['data'].isNotEmpty &&
          result['data'][0].isNotEmpty) {
        yourSavePostList.value = result['data'][0];
      } else {
        // List is empty
        yourSavePostList.clear();
        appSnackbar("Info", "No saved posts found");
      }

      getYourSavePostStatus.value = RequestStatus.success;
    } else {
      getYourSavePostStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  RxList yourInterestedTopics = [].obs;
  var getYourInterestedTopicsStatus = RequestStatus.idle.obs;
  Future<void> getYourInterestTopics() async {
    getYourInterestedTopicsStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.getYourInterestedTopics();
    if (result['success'] == true) {
      yourInterestedTopics.clear();

      yourInterestedTopics.assignAll(result['data']);
      getYourInterestedTopicsStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result['message'] == "favourite topic not found") {
      yourInterestedTopics.clear();
      getYourInterestedTopicsStatus.value = RequestStatus.empty;
    } else {
      getYourInterestedTopicsStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  void reachOut(eventId) {
    reachedOut.value = true;
  }

  var interestBasePostList = <PostWithInterestData>[].obs;
  var selectedInterestPost = Rxn<PostWithInterestData>();
  var singleInterestPostStatus = RequestStatus.idle.obs;

  var interestBastePostStatus = RequestStatus.idle.obs;
  Future<void> interestBasePost(String topicId) async {
    interestBastePostStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.interestBasePostForUser(topicId);
    if (result['success'] == true && result['data'] != null) {
      interestBasePostList.clear();

      final parsed = PostWithInterest.fromJson(result);
      if (parsed.data != null) {
        interestBasePostList.addAll(parsed.data!);
        for (final post in parsed.data!.take(5)) {
          debugPrint(
            '[InterestPost] id=${post.id} postType=${post.postType} hasPoll=${post.poll != null} pollOptions=${post.poll?.options?.length ?? 0} title=${post.title}',
          );
        }
        await _hydrateMissingPolls();
      }
      interestBastePostStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result['message'] == "No posts found") {
      interestBasePostList.clear();
      interestBastePostStatus.value = RequestStatus.success;

      appSnackbar("Info", "No posts available for this topic");
    } else {
      interestBastePostStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  Future<void> _hydrateMissingPolls() async {
    for (var index = 0; index < interestBasePostList.length; index++) {
      final post = interestBasePostList[index];
      final isPoll = post.postType?.trim().toUpperCase() == 'POLL';
      final hasOptions = (post.poll?.options?.isNotEmpty ?? false);
      final isUserPost =
          post.source == 'user' || (post.userId ?? '').isNotEmpty;
      if ((!isPoll && !isUserPost) || hasOptions || (post.id ?? '').isEmpty) {
        continue;
      }

      final result = await careCircleRepository.getPollResults(post.id!);
      if (result['success'] != true || result['data'] is! Map) {
        debugPrint(
          '[InterestPost] poll hydrate failed postId=${post.id} '
          'success=${result['success']} message=${result['message']}',
        );
        continue;
      }

      final data = result['data'] as Map;
      post.poll = PostPoll.fromJson(data);
      if (isPoll) post.postType = 'POLL';
      interestBasePostList[index] = post;
      debugPrint(
        '[InterestPost] hydrated poll postId=${post.id} pollOptions=${post.poll?.options?.length ?? 0}',
      );
    }
    interestBasePostList.refresh();
  }

  Future<PostWithInterestData?> fetchSingleUserPost(String postId) async {
    singleInterestPostStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getSingleUserPost(postId);
    if (result['success'] == true && result['data'] != null) {
      final parsed = PostWithInterestData.fromJson(result['data']);
      if (!(parsed.poll?.options?.isNotEmpty ?? false)) {
        final pollResult = await careCircleRepository.getPollResults(postId);
        if (pollResult['success'] == true && pollResult['data'] is Map) {
          parsed.poll = PostPoll.fromJson(pollResult['data'] as Map);
          debugPrint(
            '[InterestPost] hydrated single poll postId=$postId pollOptions=${parsed.poll?.options?.length ?? 0}',
          );
        } else {
          debugPrint(
            '[InterestPost] single poll hydrate failed postId=$postId '
            'success=${pollResult['success']} message=${pollResult['message']}',
          );
        }
      }
      selectedInterestPost.value = parsed;
      singleInterestPostStatus.value = RequestStatus.success;
      return parsed;
    } else {
      singleInterestPostStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
      return null;
    }
  }

  Future<void> voteOnPoll({
    required String postId,
    required String optionId,
    required int postIndex,
  }) async {
    final result = await careCircleRepository.voteOnPoll(optionId);
    if (result['success'] != true) {
      appSnackbar("Error", result['message'] ?? "Unable to vote");
      return;
    }

    final data = result['data'];
    if (data is! Map ||
        postIndex < 0 ||
        postIndex >= interestBasePostList.length) {
      return;
    }

    final post = interestBasePostList[postIndex];
    final results = data['results'] is List
        ? (data['results'] as List)
              .whereType<Map>()
              .map((item) => PostPollOption.fromJson(item))
              .toList()
        : <PostPollOption>[];

    post.poll ??= PostPoll(id: data['pollId']?.toString());
    post.poll!.id = data['pollId']?.toString() ?? post.poll!.id;
    post.poll!.totalVotes = data['totalVotes'] is int
        ? data['totalVotes']
        : int.tryParse(data['totalVotes']?.toString() ?? '');
    if (results.isNotEmpty) {
      post.poll!.options = results;
      post.poll!.results = results;
    }
    interestBasePostList[postIndex] = post;
    interestBasePostList.refresh();
  }

  var likeOrUnlikePostStatus = RequestStatus.idle.obs;

  String? get currentUserId {
    if (!Get.isRegistered<UserController>()) return null;
    return Get.find<UserController>().user.value?.id;
  }

  bool isOwnUserPost(PostWithInterestData post) {
    final loggedInUserId = currentUserId;
    if (loggedInUserId != null &&
        loggedInUserId.isNotEmpty &&
        post.userId == loggedInUserId) {
      return true;
    }
    if (loggedInUserId != null &&
        loggedInUserId.isNotEmpty &&
        post.user?.id == loggedInUserId) {
      return true;
    }
    return false;
  }

  Future<void> likeOrUnlikePost(data, int index) async {
    likeOrUnlikePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.likeOrUnlikePost(data);
    if (result['success'] == true) {
      if (result["data"]["action"] == "liked") {
        interestBasePostList[index].isLikePost = true;
        interestBasePostList[index].cCount?.userpostlikes =
            (interestBasePostList[index].cCount?.userpostlikes ?? 0) + 1;
        interestBasePostList.refresh();
      } else if (result["data"]["action"] == "unliked") {
        interestBasePostList[index].isLikePost = false;
        if (interestBasePostList[index].cCount?.userpostlikes != null &&
            interestBasePostList[index].cCount!.userpostlikes! > 0) {
          interestBasePostList[index].cCount?.userpostlikes =
              (interestBasePostList[index].cCount?.userpostlikes ?? 0) - 1;
          interestBasePostList.refresh();
        }
      }
      likeOrUnlikePostStatus.value = RequestStatus.success;
    } else {
      likeOrUnlikePostStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void savePostToUpdate(int index, bool isSaved) {
    interestBasePostList[index].isSavePost = isSaved;
    interestBasePostList.refresh();
  }

  var saveAndUnsavePostStatus = RequestStatus.idle.obs;
  Future<void> savePostToggle(String postId, int index) async {
    final bool isCurrentlySaved =
        interestBasePostList[index].isSavePost == true;
    saveAndUnsavePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.saveAndUnsavePost(postId);
    if (result['success'] == true) {
      final bool isSaved = !isCurrentlySaved;
      savePostToUpdate(index, isSaved);
      await getYourSavedPost();
      appSnackbar(
        "Success",
        isSaved ? "Post saved successfully" : "Post removed from saved posts",
      );
      saveAndUnsavePostStatus.value = RequestStatus.success;
    } else {
      saveAndUnsavePostStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var postAccordingToMyInterest = <PostWithInterestData>[].obs;

  var getYourPostAsInteresStatus = RequestStatus.idle.obs;
  Future<void> fetchPostAsPerYourInterest() async {
    getYourPostAsInteresStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getYourPostAsPerYourInterest();
    if (result['success'] == true && result['data'] != null) {
      postAccordingToMyInterest.clear();

      final parsed = PostWithInterest.fromJson(result);
      if (parsed.data != null) {
        postAccordingToMyInterest.addAll(
          parsed.data!.where(_hasRenderablePostContent),
        );
      }
      getYourPostAsInteresStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result['message'] == "User has no selected interests") {
      getYourPostAsInteresStatus.value = RequestStatus.success;

      appSnackbar("No Interests", "Please select your interests to see posts.");
    } else if (result['success'] == false &&
        result['message'] == "No posts found") {
      /// Special case: no selected interests
      getYourPostAsInteresStatus.value = RequestStatus.success;

      appSnackbar("Success", "No posts found");
    } else {
      getYourPostAsInteresStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  bool _hasRenderablePostContent(PostWithInterestData post) {
    final hasMedia =
        (post.image ?? '').trim().isNotEmpty ||
        (post.images?.isNotEmpty ?? false) ||
        (post.videoUrl ?? '').trim().isNotEmpty;
    final hasPoll = post.poll?.options?.isNotEmpty ?? false;
    final hasText =
        (post.title ?? '').trim().isNotEmpty &&
        ((post.content ?? '').trim().isNotEmpty ||
            post.postType?.trim().toUpperCase() == 'TEXT');
    return hasMedia || hasPoll || hasText;
  }

  var myGroups = <MyGroupsData>[].obs;

  var getYourGroupsStatus = RequestStatus.idle.obs;
  Future<void> fetchYourGroups() async {
    getYourGroupsStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getYourGroups();
    if (result['success'] == true && result['data'] != null) {
      myGroups.clear();

      final parsed = MyGroupsModel.fromJson(result);
      if (parsed.data != null) {
        myGroups.addAll(parsed.data!);
      }
      getYourGroupsStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result['message'] == "Group chat rooms not found") {
      myGroups.clear();
      getYourGroupsStatus.value = RequestStatus.success;
    } else {
      getYourGroupsStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var othersGroups = <MyGroupsData>[].obs;

  var getOthersGroupsStatus = RequestStatus.idle.obs;

  /// Groups near the shared location that the user hasn't joined, nearest first.
  /// [loadMore] appends the next page.
  Future<void> fetchOthersGroups({bool loadMore = false}) async {
    if (loadMore && (!groupsHasMore.value || loadingMore.value)) return;
    if (loadMore) {
      loadingMore.value = true;
    } else {
      getOthersGroupsStatus.value = RequestStatus.loading;
      groupLocationErrorMessage.value = '';
    }

    try {
      final query = await _nearbyQuery(
        (m) => groupLocationErrorMessage.value = m,
      );
      if (query == null) {
        othersGroups.clear();
        groupsHasMore.value = false;
        getOthersGroupsStatus.value = RequestStatus.error;
        return;
      }

      final page = loadMore ? _groupsPage + 1 : 1;
      final result = await careCircleRepository.getOthersGroups(
        location: query,
        page: page,
        limit: groupsPageLimit,
      );
      if (result['success'] == true) {
        final groups = result['data'] == null
            ? <MyGroupsData>[]
            : (MyGroupsModel.fromJson(result).data ?? <MyGroupsData>[]);
        if (loadMore) {
          othersGroups.addAll(groups);
        } else {
          othersGroups.assignAll(groups);
        }
        _groupsPage = page;
        groupsHasMore.value = groups.length == groupsPageLimit;
        getOthersGroupsStatus.value = RequestStatus.success;
      } else if (!loadMore) {
        othersGroups.clear();
        groupsHasMore.value = false;
        groupLocationErrorMessage.value =
            result['message']?.toString() ?? "Unable to load nearby groups";
        getOthersGroupsStatus.value = RequestStatus.error;
      }
    } finally {
      loadingMore.value = false;
    }
  }

  var postLoadingStatus = <RxBool>[].obs;
  var postReachOutOnAssistanceStatus = RequestStatus.idle.obs;

  void _markOtherAssistanceRequestSent(int index) {
    if (index < 0 || index >= othersCreatedAssistance.length) return;

    othersCreatedAssistance[index].status = "VolunteerRequestSent";
    othersCreatedAssistance.refresh();
  }

  Future<void> reachOutOnAssistance(String assistancId, int index) async {
    postReachOutOnAssistanceStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.reachOutOnAssistanceRequest(
      assistancId,
    );
    if (result['success'] == true) {
      _markOtherAssistanceRequestSent(index);
      await userFetchOthersCreatedAssitance();
      postReachOutOnAssistanceStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
    } else {
      final message = (result['message'] ?? "Something went wrong").toString();
      if (message.toLowerCase().contains("already sent a request")) {
        _markOtherAssistanceRequestSent(index);
        postReachOutOnAssistanceStatus.value = RequestStatus.success;
        appSnackbar("Info", "Request already sent");
        return;
      }

      postReachOutOnAssistanceStatus.value = RequestStatus.error;
      appSnackbar("Error", message);
    }
  }

  Future<void> completeAssistanceByVolunter(String assistancId) async {
    postReachOutOnAssistanceStatus.value = RequestStatus.loading;

    final result = await careCircleRepository
        .assistanceRequestCompleteByVolunter(assistancId);
    if (result['success'] == true) {
      await Future.wait([
        userFetchOthersCreatedAssitance(),
        userFetchCreatedAssitance(),
      ]);
      postReachOutOnAssistanceStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
    } else {
      postReachOutOnAssistanceStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  Future<void> markTopicAsFavourite(String topicId) async {
    final result = await careCircleRepository.postYourFavouriteTopic(topicId);
    if (result['success'] == true) {
      appSnackbar("Success", result['message'] ?? "");
    } else {
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var acceptVolunterRequestStatus = RequestStatus.idle.obs;
  Future<void> acceptrequestOnAssistance(
    String assistancId,
    data,
    int index,
  ) async {
    acceptVolunterRequestStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.acceptRequestOnAssistance(
      assistancId,
      data,
    );
    if (result['success'] == true) {
      final postId = voluntersRequestsList[index].postId ?? "";
      await Future.wait([
        userFetchCreatedAssitance(),
        userFetchOthersCreatedAssitance(),
        if (postId.isNotEmpty) getVoluntersRequestOnEachAssistance(postId),
      ]);
      acceptVolunterRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
    } else {
      acceptVolunterRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void changePage(int index) {
    currentPage.value = index;
  }

  var completeTaskOwnerRequestStatus = RequestStatus.idle.obs;
  Future<void> completeTaskByOwner(String assistancId, {String? postId}) async {
    completeTaskOwnerRequestStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.completeAssistanceFromOwner(
      assistancId,
    );
    if (result['success'] == true) {
      await Future.wait([
        userFetchCreatedAssitance(),
        userFetchOthersCreatedAssitance(),
        if (postId != null && postId.isNotEmpty)
          getVoluntersRequestOnEachAssistance(postId),
      ]);
      completeTaskOwnerRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
    } else if (result['success'] == false &&
        result['message'] == "action is required") {
      appSnackbar("Error", "Your Volunter need to Complete it First");
    } else {
      completeTaskOwnerRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
    taskCompleted.value = true;
  }

  void changeYourRequestPage(int page) {
    currentYourRequestPage.value = page;
  }

  var latestEvent = LatestEventsData().obs;

  var getLatestEventStatus = RequestStatus.idle.obs;

  /// The next upcoming event near the shared location.
  Future<void> userFetchLatestEvents() async {
    getLatestEventStatus.value = RequestStatus.loading;
    await careLocation.ensureLocation();
    final result = await careCircleRepository.getLatesEvent(
      location: careLocation.queryParameters,
    );
    if (result['success'] == true) {
      final data = result['data'];
      latestEvent.value = data is Map<String, dynamic>
          ? LatestEventsData.fromJson(data)
          : LatestEventsData();
      getLatestEventStatus.value = RequestStatus.success;
    } else {
      latestEvent.value = LatestEventsData();
      getLatestEventStatus.value = RequestStatus.error;
    }
  }

  String formatDate(String dateString) {
    if (dateString.isEmpty) {
      return "";
    }

    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('d MMM').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  /// "Address, City, Country · 3.2 km away" (distance only when known).
  String eventLocationLabel({
    String? address,
    String? city,
    String? country,
    double? distanceKm,
  }) {
    final place = [address, city, country]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(', ');
    if (distanceKm == null) return place;
    final distance = '${distanceKm.toStringAsFixed(1)} km away';
    return place.isEmpty ? distance : '$place · $distance';
  }

  String formatDateAndTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    return DateFormat('EEEE h:mm a').format(dateTime);
  }

  var markAsGoingOnEventStatus = RequestStatus.idle.obs;
  Future<void> markAsGoingOnEvents(String eventId) async {
    markAsGoingOnEventStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.onEventMarkAsGoing(eventId);
    if (result['success'] == true) {
      _setGoing(eventId, true);
      markAsGoingOnEventStatus.value = RequestStatus.success;
      appSnackbar("Success", result["message"]);
    } else {
      markAsGoingOnEventStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  /// Undoes "going" for an event.
  Future<void> unmarkGoingOnEvent(String eventId) async {
    markAsGoingOnEventStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.unmarkGoingOnEvent(eventId);
    if (result['success'] == true) {
      _setGoing(eventId, false);
      markAsGoingOnEventStatus.value = RequestStatus.success;
      appSnackbar("Done", result["message"] ?? "You're no longer going.");
    } else {
      markAsGoingOnEventStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void _setGoing(String eventId, bool going) {
    if (latestEvent.value.id == eventId) {
      latestEvent.update((val) {
        val?.isMark = going;
        final count = val?.eventParticipant ?? 0;
        val?.eventParticipant = going ? count + 1 : (count > 0 ? count - 1 : 0);
      });
    }
    final index = nearestEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = nearestEvents[index];
      event.isMark = going;
      final count = event.eventParticipant ?? 0;
      event.eventParticipant = going ? count + 1 : (count > 0 ? count - 1 : 0);
      nearestEvents[index] = event;
      nearestEvents.refresh();
    }
  }

  var nearestEvents = <NearestEventsData>[].obs;

  var getEventNearYouStatus = RequestStatus.idle.obs;

  /// Upcoming events near the shared location, soonest first. [loadMore]
  /// appends the next page.
  Future<void> userFetchNearestEvents({bool loadMore = false}) async {
    if (loadMore && (!eventsHasMore.value || loadingMore.value)) return;
    if (loadMore) {
      loadingMore.value = true;
    } else {
      getEventNearYouStatus.value = RequestStatus.loading;
    }
    try {
      await careLocation.ensureLocation();
      final page = loadMore ? _eventsPage + 1 : 1;
      final result = await careCircleRepository.getNearesEvent(
        location: careLocation.queryParameters,
        page: page,
        limit: eventsPageLimit,
      );
      if (result['success'] == true) {
        final List<dynamic> eventList = result['data'] is List
            ? result['data']
            : [];
        final events = eventList
            .map((eventJson) => NearestEventsData.fromJson(eventJson))
            .toList();
        if (loadMore) {
          nearestEvents.addAll(events);
        } else {
          nearestEvents.assignAll(events);
        }
        _eventsPage = page;
        eventsHasMore.value = events.length == eventsPageLimit;
        getEventNearYouStatus.value = RequestStatus.success;
      } else if (!loadMore) {
        nearestEvents.clear();
        eventsHasMore.value = false;
        getEventNearYouStatus.value = RequestStatus.error;
      }
    } finally {
      loadingMore.value = false;
    }
  }

  var createdAssistance = <CreatedAssistanceData>[].obs;

  var getCrteatedAssistanceStatus = RequestStatus.idle.obs;
  Future<void> userFetchCreatedAssitance() async {
    getCrteatedAssistanceStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getCreatedAssistance();
    if (result['success'] == true) {
      List<dynamic> createdAssistanceList = result['data'] ?? [];
      createdAssistance.value = createdAssistanceList
          .map(
            (assistancetJson) =>
                CreatedAssistanceData.fromJson(assistancetJson),
          )
          .toList();
      getCrteatedAssistanceStatus.value = RequestStatus.success;
    } else {
      getCrteatedAssistanceStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var othersCreatedAssistance = <OthersCreatedAssistance>[].obs;

  var getOthersCrteatedAssistanceStatus = RequestStatus.idle.obs;

  /// Help requests from others near the shared location, nearest first.
  /// [loadMore] appends the next page.
  Future<void> userFetchOthersCreatedAssitance({bool loadMore = false}) async {
    if (loadMore && (!assistanceHasMore.value || loadingMore.value)) return;
    final userController = Get.put(UserController());
    final String loggedInUserId = userController.user.value?.id ?? '';
    if (loadMore) {
      loadingMore.value = true;
    } else {
      getOthersCrteatedAssistanceStatus.value = RequestStatus.loading;
      assistanceLocationErrorMessage.value = '';
    }

    try {
      final query = await _nearbyQuery(
        (m) => assistanceLocationErrorMessage.value = m,
      );
      if (query == null) {
        othersCreatedAssistance.clear();
        postLoadingStatus.clear();
        assistanceHasMore.value = false;
        getOthersCrteatedAssistanceStatus.value = RequestStatus.error;
        return;
      }

      final page = loadMore ? _assistancePage + 1 : 1;
      final result = await careCircleRepository
          .getOthersCreatedAssistance(
            location: query,
            page: page,
            limit: assistancePageLimit,
          )
          .timeout(const Duration(seconds: 15));
      if (result['success'] == true) {
        final List<dynamic> rows = result['data'] is List ? result['data'] : [];
        // The list includes the user's own requests; they're shown separately.
        final requests = rows
            .map((json) => OthersCreatedAssistance.fromJson(json))
            .where((request) => request.userId != loggedInUserId)
            .toList();

        if (loadMore) {
          othersCreatedAssistance.addAll(requests);
          postLoadingStatus.addAll(requests.map((_) => false.obs));
        } else {
          othersCreatedAssistance.assignAll(requests);
          postLoadingStatus.value = List.generate(
            requests.length,
            (_) => false.obs,
          );
        }
        _assistancePage = page;
        assistanceHasMore.value = rows.length == assistancePageLimit;
        getOthersCrteatedAssistanceStatus.value = RequestStatus.success;
      } else if (!loadMore) {
        othersCreatedAssistance.clear();
        postLoadingStatus.clear();
        assistanceHasMore.value = false;
        assistanceLocationErrorMessage.value =
            result['message']?.toString() ?? "Unable to load nearby requests.";
        getOthersCrteatedAssistanceStatus.value = RequestStatus.error;
      }
    } catch (_) {
      if (!loadMore) {
        othersCreatedAssistance.clear();
        postLoadingStatus.clear();
        assistanceLocationErrorMessage.value =
            "Unable to load nearby requests. Pull down to try again.";
        getOthersCrteatedAssistanceStatus.value = RequestStatus.error;
      }
    } finally {
      loadingMore.value = false;
    }
  }

  var voluntersRequestLoadingStatus = <RxBool>[].obs;
  var getVoluntersRequesttatus = RequestStatus.idle.obs;
  var voluntersRequestsList = <VolunterRequestsData>[].obs;

  // File management variables
  var imageFile = Rx<File?>(null);
  var postImages = <XFile>[].obs;
  var videoFile = Rx<XFile?>(null);
  var documentFile = Rx<XFile?>(null);

  // File management methods
  void setImageFile(File? file) {
    imageFile.value = file;
  }

  void setVideoFile(XFile? file) {
    videoFile.value = file;
  }

  void setDocumentFile(XFile? file) {
    documentFile.value = file;
  }

  void clearImageFile() {
    imageFile.value = null;
    postImages.clear();
  }

  void clearVideoFile() {
    videoFile.value = null;
  }

  void clearDocumentFile() {
    documentFile.value = null;
  }

  var createPostStatus = RequestStatus.idle.obs;

  bool _hasHashtag(String value) {
    return RegExp(r'(^|\s)#[A-Za-z0-9_]+').hasMatch(value);
  }

  String _hashtagFromTitle(String title) {
    final words = RegExp(r'[A-Za-z0-9]+')
        .allMatches(title)
        .map((match) => match.group(0) ?? '')
        .where((word) => word.isNotEmpty);
    final firstWord = words.isEmpty ? 'post' : words.first;
    return '#$firstWord';
  }

  Future<void> createUserPost(
    String interestId,
    String postTitle,
    String? postContent,
    String postType,
    List<XFile> images,
    XFile? videoFile,
    String? pollQuestion,
    List<String> pollOptions,
    DateTime? pollEndsAt,
  ) async {
    createPostStatus.value = RequestStatus.loading;

    final normalizedInterestId = interestId.trim();
    final title = postTitle.trim();
    final rawContent = postContent?.trim() ?? '';
    var content = rawContent;
    var titleForRequest = title;
    final hasCategory = normalizedInterestId.isNotEmpty;
    final hasHashtag =
        _hasHashtag(title) ||
        _hasHashtag(rawContent) ||
        (pollQuestion != null && _hasHashtag(pollQuestion));

    if (!hasHashtag) {
      final fallbackHashtag = _hashtagFromTitle(title);
      content = content.isEmpty ? fallbackHashtag : '$content $fallbackHashtag';
      titleForRequest = '$title $fallbackHashtag';
    }
    final normalizedPollQuestion = pollQuestion?.trim() ?? '';
    final hasPoll =
        normalizedPollQuestion.isNotEmpty && pollOptions.length >= 2;

    final data = <String, dynamic>{
      'postTitle': titleForRequest,
      'postType': postType,
      if (content.isNotEmpty) 'postContent': content,
      if (hasCategory) 'categoryId': normalizedInterestId,
      if (hasPoll) ...{
        'pollQuestion': normalizedPollQuestion,
        'pollOptions': pollOptions,
        if (pollEndsAt != null)
          'pollEndsAt': pollEndsAt.toUtc().toIso8601String(),
      },
    };

    final result = await careCircleRepository.createUserPost(
      data,
      images,
      videoFile,
    );

    if (result['success'] == true) {
      createPostStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Post created successfully");

      // Refresh the posts list
      if (interestId.trim().isNotEmpty) {
        await interestBasePost(interestId);
      }
    } else {
      createPostStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Failed to create post");
    }
  }

  Future<void> getVoluntersRequestOnEachAssistance(String assistanceId) async {
    getVoluntersRequesttatus.value = RequestStatus.loading;

    final result = await careCircleRepository.getVoluntersRequests();

    if (result['success'] == true) {
      List<dynamic> voluntersRequestList = result['data'] ?? [];

      // Filter the list based on the assistanceId
      List<VolunterRequestsData> receivedVoluntersList = voluntersRequestList
          .where((voluntersJson) {
            final voluntersResponse = VolunterRequestsData.fromJson(
              voluntersJson,
            );
            return voluntersResponse.postId == assistanceId;
          })
          .map(
            (assistancetJson) => VolunterRequestsData.fromJson(assistancetJson),
          )
          .toList();

      // Initialize the loading status for each volunteer request AFTER filtering
      voluntersRequestLoadingStatus.value = List.generate(
        receivedVoluntersList.length,
        (_) => true.obs,
      );

      // Update the list of volunteer requests
      voluntersRequestsList.value = receivedVoluntersList;

      // Set loading status to false after successfully fetching the data
      for (int i = 0; i < voluntersRequestsList.length; i++) {
        voluntersRequestLoadingStatus[i].value = false;
      }

      getVoluntersRequesttatus.value = RequestStatus.success;
    } else {
      getVoluntersRequesttatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  String statusLabelForOtherAssistance(String? status) {
    switch (status) {
      case "NoRequest":
        return "Reach Out";
      case "VolunteerRequestSent":
        return "Request Sent";
      case "ReachOut":
        return "Selected / In Progress";
      case "MarkAsCompleted":
        return "Waiting Owner Confirmation";
      case "TaskCompleted":
        return "Completed";
      default:
        return "Reach Out";
    }
  }

  String statusLabelForOwnerAssistance(String? status) {
    switch (status) {
      case "NoRequest":
        return "No Request Received";
      case "VolunteerRequestSent":
        return "Volunteer Request Received";
      case "ReachOut":
        return "Selected / In Progress";
      case "MarkAsCompleted":
        return "Confirm Completed";
      case "TaskCompleted":
        return "Completed";
      default:
        return "No Request Received";
    }
  }

  String volunteerActionLabel(String? status) {
    switch (status) {
      case "ReachOut":
        return "Unselect";
      case "MarkAsCompleted":
        return "Confirm Completed";
      case "TaskCompleted":
        return "Completed";
      default:
        return "Select";
    }
  }

  Color volunteerActionBackgroundColor(String? status) {
    switch (status) {
      case "ReachOut":
        return const Color(0xFFF4BD2A);
      case "MarkAsCompleted":
        return Colors.green;
      case "TaskCompleted":
        return const Color(0xFFB4E197);
      default:
        return Colors.white;
    }
  }

  Color volunteerActionTextColor(String? status) {
    switch (status) {
      case "VolunteerRequestSent":
        return const Color(0xFFF4BD2A);
      case "ReachOut":
      case "MarkAsCompleted":
      case "TaskCompleted":
        return Colors.white;
      default:
        return const Color(0xFFF4BD2A);
    }
  }

  bool canTapVolunteerAction(String? status) {
    return status != "TaskCompleted";
  }

  bool canVolunteerComplete(String? status) {
    return status == "ReachOut";
  }

  bool canOwnerConfirmCompletion(String? status) {
    return status == "MarkAsCompleted";
  }

  var yourPostList = <YourPostModelData>[].obs;

  var fetchingYourPostStatus = RequestStatus.idle.obs;
  Future<void> yourCreatedPost() async {
    fetchingYourPostStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.createdPostByUser();
    if (result['success'] == true && result['data'] != null) {
      yourPostList.clear();

      final parsed = YourPostModel.fromJson(result);
      if (parsed.data != null) {
        yourPostList.addAll(parsed.data!);
      }
      fetchingYourPostStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result['message'] == "No posts found") {
      yourPostList.clear();
      fetchingYourPostStatus.value = RequestStatus.success;

      appSnackbar("Info", "No posts available for this topic");
    } else {
      interestBastePostStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var reportPostRequestStatus = RequestStatus.idle.obs;
  Future<void> postReport(String postId) async {
    reportPostRequestStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.userReportPost(postId);
    if (result['success'] == true) {
      reportPostRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
    } else {
      reportPostRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
    taskCompleted.value = true;
  }

  var deleteUserPostStatus = RequestStatus.idle.obs;
  Future<bool> deleteUserPost(String postId, {int? index}) async {
    if (postId.trim().isEmpty) return false;
    deleteUserPostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.deleteUserPost(postId);
    if (result['success'] == true) {
      if (index != null &&
          index >= 0 &&
          index < interestBasePostList.length &&
          interestBasePostList[index].id == postId) {
        interestBasePostList.removeAt(index);
      } else {
        interestBasePostList.removeWhere((post) => post.id == postId);
      }
      yourSavePostList.removeWhere((item) {
        if (item is! Map) return false;
        return item['id'] == postId ||
            (item['userPost'] is Map && item['userPost']['id'] == postId);
      });
      yourPostList.removeWhere((post) => post.id == postId);
      deleteUserPostStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Post deleted successfully");
      return true;
    }

    deleteUserPostStatus.value = RequestStatus.error;
    appSnackbar("Error", result['message'] ?? "Something went wrong");
    return false;
  }
}
//likePost

// var headers = {
//   'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE2OWZlMjJlLTU5YTktNDg3OS1iMjhiLTQzZTBlOGYyNDU1NSIsInVzZXJUeXBlIjoiVVNFUiIsImlhdCI6MTc1NjM5NDYxOSwiZXhwIjoxNzU2NDgxMDE5fQ.XWHwr5YrAIVt4KtHp-9jpz3n2EhmhUa1MWIgGesRrCQ',
//   'Content-Type': 'application/json'
// };
// var request = http.Request('POST', Uri.parse('http://localhost:3000/api/v1/user/post/likeAndUnlikePost'));
// request.body = json.encode({
//   "type": "posts",
//   "postId": "610fc312-60bf-4848-967a-bace92a1ed19"
// });
// request.headers.addAll(headers);

// http.StreamedResponse response = await request.send();

// if (response.statusCode == 200) {
//   print(await response.stream.bytesToString());
// }
// else {
//   print(response.reasonPhrase);
// }

//commentpost
// var headers = {
//   'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjE2OWZlMjJlLTU5YTktNDg3OS1iMjhiLTQzZTBlOGYyNDU1NSIsInVzZXJUeXBlIjoiVVNFUiIsImlhdCI6MTc1NjM5NDYxOSwiZXhwIjoxNzU2NDgxMDE5fQ.XWHwr5YrAIVt4KtHp-9jpz3n2EhmhUa1MWIgGesRrCQ',
//   'Content-Type': 'application/json'
// };
// var request = http.Request('POST', Uri.parse('http://localhost:3000/api/v1/user/post/comment'));
// request.body = json.encode({
//   "comment": "first comment",
//   "type": "posts",
//   "postId": "610fc312-60bf-4848-967a-bace92a1ed19"
// });
// request.headers.addAll(headers);

// http.StreamedResponse response = await request.send();

// if (response.statusCode == 200) {
//   print(await response.stream.bytesToString());
// }
// else {
//   print(response.reasonPhrase);
// }
