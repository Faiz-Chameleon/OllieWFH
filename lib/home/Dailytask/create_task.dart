import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/home/home_repository.dart';
import 'package:ollie/home/Dailytask/device_time_zone_service.dart';
import 'package:ollie/home/Dailytask/easy_date_picker_controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  final HomeRepository _homeRepository = HomeRepository();
  static const Duration _minimumReminderLeadTime = Duration(minutes: 6);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePicker = false;

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<String> _getTimeZone() async {
    return DeviceTimeZoneService.getIanaTimeZone();
  }

  Future<void> _submitTask() async {
    if (_taskController.text.trim().isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      final now = DateTime.now();
      final scheduledAt = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      if (scheduledAt.isBefore(now.add(_minimumReminderLeadTime))) {
        appSnackbar(
          "Error",
          "Please choose a time at least 6 minutes from now.",
        );
        return;
      }

      final timeZone = await _getTimeZone();
      final payload = {
        "taskName": _taskController.text.trim(),
        "taskDescription": _descController.text.trim(),
        "date": _formatDate(selectedDate!),
        "time": _formatTime(selectedTime!),
        "timeZone": timeZone,
      };

      final result = await _homeRepository.createTask(payload);
      if (result["success"] == true) {
        if (Get.isRegistered<EasyDatePickerController>()) {
          await Get.find<EasyDatePickerController>().userTaskByDateOnHome();
        }
        appSnackbar(
          "Success",
          result["message"] ?? "Task created successfully",
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        appSnackbar("Error", result["message"] ?? "Something went wrong");
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
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
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
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _taskController.text.trim().isNotEmpty &&
                          selectedDate != null &&
                          selectedTime != null
                      ? const Color(0xFF3C3129)
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Create a Task",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
