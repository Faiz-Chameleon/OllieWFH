import 'package:get/get.dart';

class TodoController extends GetxController {
  // Model: Observable list of tasks
  final tasks = <Map<String, dynamic>>[].obs;

  // Model: Observable selected date
  final selectedDate = DateTime.now().obs;

  // Model: Observable focused date for calendar
  final focusedDate = DateTime.now().obs;

  // Business Logic: Load sample tasks

  // Business Logic: Toggle task completion
  void toggleTask(int index) {
    tasks[index]["done"] = !(tasks[index]["done"] as bool);
    tasks.refresh();
  }

  // Business Logic: Add new task
  void addTask(Map<String, dynamic> task) {
    tasks.add(task);
  }

  // Business Logic: Remove task
  void removeTask(int index) {
    tasks.removeAt(index);
  }

  // Business Logic: Get filtered tasks for selected date
  List<Map<String, dynamic>> get filteredTasks {
    return tasks.where((task) {
      final taskDate = task["date"];
      final selected = selectedDate.value;
      return taskDate == "${selected.day}-${selected.month}-${selected.year}";
    }).toList();
  }

  // Business Logic: Set selected date
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  // Business Logic: Set focused date for calendar
  void setFocusedDate(DateTime date) {
    focusedDate.value = date;
    selectedDate.value = date;
  }

  // Business Logic: Get task statistics
  Map<String, int> get taskStatistics {
    final total = tasks.length;
    final completed = tasks.where((task) => task["done"] == true).length;
    final pending = total - completed;

    return {'total': total, 'completed': completed, 'pending': pending};
  }

  // Business Logic: Get tasks for a specific date
  List<Map<String, dynamic>> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      final taskDate = task["date"];
      return taskDate == "${date.day}-${date.month}-${date.year}";
    }).toList();
  }

  // Business Logic: Check if a date has tasks
  bool hasTasksForDate(DateTime date) {
    return getTasksForDate(date).isNotEmpty;
  }

  // Business Logic: Get completion rate for a date
  double getCompletionRateForDate(DateTime date) {
    final dateTasks = getTasksForDate(date);
    if (dateTasks.isEmpty) return 0.0;

    final completed = dateTasks.where((task) => task["done"] == true).length;
    return completed / dateTasks.length;
  }
}
