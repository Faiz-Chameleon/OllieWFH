import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/care_circle_repository.dart';
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
  final CareCircleRepository careCircleRepository = CareCircleRepository();
  static int? pendingInitialTab;
  final ScrollController interestsScrollController = ScrollController();
  var selectedTabIndex = 0.obs;
  var reachedOut = false.obs;
  var currentPage = 0.obs;
  var taskCompleted = false.obs;
  var currentYourRequestPage = 0.obs;
  var assistanceFilterEnabled = false.obs;
  var assistanceFilterRadiusKm = 3.0.obs;
  var assistanceFilterLoading = false.obs;
  var assistanceFilterLocation = Rxn<LatLng>();
  var assistanceLocationErrorMessage = ''.obs;
  static const int assistancePageLimit = 20;

  @override
  void onInit() {
    super.onInit();
    if (pendingInitialTab != null) {
      selectedTabIndex.value = pendingInitialTab!;
      pendingInitialTab = null;
    }
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
      userFetchOthersCreatedAssitance().then((value) {
        userFetchCreatedAssitance();
      });
    } else if (selectedTabIndex.value == 1) {
      fetchOthersGroups().then((value) {
        fetchYourGroups();
      });
    } else if (selectedTabIndex.value == 2) {
      fetchPostAsPerYourInterest().then((value) {
        getInterestForPost().then((value) {
          getYourSavedPost();
        });
      });
    } else if (selectedTabIndex.value == 3) {
      userFetchLatestEvents().then((value) {
        userFetchNearestEvents();
      });
    }
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

  Future<PostWithInterestData?> fetchSingleUserPost(String postId) async {
    singleInterestPostStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getSingleUserPost(postId);
    if (result['success'] == true && result['data'] != null) {
      final parsed = PostWithInterestData.fromJson(result['data']);
      selectedInterestPost.value = parsed;
      singleInterestPostStatus.value = RequestStatus.success;
      return parsed;
    } else {
      singleInterestPostStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
      return null;
    }
  }

  var likeOrUnlikePostStatus = RequestStatus.idle.obs;
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
      myGroups.clear();

      final parsed = PostWithInterest.fromJson(result);
      if (parsed.data != null) {
        postAccordingToMyInterest.addAll(parsed.data!);
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
  Future<void> fetchOthersGroups() async {
    final UserController userController = Get.find<UserController>();
    getOthersGroupsStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getOthersGroups();
    if (result['success'] == true && result['data'] != null) {
      othersGroups.clear();

      final parsed = MyGroupsModel.fromJson(result);
      if (parsed.data != null) {
        for (final group in parsed.data!) {
          bool isParticipant = false;

          for (var user in group.participants?.users ?? []) {
            if (user.id == userController.user.value?.id) {
              isParticipant = true;
              break;
            }
          }

          if (!isParticipant) {
            othersGroups.add(group);
          }
        }
      }
      getOthersGroupsStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result["message"] == 'No featured groups found') {
      othersGroups.clear();
      getOthersGroupsStatus.value = RequestStatus.success;
    } else {
      getOthersGroupsStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
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
  Future<void> userFetchLatestEvents() async {
    getLatestEventStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getLatesEvent();
    if (result['success'] == true) {
      latestEvent.value = LatestEventsData.fromJson(result['data']);
      getLatestEventStatus.value = RequestStatus.success;
    } else if (result['success'] == false &&
        result["message"] ==
            "Latest event not found or user is not marked as participating") {
      getLatestEventStatus.value = RequestStatus
          .success; // You can set it to success because there is no event but not an error.
      latestEvent.value = LatestEventsData();
    } else {
      getLatestEventStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
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

  String formatDateAndTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    return DateFormat('EEEE h:mm a').format(dateTime);
  }

  var markAsGoingOnEventStatus = RequestStatus.idle.obs;
  Future<void> markAsGoingOnEvents(String eventId) async {
    markAsGoingOnEventStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.onEventMarkAsGoing(eventId);
    if (result['success'] == true) {
      latestEvent.update((val) {
        val?.isMark = true;
      });
      markAsGoingOnEventStatus.value = RequestStatus.success;
      appSnackbar("Success", result["message"]);
    } else {
      markAsGoingOnEventStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var nearestEvents = <NearestEventsData>[].obs;

  var getEventNearYouStatus = RequestStatus.idle.obs;
  Future<void> userFetchNearestEvents() async {
    getEventNearYouStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getNearesEvent();
    if (result['success'] == true) {
      List<dynamic> eventList = result['data'] ?? [];
      nearestEvents.value = eventList
          .map((eventJson) => NearestEventsData.fromJson(eventJson))
          .toList();
      getEventNearYouStatus.value = RequestStatus.success;
    } else {
      getEventNearYouStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
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
  Future<void> userFetchOthersCreatedAssitance({int page = 1}) async {
    final userController = Get.put(UserController());
    final String loggedInUserId = userController.user.value?.id ?? '';
    getOthersCrteatedAssistanceStatus.value = RequestStatus.loading;

    final hasLocation = await loadAssistanceFilterCurrentLocation(
      showSnackbars: false,
    );
    final LatLng? activeLocation = assistanceFilterLocation.value;
    if (!hasLocation || activeLocation == null) {
      othersCreatedAssistance.clear();
      postLoadingStatus.clear();
      assistanceLocationErrorMessage.value =
          "Location permission is required to load nearby assistance.";
      getOthersCrteatedAssistanceStatus.value = RequestStatus.error;
      return;
    }

    final result = await careCircleRepository.getOthersCreatedAssistance(
      page: page,
      limit: assistancePageLimit,
      latitude: activeLocation.latitude,
      longitude: activeLocation.longitude,
      radiusKm: assistanceFilterEnabled.value
          ? assistanceFilterRadiusKm.value
          : null,
    );
    if (result['success'] == true) {
      List<dynamic> othersCreatedAssistanceList = result['data'] ?? [];
      List<OthersCreatedAssistance> filteredList = othersCreatedAssistanceList
          .where((assistancetJson) {
            final assistance = OthersCreatedAssistance.fromJson(
              assistancetJson,
            );
            return assistance.userId != loggedInUserId;
          })
          .map(
            (assistancetJson) =>
                OthersCreatedAssistance.fromJson(assistancetJson),
          )
          .toList();

      othersCreatedAssistance.value = filteredList;
      postLoadingStatus.value = List.generate(
        filteredList.length,
        (_) => false.obs,
      );
      assistanceLocationErrorMessage.value = '';
      getOthersCrteatedAssistanceStatus.value = RequestStatus.success;
    } else {
      getOthersCrteatedAssistanceStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  Future<bool> loadAssistanceFilterCurrentLocation({
    bool showSnackbars = true,
  }) async {
    assistanceFilterLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        assistanceLocationErrorMessage.value =
            "Turn on location services to load nearby assistance.";
        if (showSnackbars) {
          appSnackbar(
            "Location Disabled",
            "Please enable location services to load nearby assistance.",
          );
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        assistanceLocationErrorMessage.value =
            "Location permission is required to load nearby assistance.";
        if (showSnackbars) {
          appSnackbar(
            "Permission Required",
            "Location permission is needed to load nearby assistance.",
          );
        }
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      assistanceFilterLocation.value = LatLng(
        position.latitude,
        position.longitude,
      );
      assistanceLocationErrorMessage.value = '';
      return true;
    } catch (e) {
      assistanceLocationErrorMessage.value =
          "Unable to get your current location. Nearby assistance cannot be loaded.";
      if (showSnackbars) {
        appSnackbar("Error", "Unable to fetch current location.");
      }
      return false;
    } finally {
      assistanceFilterLoading.value = false;
    }
  }

  Future<void> applyAssistanceNearbyFilter({double? radiusKm}) async {
    if (radiusKm != null) {
      assistanceFilterRadiusKm.value = radiusKm;
    }

    if (assistanceFilterLocation.value == null) {
      await loadAssistanceFilterCurrentLocation();
    }

    if (assistanceFilterLocation.value == null) {
      return;
    }

    assistanceFilterEnabled.value = true;
    await userFetchOthersCreatedAssitance();
  }

  Future<void> clearAssistanceNearbyFilter() async {
    assistanceFilterEnabled.value = false;
    await userFetchOthersCreatedAssitance();
  }

  var voluntersRequestLoadingStatus = <RxBool>[].obs;
  var getVoluntersRequesttatus = RequestStatus.idle.obs;
  var voluntersRequestsList = <VolunterRequestsData>[].obs;

  // File management variables
  var imageFile = Rx<File?>(null);
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
  }

  void clearVideoFile() {
    videoFile.value = null;
  }

  void clearDocumentFile() {
    documentFile.value = null;
  }

  var createPostStatus = RequestStatus.idle.obs;
  Future<void> createUserPost(
    String interestId,
    String postTitle,
    String postContent,
    File? imageFile,
    XFile? videoFile,
    XFile? documentFile,
  ) async {
    createPostStatus.value = RequestStatus.loading;

    final data = {'postTitle': postTitle, 'postContent': postContent};

    final result = await careCircleRepository.createUserPost(
      interestId,
      data,
      imageFile,
      videoFile,
      documentFile,
    );

    if (result['success'] == true) {
      createPostStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Post created successfully");

      // Refresh the posts list
      await interestBasePost(interestId);
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
