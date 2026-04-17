import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/CareCircle/interests/open_pdf.dart';
import 'package:ollie/CareCircle/interests/open_word_file.dart';
import 'package:ollie/CareCircle/interests/video_player_widget.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/post_with_interest_model.dart';
import 'package:ollie/request_status.dart';

import '../care_circle_controller.dart';

class TopicPostDetailScreen extends StatefulWidget {
  const TopicPostDetailScreen({
    super.key,
    required this.controller,
    required this.post,
    required this.index,
  });

  final CareCircleController controller;
  final PostWithInterestData post;
  final int index;

  @override
  State<TopicPostDetailScreen> createState() => _TopicPostDetailScreenState();
}

class _TopicPostDetailScreenState extends State<TopicPostDetailScreen> {
  late PostWithInterestData _displayPost;

  @override
  void initState() {
    super.initState();
    _displayPost = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.post.source == "user" &&
          (widget.post.id?.isNotEmpty ?? false)) {
        final latestPost = await widget.controller.fetchSingleUserPost(
          widget.post.id!,
        );
        if (!mounted || latestPost == null) return;
        setState(() {
          _displayPost = latestPost;
        });
        widget.controller.interestBasePostList[widget.index] = latestPost;
        widget.controller.interestBasePostList.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Post Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final isLoading =
            widget.controller.singleInterestPostStatus.value ==
                RequestStatus.loading &&
            widget.post.source == "user";

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          (_displayPost.user?.image?.isNotEmpty ?? false)
                          ? NetworkImage(_displayPost.user!.image!)
                          : null,
                      child:
                          _displayPost.user?.image == null ||
                              _displayPost.user!.image!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _displayPost.source == "user"
                              ? Text(
                                  _displayPost.user?.firstName ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Text(
                                  "Admin",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                          Text(
                            widget.controller.formatDate(
                              _displayPost.createdAt ?? "",
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 16),
                          const SizedBox(width: 6),
                          Text((_displayPost.views ?? 0).toString()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _displayPost.title ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _displayPost.content ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: txtColor,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _displayPost.image != null
                      ? _buildMediaWidget(_displayPost.image!)
                      : Image.asset(
                          "assets/images/Card.png",
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final data = {
                          "type": _displayPost.source == "user"
                              ? "user-posts"
                              : "posts",
                          "postId": _displayPost.id.toString(),
                        };
                        widget.controller.likeOrUnlikePost(data, widget.index);
                        setState(() {
                          _displayPost = widget
                              .controller
                              .interestBasePostList[widget.index];
                        });
                      },
                      child: Icon(
                        _displayPost.isLikePost == false
                            ? Icons.thumb_up_alt_outlined
                            : Icons.thumb_up,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _displayPost.source == "user"
                          ? (_displayPost.cCount?.userpostlikes ?? 0).toString()
                          : (_displayPost.cCount?.postLike ?? 0).toString(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => CommentsScreenOnPost(
                            postId: _displayPost.id.toString(),
                          ),
                        );
                      },
                      child: const Icon(Icons.comment_outlined, size: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (_displayPost.cCount?.userpostcomments ?? 0).toString(),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        widget.controller.savePostToggle(
                          _displayPost.id.toString(),
                          widget.index,
                        );
                        setState(() {
                          _displayPost = widget
                              .controller
                              .interestBasePostList[widget.index];
                        });
                      },
                      child: Icon(
                        _displayPost.isSavePost == false
                            ? Icons.bookmark_border
                            : Icons.bookmark_added,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMediaWidget(String url) {
    final extension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return Image.network(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return SizedBox(
        height: 240,
        width: double.infinity,
        child: VideoPlayerWidget(
          videoUrl: url,
          autoPlay: false,
          looping: false,
        ),
      );
    } else if (extension == 'pdf') {
      return GestureDetector(
        onTap: () async => openPdf(url),
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.red[100],
          child: const Center(
            child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50),
          ),
        ),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      return GestureDetector(
        onTap: () async => openDocFile(url),
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.blue[100],
          child: const Center(
            child: Icon(Icons.description, color: Colors.blue, size: 50),
          ),
        ),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.insert_drive_file, color: Colors.grey),
    );
  }
}
