import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import '../care_circle_controller.dart';

class SavedPostsScreen extends StatelessWidget {
  SavedPostsScreen({super.key});
  final CareCircleController controller = Get.put(CareCircleController());

  final List<Map<String, dynamic>> savedPosts = [
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "Ever caught your pet doing something hilarious? Tell us the most mischievous thing your pet has ever done!",
      "image": "assets/images/Card (1).png",
    },
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "Calling all pet lovers! Drop a pic of your furry (or feathery) friend and tell us their funniest habit!",
      "image": "assets/images/Card (1).png",
    },
    {
      "user": "Shelley",
      "time": "9:20 AM",
      "text": "What's your pet’s favorite treat? Homemade or store-bought, share your top pet snack recommendations!",
      "image": null,
    },
    {"user": "Shelley", "time": "9:20 AM", "text": "Look at this adorable moment caught on camera!", "image": "assets/images/Card.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BGcolor,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Saved Posts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          itemCount: savedPosts.length + 1, // +1 for the ad block
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final post = savedPosts[index > 3 ? index - 1 : index];

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage("assets/icons/Frame 1686560584.png"), // Replace with actual profile if available
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post["user"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(post["time"], style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.more_horiz, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Post Text
                  Text(post["text"], style: const TextStyle(fontSize: 14)),

                  // Optional Image
                  if (post["image"] != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(post["image"], height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Reaction Row
                  Row(
                    children: const [
                      Icon(Icons.thumb_up_alt_outlined, size: 18),
                      SizedBox(width: 4),
                      Text("634"),
                      SizedBox(width: 16),
                      Icon(Icons.comment_outlined, size: 18),
                      SizedBox(width: 4),
                      Text("634"),
                      SizedBox(width: 16),
                      Icon(Icons.remove_red_eye_outlined, size: 18),
                      SizedBox(width: 4),
                      Text("634"),
                      Spacer(),
                      Icon(Icons.bookmark, size: 18),
                      SizedBox(width: 4),
                      Text("Saved"),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
