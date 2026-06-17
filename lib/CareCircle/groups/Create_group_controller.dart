// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/group_repository.dart';
import 'package:ollie/HomeMain/HomeMain.dart';
import 'package:ollie/HomeMain/bottomController.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';
import 'package:path_provider/path_provider.dart';

class CreateGroupController extends GetxController {
  final GroupRepository groupsRepository = GroupRepository();
  final description = "".obs;
  final descriptionController = TextEditingController();

  var selectedImage = Rx<File?>(null);

  var groupName = "".obs;
  final groupNameController = TextEditingController();
  final groupPrivacy = "PUBLIC".obs;

  void selectGroupPrivacy(String value) {
    if (value == "PUBLIC" || value == "PRIVATE") {
      groupPrivacy.value = value;
    }
  }

  void clearGroupName() {
    groupName.value = "";
    groupNameController.clear();
    groupPrivacy.value = "PUBLIC";
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

    if (file == null) {
      createGrouptRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", "Please select a group image");
      return;
    }

    final fileToSend = await _compressedGroupImage(File(file.path));
    if (await fileToSend.length() > 900 * 1024) {
      createGrouptRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", "Please choose a smaller group image");
      return;
    }

    final requestData = Map<String, dynamic>.from(data);
    requestData.addAll(await _getGroupLocationPayload());

    final result = await groupsRepository.createGroups(requestData, fileToSend);
    if (result['success'] == true) {
      createGrouptRequestStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "");
      clearAll();
      navigateToCareCircle(1);
    } else {
      createGrouptRequestStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  void navigateToCareCircle(int tabIndex) {
    final bottomController = Get.isRegistered<Bottomcontroller>()
        ? Get.find<Bottomcontroller>()
        : Get.put(Bottomcontroller());
    bottomController.updateIndex(1);

    CareCircleController.pendingInitialTab = tabIndex;
    final careController = Get.isRegistered<CareCircleController>()
        ? Get.find<CareCircleController>()
        : Get.put(CareCircleController());
    careController.changeTab(tabIndex);

    final navigatorState = Get.key.currentState;
    if (navigatorState?.canPop() ?? false) {
      navigatorState!.popUntil((route) => route.isFirst);
    } else {
      Get.offAll(() => ConvexStyledBarScreen(), transition: Transition.fadeIn);
    }

    Future.microtask(() => bottomController.updateIndex(1));
  }

  Future<Map<String, dynamic>> _getGroupLocationPayload() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return {};

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return {};
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      String? city;
      String? country;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = place.locality?.isNotEmpty == true
              ? place.locality
              : place.subAdministrativeArea;
          country = place.country;
        }
      } catch (_) {}

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        if (city != null && city.isNotEmpty) 'city': city,
        if (country != null && country.isNotEmpty) 'country': country,
      };
    } catch (_) {
      return {};
    }
  }

  Future<File> _compressedGroupImage(File source) async {
    final sourceSize = await source.length();
    if (sourceSize <= 900 * 1024) {
      return source;
    }

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/group_image_${DateTime.now().microsecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      source.path,
      targetPath,
      minWidth: 800,
      minHeight: 800,
      quality: 60,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressed == null) {
      return source;
    }

    final compressedFile = File(compressed.path);
    if (await compressedFile.length() > sourceSize) {
      return source;
    }

    return compressedFile;
  }
}
