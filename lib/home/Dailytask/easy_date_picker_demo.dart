// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/request_status.dart';
import 'easy_date_picker_controller.dart' as local_controller;
import 'package:ollie/common/common.dart';

// Extension to get month name from DateTime
extension DateExtensions on DateTime {
  String get monthName => [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ][month - 1];
}

/// To use this screen, navigate to EasyDatePickerDemoScreen() from anywhere in your app.
/// Example:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => EasyDatePickerDemoScreen()));
class EasyDatePickerDemoScreen extends StatefulWidget {
  EasyDatePickerDemoScreen({Key? key}) : super(key: key);

  @override
  State<EasyDatePickerDemoScreen> createState() =>
      _EasyDatePickerDemoScreenState();
}

class _EasyDatePickerDemoScreenState extends State<EasyDatePickerDemoScreen> {
  final local_controller.EasyDatePickerController controller = Get.put(
    local_controller.EasyDatePickerController(),
  );

  @override
  void initState() {
    super.initState();
    controller.userTaskByDate();

    // ✅ Add page request listener here
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        backgroundColor: BGcolor,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'To-Do List',
          style: GoogleFonts.darkerGrotesque(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: HeadingColor,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Black,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateTaskSheet(controller: controller),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Obx(
            () => EasyInfiniteDateTimeLine(
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2030, 3, 18),
              focusDate: controller.focusedDate.value,
              activeColor: ksecondaryColor,
              showTimelineHeader: true,
              timeLineProps: const EasyTimeLineProps(hPadding: 16),
              dayProps: const EasyDayProps(width: 64, height: 64),
              itemBuilder: (context, date, isSelected, onTap) {
                return InkResponse(
                  onTap: onTap,
                  child: CircleAvatar(
                    backgroundColor: isSelected
                        ? ksecondaryColor
                        : Colors.white,
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : HeadingColor,
                      ),
                    ),
                  ),
                );
              },
              onDateChange: (date) {
                controller.setFocusedDate(date);
              },
            ),
          ),
          const SizedBox(height: 24),
          // Custom Task List Widget
          Expanded(
            child: Obx(() {
              final taskList = controller.tasks;

              if (taskList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          size: 34,
                          color: buttonColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "No tasks for today",
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: HeadingColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tap + to add your first task",
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 110),
                itemCount: taskList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = taskList[index];
                  final originalIndex = controller.tasks.indexOf(task);
                  final isDone = task["markAsComplete"] == true;
                  final taskName = (task["taskName"] ?? "Untitled task")
                      .toString();
                  final description = (task["taskDescription"] ?? "")
                      .toString();
                  final timeText =
                      (task["scheduledTime"] ?? task["time"] ?? "Any time")
                          .toString();

                  return _TaskCard(
                    title: taskName,
                    description: description,
                    timeText: timeText,
                    isDone: isDone,
                    onComplete: () =>
                        controller.toggleTask(originalIndex, task["id"]),
                    onTap: () {
                      if (!isDone) {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return Dialog(
                              backgroundColor: BGcolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: ksecondaryColor.withOpacity(
                                          0.18,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        color: buttonColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      taskName,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.darkerGrotesque(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: HeadingColor,
                                      ),
                                    ),
                                    if (description.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.darkerGrotesque(
                                          fontSize: 17,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              controller.toggleTask(
                                                originalIndex,
                                                task["id"],
                                              );
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: buttonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              minimumSize: const Size(
                                                double.infinity,
                                                46,
                                              ),
                                            ),
                                            child: Text(
                                              "Mark Done",
                                              style:
                                                  GoogleFonts.darkerGrotesque(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            backgroundColor: BGcolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              "Delete Task",
                              style: GoogleFonts.darkerGrotesque(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete "$taskName"?',
                              style: GoogleFonts.darkerGrotesque(fontSize: 18),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await controller.deleteTask(task["id"]);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            }),

            // PagedListView<int, Map<String, dynamic>>(
            //   pagingController: controller.pagingController,
            //   builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
            //     itemBuilder: (context, task, index) {
            //       final isDone = task["done"] == true;

            //       // Fix: Parse the date string safely
            //       DateTime taskDate =
            //           DateTime.tryParse(task['date'].toString()) ??
            //           DateTime.now();

            //       // Fix: check previous task's date to show header only once
            //       bool showDateHeader = false;
            //       if (index == 0) {
            //         showDateHeader = true;
            //       } else {
            //         final prevTask =
            //             controller.pagingController.itemList![index - 1];
            //         DateTime prevDate =
            //             DateTime.tryParse(prevTask['date'].toString()) ??
            //             DateTime.now();
            //         showDateHeader = !_isSameDay(taskDate, prevDate);
            //       }
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeText;
  final bool isDone;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.title,
    required this.description,
    required this.timeText,
    required this.isDone,
    required this.onComplete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDone ? const Color(0xFF2E9B65) : const Color(0xFF3C3129);
    final surface = isDone ? const Color(0xFFF1FBF5) : const Color(0xFFFFF7E5);
    final rail = isDone ? const Color(0xFF8ED3A7) : ksecondaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: isDone ? const Color(0xFFD7F0E0) : const Color(0xFFF0E1AD),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 96,
                decoration: BoxDecoration(
                  color: rail,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onComplete,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: accent,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDone ? "Completed task" : "Upcoming task",
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: accent.withOpacity(0.75),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 24,
                                  height: 0.95,
                                  fontWeight: FontWeight.w800,
                                  color: isDone ? Colors.black45 : HeadingColor,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: accent.withOpacity(0.12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 15,
                                color: accent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                timeText,
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFFD9F5E5)
                                : const Color(0xFFFFE7BA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isDone ? "Done" : "Pending",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDone
                                  ? const Color(0xFF1D7A4D)
                                  : const Color(0xFF9D6500),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: onDelete,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                          label: Text(
                            "Delete",
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

class CreateTaskSheet extends StatefulWidget {
  final local_controller.EasyDatePickerController controller;
  const CreateTaskSheet({Key? key, required this.controller}) : super(key: key);

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  static const Duration _minimumReminderLeadTime = Duration(minutes: 6);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePicker = false;

  void _submitTask() async {
    if (_taskController.text.trim().isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      await widget.controller.userCreateTask(
        taskName: _taskController.text.trim(),
        taskDescription: _descController.text.trim(),
        date: selectedDate!,
        time: selectedTime!,
      );

      if (!mounted) {
        return;
      }

      if (widget.controller.createTaskStatus.value == RequestStatus.success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: BGcolor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Icon(Icons.drag_handle, color: Colors.black26),
              ),
              20.verticalSpace,
              Text(
                "Create a Task",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              20.verticalSpace,
              Text(
                "What do you want to do?",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextField(
                controller: _taskController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: "Type your task here",
                ),
              ),
              15.verticalSpace,
              Text(
                "Add a short note",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextField(
                controller: _descController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: "Example: Take medicine after breakfast",
                ),
              ),
              25.verticalSpace,

              /// Expandable Date & Time Section
              GestureDetector(
                onTap: () {
                  setState(() => showDateTimePicker = !showDateTimePicker);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: ksecondaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose day and time",
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        showDateTimePicker
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),
              if (showDateTimePicker) ...[
                15.verticalSpace,
                Text(
                  "Select a day",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                8.verticalSpace,
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaleFactor: 1.15),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: Theme.of(
                                context,
                              ).textTheme.apply(fontSizeFactor: 1.15),
                              datePickerTheme: const DatePickerThemeData(
                                headerHeadlineStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                                weekdayStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                dayStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedDate != null
                          ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                          : "Choose a day",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                15.verticalSpace,
                Text(
                  "Select a time",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                8.verticalSpace,
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                      initialEntryMode: TimePickerEntryMode.inputOnly,
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaleFactor: 1.15),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              timePickerTheme: const TimePickerThemeData(
                                hourMinuteTextStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                dayPeriodTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                dialTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (picked != null) {
                      final now = DateTime.now();
                      final selected = DateTime(
                        selectedDate?.year ?? now.year,
                        selectedDate?.month ?? now.month,
                        selectedDate?.day ?? now.day,
                        picked.hour,
                        picked.minute,
                      );
                      if (selectedDate != null &&
                          selected.isBefore(
                            now.add(_minimumReminderLeadTime),
                          )) {
                        appSnackbar(
                          "Error",
                          "Please choose a time at least 6 minutes from now.",
                        );
                        return;
                      }
                      setState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : "Choose a time",
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: HeadingColor,
                          ),
                        ),
                        const Icon(Icons.access_time, color: HeadingColor),
                      ],
                    ),
                  ),
                ),
              ],
              30.verticalSpace,
              Obx(
                () => ElevatedButton(
                  onPressed:
                      widget.controller.createTaskStatus.value ==
                          RequestStatus.loading
                      ? null
                      : _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _taskController.text.trim().isNotEmpty &&
                            selectedDate != null &&
                            selectedTime != null &&
                            widget.controller.createTaskStatus.value !=
                                RequestStatus.loading
                        ? buttonColor
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child:
                      widget.controller.createTaskStatus.value ==
                          RequestStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "Save Task",
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
