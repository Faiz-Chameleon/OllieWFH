import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ollie/Models/comment_model.dart';
import 'package:ollie/blogs/blog_comments_screen.dart';
import 'package:ollie/blogs/blogs_controller.dart';
import 'package:ollie/request_status.dart';

class BlogDetailScreen extends StatefulWidget {
  final BlogsController controller;
  final String? blogId;

  const BlogDetailScreen({super.key, required this.controller, this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getIndividualBlogDetails(widget.blogId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      body: Obx(() {
        if (widget.controller.getIndividuaBlogDetailsStatus.value ==
            RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final blog = widget.controller.completeBlogData.value.data;
        if (blog == null) {
          return const Center(child: Text("No data found"));
        }
        return Column(
          children: [
            Stack(
              children: [
                // Blog Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  child: Image.network(
                    blog.image ??
                        "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg", // Replace with your image URL
                    width: double.infinity,
                    height: 280.h,
                    fit: BoxFit.cover,
                  ),
                ),
                // Top bar
                Positioned(
                  top: 34.h,
                  left: 16.w,
                  right: 16.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(
                        onPressed: () {
                          Get.back();
                        },
                        color: Colors.white,
                      ),
                      Icon(Icons.bookmark_border, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.verticalSpace,
                      // Tags
                      Wrap(
                        spacing: 10,
                        children: [
                          _tag(blog.category?.name ?? "N/A"),
                          // _tag("6 min read"),
                          _tag(
                            widget.controller.timeAgo(
                              blog.createdAt.toString(),
                            ),
                          ),
                          _tag("Sponsored", bgColor: Color(0xFFFFE08A)),
                        ],
                      ),
                      16.verticalSpace,
                      // Title
                      Text(
                        blog.title ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      20.verticalSpace,
                      // Author + Likes + Comments
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.amber,
                            radius: 16,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          8.horizontalSpace,
                          const Text(
                            "Jean Prangley",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Obx(() {
                            final blog =
                                widget.controller.completeBlogData.value.data;
                            final isLoading =
                                widget
                                    .controller
                                    .likeOrUnlikeBlogStatus
                                    .value ==
                                RequestStatus.loading;

                            if (blog == null) {
                              return const SizedBox.shrink(); // Or handle null safely
                            }

                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      await widget.controller.likeOrUnlikeBlog(
                                        blog.id!,
                                      );
                                    },
                              child: Row(
                                children: [
                                  if (isLoading)
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      blog.isLiked == true
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_alt_outlined,
                                      size: 18,
                                      color: blog.isLiked == true
                                          ? Colors.red
                                          : Colors.grey.shade700,
                                    ),
                                  4.horizontalSpace,
                                  Text(
                                    "${blog.cCount?.likes ?? 0}",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          16.horizontalSpace,
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentTreeScreen(
                                    blogId: blog.id.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  size: 18,
                                  color: Colors.grey.shade700,
                                ),
                                4.horizontalSpace,
                                Text(
                                  "${blog.cCount?.comments ?? 0}",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),

                          16.horizontalSpace,
                        ],
                      ),
                      24.verticalSpace,
                      // Content
                      Text(
                        blog.content ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      40.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _tag(String label, {Color bgColor = const Color(0xffF5F5F5)}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label, style: TextStyle(fontSize: 12.sp)),
    );
  }

  Widget _iconLabel(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        4.horizontalSpace,
        Text(count, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }

  final String dummyContent = '''
Dumplings are a beloved dish found in cuisines worldwide, from Chinese jiaozi to Polish pierogi and Japanese gyoza. These bite-sized delights typically consist of dough wrapped around a savory or sweet filling, which can include meat, vegetables, or even fruit.

They can be steamed, boiled, fried, or baked, each method offering a unique texture and taste. Dumplings are not just about flavor—they hold cultural significance, often symbolizing luck and togetherness in various traditions. Whether enjoyed as comfort food or a festive treat, dumplings are a delicious way to explore global flavors in a single bite!

Beyond their delicious taste, dumplings have a rich history that dates back thousands of years. In China, they are often served during the Lunar New Year to bring prosperity.

So next time you enjoy a dumpling, you're not just savoring a tasty treat—you're biting into a piece of culinary history.
''';
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
