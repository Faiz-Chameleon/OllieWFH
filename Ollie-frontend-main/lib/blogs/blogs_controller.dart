import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/Models/all_blogs_topics_model.dart';
import 'package:ollie/Models/blog_topics_model.dart';
import 'package:ollie/Models/blogs_model.dart';
import 'package:ollie/Models/complete_blog_detail_model.dart';
import 'package:ollie/Models/latest_blogs_model.dart';
import 'package:ollie/blogs/blog_repository.dart';
import 'package:ollie/request_status.dart';

class BlogsController extends GetxController {
  var selectedTab = 0.obs;
  final topicData = [
    {"title": "Wellness Plans"},
    {"title": "News"},
    {"title": "Food"},
    {"title": "Pets"},
    {"title": "Fitness"},
    {"title": "Hobbies"},
    {"title": "Legal Aid"},
    {"title": "Healthcare"},
    {"title": "Lifestyle"},
  ].obs;

  var topics = ["Wellness Plans", "News", "Food", "Pets", "Fitness", "Healthcare", "Hobbies", "Legal Aid", "News"].obs;

  var latestBlogs = [
    {"title": "Here’s What You Need To Know About Dumplings", "category": "Food", "image": "assets/images/Frame 1686560355.png"},
    {"title": "New Breakthrough in Arthritis Treatment Brings Hope", "category": "News", "image": "assets/images/Frame 1686560354.png"},
    {"title": "How Sleep Affects Brain Health as You Age", "category": "Healthcare", "image": "assets/images/Frame 1686560367.png"},
  ].obs;

  Widget tabButton(String title, int index, BlogsController controller) {
    return Obx(
      () => GestureDetector(
        onTap: () => selectedTab.value = index,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            title,
            style: TextStyle(color: selectedTab.value == index ? Colors.black : Colors.grey, fontWeight: FontWeight.w600, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget topicPill(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFFFECA3), borderRadius: BorderRadius.circular(20)),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget featuredBlogCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset("assets/images/Frame 1686560355.png", height: 200.h, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFECA3), borderRadius: BorderRadius.circular(12)),
                  child: const Text("Sponsored", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.bookmark_border, size: 18),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Here’s What You Need To Know About Dumplings", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                12.verticalSpace,
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text("Jean Prangley", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Text("· 6 min read", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3C2), borderRadius: BorderRadius.circular(12)),
                      child: const Text("Food", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget latestBlogItem(String title, String category, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                4.verticalSpace,
                Text("1 day ago · 6 min read", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final BlogRepository blogRepository = BlogRepository();

  var getBlogStatus = RequestStatus.idle.obs;

  final Rxn<BlogDetails> popularBlog = Rxn<BlogDetails>();
  final Rxn<BlogDetails> trendingBlog = Rxn<BlogDetails>();
  final Rxn<BlogDetails> recentBlog = Rxn<BlogDetails>();

  Future<void> getBlogs(String type) async {
    getBlogStatus.value = RequestStatus.loading;

    final result = await blogRepository.getBlogsWithRespectToCategories(type);
    if (result['success'] == true) {
      final blogModel = BlogsModel.fromJson(result);
      currentTab.value == "";

      switch (type.toString()) {
        case 'popular':
          popularBlog.value = blogModel.data;
          break;
        case 'trending':
          trendingBlog.value = blogModel.data;
          break;
        case 'recent':
          recentBlog.value = blogModel.data;
          break;
      }
      getBlogStatus.value = RequestStatus.success;
    } else {
      getBlogStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  String timeAgo(String isoString) {
    final createdAt = DateTime.parse(isoString).toLocal(); // Convert from UTC to local
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  RxList<BlogData> blogsTopicNames = <BlogData>[].obs;
  var getBlogTopicsStatus = RequestStatus.idle.obs;
  Future<void> getBlogsTopics() async {
    getBlogTopicsStatus.value = RequestStatus.loading;

    final result = await blogRepository.getBlogsTopics();
    if (result['success'] == true) {
      final topicModel = BlogTopics.fromJson(result);
      blogsTopicNames.assignAll(topicModel.data ?? []);
      getBlogTopicsStatus.value = RequestStatus.success;
    } else {
      getBlogTopicsStatus.value = RequestStatus.error;

      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var getLatestBlogsStatus = RequestStatus.idle.obs;
  RxList<Blogs> latestBlogsList = <Blogs>[].obs;

  Future<void> getLatestBlogs() async {
    getLatestBlogsStatus.value = RequestStatus.loading;

    final result = await blogRepository.getLatestBlogsList();
    if (result['success'] == true) {
      final blogsListModel = LatestBlogs.fromJson(result);
      latestBlogsList.assignAll(blogsListModel.data?.blogs ?? []);
      getLatestBlogsStatus.value = RequestStatus.success;
    } else {
      getLatestBlogsStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var getBlogsByTopicsStatus = RequestStatus.idle.obs;
  RxList<BlogsByItsTopics> blogsByTopicsList = <BlogsByItsTopics>[].obs;
  Future<void> getBlogsByCategory(String topicId) async {
    getBlogsByTopicsStatus.value = RequestStatus.loading;

    final result = await blogRepository.getBlogsByItsTopic(topicId);
    if (result['success'] == true) {
      final blogTopicsModel = AllBlogTopics.fromJson(result);
      blogsByTopicsList.assignAll(blogTopicsModel.data?.blogs ?? []);
      getBlogsByTopicsStatus.value = RequestStatus.success;
    } else {
      getBlogsByTopicsStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var getBlogsByTopicOnFilterStatus = RequestStatus.idle.obs;
  RxList<BlogsByItsTopics> blogsByTopicsListOnFilter = <BlogsByItsTopics>[].obs;
  Future<void> getBlogsByCategoryOnFilter(String topicName) async {
    getBlogsByTopicOnFilterStatus.value = RequestStatus.loading;

    final result = await blogRepository.getBlogsByItsTopicOnFilter(topicName);
    if (result['success'] == true) {
      final blogTopicsModel = AllBlogTopics.fromJson(result);
      blogsByTopicsListOnFilter.assignAll(blogTopicsModel.data?.blogs ?? []);
      getBlogsByTopicOnFilterStatus.value = RequestStatus.success;
    } else {
      getBlogsByTopicOnFilterStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  Rx<CompleteBlog> completeBlogData = CompleteBlog().obs;
  var getIndividuaBlogDetailsStatus = RequestStatus.idle.obs;
  Future<void> getIndividualBlogDetails(String blogId) async {
    getBlogsByTopicsStatus.value = RequestStatus.loading;

    final result = await blogRepository.getBlogDetails(blogId);
    if (result['success'] == true) {
      final blogTopicsModel = AllBlogTopics.fromJson(result);
      blogsByTopicsList.assignAll(blogTopicsModel.data?.blogs ?? []);
      completeBlogData.value = CompleteBlog.fromJson(result);
      getBlogsByTopicsStatus.value = RequestStatus.success;
    } else {
      getBlogsByTopicsStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var likeOrUnlikeBlogStatus = RequestStatus.idle.obs;
  Future<void> likeOrUnlikeBlog(String blogId) async {
    likeOrUnlikeBlogStatus.value = RequestStatus.loading;

    final result = await blogRepository.likeOrUnlikeBlog(blogId);
    if (result['success'] == true) {
      final action = result['data']['action'];
      final likeCount = result['data']['likeCount'];

      completeBlogData.update((val) {
        val?.data?.cCount?.likes = likeCount;
        val?.data?.isLiked = action == 'liked';
      });

      likeOrUnlikeBlogStatus.value = RequestStatus.success;
    } else {
      likeOrUnlikeBlogStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  // Track current tab
  var currentTab = "popular".obs;

  var isInitialDataLoaded = false.obs;

  // Load blog for specific tab
  Future<void> loadBlogForTab(String tabType) async {
    currentTab.value = tabType;
    await getBlogs(tabType);

    if (!isInitialDataLoaded.value) {
      await getBlogsTopics();
      await getLatestBlogs();
      isInitialDataLoaded.value = true;
    }
  }

  var saveAndUnsaveBlogStatus = RequestStatus.idle.obs;
  Future<void> saveBlogToggle(String blogId, String fromWhere) async {
    saveAndUnsaveBlogStatus.value = RequestStatus.loading;

    final result = await blogRepository.saveAndUnsaveBlog(blogId);
    if (result['success'] == true) {
      if (fromWhere == "popular") {
        popularBlog.update((val) {
          val?.isSaveBlog = true;
        });
      } else if (fromWhere == "trending") {
        trendingBlog.update((val) {
          val?.isSaveBlog = true;
        });
      } else {
        recentBlog.update((val) {
          val?.isSaveBlog = true;
        });
      }
      saveAndUnsaveBlogStatus.value = RequestStatus.success;
    } else {
      saveAndUnsaveBlogStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }
}
