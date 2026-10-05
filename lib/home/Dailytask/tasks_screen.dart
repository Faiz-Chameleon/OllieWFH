import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/home/Dailytask/task_editor_sheet.dart';
import 'package:ollie/home/Dailytask/task_widgets.dart';
import 'package:get/get.dart';
import 'package:ollie/request_status.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskController controller = findTaskController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedDate.value = DateUtils.dateOnly(
        widget.initialDate ?? DateTime.now(),
      );
      controller.refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        backgroundColor: BGcolor,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: const BackButton(color: Black),
        title: Text(
          'To-Do List',
          style: GoogleFonts.darkerGrotesque(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: HeadingColor,
          ),
        ),
        actions: [
          Obx(
            () => controller.isTodaySelected
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => controller.selectDate(DateTime.now()),
                    child: Text(
                      'Today',
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: HeadingColor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Black,
        tooltip: 'New task',
        onPressed: () => showTaskEditor(
          context,
          controller,
          initialDate: controller.selectedDate.value,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          8.verticalSpace,
          Obx(
            () => EasyInfiniteDateTimeLine(
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(DateTime.now().year + 5, 12, 31),
              focusDate: controller.selectedDate.value,
              activeColor: ksecondaryColor,
              showTimelineHeader: true,
              timeLineProps: const EasyTimeLineProps(hPadding: 16),
              dayProps: const EasyDayProps(width: 56, height: 76),
              itemBuilder: (context, date, isSelected, onTap) => _DayCell(
                date: date,
                isSelected: isSelected,
                counts: controller.summaryFor(date),
                onTap: onTap,
              ),
              onDateChange: controller.selectDate,
            ),
          ),
          12.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _ProgressHeader(controller: controller),
          ),
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _FilterBar(controller: controller),
          ),
          8.verticalSpace,
          Expanded(
            child: RefreshIndicator(
              color: buttonColor,
              onRefresh: controller.refreshAll,
              child: Obx(() {
                final status = controller.loadStatus.value;
                final items = controller.visibleTasks;

                if (status == RequestStatus.loading &&
                    controller.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (status == RequestStatus.error && controller.tasks.isEmpty) {
                  return _Message(
                    icon: Icons.cloud_off,
                    title: "Couldn't load tasks",
                    subtitle: 'Pull down to try again',
                  );
                }
                if (items.isEmpty) {
                  return _Message(
                    icon: Icons.event_note_rounded,
                    title: controller.tasks.isEmpty
                        ? 'Nothing planned for ${formatTaskDay(controller.selectedDate.value).toLowerCase()}'
                        : controller.filter.value == TaskFilter.done
                        ? 'Nothing done yet'
                        : 'All done!',
                    subtitle: controller.tasks.isEmpty
                        ? 'Tap + to add a task'
                        : null,
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 110.h),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 10.verticalSpace,
                  itemBuilder: (context, index) {
                    final task = items[index];
                    return TaskCard(
                      key: ValueKey('${task.id}-${task.occurrenceDate}'),
                      task: task,
                      onToggle: () => controller.setDone(task, !task.isDone),
                      onTap: () => showTaskDetails(context, controller, task),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.counts,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final ({int total, int completed})? counts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = SupplementData.daysBetween(DateTime.now(), date) == 0;
    final total = counts?.total ?? 0;
    final allDone = total > 0 && counts!.completed >= total;

    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            supplementWeekdayLabels[date.weekday % 7],
            style: GoogleFonts.darkerGrotesque(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          2.verticalSpace,
          CircleAvatar(
            radius: 19,
            backgroundColor: isSelected ? ksecondaryColor : Colors.white,
            child: Text(
              date.day.toString(),
              style: GoogleFonts.darkerGrotesque(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: isToday && !isSelected ? taskOverdueColor : HeadingColor,
              ),
            ),
          ),
          4.verticalSpace,
          // Marker: green when everything is done, amber when something is left.
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: total == 0
                  ? Colors.transparent
                  : allDone
                  ? taskDoneColor
                  : buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = controller.progressOf(controller.tasks);
      final ratio = progress.total == 0
          ? 0.0
          : progress.completed / progress.total;

      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1C5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatTaskDay(controller.selectedDate.value),
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: HeadingColor,
                    ),
                  ),
                ),
                Text(
                  progress.total == 0
                      ? 'No tasks'
                      : '${progress.completed} of ${progress.total} done',
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
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
        ),
      );
    });
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = controller.progressOf(controller.tasks);
      final counts = {
        TaskFilter.all: progress.total,
        TaskFilter.todo: progress.total - progress.completed,
        TaskFilter.done: progress.completed,
      };
      const labels = {
        TaskFilter.all: 'All',
        TaskFilter.todo: 'To do',
        TaskFilter.done: 'Done',
      };

      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final filter in TaskFilter.values)
            Padding(
              padding: EdgeInsets.zero,
              child: ChoiceChip(
                label: Text(
                  '${labels[filter]} ${counts[filter]}',
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: HeadingColor,
                  ),
                ),
                selected: controller.filter.value == filter,
                selectedColor: const Color(0xFFFFE4A6),
                backgroundColor: Colors.white,
                showCheckmark: false,
                onSelected: (_) => controller.filter.value = filter,
              ),
            ),
        ],
      );
    });
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    // Scrollable so pull-to-refresh still works on an empty list.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
        Icon(icon, size: 40, color: buttonColor),
        12.verticalSpace,
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.darkerGrotesque(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: HeadingColor,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.darkerGrotesque(
              fontSize: 17.sp,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }
}
