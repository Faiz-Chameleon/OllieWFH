// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, unnecessary_import, unused_element, use_full_hex_values_for_flutter_colors, avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ollie/Auth/login/user_controller.dart';

import 'package:ollie/CareCircle/assistance/game_font.dart';

class YourPostsScreen extends StatefulWidget {
  @override
  _YourPostsScreenState createState() => _YourPostsScreenState();
}

class _YourPostsScreenState extends State<YourPostsScreen> {
  final UserController userController = Get.find<UserController>();
  // --- Config ---
  final bool vsAI = true;
  static const String human = 'X';
  static const String ai = 'O';

  // Game state
  bool oTurn = false; // Human(X) starts -> it's NOT O's turn initially
  List<String> displayElement = List.filled(9, '');
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  bool gameOver = false;
  bool aiThinking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D6),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            width: 25.w,
            height: 25.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // background color
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.black),
            ),
          ),
        ),

        // title: Text(
        //   'Flutter Tetris',
        //   style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w700),
        // ),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        userController.user.value?.firstName ?? "",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(xScore.toString(), style: const TextStyle(fontSize: 20, color: Colors.black)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Bot',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(oScore.toString(), style: const TextStyle(fontSize: 20, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Don't allow taps when it's AI's turn or game over
                    if (gameOver || (_isAITurn() && vsAI) || displayElement[index].isNotEmpty) return;
                    _tapped(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1020),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(child: TicGlyph(mark: displayElement[index], size: 56)),
                  ),
                );
              },
            ),
          ),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       ElevatedButton(
          //         style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
          //         onPressed: _clearScoreBoard,
          //         child: const Text("Clear Score Board"),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // ----- GAMEPLAY -----
  void _tapped(int index) {
    if (gameOver || displayElement[index].isNotEmpty) return;

    setState(() {
      displayElement[index] = oTurn ? 'O' : 'X';
      filledBoxes++;
      oTurn = !oTurn;
    });

    _checkWinnerOrAI();
  }

  void _checkWinnerOrAI() {
    final winner = _winner(displayElement);
    if (winner != null) {
      _finish(winner);
      return;
    }
    if (filledBoxes == 9) {
      _showDrawDialog();
      return;
    }

    // If it's AI's turn, make a move with a short delay
    if (vsAI && _isAITurn() && !gameOver) {
      aiThinking = true;
      Future.delayed(const Duration(milliseconds: 300), _computerMove);
    }
  }

  bool _isAITurn() => (oTurn && ai == 'O') || (!oTurn && ai == 'X');

  // Heuristic: win -> block -> center -> corner -> side
  void _computerMove() {
    if (gameOver) return;

    int? move = _lineCompletionIndex(ai) ?? _lineCompletionIndex(human);
    move ??= displayElement[4].isEmpty ? 4 : null;

    move ??= [0, 2, 6, 8].firstWhere((i) => displayElement[i].isEmpty, orElse: () => -1);
    if (move == -1) {
      final sides = [1, 3, 5, 7].where((i) => displayElement[i].isEmpty).toList();
      move = sides.isNotEmpty ? sides.first : null;
    }

    if (move != null && displayElement[move].isEmpty) {
      setState(() {
        displayElement[move!] = ai;
        filledBoxes++;
        oTurn = !oTurn;
      });
    }
    aiThinking = false;

    final winner = _winner(displayElement);
    if (winner != null) {
      _finish(winner);
    } else if (filledBoxes == 9) {
      _showDrawDialog();
    }
  }

  // Returns index to complete a line for player p if available
  int? _lineCompletionIndex(String p) {
    const winLines = <List<int>>[
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final l in winLines) {
      final a = displayElement[l[0]], b = displayElement[l[1]], c = displayElement[l[2]];
      final vals = [a, b, c];
      if (vals.where((v) => v == p).length == 2 && vals.contains('')) {
        final idx = l[vals.indexOf('')];
        return displayElement[idx].isEmpty ? idx : null;
      }
    }
    return null;
  }

  String? _winner(List<String> b) {
    const lines = <List<int>>[
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final l in lines) {
      if (b[l[0]].isNotEmpty && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) {
        return b[l[0]]; // "X" or "O"
      }
    }
    return null;
  }

  void _finish(String winner) {
    gameOver = true;
    _showWinDialog(winner);
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }

  // ----- DIALOGS -----
  void _showWinDialog(String winner) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('" $winner " is Winner!!!'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Play Again"),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDrawDialog() {
    gameOver = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Draw"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  // ----- RESET -----
  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
      filledBoxes = 0;
      gameOver = false;
      // Human (X) starts each round
      oTurn = false;
    });
  }

  void _clearScoreBoard() {
    setState(() {
      xScore = 0;
      oScore = 0;
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
      filledBoxes = 0;
      gameOver = false;
      oTurn = false; // X starts again
    });
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

//     return
// Scaffold(
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
