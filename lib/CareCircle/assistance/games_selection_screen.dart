import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ollie/CareCircle/assistance/game_2048.dart';
import 'package:ollie/CareCircle/assistance/pac_man_game.dart';
import 'package:ollie/CareCircle/assistance/your_post_screen.dart';
import 'package:ollie/Constants/constants.dart';

import 'tetris_game.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final gameWidgets = <({String title, String image, Widget Function() screen})>[
      (title: 'Tic Tac Toe', image: 'assets/images/zac-cain-4ETshgrhbJw-unsplash.png', screen: () => YourPostsScreen()),
      (title: 'Pac-Man', image: 'assets/images/zac-cain-4ETshgrhbJw-unsplash (2).png', screen: () => PacmanGame()),
      (title: 'Tetris', image: 'assets/images/zac-cain-4ETshgrhbJw-unsplash (3).png', screen: () => TetrisGame()),
      (title: '2048', image: 'assets/images/zac-cain-4ETshgrhbJw-unsplash (4).png', screen: () => Game2048()),

      // add more here...
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3DD),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: BGcolor,
        elevation: 0,

        title: const Text(
          "Games",
          style: TextStyle(color: Black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Image.asset("assets/icons/MagnifyingGlass.png", scale: 4),
                const SizedBox(width: 10),

                // GestureDetector(
                //   onTap: () {
                //     Get.to(() => NotificationsScreen(), transition: Transition.fadeIn);
                //   },
                //   child: Image.asset("assets/icons/Vector (2).png", scale: 4),
                // ),
                const SizedBox(width: 10),

                // GestureDetector(
                //   onTap: () {
                //     Get.to(() => CreditsSubscriptionScreen(), transition: Transition.fadeIn);
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     decoration: BoxDecoration(color: kprimaryColor, borderRadius: BorderRadius.circular(20)),
                //     child: Row(
                //       children: [
                //         Image.asset("assets/icons/Vector (1).png", scale: 4),
                //         const SizedBox(width: 5),
                //         const Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: gameWidgets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: .9,
          ),
          itemBuilder: (context, index) {
            final item = gameWidgets[index];
            return GestureDetector(
              onTap: () => Get.to(item.screen(), transition: Transition.fadeIn), // 👈 routes per index
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(item.image, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigate to game screen
        debugPrint("Tapped on $title");
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107), // yellow background like your screenshot
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }
}
