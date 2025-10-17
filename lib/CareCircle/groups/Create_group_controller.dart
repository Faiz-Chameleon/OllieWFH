// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/care_circle_screen.dart';
import 'package:ollie/CareCircle/group_repository.dart';
import 'package:ollie/CareCircle/groups/groups_screen.dart';
import 'package:ollie/CareCircle/groups/see_all_groups.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/request_status.dart';

class CreateGroupController extends GetxController {
  final GroupRepository groupsRepository = GroupRepository();
  final description = "".obs;
  final descriptionController = TextEditingController();

  var selectedImage = Rx<File?>(null);

  var groupName = "".obs;
  final groupNameController = TextEditingController();

  void clearGroupName() {
    groupName.value = "";
    groupNameController.clear();
  }

  void clearAll() {
    description.value = "";
    descriptionController.clear();

    groupName.value = "";
    groupNameController.clear();

    selectedImage.value = null;
  }

  var createGrouptRequestStatus = RequestStatus.idle.obs;
  Future<void> createGroupsForChat(data, file) async {
    createGrouptRequestStatus.value = RequestStatus.loading;
    final fileToSend = File(file.path);
    final result = await groupsRepository.createGroups(data, fileToSend);
    if (result['success'] == true) {
      createGrouptRequestStatus.value = RequestStatus.success;
      Get.snackbar("Success", result['message'] ?? "");
      clearAll();
      navigateToCareCircle(1);
    } else {
      createGrouptRequestStatus.value = RequestStatus.error;
      Get.snackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void navigateToCareCircle(int tabIndex) {
    final bottomController = Get.find<Bottomcontroller>();
    bottomController.updateIndex(0);

    Get.to(() => Care_Circle_screen());

    final careController = Get.find<CareCircleController>();
    careController.changeTab(tabIndex);
  }
}
