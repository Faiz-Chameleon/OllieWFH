import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/task_model.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/Dailytask/task_editor_sheet.dart';
import 'package:ollie/home/Dailytask/task_widgets.dart';
import 'package:ollie/home/Dailytask/tasks_screen.dart';
import 'package:ollie/request_status.dart';

/// Home screen card: today's progress and the next few tasks, each tickable.
class TodayTasksCard extends StatelessWidget {
  const TodayTasksCard({super.key, required this.controller});

  final TaskController controller;

  static const int _maxRows = 3;

  Future<void> _openList() async {
    await Get.to(() => const TasksScreen(), transition: Transition.fadeIn);
    controller.loadToday();
  }

  /// Not-done tasks first (earliest first), then done ones.
  List<TaskItem> _ordered(List<TaskItem> items) {
    final pending = items.where((task) => !task.isDone).toList();
    final done = items.where((task) => task.isDone).toList();
    return [...pending, ...done];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openList,
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1C5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          final items = controller.todayTasks;
          final status = controller.todayStatus.value;
          final progress = controller.progressOf(items);
          final ratio = progress.total == 0
              ? 0.0
              : progress.completed / progress.total;
          final rows = _ordered(items);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Daily Tasks",
                      style: GoogleFonts.darkerGrotesque(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveFontSize(28, min: 24, max: 32),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'New task',
                    onPressed: () => showTaskEditor(
                      context,
                      controller,
                      initialDate: DateTime.now(),
                    ),
                    icon: const Icon(
                      Icons.add_circle,
                      color: buttonColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
              Text(
                progress.total == 0
                    ? "See how much you have achieved today!"
                    : progress.completed == progress.total
                    ? "All ${progress.total} done today. Well done!"
                    : "${progress.completed} of ${progress.total} done today",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: responsiveFontSize(20, min: 18, max: 24),
                ),
              ),
              if (progress.total > 0) ...[
                8.verticalSpace,
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: ratio == 1 ? taskDoneColor : buttonColor,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              if (status == RequestStatus.loading && items.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (status == RequestStatus.error && items.isEmpty)
                Center(
                  child: TextButton(
                    onPressed: controller.loadToday,
                    child: const Text("Couldn't load tasks. Tap to retry"),
                  ),
                )
              else if (items.isEmpty)
                Text(
                  "No tasks for today. Tap + to add one.",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: responsiveFontSize(20, min: 18, max: 24),
                  ),
                )
              else ...[
                for (final task in rows.take(_maxRows))
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: _TodayTaskRow(
                      task: task,
                      onToggle: () => controller.setDone(task, !task.isDone),
                      onTap: () => showTaskDetails(context, controller, task),
                    ),
                  ),
                if (rows.length > _maxRows)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      "+${rows.length - _maxRows} more · View all",
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: responsiveFontSize(18, min: 16, max: 22),
                        fontWeight: FontWeight.w700,
                        color: buttonColor,
                      ),
                    ),
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _TodayTaskRow extends StatelessWidget {
  const _TodayTaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue(DateTime.now());
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            TaskCheckbox(done: task.isDone, onTap: onToggle),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                task.taskName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsiveFontSize(16, min: 14, max: 20),
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isDone ? Colors.black38 : Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            if (task.isRecurring)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.repeat, size: 16, color: Colors.black38),
              ),
            Text(
              formatTaskTime(context, task),
              style: TextStyle(
                fontSize: responsiveFontSize(14, min: 12, max: 18),
                fontWeight: FontWeight.w600,
                color: overdue ? taskOverdueColor : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
