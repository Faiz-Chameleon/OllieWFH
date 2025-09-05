// ignore_for_file: use_full_hex_values_for_flutter_colors, avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ollie/CareCircle/assistance/assistance_controller.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/interests/comments_screen_on_post.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Subscription/credits/credits_sreen.dart';
import 'package:ollie/home/notifications/notificatins_screen.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/widgets/showdilogbox.dart';

import '../../Volunteers/volunteers_scnreen.dart';

class YourPostsScreen extends StatefulWidget {
  @override
  _YourPostsScreenState createState() => _YourPostsScreenState();
}

class _YourPostsScreenState extends State<YourPostsScreen> {
  bool oTurn = true;

  // 1st player is O
  List<String> displayElement = ['', '', '', '', '', '', '', '', ''];
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player X',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(xScore.toString(), style: TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player O',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(oScore.toString(), style: TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _tapped(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                    child: Center(
                      child: Text(displayElement[index], style: TextStyle(color: Colors.white, fontSize: 35)),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // foreground
                    ),
                    onPressed: () {
                      _clearScoreBoard();
                    },
                    child: Text("Clear Score Board"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapped(int index) {
    setState(() {
      if (oTurn && displayElement[index] == '') {
        displayElement[index] = 'O';
        filledBoxes++;
      } else if (!oTurn && displayElement[index] == '') {
        displayElement[index] = 'X';
        filledBoxes++;
      }

      oTurn = !oTurn;
      _checkWinner();
    });
  }

  void _checkWinner() {
    // Checking rows
    if (displayElement[0] == displayElement[1] && displayElement[0] == displayElement[2] && displayElement[0] != '') {
      _showWinDialog(displayElement[0]);
    }
    if (displayElement[3] == displayElement[4] && displayElement[3] == displayElement[5] && displayElement[3] != '') {
      _showWinDialog(displayElement[3]);
    }
    if (displayElement[6] == displayElement[7] && displayElement[6] == displayElement[8] && displayElement[6] != '') {
      _showWinDialog(displayElement[6]);
    }

    // Checking Column
    if (displayElement[0] == displayElement[3] && displayElement[0] == displayElement[6] && displayElement[0] != '') {
      _showWinDialog(displayElement[0]);
    }
    if (displayElement[1] == displayElement[4] && displayElement[1] == displayElement[7] && displayElement[1] != '') {
      _showWinDialog(displayElement[1]);
    }
    if (displayElement[2] == displayElement[5] && displayElement[2] == displayElement[8] && displayElement[2] != '') {
      _showWinDialog(displayElement[2]);
    }

    // Checking Diagonal
    if (displayElement[0] == displayElement[4] && displayElement[0] == displayElement[8] && displayElement[0] != '') {
      _showWinDialog(displayElement[0]);
    }
    if (displayElement[2] == displayElement[4] && displayElement[2] == displayElement[6] && displayElement[2] != '') {
      _showWinDialog(displayElement[2]);
    } else if (filledBoxes == 9) {
      _showDrawDialog();
    }
  }

  void _showWinDialog(String winner) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("\" " + winner + " \" is Winner!!!"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // foreground
              ),
              child: Text("Play Again"),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }

  void _showDrawDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Draw"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // foreground
              ),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
    });

    filledBoxes = 0;
  }

  void _clearScoreBoard() {
    setState(() {
      xScore = 0;
      oScore = 0;
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
    });
    filledBoxes = 0;
  }
}

// class YourPostsScreen extends StatefulWidget {
//   YourPostsScreen({super.key});

//   @override
//   State<YourPostsScreen> createState() => _YourPostsScreenState();
// }

// class _YourPostsScreenState extends State<YourPostsScreen> {
//   final Assistance_Controller controller = Get.put(Assistance_Controller());

//   final CareCircleController careControllercontroller = Get.put(CareCircleController());

//   final RxBool taskCompleted = false.obs;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       careControllercontroller.yourCreatedPost();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (Get.arguments == true) {
//         Get.snackbar(
//           "Success",
//           "Your post has been created successfully!",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFFFFD680),
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         );
//       }
//     });

//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF3DD),
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         centerTitle: false,
//         automaticallyImplyLeading: false,
//         backgroundColor: BGcolor,
//         elevation: 0,
//         title: const Text(
//           "Your Posts",
//           style: TextStyle(color: Black, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 // Image.asset("assets/icons/MagnifyingGlass.png", scale: 4),
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(() => NotificationsScreen(), transition: Transition.fadeIn);
//                   },
//                   child: Image.asset("assets/icons/Vector (2).png", scale: 4),
//                 ),
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(20)),
//                     child: Row(
//                       children: [
//                         Image.asset("assets/icons/Vector (1).png", scale: 4),
//                         const SizedBox(width: 5),
//                         const Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             Expanded(
//               child: Obx(() {
//                 if (careControllercontroller.fetchingYourPostStatus.value == RequestStatus.loading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 // Error
//                 if (careControllercontroller.fetchingYourPostStatus.value == RequestStatus.error) {
//                   return const Center(child: Text("Something went wrong"));
//                 }

//                 // No posts
//                 if (careControllercontroller.yourPostList.isEmpty) {
//                   return const Center(child: Text("No posts available"));
//                 }
//                 return ListView.separated(
//                   itemCount: careControllercontroller.yourPostList.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (context, index) {
//                     final post = careControllercontroller.yourPostList[index];
//                     return Container(
//                       width: 1.sw,
//                       // height: 350.h,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 16,
//                                 backgroundImage: NetworkImage(post.user?.image ?? ""),
//                                 child: post.user?.image == null
//                                     ? Icon(Icons.person, size: 20) // Default icon when there is no image
//                                     // ignore: dead_code
//                                     : null,
//                               ),
//                               const SizedBox(width: 10),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(post.user?.firstName ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
//                                   Text(careControllercontroller.formatDate(post.createdAt ?? ""), style: const TextStyle(fontSize: 12)),
//                                 ],
//                               ),
//                               const Spacer(),
//                               PopupMenuButton(
//                                 shape: TooltipShapeBorder(),
//                                 itemBuilder: (context) => [const PopupMenuItem(value: 'report', child: Text("Report"))],
//                                 onSelected: (value) {},
//                                 icon: const Icon(Icons.more_horiz, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           Text("Title: ${post.title}", style: const TextStyle(fontSize: 14)),
//                           Text('Description: ${post.content}' ?? "", style: const TextStyle(fontSize: 14)),

//                           if (post.image != null) ...[
//                             const SizedBox(height: 10),
//                             ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildMediaWidget(post.image.toString())),
//                           ] else ...[
//                             const SizedBox(height: 10),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.asset("assets/images/Card.png", height: 150, width: double.infinity, fit: BoxFit.cover),
//                             ),
//                           ],

//                           // if (post.document != null) ...[
//                           //   const SizedBox(height: 10),
//                           //   Row(
//                           //     children: [
//                           //       const Icon(
//                           //         Icons.insert_drive_file,
//                           //         color: Colors.black,
//                           //       ),
//                           //       const SizedBox(width: 8),
//                           //       Expanded(
//                           //         child: Text(post.document!.path.split('/').last),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ],
//                           const SizedBox(height: 12),

//                           // Row(
//                           //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           //   children: [
//                           //     GestureDetector(
//                           //       onTap: () {
//                           //         var data = {"type": "user-posts", "postId": post.id.toString()};
//                           //         careControllercontroller.likeOrUnlikePost(data, index);
//                           //       },
//                           //       child: Icon(Icons.thumb_up_alt_outlined),
//                           //     ),
//                           //     const SizedBox(width: 4),
//                           //     Text(post.cCount?.userpostlikes?.toString() ?? "0"),

//                           //     const SizedBox(width: 16),
//                           //     Row(
//                           //       children: [
//                           //         GestureDetector(
//                           //           onTap: () {
//                           //             Get.to(() => CommentsScreenOnPost(postId: post.id.toString()));
//                           //           },
//                           //           child: Icon(Icons.comment_outlined, size: 18),
//                           //         ),
//                           //         SizedBox(width: 4),
//                           //         Text(post.cCount?.userpostcomments != null ? post.cCount!.userpostcomments.toString() : "0"),
//                           //       ],
//                           //     ),
//                           //     const SizedBox(width: 16),
//                           //     const Icon(Icons.remove_red_eye_outlined, size: 18),
//                           //     const SizedBox(width: 4),
//                           //     Text(post.views.toString()),
//                           //     const Spacer(),
//                           //     GestureDetector(
//                           //       onTap: () {
//                           //         careControllercontroller.savePostToggle(post.id.toString(), index);
//                           //       },
//                           //       child: Icon(Icons.bookmark_border, size: 18),
//                           //     ),
//                           //     const SizedBox(width: 4),
//                           //     const Text("Save"),
//                           //   ],
//                           // ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//                 // ListView(
//                 //   children: [
//                 //     // Obx(
//                 //     //   () => _buildPostCard(
//                 //     //     context,
//                 //     //     userName: "You",
//                 //     //     time: controller.formattedTime,
//                 //     //     category: controller.selectedCategory.value,
//                 //     //     message: "I need help with groceries, is anyone available?",
//                 //     //     latLng: controller.selectedLatLng.value,
//                 //     //     completed: taskCompleted.value,
//                 //     //     onTapComplete: () => taskCompleted.value = true,
//                 //     //   ),
//                 //     // ),
//                 //     const SizedBox(height: 16),
//                 //     Container(
//                 //       height: 70.h,
//                 //       color: Color(0xff1e18180d),
//                 //       alignment: Alignment.center,
//                 //       child: const Text("ADVERTISEMENT", style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.w500)),
//                 //     ),
//                 //   ],
//                 // );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMediaWidget(String url) {
//     final extension = url.split('.').last.toLowerCase();

//     if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
//       // ✅ Image
//       return Image.network(
//         url,
//         height: 150,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return _placeholder();
//         },
//       );
//     } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
//       // ✅ Video
//       return Container(
//         height: 150,
//         width: double.infinity,
//         color: Colors.black,
//         child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
//       );
//       // Later: integrate `video_player` package for playback
//     } else if (extension == 'pdf') {
//       // ✅ PDF
//       return Container(
//         height: 150,
//         width: double.infinity,
//         color: Colors.red[100],
//         child: const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 50)),
//       );
//     } else if (['doc', 'docx'].contains(extension)) {
//       // ✅ Word document
//       return Container(
//         height: 150,
//         width: double.infinity,
//         color: Colors.blue[100],
//         child: const Center(child: Icon(Icons.description, color: Colors.blue, size: 50)),
//       );
//     } else {
//       // ❌ Unknown file type
//       return _placeholder();
//     }
//   }

//   Widget _placeholder() {
//     return Container(
//       height: 150,
//       width: double.infinity,
//       color: Colors.grey[300],
//       child: const Icon(Icons.insert_drive_file, color: Colors.grey),
//     );
//   }
// }
