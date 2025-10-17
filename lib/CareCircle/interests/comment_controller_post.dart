import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comments_on_post_repository.dart';
import 'package:ollie/Models/comment_model.dart';
import 'package:ollie/request_status.dart';

class CommentsOnPost extends GetxController {
  final CommentsOnPostRepository commentsRepository = CommentsOnPostRepository();

  final RxList<Comment> mainComments = <Comment>[].obs;
  final RxString replyingToId = ''.obs;
  final RxString replyingToName = ''.obs;
  final RxBool isLoading = false.obs;

  // Text editing controller
  final messageController = TextEditingController();

  // API status variables
  var mainCommentStatus = RequestStatus.idle.obs;
  var getCommentsStatus = RequestStatus.idle.obs;
  var likeStatus = RequestStatus.idle.obs;

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // Load comments from API
  Future<void> loadComments(String postId) async {
    var data = {"type": "user-posts", "postId": postId.toString()};
    try {
      isLoading.value = true;
      getCommentsStatus.value = RequestStatus.loading;

      final result = await commentsRepository.getCommentsOnPost(data);

      if (result['success'] == true) {
        getCommentsStatus.value = RequestStatus.success;
        final List<dynamic> commentsData = result['data'] ?? [];
        mainComments.assignAll(_parseComments(commentsData));
      } else {
        getCommentsStatus.value = RequestStatus.error;
        Get.snackbar('Error', result['message'] ?? 'Failed to load comments');
      }
    } catch (e) {
      getCommentsStatus.value = RequestStatus.error;
      Get.snackbar('Error', 'Failed to load comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Parse API response to Comment objects
  List<Comment> _parseComments(List<dynamic> commentsData) {
    return commentsData.map<Comment>((commentData) {
      final userData = commentData['user'] ?? {};
      final repliesData = commentData['replies'] ?? [];

      // Check for various possible field names that indicate if current user liked the comment
      final isLikedByMe =
          commentData['isLikedByMe'] ??
          commentData['userLiked'] ??
          commentData['likedByCurrentUser'] ??
          commentData['isLiked'] ??
          commentData['hasLiked'] ??
          false;

      return Comment(
        id: commentData['id'] ?? '',
        user: commentData['userId'] ?? '',
        userName: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
        avatar: userData['image'],
        message: commentData['comment'] ?? '',
        likes: commentData['likeCount'] ?? 0,
        isLiked: isLikedByMe,
        createdAt: DateTime.parse(commentData['createdAt'] ?? DateTime.now().toIso8601String()),
        replies: _parseComments(repliesData),
      );
    }).toList();
  }

  // Post comment
  Future<void> postComment(String blogId) async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar("Error", "Please enter a comment");
      return;
    }

    mainCommentStatus.value = RequestStatus.loading;

    try {
      final result = await commentsRepository.commentsOnPost({"comment": message, "type": "user-posts", "postId": blogId.toString()});

      if (result['success'] == true) {
        mainCommentStatus.value = RequestStatus.success;
        messageController.clear();
        await loadComments(blogId); // Reload comments
        Get.snackbar("Success", result['message'] ?? "Comment posted successfully");
      } else {
        mainCommentStatus.value = RequestStatus.error;
        Get.snackbar("Error", result['message'] ?? "Failed to post comment");
      }
    } catch (e) {
      mainCommentStatus.value = RequestStatus.error;
      Get.snackbar("Error", "Failed to post comment: $e");
    }
  }

  // Toggle like for main comment
  Future<void> toggleLike(Comment comment) async {
    try {
      likeStatus.value = RequestStatus.loading;

      final result = await commentsRepository.likeAndReplyOnPost(comment.id, {"like": !comment.isLiked, "commentId": comment.id});

      if (result['success'] == true) {
        likeStatus.value = RequestStatus.success;
        final index = mainComments.indexWhere((c) => c.id == comment.id);
        if (index != -1) {
          final updatedComment = comment.copyWith(likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1, isLiked: !comment.isLiked);
          mainComments[index] = updatedComment;
        }
      } else {
        likeStatus.value = RequestStatus.error;
        Get.snackbar("Error", result['message'] ?? "Failed to update like");
      }
    } catch (e) {
      likeStatus.value = RequestStatus.error;
      Get.snackbar("Error", "Failed to update like: $e");
    }
  }

  // Toggle like for reply
  Future<void> toggleReplyLike(Comment reply, String parentCommentId) async {
    try {
      likeStatus.value = RequestStatus.loading;

      final result = await commentsRepository.likeAndReplyOnPost(reply.id, {"like": !reply.isLiked, "commentId": parentCommentId.toString()});

      if (result['success'] == true) {
        likeStatus.value = RequestStatus.success;
        final parentIndex = mainComments.indexWhere((c) => c.id == parentCommentId);
        if (parentIndex != -1) {
          final parentComment = mainComments[parentIndex];
          final replyIndex = parentComment.replies.indexWhere((r) => r.id == reply.id);

          if (replyIndex != -1) {
            final updatedReply = reply.copyWith(likes: reply.isLiked ? reply.likes - 1 : reply.likes + 1, isLiked: !reply.isLiked);

            final updatedReplies = List<Comment>.from(parentComment.replies);
            updatedReplies[replyIndex] = updatedReply;

            mainComments[parentIndex] = parentComment.copyWith(replies: updatedReplies);
          }
        }
      } else {
        likeStatus.value = RequestStatus.error;
        Get.snackbar("Error", result['message'] ?? "Failed to update like");
      }
    } catch (e) {
      likeStatus.value = RequestStatus.error;
      Get.snackbar("Error", "Failed to update like: $e");
    }
  }

  // Start reply
  void startReply(Comment comment) {
    replyingToId.value = comment.id;
    replyingToName.value = comment.userName;
  }

  // Cancel reply
  void cancelReply() {
    replyingToId.value = '';
    replyingToName.value = '';
    messageController.clear();
  }

  // Submit message (comment or reply)
  Future<void> submitMessage(String blogId) async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar("Error", "Please enter a message");
      return;
    }

    if (replyingToId.value.isNotEmpty) {
      // Submit reply
      try {
        final result = await commentsRepository.likeAndReplyOnPost(replyingToId.value, {"reply": message, "commentId": replyingToId.value});

        if (result['success'] == true) {
          messageController.clear();
          cancelReply();
          await loadComments(blogId); // Reload comments to show new reply
          Get.snackbar("Success", result['message'] ?? "Reply posted successfully");
        } else {
          Get.snackbar("Error", result['message'] ?? "Failed to post reply");
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to post reply: $e");
      }
    } else {
      // Submit main comment
      await postComment(blogId);
    }
  }

  // Format time ago
  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// var headers = {
//   'x-access-token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijg2MDY0YTgwLTFlYjQtNGViNS1iMTFhLWJlNjY3NGRhOWNjZCIsInVzZXJUeXBlIjoiVVNFUiIsImlhdCI6MTc1NjQwMDcxNSwiZXhwIjoxNzU2NDg3MTE1fQ.-JNfv8Fe_kXh_ivstVedgklX7we3GqIZjpjbkn09xJI',
//   'Content-Type': 'application/json'
// };
// var request = http.Request('GET', Uri.parse('http://localhost:3000/api/v1/user/post/showPostCommentLikeReply'));
// request.body = json.encode({
//   "type": "user-posts",
//   "postId": "f457e024-8c2d-4fa3-b2ed-35ebd6a32315"
// });
// request.headers.addAll(headers);

// http.StreamedResponse response = await request.send();

// if (response.statusCode == 200) {
//   print(await response.stream.bytesToString());
// }
// else {
//   print(response.reasonPhrase);
// }
