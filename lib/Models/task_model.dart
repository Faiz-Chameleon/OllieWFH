import 'package:ollie/Models/supplement_model.dart';

enum TaskRecurrence {
  none('NONE'),
  daily('DAILY'),
  weekly('WEEKLY'),
  interval('INTERVAL'),
  monthly('MONTHLY');

  const TaskRecurrence(this.apiValue);

  final String apiValue;

  static TaskRecurrence fromApi(Object? value) {
    final raw = value?.toString().toUpperCase();
    return TaskRecurrence.values.firstWhere(
      (item) => item.apiValue == raw,
      orElse: () => TaskRecurrence.none,
    );
  }
}

enum TaskPriority {
  low('LOW', 'Low'),
  medium('MEDIUM', 'Medium'),
  high('HIGH', 'High');

  const TaskPriority(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static TaskPriority fromApi(Object? value) {
    final raw = value?.toString().toUpperCase();
    return TaskPriority.values.firstWhere(
      (item) => item.apiValue == raw,
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Categories offered in the task editor. The API stores any short string.
const List<String> taskCategories = [
  'Health',
  'Appointment',
  'Home',
  'Errand',
  'Social',
  'Exercise',
  'Other',
];

/// Reminder lead times offered in the task editor, in minutes before the task.
const List<int> taskReminderLeadOptions = [0, 5, 15, 30, 60, 1440];

String describeReminderLead(int minutes) {
  if (minutes == 0) return 'At time of task';
  if (minutes == 1440) return '1 day before';
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return hours == 1 ? '1 hour before' : '$hours hours before';
  }
  return '$minutes min before';
}

class TaskChecklistItem {
  const TaskChecklistItem({this.id, required this.text, this.done = false});

  /// Null for items not saved yet; the API assigns one.
  final String? id;
  final String text;
  final bool done;

  factory TaskChecklistItem.fromJson(Map<String, dynamic> json) {
    return TaskChecklistItem(
      id: json['id']?.toString(),
      text: json['text']?.toString() ?? '',
      done: json['done'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'text': text,
    'done': done,
  };

  TaskChecklistItem copyWith({bool? done}) =>
      TaskChecklistItem(id: id, text: text, done: done ?? this.done);
}

/// One task on one day. A recurring task appears once per day it occurs on,
/// with its own completion and checklist state.
class TaskItem {
  TaskItem({
    required this.id,
    required this.taskName,
    this.taskDescription,
    required this.taskDate,
    required this.occurrenceDate,
    required this.scheduledTime,
    this.timeZone,
    this.recurrence = TaskRecurrence.none,
    this.daysOfWeek = const [],
    this.intervalDays,
    this.recurrenceEndDate,
    this.priority = TaskPriority.medium,
    this.category,
    this.checklist = const [],
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 5,
    this.isDone = false,
  });

  final String id;
  final String taskName;
  final String? taskDescription;

  /// The task's own (first) date.
  final DateTime taskDate;

  /// The day this entry is for.
  final DateTime occurrenceDate;

  /// "HH:mm:ss".
  final String scheduledTime;
  final String? timeZone;
  final TaskRecurrence recurrence;

  /// WEEKLY only. 0 = Sunday ... 6 = Saturday.
  final List<int> daysOfWeek;
  final int? intervalDays;
  final DateTime? recurrenceEndDate;
  final TaskPriority priority;
  final String? category;
  final List<TaskChecklistItem> checklist;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final bool isDone;

  bool get isRecurring => recurrence != TaskRecurrence.none;

  int get checklistDone => checklist.where((item) => item.done).length;

  ({int hour, int minute})? get time => SupplementData.parseTime(scheduledTime);

  /// When this occurrence starts, in device-local time.
  DateTime get startsAt {
    final parsed = time;
    return DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
      parsed?.hour ?? 0,
      parsed?.minute ?? 0,
    );
  }

  /// Not done and already past its time.
  bool isOverdue(DateTime now) => !isDone && startsAt.isBefore(now);

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? value) {
      final raw = value?.toString() ?? '';
      return SupplementData.parseDate(
        raw.length >= 10 ? raw.substring(0, 10) : raw,
      );
    }

    final taskDate =
        date(json['taskDate']) ?? date(json['scheduledDate']) ?? DateTime.now();
    final rawDays = json['daysOfWeek'];
    final rawChecklist = json['checklist'];

    return TaskItem(
      id: json['id']?.toString() ?? '',
      taskName: json['taskName']?.toString() ?? 'Untitled task',
      taskDescription: _clean(json['taskDescription']),
      taskDate: taskDate,
      occurrenceDate: date(json['occurrenceDate']) ?? taskDate,
      scheduledTime: json['scheduledTime']?.toString() ?? '00:00:00',
      timeZone: _clean(json['timeZone']),
      recurrence: TaskRecurrence.fromApi(json['recurrence']),
      daysOfWeek: rawDays is List
          ? (rawDays
                .map((item) => int.tryParse(item.toString()))
                .whereType<int>()
                .where((day) => day >= 0 && day <= 6)
                .toSet()
                .toList()
              ..sort())
          : const [],
      intervalDays: int.tryParse(json['intervalDays']?.toString() ?? ''),
      recurrenceEndDate: date(json['recurrenceEndDate']),
      priority: TaskPriority.fromApi(json['priority']),
      category: _clean(json['category']),
      checklist: rawChecklist is List
          ? rawChecklist
                .whereType<Map>()
                .map(
                  (item) => TaskChecklistItem.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .where((item) => item.text.isNotEmpty)
                .toList()
          : const [],
      reminderEnabled: json['reminderEnabled'] != false,
      reminderMinutesBefore:
          int.tryParse(json['reminderMinutesBefore']?.toString() ?? '') ?? 5,
      isDone: json['markAsComplete'] == true,
    );
  }

  static String? _clean(Object? value) {
    final raw = value?.toString().trim();
    return raw == null || raw.isEmpty ? null : raw;
  }

  TaskItem copyWith({bool? isDone, List<TaskChecklistItem>? checklist}) {
    return TaskItem(
      id: id,
      taskName: taskName,
      taskDescription: taskDescription,
      taskDate: taskDate,
      occurrenceDate: occurrenceDate,
      scheduledTime: scheduledTime,
      timeZone: timeZone,
      recurrence: recurrence,
      daysOfWeek: daysOfWeek,
      intervalDays: intervalDays,
      recurrenceEndDate: recurrenceEndDate,
      priority: priority,
      category: category,
      checklist: checklist ?? this.checklist,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Short description of how the task repeats, or null for one-off tasks.
  String? get recurrenceSummary {
    final base = switch (recurrence) {
      TaskRecurrence.none => null,
      TaskRecurrence.daily => 'Every day',
      TaskRecurrence.weekly =>
        daysOfWeek.length == 7
            ? 'Every day'
            : 'Every ${daysOfWeek.map((day) => supplementWeekdayLabels[day]).join(', ')}',
      TaskRecurrence.interval =>
        intervalDays == 1 ? 'Every day' : 'Every ${intervalDays ?? '?'} days',
      TaskRecurrence.monthly => 'Monthly on day ${taskDate.day}',
    };
    final end = recurrenceEndDate;
    if (base == null || end == null) return base;
    return '$base until ${end.day}/${end.month}/${end.year}';
  }
}

/// Everything the task editor collects. Sent as the create/edit request body.
class TaskInput {
  TaskInput({
    required this.taskName,
    this.taskDescription = '',
    required this.date,
    required this.hour,
    required this.minute,
    this.recurrence = TaskRecurrence.none,
    this.daysOfWeek = const {},
    this.intervalDays = 2,
    this.recurrenceEndDate,
    this.priority = TaskPriority.medium,
    this.category,
    this.checklist = const [],
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 5,
  });

  final String taskName;
  final String taskDescription;
  final DateTime date;
  final int hour;
  final int minute;
  final TaskRecurrence recurrence;
  final Set<int> daysOfWeek;
  final int intervalDays;
  final DateTime? recurrenceEndDate;
  final TaskPriority priority;
  final String? category;
  final List<TaskChecklistItem> checklist;
  final bool reminderEnabled;
  final int reminderMinutesBefore;

  DateTime get startsAt =>
      DateTime(date.year, date.month, date.day, hour, minute);

  /// Returns an error message, or null when the input can be saved.
  String? validate() {
    if (taskName.trim().isEmpty) return 'Please enter a task name.';
    if (recurrence == TaskRecurrence.weekly && daysOfWeek.isEmpty) {
      return 'Please choose at least one day.';
    }
    if (recurrence == TaskRecurrence.interval &&
        (intervalDays < 1 || intervalDays > 365)) {
      return 'Repeat interval must be between 1 and 365 days.';
    }
    final end = recurrenceEndDate;
    if (recurrence != TaskRecurrence.none &&
        end != null &&
        SupplementData.daysBetween(date, end) < 0) {
      return 'End date cannot be before the task date.';
    }
    return null;
  }

  Map<String, dynamic> toPayload() {
    final hasEnd =
        recurrence != TaskRecurrence.none && recurrenceEndDate != null;
    return {
      'taskName': taskName.trim(),
      'taskDescription': taskDescription.trim(),
      'date': SupplementData.formatDate(date),
      'time':
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00',
      'recurrence': recurrence.apiValue,
      'daysOfWeek': recurrence == TaskRecurrence.weekly
          ? (daysOfWeek.toList()..sort())
          : null,
      'intervalDays': recurrence == TaskRecurrence.interval
          ? intervalDays
          : null,
      'recurrenceEndDate': hasEnd
          ? SupplementData.formatDate(recurrenceEndDate!)
          : null,
      'priority': priority.apiValue,
      'category': category,
      'checklist': checklist
          .where((item) => item.text.trim().isNotEmpty)
          .map((item) => item.toJson())
          .toList(),
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }
}
