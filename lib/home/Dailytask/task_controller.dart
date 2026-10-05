import 'package:get/get.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/task_model.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/home/home_repository.dart';
import 'package:ollie/request_status.dart';

enum TaskFilter { all, todo, done }

/// Shared by the To-Do screen and the home "Daily Tasks" card. The screen follows
/// [selectedDate]; the home card always shows [todayTasks].
class TaskController extends GetxController {
  TaskController({HomeRepository? repository})
    : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;

  final selectedDate = _dateOnly(DateTime.now()).obs;
  final tasks = <TaskItem>[].obs;
  final todayTasks = <TaskItem>[].obs;
  final filter = TaskFilter.all.obs;

  /// YYYY-MM-DD -> counts, for calendar markers.
  final summary = <String, ({int total, int completed})>{}.obs;

  final loadStatus = RequestStatus.idle.obs;
  final todayStatus = RequestStatus.idle.obs;
  final saveStatus = RequestStatus.idle.obs;

  DateTime? _summaryFrom;
  DateTime? _summaryTo;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _apiDate(DateTime date) => SupplementData.formatDate(date);

  // The by-date endpoint takes DD-MM-YYYY.
  static String _dayMonthYear(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-${date.year}';

  bool get isTodaySelected =>
      SupplementData.daysBetween(selectedDate.value, DateTime.now()) == 0;

  List<TaskItem> get visibleTasks => switch (filter.value) {
    TaskFilter.all => tasks,
    TaskFilter.todo => tasks.where((task) => !task.isDone).toList(),
    TaskFilter.done => tasks.where((task) => task.isDone).toList(),
  };

  ({int total, int completed}) progressOf(List<TaskItem> items) => (
    total: items.length,
    completed: items.where((task) => task.isDone).length,
  );

  Future<void> selectDate(DateTime date) async {
    selectedDate.value = _dateOnly(date);
    await Future.wait([loadSelectedDay(), _ensureSummaryCovers(date)]);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadSelectedDay(),
      loadToday(),
      loadSummary(around: selectedDate.value),
    ]);
  }

  Future<void> loadSelectedDay() async {
    final date = selectedDate.value;
    loadStatus.value = RequestStatus.loading;
    final items = await _fetchDay(date);
    // Ignore a slow response for a day the user has already moved away from.
    if (date != selectedDate.value) return;
    if (items == null) {
      loadStatus.value = RequestStatus.error;
      return;
    }
    tasks.assignAll(items);
    loadStatus.value = RequestStatus.success;
  }

  Future<void> loadToday() async {
    todayStatus.value = RequestStatus.loading;
    final items = await _fetchDay(_dateOnly(DateTime.now()));
    if (items == null) {
      todayStatus.value = RequestStatus.error;
      return;
    }
    todayTasks.assignAll(items);
    todayStatus.value = RequestStatus.success;
  }

  Future<List<TaskItem>?> _fetchDay(DateTime date) async {
    final result = await _repository.getUserTasksByDate(_dayMonthYear(date));
    if (result['success'] != true) return null;
    final data = result['data'];
    // The API wraps the list in another list.
    final list = data is List && data.isNotEmpty && data.first is List
        ? data.first as List
        : data is List
        ? data
        : const [];
    return list
        .whereType<Map>()
        .map(
          (item) => TaskItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<void> _ensureSummaryCovers(DateTime date) async {
    final from = _summaryFrom;
    final to = _summaryTo;
    if (from != null &&
        to != null &&
        !date.isBefore(from) &&
        !date.isAfter(to)) {
      return;
    }
    await loadSummary(around: date);
  }

  /// Loads markers for two weeks before to a month after [around].
  Future<void> loadSummary({required DateTime around}) async {
    final from = _dateOnly(around).subtract(const Duration(days: 14));
    final to = _dateOnly(around).add(const Duration(days: 31));
    final result = await _repository.getTaskSummary(
      _apiDate(from),
      _apiDate(to),
    );
    if (result['success'] != true || result['data'] is! Map) return;

    final next = <String, ({int total, int completed})>{};
    (result['data'] as Map).forEach((key, value) {
      if (value is Map) {
        next[key.toString()] = (
          total: int.tryParse(value['total']?.toString() ?? '') ?? 0,
          completed: int.tryParse(value['completed']?.toString() ?? '') ?? 0,
        );
      }
    });
    summary.assignAll(next);
    _summaryFrom = from;
    _summaryTo = to;
  }

  ({int total, int completed})? summaryFor(DateTime date) =>
      summary[_apiDate(date)];

  /// Creates a task, or edits [editing]. Returns whether it was saved.
  Future<bool> save(TaskInput input, {TaskItem? editing}) async {
    final error = input.validate();
    if (error != null) {
      appSnackbar("Error", error);
      return false;
    }
    final isNewOneOff =
        editing == null && input.recurrence == TaskRecurrence.none;
    if (isNewOneOff && input.startsAt.isBefore(DateTime.now())) {
      appSnackbar("Error", "Please choose a time in the future.");
      return false;
    }

    saveStatus.value = RequestStatus.loading;
    final result = editing == null
        ? await _repository.createTask(input.toPayload())
        : await _repository.rescheduleTask(editing.id, input.toPayload());

    final saved =
        result['success'] == true || _isInvalidFcmTokenError(result['message']);
    if (!saved) {
      saveStatus.value = RequestStatus.error;
      // The server may have saved the task before failing on a side effect,
      // so show whatever it now has.
      refreshAll();
      appSnackbar(
        "Error",
        result['message']?.toString() ?? "Something went wrong",
      );
      return false;
    }

    saveStatus.value = RequestStatus.success;
    await refreshAll();
    if (result['success'] == true) {
      appSnackbar("Success", editing == null ? "Task created" : "Task updated");
    } else {
      appSnackbar(
        "Task Saved",
        "Task was saved, but this device has no valid push token, so reminders can't reach it.",
      );
    }
    return true;
  }

  /// Marks one occurrence done or not done, updating the lists straight away.
  Future<void> setDone(TaskItem task, bool done) async {
    _replace(task, task.copyWith(isDone: done));
    final result = await _repository.markTaskCompleted(
      task.id,
      completed: done,
      date: task.isRecurring ? _apiDate(task.occurrenceDate) : null,
    );
    if (result['success'] != true &&
        !_isInvalidFcmTokenError(result['message'])) {
      _replace(task, task);
      appSnackbar(
        "Error",
        result['message']?.toString() ?? "Something went wrong",
      );
      return;
    }
    _bumpSummary(task.occurrenceDate, done ? 1 : -1);
  }

  Future<void> toggleChecklistItem(
    TaskItem task,
    TaskChecklistItem item,
  ) async {
    final itemId = item.id;
    if (itemId == null) return;
    final toggled = task.copyWith(
      checklist: [
        for (final entry in task.checklist)
          entry.id == itemId ? entry.copyWith(done: !entry.done) : entry,
      ],
    );
    _replace(task, toggled);
    final result = await _repository.toggleChecklistItem(
      task.id,
      itemId: itemId,
      done: !item.done,
      date: task.isRecurring ? _apiDate(task.occurrenceDate) : null,
    );
    if (result['success'] != true) {
      _replace(toggled, task);
      appSnackbar(
        "Error",
        result['message']?.toString() ?? "Something went wrong",
      );
    }
  }

  /// Deletes the task, or with [onlyThisDay] just this day of a recurring task.
  Future<void> delete(TaskItem task, {bool onlyThisDay = false}) async {
    final result = await _repository.deleteTask(
      task.id,
      onlyDate: onlyThisDay ? _apiDate(task.occurrenceDate) : null,
    );
    if (result['success'] != true) {
      appSnackbar(
        "Error",
        result['message']?.toString() ?? "Something went wrong",
      );
      return;
    }
    appSnackbar(
      "Success",
      onlyThisDay ? "Removed from this day" : "Task deleted",
    );
    await refreshAll();
  }

  /// The latest copy of [task] in either list, e.g. for an open details sheet.
  TaskItem? find(TaskItem task) {
    bool same(TaskItem other) =>
        other.id == task.id &&
        SupplementData.daysBetween(other.occurrenceDate, task.occurrenceDate) ==
            0;
    return tasks.firstWhereOrNull(same) ?? todayTasks.firstWhereOrNull(same);
  }

  void _replace(TaskItem old, TaskItem updated) {
    for (final list in [tasks, todayTasks]) {
      final index = list.indexWhere(
        (item) =>
            item.id == old.id &&
            SupplementData.daysBetween(
                  item.occurrenceDate,
                  old.occurrenceDate,
                ) ==
                0,
      );
      if (index != -1) list[index] = updated;
    }
  }

  void _bumpSummary(DateTime date, int completedDelta) {
    final key = _apiDate(date);
    final entry = summary[key];
    if (entry == null) return;
    summary[key] = (
      total: entry.total,
      completed: (entry.completed + completedDelta).clamp(0, entry.total),
    );
  }

  bool _isInvalidFcmTokenError(Object? message) =>
      (message ?? '').toString().toLowerCase().contains('not a valid fcm');
}
