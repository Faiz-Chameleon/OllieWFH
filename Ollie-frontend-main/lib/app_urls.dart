class ApiUrls {
  // http://3.96.147.42/api/v1
  // http://192.168.1.20:3000/api/v1
  static const String baseUrl = 'http://3.96.202.108/api/v1';
  static const String registerApi = "/user/auth/userRegister";
  static const String verifyOTPApi = "/user/auth/userVerifyOtp";
  static const String getInterest = "/user/auth/getInterest";
  static const String forgotPassword = "/user/auth/userForgetPassword";
  static const String resendOTP = "/user/auth/resendOtp";
  static const String resetPassword = "/user/auth/userResetPassword";
  static const String loginUser = "/user/auth/userLogin";
  static const String createProfile = "/user/auth/createProfile";
  static const String createTask = "/user/task/createUserTask";
  static const String getAllUserTask = "/user/task/getAllUserTask";
  static const String getByDateTask = "/user/task/getTaskByDate";

  static const String markTaskAsComplete = "/user/task/markAsCompletedTask";
  static const String getBlogsByCategory = "/user/blog/getBlogByType";
  static const String getBlogsTopics = "/user/blog/getAllTopics";
  static const String getYourInterestedTopics = "/user/blog/getFavoriteTopics";
  static const String getLatestBlogs = "/user/blog/getAllLatestBlog";
  static const String getBlogsByTopics = "/user/blog/getAllBlogByTopics";
  static const String getBlogsDetails = "/user/blog/getSingleBlog";
  static const String blogLikeOrUnlike = "/user/blog/likeAndUnlikeBlog";
  static const String postLikeOrUnlike = "/user/post/likeAndUnlikeUserPost";
  static const String commentsOnBlog = "/user/blog/commentBlog";
  static const String getCommentsOnBlog = "/user/blog/getCommentsLikeReply";
  static const String likeAndReplyOnComment = "/user/blog/likeAndReplyOnComment";
  static const String saveBlog = "/user/blog/saveBlog";
  static const String getLatestEvent = "/user/event/showLatestEvent";
  static const String markAsGoingOnEvent = "/user/event/markAsGoing";
  static const String getNearesEvent = "/user/event/showAllEventNearBy";
  static const String createAssistance = "/user/postrequest/createPostRequest";
  static const String getReasonsForAssistance = "/user/postrequest/getPostRequestCaterogy";
  static const String getcreatedAssistance = "/user/postrequest/getUserPostRequest";
  static const String getOthersCreatedAssistance = "/user/postrequest/getAllPostRequest";
  static const String reachOnOthersCreatedAssistance = "/user/postrequest/sendVolunteerRequest";
  static const String volunterCompletedCreatedAssistance = "/user/postrequest/markAsCompletedByVolunteer";
  static const String markTopicAsFavourite = "/user/blog/saveFavouriteTopic";
  static const String getRequestOfVolunteers = "/user/postrequest/getAllVolenteerRequest";
  static const String acceptVoluntersRequest = "/user/postrequest/acceptVolunteerRequest";
  static const String completeAssistanceByOwner = "/user/postrequest/confirmTaskCompletedByOwner";
  static const String createChatRoom = "/user/chat/createOneToOneChatRoom";
  static const String sendAttachementOnChatRoom = "/user/chat/uplaodAttachment";
  static const String createGroups = "/user/chat/createGroupChatRoom";
  static const String getYoursGroup = "/user/chat/getGroupChatRooms";
  static const String getOthersGroup = "/user/chat/getFeatureGroups";
  static const String joinGroupChatRoom = "/user/chat/addParticipantinChatRoom";
  static const String postOnYourInteres = "/user/post/showAllPostByUserSelectedInterest";
  static const String interestBaseMultiplePost = "/user/post/showAllPostByInterest";
  static const String createUserPost = "/user/post/createUserPost";
  static const String getMe = "/user/auth/getMe";
}
