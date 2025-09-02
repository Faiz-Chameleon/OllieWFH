// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/Volunteers/socket_controller.dart';
import 'package:ollie/home/Dailytask/easy_date_picker_controller.dart';
import 'package:ollie/home/Dailytask/easy_date_picker_demo.dart';
import 'package:ollie/home/HomeController.dart';

import 'package:ollie/home/notifications/notificatins_screen.dart';
import 'package:ollie/home/sos/sos_screen.dart';
import 'package:ollie/myprofile/my_profile_screen.dart';
import 'package:ollie/request_status.dart';

class Home_Screen extends StatefulWidget {
  Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final HomeController controller = Get.put(HomeController());
  final SocketController socketController = Get.put(SocketController());
  final UserController userController = Get.find<UserController>();
  final EasyDatePickerController taskController = Get.put(EasyDatePickerController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketController.connectSocket();
      taskController.userTaskByDateOnHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              80.verticalSpace,
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => MyProfileScreen(), transition: Transition.fadeIn);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: userController.user.value?.image != null && userController.user.value?.image!.isNotEmpty == true
                              ? NetworkImage(userController.user.value!.image!)
                              : const AssetImage("assets/icons/Frame 1686560584.png") as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final userController = Get.find<UserController>();
                              userController.logout();
                            },
                            child: Text("Hi ${userController.user.value?.firstName}!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          Text(controller.today, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => NotificationsScreen(), transition: Transition.fadeIn);
                        },
                        child: Image.asset("assets/icons/Vector (2).png", scale: 4),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Image.asset("assets/icons/Vector (1).png", scale: 4),
                              const SizedBox(width: 5),
                              const Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Tasks
              GestureDetector(
                onTap: () {
                  Get.to(() => EasyDatePickerDemoScreen(), transition: Transition.fadeIn);
                  // Get.to(() => TodoListScreen(), transition: Transition.fadeIn);
                },
                child: Container(
                  width: 1.sw,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFFF1C5), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      const Text("See how much you have achieved today!", style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 10),
                      Obx(() {
                        if (taskController.getTaskStatusOnHome.value == RequestStatus.loading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (taskController.getTaskStatusOnHome.value == RequestStatus.error) {
                          return Center(child: Text("Failed to load tasks"));
                        } else {
                          return Column(
                            children: [
                              // Check if the task list is empty or not
                              if (taskController.tasksOnHome.isEmpty)
                                Text("No tasks for today")
                              else
                                ...taskController.tasksOnHome.map((task) {
                                  return Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: TaskTile(
                                      text: task['taskName'] ?? "No task name",
                                      isDone: task['markAsComplete'] ?? false,
                                      onTap: () => taskController.markTaskAsCompleted(task['id']),
                                    ),
                                  );
                                }).toList(),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ad Placeholder
              // Container(
              //   height: 60,
              //   width: double.infinity,
              //   color: const Color(0xFFEFE1D0),
              //   child: const Center(
              //     child: Text("ADVERTISEMENT", style: TextStyle(color: Colors.black45)),
              //   ),
              // ),

              // Features Grid
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 3.2,
                      child: GestureDetector(
                        onTap: () {
                          final bottomController = Get.find<Bottomcontroller>();
                          bottomController.updateIndex(1);
                          Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
                        },
                        child: FeatureCard(
                          title: "Care Circle",
                          description: "Stay connected with a community that cares.",
                          backgroundImage: "assets/images/satisfied.png",
                          backgroundImageAlignment: Alignment.topRight,
                          backgroundImageHeight: 200,
                          backgroundImagePadding: const EdgeInsets.only(top: 0, left: 0),
                        ),
                      ),
                    ),

                    // StaggeredGridTile.count(
                    //   crossAxisCellCount: 2,
                    //   mainAxisCellCount: 1.9,
                    //   child: FeatureCard(title: "Games", description: "Fun exercises to keep your mind sharp!"),
                    // ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 5.1,
                      child: GestureDetector(
                        onTap: () {
                          final bottomController = Get.find<Bottomcontroller>();
                          bottomController.updateIndex(3);
                          Get.to(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
                        },
                        child: FeatureCard(
                          title: "Blogs & Articles",
                          description: "Your go-to space for tips and guidance!",
                          backgroundImage: "assets/images/Layer_1.png",
                          backgroundImageAlignment: Alignment.topRight,
                          backgroundImageHeight: 200,
                          backgroundImagePadding: const EdgeInsets.only(top: 8, right: 0),
                        ),
                      ),
                    ),

                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1.9,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => SOSScreen(), transition: Transition.fadeIn);
                        },

                        child: FeatureCard(title: "SOS", description: "Quick access to help when you need it."),
                      ),
                    ),
                  ],
                ),
              ),
              100.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String text;
  final bool isDone;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.text, required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? const Color(0xFFF4BD2A) : Colors.grey),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                color: isDone ? Colors.black38 : Colors.black87,
              ),
            ),
          ],
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
      decoration: BoxDecoration(color: const Color(0xFFFFF1C5), borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          // Background image
          if (backgroundImage != null)
            Align(
              alignment: backgroundImageAlignment,
              child: Padding(
                padding: backgroundImagePadding,
                child: Image.asset(backgroundImage!, height: backgroundImageHeight),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
