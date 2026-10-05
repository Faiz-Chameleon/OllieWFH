import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/task_model.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/home_repository.dart';

String _iso(DateTime date) => SupplementData.formatDate(date);

Map<String, dynamic> _taskJson({
  String id = 't1',
  String name = 'Call pharmacy',
  DateTime? date,
  String time = '09:00:00',
  bool done = false,
  String recurrence = 'NONE',
  List<Map<String, dynamic>> checklist = const [],
  String priority = 'MEDIUM',
  String? category,
}) {
  final day = _iso(date ?? DateTime.now());
  return {
    'id': id,
    'taskName': name,
    'taskDescription': 'Ask about refill',
    'taskDate': day,
    'occurrenceDate': day,
    'scheduledDate': '${day}T00:00:00.000Z',
    'scheduledTime': time,
    'recurrence': recurrence,
    'daysOfWeek': null,
    'priority': priority,
    'category': category,
    'checklist': checklist,
    'reminderEnabled': true,
    'reminderMinutesBefore': 15,
    'markAsComplete': done,
  };
}

/// Records calls and answers from in-memory data.
class _FakeRepository extends HomeRepository {
  List<Map<String, dynamic>> day = [];
  bool failWrites = false;
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> getUserTasksByDate(date) async {
    calls.add('get $date');
    return {
      'success': true,
      'data': [day],
    };
  }

  @override
  Future<Map<String, dynamic>> getTaskSummary(String from, String to) async {
    calls.add('summary');
    return {
      'success': true,
      'data': {
        _iso(DateTime.now()): {'total': day.length, 'completed': 0},
      },
    };
  }

  @override
  Future<Map<String, dynamic>> markTaskCompleted(
    String taskId, {
    bool completed = true,
    String? date,
  }) async {
    calls.add('complete $taskId $completed ${date ?? '-'}');
    return failWrites
        ? {'success': false, 'message': 'boom'}
        : {'success': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> toggleChecklistItem(
    String taskId, {
    required String itemId,
    required bool done,
    String? date,
  }) async {
    calls.add('check $taskId $itemId $done');
    return failWrites
        ? {'success': false, 'message': 'boom'}
        : {'success': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    calls.add('create ${data['taskName']}');
    return {'success': true, 'data': data};
  }

  @override
  Future<Map<String, dynamic>> deleteTask(
    String taskId, {
    String? onlyDate,
  }) async {
    calls.add('delete $taskId ${onlyDate ?? 'all'}');
    return {'success': true, 'data': null};
  }
}

void main() {
  // appSnackbar looks up the widget binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskItem', () {
    test('parses the API shape, including recurring fields', () {
      final task = TaskItem.fromJson({
        ..._taskJson(
          recurrence: 'WEEKLY',
          priority: 'HIGH',
          category: 'Health',
          checklist: [
            {'id': 'a', 'text': 'Bring card', 'done': true},
            {'id': 'b', 'text': 'Ask about BP', 'done': false},
          ],
        ),
        'daysOfWeek': [5, 1],
        'occurrenceDate': '2026-10-09',
        'recurrenceEndDate': '2026-12-31',
      });

      expect(task.isRecurring, isTrue);
      expect(task.daysOfWeek, [1, 5]);
      expect(task.occurrenceDate, DateTime(2026, 10, 9));
      expect(task.priority, TaskPriority.high);
      expect(task.checklistDone, 1);
      expect(task.recurrenceSummary, 'Every Mon, Fri until 31/12/2026');
      expect(task.reminderMinutesBefore, 15);
    });

    test('older rows without taskDate fall back to scheduledDate', () {
      final task = TaskItem.fromJson({
        'id': 'x',
        'taskName': 'Old',
        'scheduledDate': '2026-10-05T00:00:00.000Z',
        'scheduledTime': '07:30:00',
        'markAsComplete': false,
      });
      expect(task.taskDate, DateTime(2026, 10, 5));
      expect(task.occurrenceDate, DateTime(2026, 10, 5));
      expect(task.recurrence, TaskRecurrence.none);
      expect(task.startsAt, DateTime(2026, 10, 5, 7, 30));
    });

    test('isOverdue only for unfinished past tasks', () {
      final task = TaskItem.fromJson(_taskJson(date: DateTime(2026, 10, 5)));
      expect(task.isOverdue(DateTime(2026, 10, 5, 10)), isTrue);
      expect(task.isOverdue(DateTime(2026, 10, 5, 8)), isFalse);
      expect(
        task.copyWith(isDone: true).isOverdue(DateTime(2026, 10, 6)),
        isFalse,
      );
    });

    test('monthly summary names the day', () {
      final task = TaskItem.fromJson({
        ..._taskJson(recurrence: 'MONTHLY', date: DateTime(2026, 1, 31)),
      });
      expect(task.recurrenceSummary, 'Monthly on day 31');
    });
  });

  group('TaskInput', () {
    test('builds the request body', () {
      final payload = TaskInput(
        taskName: '  Walk ',
        date: DateTime(2026, 10, 5),
        hour: 7,
        minute: 5,
        recurrence: TaskRecurrence.weekly,
        daysOfWeek: {5, 1},
        recurrenceEndDate: DateTime(2026, 12, 31),
        priority: TaskPriority.low,
        category: 'Exercise',
        checklist: const [
          TaskChecklistItem(text: 'Stretch'),
          TaskChecklistItem(text: '  '),
          TaskChecklistItem(id: 'k', text: 'Water', done: true),
        ],
        reminderMinutesBefore: 30,
      ).toPayload();

      expect(payload['taskName'], 'Walk');
      expect(payload['date'], '2026-10-05');
      expect(payload['time'], '07:05:00');
      expect(payload['recurrence'], 'WEEKLY');
      expect(payload['daysOfWeek'], [1, 5]);
      expect(payload['intervalDays'], isNull);
      expect(payload['recurrenceEndDate'], '2026-12-31');
      expect(payload['priority'], 'LOW');
      expect(payload['checklist'], [
        {'text': 'Stretch', 'done': false},
        {'id': 'k', 'text': 'Water', 'done': true},
      ]);
      expect(payload['reminderMinutesBefore'], 30);
    });

    test('one-off tasks send no end date', () {
      final payload = TaskInput(
        taskName: 'x',
        date: DateTime(2026, 10, 5),
        hour: 9,
        minute: 0,
        recurrenceEndDate: DateTime(2026, 12, 31),
      ).toPayload();
      expect(payload['recurrenceEndDate'], isNull);
    });

    test('validate catches incomplete input', () {
      TaskInput input({
        String name = 'x',
        TaskRecurrence recurrence = TaskRecurrence.none,
        Set<int> days = const {},
        DateTime? end,
      }) => TaskInput(
        taskName: name,
        date: DateTime(2026, 10, 5),
        hour: 9,
        minute: 0,
        recurrence: recurrence,
        daysOfWeek: days,
        recurrenceEndDate: end,
      );

      expect(input().validate(), isNull);
      expect(input(name: ' ').validate(), isNotNull);
      expect(input(recurrence: TaskRecurrence.weekly).validate(), isNotNull);
      expect(
        input(recurrence: TaskRecurrence.weekly, days: {1}).validate(),
        isNull,
      );
      expect(
        input(
          recurrence: TaskRecurrence.daily,
          end: DateTime(2026, 10, 1),
        ).validate(),
        isNotNull,
      );
    });

    test('describeReminderLead', () {
      expect(describeReminderLead(0), 'At time of task');
      expect(describeReminderLead(15), '15 min before');
      expect(describeReminderLead(60), '1 hour before');
      expect(describeReminderLead(1440), '1 day before');
    });
  });

  group('TaskController', () {
    late _FakeRepository repository;
    late TaskController controller;

    setUp(() {
      Get.testMode = true;
      repository = _FakeRepository()
        ..day = [
          _taskJson(),
          _taskJson(
            id: 't2',
            name: 'Walk',
            recurrence: 'DAILY',
            checklist: [
              {'id': 'a', 'text': 'Stretch', 'done': false},
            ],
          ),
        ];
      controller = TaskController(repository: repository);
    });

    test('loads today and unwraps the nested list', () async {
      await controller.loadToday();
      expect(controller.todayTasks.map((task) => task.id), ['t1', 't2']);
    });

    test(
      'setDone updates both lists and sends the occurrence date for recurring tasks',
      () async {
        await controller.refreshAll();
        final walk = controller.tasks.firstWhere((task) => task.id == 't2');
        await controller.setDone(walk, true);

        expect(
          controller.tasks.firstWhere((task) => task.id == 't2').isDone,
          isTrue,
        );
        expect(
          controller.todayTasks.firstWhere((task) => task.id == 't2').isDone,
          isTrue,
        );
        expect(
          repository.calls.last,
          'complete t2 true ${_iso(DateTime.now())}',
        );

        final call = controller.tasks.firstWhere((task) => task.id == 't1');
        await controller.setDone(call, true);
        expect(repository.calls.last, 'complete t1 true -');
      },
    );

    test('setDone reverts when the request fails', () async {
      await controller.refreshAll();
      repository.failWrites = true;
      await controller.setDone(controller.tasks.first, true);
      expect(controller.tasks.first.isDone, isFalse);
    });

    test('checklist toggles and reverts on failure', () async {
      await controller.refreshAll();
      final walk = controller.tasks.firstWhere((task) => task.id == 't2');
      await controller.toggleChecklistItem(walk, walk.checklist.first);
      expect(controller.find(walk)!.checklist.first.done, isTrue);

      repository.failWrites = true;
      final updated = controller.find(walk)!;
      await controller.toggleChecklistItem(updated, updated.checklist.first);
      expect(controller.find(walk)!.checklist.first.done, isTrue);
    });

    test('filters', () async {
      await controller.refreshAll();
      await controller.setDone(controller.tasks.first, true);
      controller.filter.value = TaskFilter.todo;
      expect(controller.visibleTasks.map((task) => task.id), ['t2']);
      controller.filter.value = TaskFilter.done;
      expect(controller.visibleTasks.map((task) => task.id), ['t1']);
    });

    test(
      'save rejects a new one-off task in the past without calling the API',
      () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final saved = await controller.save(
          TaskInput(taskName: 'x', date: yesterday, hour: 9, minute: 0),
        );
        expect(saved, isFalse);
        expect(
          repository.calls.where((call) => call.startsWith('create')),
          isEmpty,
        );
      },
    );

    test('delete one day of a recurring task', () async {
      await controller.refreshAll();
      final walk = controller.tasks.firstWhere((task) => task.id == 't2');
      await controller.delete(walk, onlyThisDay: true);
      expect(repository.calls, contains('delete t2 ${_iso(DateTime.now())}'));
    });
  });
}
