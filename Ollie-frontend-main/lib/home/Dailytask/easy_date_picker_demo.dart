import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ollie/request_status.dart';
import 'easy_date_picker_controller.dart' as local_controller;

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
      appBar: AppBar(title: const Text('To-Do List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateTaskSheet(controller: controller),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Obx(
            () => Text(
              "${controller.focusedDate.value.monthName} ${controller.focusedDate.value.year}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => EasyDateTimeLinePicker.itemBuilder(
              firstDate: DateTime(2025, 1, 1),
              lastDate: DateTime(2030, 3, 18),
              focusedDate: controller.focusedDate.value,
              itemExtent: 64.0,
              itemBuilder:
                  (context, date, isSelected, isDisabled, isToday, onTap) {
                    return InkResponse(
                      onTap: onTap,
                      child: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blue : null,
                        child: Text(date.day.toString()),
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
                return const Center(child: Text("No tasks for this date"));
              }

              return ListView.separated(
                itemCount: taskList.length,
                separatorBuilder: (_, __) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = taskList[index];
                  final originalIndex = controller.tasks.indexOf(task);
                  final isDone = task["markAsComplete"];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.toggleTask(originalIndex, task["id"]);
                        },
                        child: Container(
                          height: 58.h,
                          width: 35.h,
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          child: Icon(
                            isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isDone
                                ? const Color(0xFFF4BD2A)
                                : Colors.black45,
                            size: 28,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isDone) {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return Dialog(
                                    backgroundColor: const Color(0xFFFDF3DD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 30,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            task["taskName"] as String,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (task["taskDescription"] != null &&
                                              (task["taskDescription"]
                                                      as String)
                                                  .isNotEmpty)
                                            Text(
                                              task["taskDescription"] as String,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          const SizedBox(height: 25),
                                          ElevatedButton(
                                            onPressed: () {
                                              controller.toggleTask(
                                                originalIndex,
                                                task["id"],
                                              );
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF3C3129,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              minimumSize: const Size(
                                                double.infinity,
                                                45,
                                              ),
                                            ),
                                            child: const Text(
                                              "Mark as Completed",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Colors.black,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              minimumSize: const Size(
                                                double.infinity,
                                                45,
                                              ),
                                              foregroundColor: Colors.black,
                                            ),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            height: 58.h,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFFFFE38E) : white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task["taskName"],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  task["scheduledTime"] ?? "9:00 PM",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

class CreateTaskSheet extends StatefulWidget {
  final local_controller.EasyDatePickerController controller;
  const CreateTaskSheet({Key? key, required this.controller}) : super(key: key);

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePicker = false;

  void _submitTask() async {
    if (_taskController.text.trim().isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      String formatTimeOfDay(TimeOfDay time) {
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        return DateFormat('HH:mm:ss').format(dt);
      }

      final formattedTime = formatTimeOfDay(selectedTime!);
      final formattedDate = DateFormat('yyyy-MM-dd').format(
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day),
      );

      var data = {
        "taskName": _taskController.text.trim(),
        "taskDescription": _descController.text.trim(),
        "date": formattedDate.toString(),

        "time": formattedTime,
      };
      await widget.controller.userCreateTask(data);

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
            color: white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Icon(Icons.drag_handle, color: Colors.black26),
              ),
              20.verticalSpace,
              const Text(
                "Create a Task",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              20.verticalSpace,
              const Text("Task", style: TextStyle(fontWeight: FontWeight.w600)),
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  hintText: "Enter the new task name",
                ),
              ),
              15.verticalSpace,
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: "Enter task description",
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
                    color: const Color(0xFFF4BD2A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date and Time",
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Date"),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                            : "Pick Date",
                      ),
                    ),
                    const Text("Time"),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
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
                              _isSameDay(selectedDate!, now) &&
                              selected.isBefore(now)) {
                            Get.snackbar(
                              "Error",
                              "You can't select a past time.",
                            );

                            return;
                          }
                          setState(() => selectedTime = picked);
                        }
                      },

                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : "Pick Time",
                      ),
                    ),
                  ],
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
                        ? const Color(0xFF3C3129)
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
                      : const Text(
                          "Create a Task",
                          style: TextStyle(color: Colors.white),
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

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
