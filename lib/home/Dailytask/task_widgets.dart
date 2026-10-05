import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/task_model.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/Dailytask/task_editor_sheet.dart';

const Color taskDoneColor = Color(0xFF2E9B65);
const Color taskOverdueColor = Color(0xFFC0392B);

Color taskPriorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.high => const Color(0xFFE0533D),
  TaskPriority.medium => ksecondaryColor,
  TaskPriority.low => const Color(0xFFB9B2A8),
};

String formatTaskTime(BuildContext context, TaskItem task) {
  final parsed = task.time;
  if (parsed == null) return task.scheduledTime;
  return TimeOfDay(hour: parsed.hour, minute: parsed.minute).format(context);
}

String formatTaskDay(DateTime day) {
  final diff = SupplementData.daysBetween(DateTime.now(), day);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return '${supplementWeekdayLabels[day.weekday % 7]} ${day.day}/${day.month}/${day.year}';
}

/// Round tick button used on task rows.
class TaskCheckbox extends StatelessWidget {
  const TaskCheckbox({super.key, required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Mark not done' : 'Mark done',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? taskDoneColor : Colors.white,
            border: Border.all(
              color: done ? taskDoneColor : Colors.black26,
              width: 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Colors.black54;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: tint),
        3.horizontalSpace,
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: tint,
            ),
          ),
        ),
      ],
    );
  }
}

/// A task row on the To-Do screen.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
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
    final surface = task.isDone
        ? const Color(0xFFF1FBF5)
        : const Color(0xFFFFF7E5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(
                color: task.isDone
                    ? taskDoneColor
                    : taskPriorityColor(task.priority),
                width: 5,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskCheckbox(done: task.isDone, onTap: onToggle),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w700,
                        color: task.isDone ? Colors.black38 : HeadingColor,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.taskDescription != null)
                      Text(
                        task.taskDescription!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 16.sp,
                          color: Colors.black54,
                        ),
                      ),
                    6.verticalSpace,
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: overdue ? Icons.schedule : Icons.access_time,
                          label: overdue
                              ? '${formatTaskTime(context, task)} · Overdue'
                              : formatTaskTime(context, task),
                          color: overdue ? taskOverdueColor : null,
                        ),
                        if (task.isRecurring)
                          const _MetaChip(icon: Icons.repeat, label: 'Repeats'),
                        if (task.checklist.isNotEmpty)
                          _MetaChip(
                            icon: Icons.checklist,
                            label:
                                '${task.checklistDone}/${task.checklist.length}',
                          ),
                        if (task.category != null)
                          _MetaChip(
                            icon: Icons.label_outline,
                            label: task.category!,
                          ),
                        if (task.priority == TaskPriority.high && !task.isDone)
                          _MetaChip(
                            icon: Icons.flag,
                            label: 'High',
                            color: taskPriorityColor(TaskPriority.high),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showTaskDetails(
  BuildContext context,
  TaskController controller,
  TaskItem task,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskDetailsSheet(controller: controller, task: task),
  );
  // The editor opens from here: the details sheet's own context is gone by now.
  if (action == 'edit' && context.mounted) {
    await showTaskEditor(
      context,
      controller,
      task: controller.find(task) ?? task,
    );
  }
}

/// Full view of one task: details, checklist, and actions.
class TaskDetailsSheet extends StatelessWidget {
  const TaskDetailsSheet({
    super.key,
    required this.controller,
    required this.task,
  });

  final TaskController controller;
  final TaskItem task;

  Future<void> _confirmDelete(BuildContext context, TaskItem current) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BGcolor,
        title: Text(
          "Delete task?",
          style: GoogleFonts.darkerGrotesque(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Text(
          current.isRecurring
              ? '"${current.taskName}" repeats. Remove it from ${formatTaskDay(current.occurrenceDate).toLowerCase()} only, or delete it completely?'
              : 'Delete "${current.taskName}"?',
          style: GoogleFonts.darkerGrotesque(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          if (current.isRecurring)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'day'),
              child: const Text("This day only"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'all'),
            child: Text(
              current.isRecurring ? "Delete all" : "Delete",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    Navigator.pop(context);
    await controller.delete(current, onlyThisDay: choice == 'day');
  }

  Widget _row(IconData icon, String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        10.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 18.sp,
              color: HeadingColor,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: const BoxDecoration(
            color: BGcolor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          // Rebuilds from the controller so ticks made here show straight away.
          child: Obx(() {
            final current = controller.find(task) ?? task;
            return ListView(
              controller: scrollController,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Colors.black26),
                ),
                8.verticalSpace,
                Text(
                  current.taskName,
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: HeadingColor,
                    decoration: current.isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                12.verticalSpace,
                _row(
                  Icons.event,
                  '${formatTaskDay(current.occurrenceDate)} at ${formatTaskTime(context, current)}',
                ),
                if (current.recurrenceSummary != null)
                  _row(Icons.repeat, current.recurrenceSummary!),
                _row(
                  current.reminderEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  current.reminderEnabled
                      ? 'Reminder ${describeReminderLead(current.reminderMinutesBefore).toLowerCase()}'
                      : 'No reminder',
                ),
                _row(Icons.flag_outlined, '${current.priority.label} priority'),
                if (current.category != null)
                  _row(Icons.label_outline, current.category!),
                if (current.taskDescription != null) ...[
                  8.verticalSpace,
                  Text(
                    current.taskDescription!,
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 18.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
                if (current.checklist.isNotEmpty) ...[
                  16.verticalSpace,
                  Text(
                    'Checklist · ${current.checklistDone}/${current.checklist.length}',
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: HeadingColor,
                    ),
                  ),
                  for (final item in current.checklist)
                    Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        value: item.done,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: taskDoneColor,
                        onChanged: (_) =>
                            controller.toggleChecklistItem(current, item),
                        title: Text(
                          item.text,
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 18.sp,
                            color: item.done ? Colors.black38 : HeadingColor,
                            decoration: item.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
                24.verticalSpace,
                ElevatedButton.icon(
                  onPressed: () => controller.setDone(current, !current.isDone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.isDone
                        ? Colors.white
                        : buttonColor,
                    foregroundColor: current.isDone
                        ? HeadingColor
                        : Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(current.isDone ? Icons.undo : Icons.check),
                  label: Text(
                    current.isDone ? "Mark not done" : "Mark done",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                10.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context, 'edit'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: HeadingColor,
                        ),
                        label: Text(
                          "Edit",
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: HeadingColor,
                          ),
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, current),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Delete",
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

/// The one shared [TaskController], created on first use.
TaskController findTaskController() => Get.isRegistered<TaskController>()
    ? Get.find<TaskController>()
    : Get.put(TaskController(), permanent: true);
