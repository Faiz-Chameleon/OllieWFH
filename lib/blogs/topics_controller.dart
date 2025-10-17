// lib/controllers/blog_category_controller.dart
import 'package:get/get.dart';

class BlogCategoryController extends GetxController {
  final String category;
  BlogCategoryController(this.category);

  final blogs = <Map<String, dynamic>>[].obs;
  final selectedSort = "Trending".obs;

  @override
  void onInit() {
    super.onInit();
    loadBlogs();
  }

  void loadBlogs() {
    final allBlogsMap = {
      "Wellness Plans": [
        {"title": "Heart-Healthy Eating: A Simple Plan to Get Started", "image": "assets/images/Frame 1686560355.png"},
        {"title": "What to Eat This Week: A 7-Day Wellness Meal Plan", "image": "assets/images/Frame 1686560354.png"},
        {"title": "Foods That Fuel: Nutrition Tips for Every Age", "image": "assets/images/Frame 1686560367.png"},
        {"title": "Emotional Fitness: Why It Matters Just as Much", "image": "assets/images/Frame 1686560355.png"},
      ],
      "News": [
        {"title": "The Future of Smart Homes: What’s Next in Tech?", "image": "assets/images/Frame 1686560354.png", "sponsored": true},
        {"title": "How to Spot and Avoid Financial Scams in 2025", "image": "assets/images/Frame 1686560355.png"},
        {"title": "Climate Change Report Warns of Extreme Weather in 2025", "image": "assets/images/Frame 1686560367.png", "sponsored": true},
        {"title": "Fire Safety Tips for Older Adults Living Alone", "image": "assets/images/Frame 1686560354.png", "sponsored": true},
        {"title": "How Sleep Affects Brain Health as You Age", "image": "assets/images/Frame 1686560355.png"},
      ],
      "Food": [
        {"title": "Here’s What You Need To Know About Dumplings", "image": "assets/images/Frame 1686560355.png", "sponsored": true},
        {"title": "Superfoods for a Healthier You: What to Eat & Why", "image": "assets/images/Frame 1686560354.png"},
        {"title": "Easy & Nutritious Meals for Busy Days", "image": "assets/images/Frame 1686560367.png"},
        {"title": "Truth About Processed Foods: What You Need to Know", "image": "assets/images/Frame 1686560355.png", "sponsored": true},
        {"title": "How to Reduce Food Waste & Save Money", "image": "assets/images/Frame 1686560354.png", "sponsored": true},
      ],
      "Fitness": [
        {"title": "Gentle Exercises to Keep You Active at Any Age", "image": "assets/images/Frame 1686560355.png", "sponsored": true},
        {"title": "The Importance of Stretching & Flexibility", "image": "assets/images/Frame 1686560354.png"},
        {"title": "Strength Training for Beginners: Where to Start", "image": "assets/images/Frame 1686560367.png", "sponsored": true},
        {"title": "Simple At-Home Workouts for Strength & Balance", "image": "assets/images/Frame 1686560355.png"},
        {"title": "How Walking Every Day Can Improve Your Health", "image": "assets/images/Frame 1686560354.png", "sponsored": true},
      ],
      "Pets": [
        {"title": "Top Tips for Taking Care of Senior Pets", "image": "assets/images/Frame 1686560355.png"},
        {"title": "Healthy Diets for Dogs & Cats", "image": "assets/images/Frame 1686560367.png"},
        {"title": "How to Train Your Pet at Home", "image": "assets/images/Frame 1686560354.png"},
      ],
      "Hobbies": [
        {"title": "Creative Hobby Ideas for Every Age", "image": "assets/images/Frame 1686560367.png"},
        {"title": "Gardening for Mindfulness & Fun", "image": "assets/images/Frame 1686560354.png"},
        {"title": "Simple DIY Projects for Home Decor", "image": "assets/images/Frame 1686560355.png"},
      ],
      "Legal Aid": [
        {"title": "Understanding Power of Attorney: What You Need to Know", "image": "assets/images/Frame 1686560354.png", "sponsored": true},
        {"title": "Estate Planning: Protecting Your Legacy", "image": "assets/images/Frame 1686560355.png"},
        {"title": "Common Scams & How to Stay Safe", "image": "assets/images/Frame 1686560367.png", "sponsored": true},
      ],
      "Healthcare": [
        {"title": "Managing Chronic Pain Without Medication", "image": "assets/images/Frame 1686560354.png"},
        {"title": "How Preventive Screenings Save Lives", "image": "assets/images/Frame 1686560367.png"},
        {"title": "Telehealth: The Future of Accessible Care", "image": "assets/images/Frame 1686560355.png"},
      ],
      "Lifestyle": [
        {"title": "Decluttering Your Home: A Guide to Simple Living", "image": "assets/images/Frame 1686560355.png", "sponsored": true},
        {"title": "The Benefits of Meditation & Mindfulness", "image": "assets/images/Frame 1686560354.png"},
        {"title": "How to Stay Social & Engaged in Your Community", "image": "assets/images/Frame 1686560367.png"},
      ],
    };

    if (category == "All") {
      final all = allBlogsMap.values.expand((list) => list).toList();
      blogs.assignAll(all);
    } else {
      blogs.assignAll(allBlogsMap[category] ?? []);
    }
  }
}
