import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comment_controller_post.dart';
import 'package:ollie/Models/comment_model.dart';
import 'package:ollie/request_status.dart';

class CommentsScreenOnPost extends StatefulWidget {
  final String postId;
  const CommentsScreenOnPost({super.key, required this.postId});

  @override
  State<CommentsScreenOnPost> createState() => _CommentsScreenOnPostState();
}

class _CommentsScreenOnPostState extends State<CommentsScreenOnPost> {
  late CommentsOnPost controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller
    controller = Get.put(CommentsOnPost());
    // Load comments from API
    controller.loadComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9), // Light beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        title: const Text(
          "Comments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.mainComments.isEmpty) {
                return const Center(
                  child: Text('No comments yet. Be the first to comment!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.mainComments.length,
                itemBuilder: (context, index) {
                  final comment = controller.mainComments[index];
                  return _buildCommentSection(comment, controller);
                },
              );
            }),
          ),
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildCommentSection(Comment comment, CommentsOnPost controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment
          _buildCommentItem(comment, controller, isMainComment: true),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map((reply) => _buildCommentItem(reply, controller, isMainComment: false, parentComment: comment)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, CommentsOnPost controller, {bool isMainComment = false, Comment? parentComment}) {
    return Container(
      margin: EdgeInsets.only(left: isMainComment ? 0 : 32, top: isMainComment ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connecting line for replies
          if (!isMainComment) ...[Container(width: 2, height: 40, color: Colors.grey[300], margin: const EdgeInsets.only(right: 12))],

          // Avatar
          CircleAvatar(
            radius: isMainComment ? 20 : 16,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment.avatar != null ? NetworkImage(comment.avatar!) : null,
            child: comment.avatar == null
                ? Text(
                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: isMainComment ? 16 : 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and timestamp row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMainComment ? 15 : 14, color: Colors.black87),
                      ),
                    ),
                    Text(
                      controller.formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: isMainComment ? 12 : 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  comment.message,
                  style: TextStyle(fontSize: isMainComment ? 14 : 13, color: Colors.black87, height: 1.3),
                ),
                const SizedBox(height: 8),

                // Interaction bar
                Row(
                  children: [
                    // Like button
                    GestureDetector(
                      onTap: () async {
                        if (isMainComment) {
                          await controller.toggleLike(comment);
                        } else {
                          await controller.toggleReplyLike(comment, parentComment!.id);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: isMainComment ? 18 : 16,
                            color: comment.isLiked ? Colors.blue : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: TextStyle(fontSize: isMainComment ? 13 : 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Reply button (only for main comments)
                    if (isMainComment) ...[
                      GestureDetector(
                        onTap: () => controller.startReply(comment),
                        child: Text(
                          'Reply',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(CommentsOnPost controller) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          children: [
            // Status indicator
            Obx(() {
              if (controller.mainCommentStatus.value == RequestStatus.loading) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text('Posting comment...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                );
              }
              return const SizedBox.shrink();
            }),
            Row(
              children: [
                // Attachment button

                // Message input field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                    child: Obx(
                      () => TextField(
                        controller: controller.messageController,
                        enabled: controller.mainCommentStatus.value != RequestStatus.loading,
                        decoration: InputDecoration(
                          hintText: controller.replyingToName.value.isNotEmpty
                              ? 'Reply to ${controller.replyingToName.value}...'
                              : 'Enter your message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Obx(
                  () => GestureDetector(
                    onTap: controller.mainCommentStatus.value == RequestStatus.loading ? null : () => controller.submitMessage(widget.postId),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: controller.mainCommentStatus.value == RequestStatus.loading ? Colors.grey[400] : Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: controller.mainCommentStatus.value == RequestStatus.loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
