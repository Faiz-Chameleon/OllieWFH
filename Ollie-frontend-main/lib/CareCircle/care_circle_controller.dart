import 'dart:io';
import 'package:get/get.dart';
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

class PostModel {
  final String user;
  final String time;
  final String text;
  final File? image;
  final File? document;
  final List<String>? pollOptions;

  PostModel({required this.user, required this.time, required this.text, this.image, this.document, this.pollOptions});
}

class CareCircleController extends GetxController {
  final CareCircleRepository careCircleRepository = CareCircleRepository();
  var selectedTabIndex = 0.obs;
  var reachedOut = false.obs;
  var currentPage = 0.obs;
  var taskCompleted = false.obs;
  var currentYourRequestPage = 0.obs;

  final List<String> topics = ['Fitness', 'Wellness', 'Mindfulness'];
  final List<String> images = ['assets/images/Frame 73.png', 'assets/images/Frame 73.png', 'assets/images/Frame 73.png'];
  final List<String> tabs = ['Assistance', 'Groups', 'Interests', 'Events & Activities'];

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

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  RxList yourSavePostList = [].obs;
  var getYourSavePostStatus = RequestStatus.idle.obs;
  Future<void> getYourSavedPost() async {
    getYourSavePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.getSavedPosts();
    if (result['success'] == true) {
      yourSavePostList.clear();
      if (result['data'] != null && result['data'].isNotEmpty && result['data'][0].isNotEmpty) {
        yourSavePostList.value = result['data'][0];
      } else {
        // List is empty
        yourSavePostList.clear();
        Get.snackbar("Info", "No saved posts found");
      }

      getYourSavePostStatus.value = RequestStatus.success;
    } else {
      getYourSavePostStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
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
    } else if (result['success'] == false && result['message'] == "favourite topic not found") {
      yourInterestedTopics.clear();
      getYourInterestedTopicsStatus.value = RequestStatus.empty;
    } else {
      getYourInterestedTopicsStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  void reachOut(eventId) {
    reachedOut.value = true;
  }

  var interestBasePostList = <PostWithInterestData>[].obs;

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
    } else if (result['success'] == false && result['message'] == "No posts found") {
      interestBasePostList.clear();
      interestBastePostStatus.value = RequestStatus.success;

      Get.snackbar("Info", "No posts available for this topic");
    } else {
      interestBastePostStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var likeOrUnlikePostStatus = RequestStatus.idle.obs;
  Future<void> likeOrUnlikePost(data, int index) async {
    likeOrUnlikePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.likeOrUnlikePost(data);
    if (result['success'] == true) {
      if (result["data"]["action"] == "liked") {
        interestBasePostList[index].isLikePost = true;
        interestBasePostList[index].cCount?.userpostlikes = (interestBasePostList[index].cCount?.userpostlikes ?? 0) + 1;
        interestBasePostList.refresh();
      } else if (result["data"]["action"] == "unliked") {
        interestBasePostList[index].isLikePost = false;
        if (interestBasePostList[index].cCount?.userpostlikes != null && interestBasePostList[index].cCount!.userpostlikes! > 0) {
          interestBasePostList[index].cCount?.userpostlikes = (interestBasePostList[index].cCount?.userpostlikes ?? 0) - 1;
          interestBasePostList.refresh();
        }
      }
      likeOrUnlikePostStatus.value = RequestStatus.success;
    } else {
      likeOrUnlikePostStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void savePostToUpdate(int index) {
    // Toggle the value
    interestBasePostList[index].isSavePost = true;
    // Refresh the list to notify listeners
    interestBasePostList.refresh();
  }

  var saveAndUnsavePostStatus = RequestStatus.idle.obs;
  Future<void> savePostToggle(String postId, int index) async {
    saveAndUnsavePostStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.saveAndUnsavePost(postId);
    if (result['success'] == true) {
      savePostToUpdate(index);
      saveAndUnsavePostStatus.value = RequestStatus.success;
    } else {
      saveAndUnsavePostStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
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
    } else if (result['success'] == false && result['message'] == "User has no selected interests") {
      getYourPostAsInteresStatus.value = RequestStatus.success;

      Get.snackbar("No Interests", "Please select your interests to see posts.");
    } else if (result['success'] == false && result['message'] == "No posts found") {
      /// Special case: no selected interests
      getYourPostAsInteresStatus.value = RequestStatus.success;

      Get.snackbar("Success", "No posts found");
    } else {
      getYourPostAsInteresStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
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
    } else if (result['success'] == false && result['message'] == "Group chat rooms not found") {
      myGroups.clear();
      getYourGroupsStatus.value = RequestStatus.success;
    } else {
      getYourGroupsStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
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
        parsed.data!.forEach((group) {
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
        });
      }
      getOthersGroupsStatus.value = RequestStatus.success;
    } else if (result['success'] == false && result["message"] == 'No featured groups found') {
      othersGroups.clear();
      getOthersGroupsStatus.value = RequestStatus.success;
    } else {
      getOthersGroupsStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var postLoadingStatus = <RxBool>[].obs;
  var postReachOutOnAssistanceStatus = RequestStatus.idle.obs;
  Future<void> reachOutOnAssistance(String assistancId, int index) async {
    postReachOutOnAssistanceStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.reachOutOnAssistanceRequest(assistancId);
    if (result['success'] == true) {
      othersCreatedAssistance[index].status = "VolunteerRequestSent";

      postReachOutOnAssistanceStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
    } else {
      postReachOutOnAssistanceStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  Future<void> completeAssistanceByVolunter(String assistancId) async {
    postReachOutOnAssistanceStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.assistanceRequestCompleteByVolunter(assistancId);
    if (result['success'] == true) {
      postReachOutOnAssistanceStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
    } else {
      postReachOutOnAssistanceStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  Future<void> markTopicAsFavourite(String topicId) async {
    final result = await careCircleRepository.postYourFavouriteTopic(topicId);
    if (result['success'] == true) {
      Get.snackbar("Success", result['message'] ?? "");
    } else {
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var acceptVolunterRequestStatus = RequestStatus.idle.obs;
  Future<void> acceptrequestOnAssistance(String assistancId, data, int index) async {
    acceptVolunterRequestStatus.value = RequestStatus.loading;

    final result = await careCircleRepository.acceptRequestOnAssistance(assistancId, data);
    if (result['success'] == true) {
      data["action"] == "reject" ? voluntersRequestsList.removeAt(index) : voluntersRequestsList[index].status = "ReachOut";
      acceptVolunterRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
    } else {
      acceptVolunterRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void changePage(int index) {
    currentPage.value = index;
  }

  var completeTaskOwnerRequestStatus = RequestStatus.idle.obs;
  Future<void> completeTaskByOwner(String assistancId) async {
    completeTaskOwnerRequestStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.completeAssistanceFromOwner(assistancId);
    if (result['success'] == true) {
      completeTaskOwnerRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
    } else if (result['success'] == false && result['message'] == "action is required") {
      Get.snackbar("Error", "Your Volunter need to Complete it First");
    } else {
      completeTaskOwnerRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
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
    } else if (result['success'] == false && result["message"] == "Latest event not found or user is not marked as participating") {
      getLatestEventStatus.value = RequestStatus.success; // You can set it to success because there is no event but not an error.
      latestEvent.value = LatestEventsData();
    } else {
      getLatestEventStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  String formatDate(String dateString) {
    if (dateString == null || dateString.isEmpty) {
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
      Get.snackbar("Success", result["message"]);
    } else {
      markAsGoingOnEventStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var nearestEvents = <NearestEventsData>[].obs;

  var getEventNearYouStatus = RequestStatus.idle.obs;
  Future<void> userFetchNearestEvents() async {
    getEventNearYouStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getNearesEvent();
    if (result['success'] == true) {
      List<dynamic> eventList = result['data'] ?? [];
      nearestEvents.value = eventList.map((eventJson) => NearestEventsData.fromJson(eventJson)).toList();
      getEventNearYouStatus.value = RequestStatus.success;
    } else {
      getEventNearYouStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var createdAssistance = <CreatedAssistanceData>[].obs;

  var getCrteatedAssistanceStatus = RequestStatus.idle.obs;
  Future<void> userFetchCreatedAssitance() async {
    getCrteatedAssistanceStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getCreatedAssistance();
    if (result['success'] == true) {
      List<dynamic> createdAssistanceList = result['data'] ?? [];
      createdAssistance.value = createdAssistanceList.map((assistancetJson) => CreatedAssistanceData.fromJson(assistancetJson)).toList();
      getCrteatedAssistanceStatus.value = RequestStatus.success;
    } else {
      getCrteatedAssistanceStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var othersCreatedAssistance = <OthersCreatedAssistance>[].obs;

  var getOthersCrteatedAssistanceStatus = RequestStatus.idle.obs;
  Future<void> userFetchOthersCreatedAssitance() async {
    final userController = Get.put(UserController());
    final String loggedInUserId = userController.user.value?.id ?? '';
    getOthersCrteatedAssistanceStatus.value = RequestStatus.loading;
    final result = await careCircleRepository.getOthersCreatedAssistance();
    if (result['success'] == true) {
      List<dynamic> othersCreatedAssistanceList = result['data'] ?? [];
      postLoadingStatus.value = List.generate(othersCreatedAssistanceList.length, (_) => false.obs);
      List<OthersCreatedAssistance> filteredList = othersCreatedAssistanceList
          .where((assistancetJson) {
            final assistance = OthersCreatedAssistance.fromJson(assistancetJson);
            return assistance.userId != loggedInUserId;
          })
          .map((assistancetJson) => OthersCreatedAssistance.fromJson(assistancetJson))
          .toList();
      for (int i = 0; i < othersCreatedAssistance.length; i++) {
        postLoadingStatus[i].value = false;
      }

      othersCreatedAssistance.value = filteredList;
      getOthersCrteatedAssistanceStatus.value = RequestStatus.success;
    } else {
      getOthersCrteatedAssistanceStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var voluntersRequestLoadingStatus = <RxBool>[].obs;
  var getVoluntersRequesttatus = RequestStatus.idle.obs;
  var voluntersRequestsList = <VolunterRequestsData>[].obs;

  // File management variables
  var imageFile = Rx<File?>(null);
  var videoFile = Rx<File?>(null);
  var documentFile = Rx<File?>(null);

  // File management methods
  void setImageFile(File? file) {
    imageFile.value = file;
  }

  void setVideoFile(File? file) {
    videoFile.value = file;
  }

  void setDocumentFile(File? file) {
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
  Future<void> createUserPost(String interestId, String postTitle, String postContent, File? imageFile, File? videoFile) async {
    createPostStatus.value = RequestStatus.loading;

    final data = {'postTitle': postTitle, 'postContent': postContent};

    final result = await careCircleRepository.createUserPost(interestId, data, imageFile, videoFile);

    if (result['success'] == true) {
      createPostStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "Post created successfully");

      // Refresh the posts list
      await interestBasePost(interestId);
    } else {
      createPostStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Failed to create post");
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
            final voluntersResponse = VolunterRequestsData.fromJson(voluntersJson);
            print("Post ID: ${voluntersResponse.post?.id}");
            return voluntersResponse.postId == assistanceId;
          })
          .map((assistancetJson) => VolunterRequestsData.fromJson(assistancetJson))
          .toList();

      // Initialize the loading status for each volunteer request AFTER filtering
      voluntersRequestLoadingStatus.value = List.generate(receivedVoluntersList.length, (_) => true.obs);

      // Update the list of volunteer requests
      voluntersRequestsList.value = receivedVoluntersList;

      // Set loading status to false after successfully fetching the data
      for (int i = 0; i < voluntersRequestsList.length; i++) {
        voluntersRequestLoadingStatus[i].value = false;
      }

      getVoluntersRequesttatus.value = RequestStatus.success;
    } else {
      getVoluntersRequesttatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
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
    } else if (result['success'] == false && result['message'] == "No posts found") {
      yourPostList.clear();
      fetchingYourPostStatus.value = RequestStatus.success;

      Get.snackbar("Info", "No posts available for this topic");
    } else {
      interestBastePostStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
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
