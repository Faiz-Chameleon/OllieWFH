import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/home/Dailytask/daily_task_controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateTaskSheet extends StatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  final TodoController todoController = Get.find();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePicker = false;

  void _submitTask() {
    if (_taskController.text.trim().isNotEmpty &&
        selectedDate != null &&
        selectedTime != null) {
      final formattedTime = selectedTime!.format(context);
      final dateStr =
          "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";

      todoController.tasks.add({
        "text": _taskController.text.trim(),
        "description": _descController.text.trim(),
        "date": dateStr,
        "time": formattedTime,
        "done": false,
      });
      todoController.tasks.refresh();
      Navigator.pop(context);
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
                          firstDate: DateTime(2023),
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
                        if (picked != null)
                          setState(() => selectedTime = picked);
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
