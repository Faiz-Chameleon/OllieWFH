// ignore_for_file: camel_case_types, use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/blogs/Blog_category_topics_screen.dart';
import 'package:ollie/blogs/blog_details_screen.dart';

import 'package:ollie/blogs/browes_topics_screen.dart';
import 'package:ollie/request_status.dart';
import 'blogs_controller.dart';
import 'latest_blogs_screen.dart';

class popular_screen extends StatefulWidget {
  final BlogsController controller;

  const popular_screen({super.key, required this.controller});

  @override
  State<popular_screen> createState() => _popular_screenState();
}

class _popular_screenState extends State<popular_screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.currentTab.value == "popular" ? widget.controller.loadBlogForTab(widget.controller.currentTab.value) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final blog = widget.controller.currentTab.value == 'popular'
                ? widget.controller.popularBlog.value
                : widget.controller.currentTab.value == 'trending'
                ? widget.controller.trendingBlog.value
                : widget.controller.recentBlog.value;

            if (widget.controller.getBlogStatus.value == RequestStatus.loading) {
              return Center(child: const CircularProgressIndicator());
            }

            if (blog == null) {
              return SizedBox(
                width: 0.9.sw,
                height: 250.h,
                child: Center(
                  child: Text(
                    "No blog found",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                Get.to(() => BlogDetailScreen(controller: widget.controller, blogId: blog.blog?.id));
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(blog.blog?.image ?? "", height: 200.h, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFFECA3), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              "Sponsored",
                              style: GoogleFonts.darkerGrotesque(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () async {
                              String fromWhere;
                              switch (widget.controller.currentTab.value) {
                                case 'popular':
                                  fromWhere = "popular";
                                  break;
                                case 'trending':
                                  fromWhere = "trending";
                                  break;
                                case 'recent':
                                  fromWhere = "recent";
                                  break;
                                default:
                                  fromWhere = "unknown"; // Or handle default case
                              }
                              await widget.controller.saveBlogToggle(blog.blog?.id ?? "", fromWhere); // Passing the new save state
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(blog.isSaveBlog == true ? Icons.bookmark : Icons.bookmark_border, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blog.blog?.title ?? "",
                            style: GoogleFonts.darkerGrotesque(
                              fontWeight: FontWeight.w700,
                              fontSize: 21.sp,
                              height: 1.15,
                              color: Colors.black87,
                            ),
                          ),
                          10.verticalSpace,
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 18.sp, color: Colors.black54),
                              SizedBox(width: 5.w),
                              Text(
                                blog.blog?.admin?.name ?? "",
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                widget.controller.timeAgo(blog.blog?.createdAt ?? ""),
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFFF3C2), borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  blog.blog?.category?.name ?? "",
                                  style: GoogleFonts.darkerGrotesque(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          20.verticalSpace,
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(color: Color(0xff1e18180d), borderRadius: BorderRadius.circular(12)),
          //   child: const Center(child: Text("ADVERTISEMENT")),
          // ),
          20.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Browse Topics",
                style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => BrowseTopicsScreen(controller: widget.controller), transition: Transition.fadeIn);
                },

                child: Text(
                  "See All",
                  style: GoogleFonts.darkerGrotesque(color: Colors.black54, fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Obx(() {
            if (widget.controller.getBlogTopicsStatus.value == RequestStatus.loading) {
              return Center(child: const CircularProgressIndicator());
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: widget.controller.blogsTopicNames.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () =>
                            Get.to(() => BlogCategoryScreen(category: topic.name ?? "", controller: widget.controller, topicId: topic.id.toString())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFE08A), borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            topic.name ?? "",
                            style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.w700, fontSize: 18.sp, color: Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          24.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Latest Blogs",
                style: GoogleFonts.darkerGrotesque(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => LatestBlogsScreen(controller: widget.controller), transition: Transition.fadeIn);
                },
                child: Text(
                  "See All",
                  style: GoogleFonts.darkerGrotesque(color: Colors.black54, fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          16.verticalSpace,
          Obx(() {
            final blogs = widget.controller.latestBlogsList;

            if (blogs.isEmpty) {
              return SizedBox(
                width: 0.9.sw,
                height: 250.h,
                child: Center(
                  child: Text(
                    "No blogs available",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: blogs.take(3).map((blog) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => BlogDetailScreen(controller: widget.controller, blogId: blog.id));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            blog.image ?? "", // ✅ Replace asset with blog image
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/images/placeholder.png", width: 60, height: 60), // optional fallback
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                blog.title ?? "No title",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              4.verticalSpace,
                              Text(
                                "${widget.controller.timeAgo(blog.createdAt ?? "")} · 6 min read", // optional fixed read time
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          100.verticalSpace,
        ],
      ),
    );
  }
}
