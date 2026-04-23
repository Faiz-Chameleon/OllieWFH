import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ollie/home/Dailytask/device_time_zone_service.dart';
import 'package:ollie/home/home_repository.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/common/common.dart';

class EasyDatePickerController extends GetxController {
  final HomeRepository homeRepository = HomeRepository();
  // Observable for the focused date
  final focusedDate = DateTime.now().obs;

  // Observable list of tasks
  final tasks = <Map<String, dynamic>>[].obs;

  void setFocusedDate(DateTime date) {
    focusedDate.value = date;
    userTaskByDate();
  }

  void addTask({required String text, String? description, required DateTime date, String? time}) {
    tasks.add({'text': text, 'description': description ?? '', 'date': DateTime(date.year, date.month, date.day), 'time': time, 'done': false});
  }

  List<Map<String, dynamic>> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      final taskDate = task['date'] as DateTime;
      return taskDate.year == date.year && taskDate.month == date.month && taskDate.day == date.day;
    }).toList();
  }

  void toggleTask(int index, String taskID) {
    markTaskAsCompleted(taskID);
    tasks[index]['markAsComplete'] = !(tasks[index]['markAsComplete'] as bool);
    tasks.refresh();
  }

  // Helper method to format date for API (YYYY-MM-DD)
  String formatDateForAPI(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Helper method to format time for API (HH:MM:SS)
  String formatTimeForAPI(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dt);
  }

  Future<String> _getTimeZone() async {
    return DeviceTimeZoneService.getIanaTimeZone();
  }

  var createTaskStatus = RequestStatus.idle.obs;

  Future<void> userCreateTask({required String taskName, required String taskDescription, required DateTime date, required TimeOfDay time}) async {
    createTaskStatus.value = RequestStatus.loading;

    final payload = {
      "taskName": taskName,
      "taskDescription": taskDescription,
      "date": formatDateForAPI(date),
      "time": formatTimeForAPI(time),
      "timeZone": await _getTimeZone(),
    };

    final result = await homeRepository.createTask(payload);
    if (result['success'] == true) {
      await userTaskByDate();
      await userTaskByDateOnHome();
      createTaskStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "message required frontend");
    } else {
      createTaskStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var getTaskStatus = RequestStatus.idle.obs;

  Future<void> userTaskByDate() async {
    final formattedDate =
        "${focusedDate.value.day.toString().padLeft(2, '0')}-${focusedDate.value.month.toString().padLeft(2, '0')}-${focusedDate.value.year}";
    getTaskStatus.value = RequestStatus.loading;

    final result = await homeRepository.getUserTasksByDate(formattedDate);
    if (result['success'] == true) {
      getTaskStatus.value = RequestStatus.success;
      final List<dynamic> data = result['data'][0] ?? [];
      tasks.assignAll(data.cast<Map<String, dynamic>>());
    } else {
      getTaskStatus.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var getTaskStatusOnHome = RequestStatus.idle.obs;

  final tasksOnHome = <Map<String, dynamic>>[].obs;

  Future<void> userTaskByDateOnHome() async {
    final formattedDate =
        "${focusedDate.value.day.toString().padLeft(2, '0')}-${focusedDate.value.month.toString().padLeft(2, '0')}-${focusedDate.value.year}";
    getTaskStatus.value = RequestStatus.loading;

    final result = await homeRepository.getUserTasksByDate(formattedDate);
    if (result['success'] == true) {
      getTaskStatusOnHome.value = RequestStatus.success;
      final List<dynamic> data = result['data'][0] ?? [];
      tasksOnHome.assignAll(data.cast<Map<String, dynamic>>());
    } else {
      getTaskStatusOnHome.value = RequestStatus.error;

      appSnackbar("Error", result['message'] ?? "message required frontend");
    }
  }

  var completedTaskStatus = RequestStatus.idle.obs;

  Future<void> markTaskAsCompleted(String taskId) async {
    completedTaskStatus.value = RequestStatus.loading;

    final result = await homeRepository.markTaskCompleted(taskId);

    if (result['success']) {
      completedTaskStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Task marked as completed");
    } else {
      completedTaskStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }

  var deleteTaskStatus = RequestStatus.idle.obs;

  Future<void> deleteTask(String taskId) async {
    deleteTaskStatus.value = RequestStatus.loading;

    final result = await homeRepository.deleteTask(taskId);

    if (result['success'] == true) {
      deleteTaskStatus.value = RequestStatus.success;
      tasks.removeWhere((task) => task['id'] == taskId);
      tasksOnHome.removeWhere((task) => task['id'] == taskId);
      appSnackbar("Success", result['message'] ?? "Task deleted successfully");
    } else {
      deleteTaskStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Something went wrong");
    }
  }
}
