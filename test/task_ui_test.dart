import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/Dailytask/task_editor_sheet.dart';
import 'package:ollie/home/Dailytask/task_widgets.dart';
import 'package:ollie/home/Dailytask/tasks_screen.dart';
import 'package:ollie/home/Dailytask/today_tasks_card.dart';
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
  group('Task UI', () {
    late _FakeRepository repository;
    late TaskController controller;

    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      Get.testMode = true;
      Get.reset();
      repository = _FakeRepository()
        ..day = [
          _taskJson(
            name:
                'A rather long task name that should wrap or ellipsize nicely',
            priority: 'HIGH',
            category: 'Appointment',
            checklist: [
              {'id': 'a', 'text': 'Bring card', 'done': true},
              {'id': 'b', 'text': 'Ask about BP', 'done': false},
            ],
          ),
          _taskJson(
            id: 't2',
            name: 'Walk',
            time: '23:59:00',
            recurrence: 'DAILY',
          ),
          _taskJson(id: 't3', name: 'Read', time: '23:59:00'),
          _taskJson(
            id: 't4',
            name: 'Water plants',
            time: '23:59:00',
            done: true,
          ),
        ];
      controller = Get.put(
        TaskController(repository: repository),
        permanent: true,
      );
    });

    tearDown(Get.reset);

    Future<void> pump(WidgetTester tester, Widget child, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => GetMaterialApp(home: child),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final size in const [Size(320, 1400), Size(414, 1400)]) {
      testWidgets('home card at ${size.width.toInt()}px', (tester) async {
        await controller.loadToday();
        await pump(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: TodayTasksCard(controller: controller),
            ),
          ),
          size,
        );
        expect(find.text('1 of 4 done today'), findsOneWidget);
        expect(find.text('+1 more · View all'), findsOneWidget);
        // Done tasks sort last, so the done one is the hidden fourth.
        expect(find.text('Water plants'), findsNothing);

        await tester.tap(find.byType(TaskCheckbox).at(1));
        await tester.pumpAndSettle();
        expect(find.text('2 of 4 done today'), findsOneWidget);
      });

      testWidgets(
        'tasks screen, details and editor at ${size.width.toInt()}px',
        (tester) async {
          await pump(tester, const TasksScreen(), size);
          expect(find.text('1 of 4 done'), findsOneWidget);
          expect(find.byType(TaskCard), findsNWidgets(4));

          await tester.tap(find.textContaining('To do'));
          await tester.pumpAndSettle();
          expect(find.byType(TaskCard), findsNWidgets(3));
          await tester.tap(find.textContaining('All'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Walk'));
          await tester.pumpAndSettle();
          expect(find.text('Every day'), findsOneWidget);
          expect(find.text('Mark done'), findsOneWidget);
          await tester.tap(find.text('Mark done'));
          await tester.pumpAndSettle();
          expect(find.text('Mark not done'), findsOneWidget);

          await tester.tap(find.text('Edit'));
          await tester.pumpAndSettle();
          expect(find.text('Edit Task'), findsOneWidget);
          expect(
            find.text('Changes apply to every day this task repeats.'),
            findsOneWidget,
          );
          await tester.tap(find.text('Weekly'));
          await tester.pumpAndSettle();
          expect(find.widgetWithText(FilterChip, 'Wed'), findsOneWidget);
          await tester.tap(find.text('Monthly'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Every few days'));
          await tester.pumpAndSettle();
          expect(find.text('days'), findsOneWidget);
          Navigator.of(tester.element(find.text('Edit Task'))).pop();
          await tester.pumpAndSettle();

          // Not awaited: it completes when the sheet closes.
          unawaited(
            showTaskEditor(
              tester.element(find.byType(TasksScreen)),
              controller,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('New Task'), findsOneWidget);
          final addStep = find.text('Add step');
          // Build it (the list is lazy), then bring it fully on screen: a tap
          // outside the sheet would hit the barrier and close it.
          await tester.scrollUntilVisible(
            addStep,
            150,
            scrollable: find
                .descendant(
                  of: find.byType(TaskEditorSheet),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.ensureVisible(addStep);
          await tester.pumpAndSettle();
          await tester.tap(addStep);
          await tester.pumpAndSettle();
          expect(find.text('Step'), findsOneWidget);
        },
      );
    }
  });
}
