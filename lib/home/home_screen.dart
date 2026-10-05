// ignore_for_file: prefer_const_constructors_in_immutables, unnecessary_to_list_in_spreads, unused_import, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/Dailytask/task_widgets.dart';
import 'package:ollie/home/Dailytask/today_tasks_card.dart';
import 'package:ollie/home/HomeController.dart';
import 'package:ollie/home/Supplements/supplements_screen.dart';

import 'package:ollie/home/notifications/notificatins_screen.dart';
import 'package:ollie/home/sos/sos_screen.dart';
import 'package:ollie/myprofile/my_profile_screen.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class Home_Screen extends StatefulWidget {
  Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final HomeController controller = Get.put(HomeController());
  final SocketController socketController = Get.find<SocketController>();
  final UserController userController = Get.find<UserController>();
  final TaskController taskController = findTaskController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketController.connectSocket();
      taskController.loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      body: Container(
        color: BackgroundColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 12,
              bottom: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                80.verticalSpace,
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => MyProfileScreen(),
                                transition: Transition.fadeIn,
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  userController.user.value?.image != null &&
                                      userController
                                              .user
                                              .value
                                              ?.image!
                                              .isNotEmpty ==
                                          true
                                  ? NetworkImage(
                                      userController.user.value!.image!,
                                    )
                                  : const AssetImage(
                                          "assets/icons/Frame 1686560584.png",
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hi ${userController.user.value?.firstName ?? ''}!",
                                style: GoogleFonts.darkerGrotesque(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveFontSize(
                                    26,
                                    min: 22,
                                    max: 30,
                                  ),
                                ),
                              ),
                              Text(
                                controller.today,
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: responsiveFontSize(
                                    18,
                                    min: 16,
                                    max: 22,
                                  ),
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => NotificationsScreen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: Image.asset(
                            "assets/icons/Vector (2).png",
                            scale: 4,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TodayTasksCard(controller: taskController),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(bottom: 110.h),
                  child: StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    children: [
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 2.8,
                        child: GestureDetector(
                          onTap: () {
                            final bottomController =
                                Get.find<Bottomcontroller>();
                            bottomController.updateIndex(1);
                            Get.to(
                              () => ConvexStyledBarScreen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: FeatureCard(
                            title: "Care Circle",
                            description:
                                "Stay connected with a community that cares.",
                            backgroundImage: "assets/images/satisfied.png",
                            backgroundImageAlignment: Alignment.topRight,
                            backgroundImageHeight: 200,
                            backgroundImagePadding: const EdgeInsets.only(
                              top: 0,
                              left: 0,
                            ),
                          ),
                        ),
                      ),

                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1.9,
                        child: GestureDetector(
                          onTap: () {
                            final bottomController =
                                Get.find<Bottomcontroller>();
                            bottomController.updateIndex(4);
                            // Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
                          },
                          child: FeatureCard(
                            title: "Games",
                            description:
                                "Fun exercises to keep your mind sharp!",
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 2.8,
                        child: GestureDetector(
                          onTap: () {
                            final bottomController =
                                Get.find<Bottomcontroller>();
                            bottomController.updateIndex(3);
                            Get.to(
                              () => ConvexStyledBarScreen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: FeatureCard(
                            title: "Blogs & Articles",
                            description:
                                "Your go-to space for tips and guidance!",
                            backgroundImage: "assets/images/Layer_1.png",
                            backgroundImageAlignment: Alignment.topRight,
                            backgroundImageHeight: 200,
                            backgroundImagePadding: const EdgeInsets.only(
                              top: 8,
                              right: 0,
                            ),
                          ),
                        ),
                      ),

                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1.9,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => SOSScreen(),
                              transition: Transition.fadeIn,
                            );
                          },

                          child: FeatureCard(
                            title: "SOS",
                            description:
                                "Quick access to help when you need it.",
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1.9,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => const SupplementsScreen(),
                              transition: Transition.fadeIn,
                            );
                          },
                          child: FeatureCard(
                            title: "Supplements",
                            description: "Track daily doses and reminders.",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String? backgroundImage;
  final Alignment backgroundImageAlignment;
  final double backgroundImageHeight;
  final EdgeInsets backgroundImagePadding;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.backgroundImage,
    this.backgroundImageAlignment = Alignment.topRight,
    this.backgroundImageHeight = 120,
    this.backgroundImagePadding = const EdgeInsets.only(top: -20, right: -10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1C5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background image
          if (backgroundImage != null)
            Align(
              alignment: backgroundImageAlignment,
              child: Padding(
                padding: backgroundImagePadding,
                child: Image.asset(
                  backgroundImage!,
                  height: backgroundImageHeight,
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: responsiveFontSize(26, min: 22, max: 30),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: responsiveFontSize(20, min: 18, max: 24),
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
