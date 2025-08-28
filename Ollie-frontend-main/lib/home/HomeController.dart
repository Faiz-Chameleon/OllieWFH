// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  var completedTasks = [true, false].obs;

  final features = [
    {"title": "Care Circle", "desc": "Stay connected with a community that cares.", "img": "assets/icons/House.png"},
    {"title": "Games", "desc": "Fun exercises to keep your mind sharp!", "img": "assets/icons/House.png"},
    {"title": "Blogs", "desc": "Explore interesting reads for seniors.", "img": "assets/icons/House.png"},
    {"title": "Tips", "desc": "Everyday tips for healthy living.", "img": "assets/icons/House.png"},
  ];

  String get today => DateFormat('EEE, d MMM yyyy').format(DateTime.now());

  void toggleTask(int index) {
    completedTasks[index] = !completedTasks[index];
  }
}
