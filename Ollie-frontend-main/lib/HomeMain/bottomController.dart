// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/assistance/games_selection_screen.dart';

import 'package:ollie/CareCircle/care_circle_screen.dart';
import 'package:ollie/blogs/blogs_screen.dart';
import 'package:ollie/home/home_screen.dart';

import '../olliebot/ollie_bot_screen.dart';

class Bottomcontroller extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<Widget> screens = [Home_Screen(), Care_Circle_screen(), OllieScreen(), BlogsScreen(), GameSelectionScreen()];
  updateIndex(int Index) {
    selectedIndex.value = Index;
    update();
  }
}
