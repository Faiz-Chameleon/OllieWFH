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

class _PollDetailWidget extends StatelessWidget {
  const _PollDetailWidget({required this.post, required this.onVote});

  final PostWithInterestData post;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    final poll = post.poll;
    if (poll == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D8BB)),
        ),
        child: const Text(
          'Loading poll details...',
          style: TextStyle(color: txtColor),
        ),
      );
    }

    final options = poll.options ?? const <PostPollOption>[];
    final totalVotes =
        poll.totalVotes ??
        options.fold<int>(0, (sum, option) => sum + option.votes);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D8BB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question ?? post.title ?? 'Poll',
            style: const TextStyle(
              color: txtColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (options.isEmpty)
            const Text(
              'Poll options unavailable',
              style: TextStyle(color: txtColor),
            ),
          ...options.map((option) {
            final percent = option.percentage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: option.id == null ? null : () => onVote(option.id!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: option.votedByMe
                          ? const Color(0xFFF4BD2A)
                          : const Color(0xFFE8D8BB),
                      width: option.votedByMe ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.text ?? '',
                              style: const TextStyle(color: txtColor),
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(color: txtColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: percent.clamp(0, 100) / 100,
                          backgroundColor: const Color(0xFFEDEDED),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF4BD2A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Text(
            '$totalVotes votes',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DetailImageGrid extends StatelessWidget {
  const _DetailImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: urls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            urls[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

class _TopicPostDetailScreenState extends State<TopicPostDetailScreen> {
  late PostWithInterestData _displayPost;

  @override
  void initState() {
    super.initState();
    _displayPost = widget.post;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isUserPost(widget.post) && (widget.post.id?.isNotEmpty ?? false)) {
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
            _isUserPost(widget.post);

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
                          _isUserPost(_displayPost)
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
                ..._buildPostBody(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final data = {
                          "type": _isUserPost(_displayPost)
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
                      _isUserPost(_displayPost)
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

  bool _isUserPost(PostWithInterestData post) {
    if (post.source == 'user') return true;
    if (post.source == 'posts') return false;
    if ((post.userId ?? '').isNotEmpty || post.user != null) return true;
    final postType = post.postType?.trim().toUpperCase();
    return postType == 'TEXT' ||
        postType == 'IMAGE' ||
        postType == 'VIDEO' ||
        postType == 'POLL';
  }

  List<Widget> _buildPostBody() {
    final media = _buildMediaSection();
    if (media == null) return const [];
    return [const SizedBox(height: 16), media];
  }

  Widget? _buildMediaSection() {
    final children = <Widget>[];
    final imageUrls = <String>[
      ...?_displayPost.images,
      if ((_displayPost.image ?? '').isNotEmpty) _displayPost.image!,
    ];
    if (imageUrls.isNotEmpty) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageUrls.length == 1
              ? _buildMediaWidget(imageUrls.first)
              : _DetailImageGrid(urls: imageUrls),
        ),
      );
    }

    if ((_displayPost.videoUrl ?? '').isNotEmpty) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildMediaWidget(_displayPost.videoUrl!),
        ),
      );
    }

    final postType = _displayPost.postType?.trim().toUpperCase() ?? '';
    if (postType == 'POLL' || _displayPost.poll != null) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));
      children.add(
        _PollDetailWidget(
          post: _displayPost,
          onVote: (optionId) async {
            await widget.controller.voteOnPoll(
              postId: _displayPost.id ?? '',
              optionId: optionId,
              postIndex: widget.index,
            );
            if (!mounted) return;
            setState(() {
              _displayPost =
                  widget.controller.interestBasePostList[widget.index];
            });
          },
        ),
      );
    }

    if (children.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
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
