import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/CareCircle/interests/create_post_screen.dart';
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
  final CareCircleController controller = Get.put(CareCircleController());

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
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => CreatePostScreen(topicId: widget.topicId), transition: Transition.fadeIn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC766),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Create Post", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.interestBastePostStatus.value == RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.interestBastePostStatus.value == RequestStatus.error) {
            return const Center(child: Text("Something went wrong"));
          } else if (controller.interestBasePostList.isEmpty) {
            return const Center(child: Text("No posts available"));
          }
          return ListView.separated(
            itemCount: controller.interestBasePostList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = controller.interestBasePostList[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(post.user?.image ?? ""),
                          child: post.user?.image == null || post.user?.image == ""
                              ? Icon(Icons.person, size: 20) // Default icon when there is no image
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.user?.firstName ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(controller.formatDate(post.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        PopupMenuButton(
                          shape: TooltipShapeBorder(),
                          itemBuilder: (context) => [const PopupMenuItem(value: 'report', child: Text("Report"))],
                          onSelected: (value) {
                            controller.postReport(post.id ?? "");
                          },
                          icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Title: ${post.title}", style: const TextStyle(fontSize: 14)),
                    Text('Description: ${post.content}' ?? "", style: const TextStyle(fontSize: 14)),

                    if (post.image != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildMediaWidget(post.image.toString())),
                    ] else ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset("assets/images/Card.png", height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],

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
                            var data = {"type": "user-posts", "postId": post.id.toString()};
                            controller.likeOrUnlikePost(data, index);
                          },
                          child: Icon(post.isLikePost == false ? Icons.thumb_up_alt_outlined : Icons.thumb_up, size: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(post.cCount?.userpostlikes?.toString() ?? "0"),

                        const SizedBox(width: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => CommentsScreenOnPost(postId: post.id.toString()));
                              },
                              child: Icon(Icons.comment_outlined, size: 18),
                            ),
                            SizedBox(width: 4),
                            Text(post.cCount?.userpostcomments != null ? post.cCount!.userpostcomments.toString() : "0"),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text(post.views.toString()),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            controller.savePostToggle(post.id.toString(), index);
                          },
                          child: Icon(post.isSavePost == false ? Icons.bookmark_border : Icons.bookmark_added, size: 18),
                        ),
                        const SizedBox(width: 4),
                        const Text("Save"),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
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
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.black,
        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
      );
      // Later: integrate `video_player` package for playback
    } else if (extension == 'pdf') {
      // ✅ PDF
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.red[100],
        child: const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50)),
      );
    } else if (['doc', 'docx'].contains(extension)) {
      // ✅ Word document
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.blue[100],
        child: const Center(child: Icon(Icons.description, color: Colors.blue, size: 50)),
      );
    } else {
      // ❌ Unknown file type
      return _placeholder();
    }
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: const [
            Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 16),
            _CommentWidget(user: "Julia Michael", comment: "Love this!"),
            _CommentWidget(user: "Shelley", comment: "Haha!"),
          ],
        ),
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
          const CircleAvatar(radius: 16, backgroundImage: AssetImage("assets/icons/Frame 1686560584.png")),
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
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top + arrowSize, rect.width, rect.height - arrowSize), const Radius.circular(8));
    final path = Path()..addRRect(r);
    final centerX = rect.left + rect.width - 20;
    path.moveTo(centerX, rect.top + arrowSize);
    path.lineTo(centerX - 6, rect.top);
    path.lineTo(centerX + 6, rect.top);
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
