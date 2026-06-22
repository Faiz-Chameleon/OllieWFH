import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/CareCircle/interests/create_post_screen.dart';
import 'package:ollie/CareCircle/interests/open_pdf.dart';
import 'package:ollie/CareCircle/interests/open_word_file.dart';
import 'package:ollie/CareCircle/interests/topic_post_detail_screen.dart';
import 'package:ollie/CareCircle/interests/video_player_widget.dart';
import 'package:ollie/Models/post_with_interest_model.dart';
import 'package:ollie/request_status.dart';
import '../care_circle_controller.dart';

class TopicPostScreen extends StatefulWidget {
  final String topic;
  final String topicId;

  TopicPostScreen({super.key, required this.topic, required this.topicId}) {
    // _generateSamplePosts();
  }

  @override
  State<TopicPostScreen> createState() => _TopicPostScreenState();
}

class _TopicPostScreenState extends State<TopicPostScreen> {
  final CareCircleController controller = Get.find<CareCircleController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.interestBasePost(widget.topicId);
    });
  }

  // void _generateSamplePosts() {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFFFF7E9),
        elevation: 0,
        centerTitle: false,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.topic,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                Get.to(
                  () => CreatePostScreen(topicId: widget.topicId),
                  transition: Transition.fadeIn,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC766),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Create Post",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.interestBastePostStatus.value ==
              RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.interestBastePostStatus.value ==
              RequestStatus.error) {
            return const Center(child: Text("Something went wrong"));
          } else if (controller.interestBasePostList.isEmpty) {
            return const Center(child: Text("No posts available"));
          }
          return ListView.separated(
            itemCount: controller.interestBasePostList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = controller.interestBasePostList[index];
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => TopicPostDetailScreen(
                      controller: controller,
                      post: post,
                      index: index,
                    ),
                    transition: Transition.fadeIn,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final imageUrl = post.user?.image?.trim() ?? '';
                              return CircleAvatar(
                                radius: 16,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              post.source == "user"
                                  ? Text(
                                      post.user?.firstName ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "Admin",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              Text(
                                controller.formatDate(post.createdAt ?? ""),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            shape: TooltipShapeBorder(),
                            itemBuilder: (context) {
                              final isOwnPost = controller.isOwnUserPost(post);
                              return [
                                if (isOwnPost)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  )
                                else
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Text("Report"),
                                  ),
                              ];
                            },
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final shouldDelete = await _confirmDeletePost(
                                  context,
                                );
                                if (shouldDelete == true) {
                                  await controller.deleteUserPost(
                                    post.id ?? "",
                                    index: index,
                                  );
                                }
                                return;
                              }
                              controller.postReport(post.id ?? "");
                            },
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Title: ${post.title}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Description: ${post.content ?? ""}',
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 10),
                      _buildPostBody(post, index),

                      // if (post.document != null) ...[
                      //   const SizedBox(height: 10),
                      //   Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.insert_drive_file,
                      //         color: Colors.black,
                      //       ),
                      //       const SizedBox(width: 8),
                      //       Expanded(
                      //         child: Text(post.document!.path.split('/').last),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              var data = {
                                "type": post.source == "user"
                                    ? "user-posts"
                                    : "posts",
                                "postId": post.id.toString(),
                              };
                              controller.likeOrUnlikePost(data, index);
                            },
                            child: Icon(
                              post.isLikePost == false
                                  ? Icons.thumb_up_alt_outlined
                                  : Icons.thumb_up,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          post.source == "user"
                              ? Text(
                                  post.cCount?.userpostlikes?.toString() ?? "0",
                                )
                              : Text(post.cCount?.postLike?.toString() ?? "0"),

                          const SizedBox(width: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => CommentsScreenOnPost(
                                      postId: post.id.toString(),
                                    ),
                                  );
                                },
                                child: Icon(Icons.comment_outlined, size: 18),
                              ),
                              SizedBox(width: 4),
                              Text(
                                post.cCount?.userpostcomments != null
                                    ? post.cCount!.userpostcomments.toString()
                                    : "0",
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.remove_red_eye_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text(post.views.toString()),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              controller.savePostToggle(
                                post.id.toString(),
                                index,
                              );
                            },
                            child: Icon(
                              post.isSavePost == false
                                  ? Icons.bookmark_border
                                  : Icons.bookmark_added,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text("Save"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Future<bool?> _confirmDeletePost(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This post will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(String url) {
    final extension = url.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      // ✅ Image
      return Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      // ✅ Video
      return SizedBox(
        height: 200, // Slightly taller for video controls
        width: double.infinity,
        child: VideoPlayerWidget(
          videoUrl: url,
          autoPlay: false, // Don't autoplay by default
          looping: false,
        ),
      );
      // Later: integrate `video_player` package for playback
    } else if (extension == 'pdf') {
      // ✅ PDF
      return GestureDetector(
        onTap: () async {
          await openPdf(url);
        },
        child: Container(
          height: 150,
          width: double.infinity,
          color: Colors.red[100],
          child: const Center(
            child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50),
          ),
        ),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      // ✅ Word document
      return GestureDetector(
        onTap: () async {
          await openDocFile(url);
        },
        child: Container(
          height: 150,
          width: double.infinity,
          color: Colors.blue[100],
          child: const Center(
            child: Icon(Icons.description, color: Colors.blue, size: 50),
          ),
        ),
      );
    } else {
      // ❌ Unknown file type
      return _placeholder();
    }
  }

  Widget _buildPostBody(PostWithInterestData post, int index) {
    final children = <Widget>[];
    final imageUrls = <String>[
      ...?post.images,
      if ((post.image ?? '').isNotEmpty) post.image!,
    ];
    if (imageUrls.isNotEmpty) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrls.length == 1
              ? _buildMediaWidget(imageUrls.first)
              : _ImageGrid(urls: imageUrls),
        ),
      );
    }

    if ((post.videoUrl ?? '').isNotEmpty) {
      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMediaWidget(post.videoUrl!),
        ),
      );
    }

    final postType = post.postType?.trim().toUpperCase() ?? '';
    if (postType == 'POLL' || post.poll != null) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 10));
      children.add(
        _PollPostWidget(
          post: post,
          onVote: (optionId) {
            controller.voteOnPoll(
              postId: post.id ?? '',
              optionId: optionId,
              postIndex: index,
            );
          },
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _placeholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.insert_drive_file, color: Colors.grey),
    );
  }

  void showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF7E9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: const [
            Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            _CommentWidget(user: "Julia Michael", comment: "Love this!"),
            _CommentWidget(user: "Shelley", comment: "Haha!"),
          ],
        ),
      ),
    );
  }
}

class _PollPostWidget extends StatelessWidget {
  const _PollPostWidget({required this.post, required this.onVote});

  final PostWithInterestData post;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    final poll = post.poll;
    final options = poll?.options ?? const <PostPollOption>[];
    if (poll == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D8BB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title ?? 'Poll',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading poll details...',
              style: TextStyle(color: Color(0xFF7D8496), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final totalVotes =
        poll.totalVotes ??
        options.fold<int>(0, (sum, option) => sum + option.votes);

    return Container(
      padding: const EdgeInsets.all(12),
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
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8D8BB)),
              ),
              child: const Text('Poll options unavailable'),
            ),
          ...options.map((option) {
            final percent = option.percentage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: option.id == null ? null : () => onVote(option.id!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                          Expanded(child: Text(option.text ?? 'Option')),
                          Text('$percent%'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: percent.clamp(0, 100) / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            option.votedByMe
                                ? const Color(0xFFF4BD2A)
                                : Colors.grey.shade400,
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
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final visible = urls.take(4).toList();
    final extra = urls.length - visible.length;
    return SizedBox(
      height: 180,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: visible.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(visible[index], fit: BoxFit.cover),
              if (index == visible.length - 1 && extra > 0)
                Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: Text(
                    '+$extra',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentWidget extends StatelessWidget {
  final String user;
  final String comment;

  const _CommentWidget({required this.user, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/icons/Frame 1686560584.png"),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TooltipShapeBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const arrowSize = 6.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left,
        rect.top + arrowSize,
        rect.width,
        rect.height - arrowSize,
      ),
      const Radius.circular(8),
    );
    final path = Path()..addRRect(r);
    final centerX = rect.left + rect.width - 20;
    path.moveTo(centerX, rect.top + arrowSize);
    path.lineTo(centerX - 6, rect.top);
    path.lineTo(centerX + 6, rect.top);
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
