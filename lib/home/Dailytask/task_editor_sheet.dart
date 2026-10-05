import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/task_model.dart';
import 'package:ollie/home/Dailytask/task_controller.dart';
import 'package:ollie/request_status.dart';

/// Opens the add/edit task sheet. [initialDate] seeds a new task's date.
Future<void> showTaskEditor(
  BuildContext context,
  TaskController controller, {
  TaskItem? task,
  DateTime? initialDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskEditorSheet(
      controller: controller,
      task: task,
      initialDate: initialDate,
    ),
  );
}

/// Weekdays in display order, Monday first, as API values (0 = Sunday).
const List<int> _weekdayDisplayOrder = [1, 2, 3, 4, 5, 6, 0];

const Color _chipSelected = Color(0xFFFFE4A6);

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    required this.controller,
    this.task,
    this.initialDate,
  });

  final TaskController controller;
  final TaskItem? task;
  final DateTime? initialDate;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _ChecklistDraft {
  _ChecklistDraft({this.id, String text = '', this.done = false})
    : controller = TextEditingController(text: text);

  final String? id;
  final bool done;
  final TextEditingController controller;
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final List<_ChecklistDraft> checklist = [];

  late DateTime date;
  late TimeOfDay time;
  TaskRecurrence recurrence = TaskRecurrence.none;
  Set<int> daysOfWeek = {};
  int intervalDays = 2;
  DateTime? endDate;
  TaskPriority priority = TaskPriority.medium;
  String? category;
  bool reminderEnabled = true;
  int reminderMinutesBefore = 5;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      nameController.text = task.taskName;
      notesController.text = task.taskDescription ?? '';
      date = task.taskDate;
      final parsed = task.time;
      time = TimeOfDay(hour: parsed?.hour ?? 9, minute: parsed?.minute ?? 0);
      recurrence = task.recurrence;
      daysOfWeek = task.daysOfWeek.toSet();
      intervalDays = task.intervalDays ?? 2;
      endDate = task.recurrenceEndDate;
      priority = task.priority;
      category = task.category;
      reminderEnabled = task.reminderEnabled;
      reminderMinutesBefore = task.reminderMinutesBefore;
      checklist.addAll(
        task.checklist.map(
          (item) =>
              _ChecklistDraft(id: item.id, text: item.text, done: item.done),
        ),
      );
    } else {
      final now = DateTime.now();
      final initial = widget.initialDate ?? now;
      date = DateTime(initial.year, initial.month, initial.day);
      // Default to the next whole hour.
      final nextHour = now.add(const Duration(hours: 1));
      time = TimeOfDay(hour: nextHour.hour, minute: 0);
      daysOfWeek = {date.weekday % 7};
    }
    if (!taskReminderLeadOptions.contains(reminderMinutesBefore)) {
      reminderMinutesBefore = 5;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    for (final item in checklist) {
      item.controller.dispose();
    }
    super.dispose();
  }

  TaskInput get _input => TaskInput(
    taskName: nameController.text,
    taskDescription: notesController.text,
    date: date,
    hour: time.hour,
    minute: time.minute,
    recurrence: recurrence,
    daysOfWeek: daysOfWeek,
    intervalDays: intervalDays,
    recurrenceEndDate: endDate,
    priority: priority,
    category: category,
    checklist: [
      for (final item in checklist)
        TaskChecklistItem(
          id: item.id,
          text: item.controller.text,
          done: item.done,
        ),
    ],
    reminderEnabled: reminderEnabled,
    reminderMinutesBefore: reminderMinutesBefore,
  );

  Future<void> _save() async {
    final saved = await widget.controller.save(_input, editing: widget.task);
    if (saved && mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: date.isBefore(first) ? first : date,
      firstDate: first,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      date = picked;
      if (endDate != null && endDate!.isBefore(picked)) endDate = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? date,
      firstDate: date,
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  TextStyle get _chipStyle => GoogleFonts.darkerGrotesque(
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    color: HeadingColor,
  );

  TextStyle get _valueStyle => GoogleFonts.darkerGrotesque(
    fontSize: 19.sp,
    fontWeight: FontWeight.w600,
    color: HeadingColor,
  );

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(top: 18.h, bottom: 8.h),
    child: Text(
      text,
      style: GoogleFonts.darkerGrotesque(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: HeadingColor,
      ),
    ),
  );

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: _chipStyle),
      selected: selected,
      selectedColor: _chipSelected,
      backgroundColor: Colors.white,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: HeadingColor, size: 20),
            8.horizontalSpace,
            Expanded(
              child: Text(
                label,
                style: _valueStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 20, color: Colors.black45),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final weekday = supplementWeekdayLabels[value.weekday % 7];
    return '$weekday ${value.day}/${value.month}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final repeating = recurrence != TaskRecurrence.none;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
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
              8.verticalSpace,
              Text(
                isEditing ? "Edit Task" : "New Task",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: HeadingColor,
                ),
              ),
              if (isEditing && widget.task!.isRecurring)
                Text(
                  "Changes apply to every day this task repeats.",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 16.sp,
                    color: Colors.black54,
                  ),
                ),
              _label("Task"),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: "e.g. Call the pharmacy",
                  counterText: "",
                ),
              ),
              _label("Notes"),
              TextField(
                controller: notesController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Optional details"),
              ),
              _label(repeating ? "Starts" : "When"),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _pill(
                      icon: Icons.event,
                      label: _formatDate(date),
                      onTap: _pickDate,
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    flex: 2,
                    child: _pill(
                      icon: Icons.access_time,
                      label: time.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              _label("Repeat"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _choice(
                    "Never",
                    recurrence == TaskRecurrence.none,
                    () => setState(() => recurrence = TaskRecurrence.none),
                  ),
                  _choice(
                    "Daily",
                    recurrence == TaskRecurrence.daily,
                    () => setState(() => recurrence = TaskRecurrence.daily),
                  ),
                  _choice(
                    "Weekly",
                    recurrence == TaskRecurrence.weekly,
                    () => setState(() => recurrence = TaskRecurrence.weekly),
                  ),
                  _choice(
                    "Every few days",
                    recurrence == TaskRecurrence.interval,
                    () => setState(() => recurrence = TaskRecurrence.interval),
                  ),
                  _choice(
                    "Monthly",
                    recurrence == TaskRecurrence.monthly,
                    () => setState(() => recurrence = TaskRecurrence.monthly),
                  ),
                ],
              ),
              if (recurrence == TaskRecurrence.weekly) ...[
                12.verticalSpace,
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final day in _weekdayDisplayOrder)
                      FilterChip(
                        label: Text(
                          supplementWeekdayLabels[day],
                          style: _chipStyle,
                        ),
                        selected: daysOfWeek.contains(day),
                        selectedColor: _chipSelected,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        onSelected: (selected) => setState(() {
                          selected
                              ? daysOfWeek.add(day)
                              : daysOfWeek.remove(day);
                        }),
                      ),
                  ],
                ),
              ],
              if (recurrence == TaskRecurrence.interval) ...[
                8.verticalSpace,
                Row(
                  children: [
                    Text("Every", style: _chipStyle),
                    IconButton(
                      onPressed: intervalDays > 2
                          ? () => setState(() => intervalDays--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: HeadingColor,
                    ),
                    Text("$intervalDays", style: _chipStyle),
                    IconButton(
                      onPressed: intervalDays < 365
                          ? () => setState(() => intervalDays++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: HeadingColor,
                    ),
                    Text("days", style: _chipStyle),
                  ],
                ),
              ],
              if (recurrence == TaskRecurrence.monthly) ...[
                8.verticalSpace,
                Text(
                  "On day ${date.day} of each month"
                  "${date.day > 28 ? " (or the last day of shorter months)" : ""}.",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 16.sp,
                    color: Colors.black54,
                  ),
                ),
              ],
              if (repeating) ...[
                12.verticalSpace,
                _pill(
                  icon: Icons.event_busy,
                  label: endDate == null
                      ? "Repeats forever"
                      : "Until ${_formatDate(endDate!)}",
                  onTap: _pickEndDate,
                  onClear: endDate == null
                      ? null
                      : () => setState(() => endDate = null),
                ),
              ],
              _label("Priority"),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in TaskPriority.values)
                    _choice(
                      value.label,
                      priority == value,
                      () => setState(() => priority = value),
                    ),
                ],
              ),
              _label("Category"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in taskCategories)
                    _choice(
                      value,
                      category == value,
                      // Tapping the selected category clears it.
                      () => setState(
                        () => category = category == value ? null : value,
                      ),
                    ),
                ],
              ),
              _label("Checklist"),
              for (var i = 0; i < checklist.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_box_outline_blank,
                        size: 20,
                        color: Colors.black38,
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: TextField(
                          controller: checklist[i].controller,
                          maxLength: 200,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: "Step",
                            counterText: "",
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          checklist.removeAt(i).controller.dispose();
                        }),
                        icon: const Icon(Icons.close, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              if (checklist.length < 30)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => checklist.add(_ChecklistDraft())),
                    icon: const Icon(Icons.add, color: HeadingColor),
                    label: Text("Add step", style: _chipStyle),
                  ),
                ),
              8.verticalSpace,
              // ListTile paints on the nearest Material; the sheet's coloured
              // Container would otherwise hide its ink.
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: reminderEnabled,
                  activeThumbColor: ksecondaryColor,
                  title: Text(
                    "Remind me",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: HeadingColor,
                    ),
                  ),
                  onChanged: (value) => setState(() => reminderEnabled = value),
                ),
              ),
              if (reminderEnabled)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final minutes in taskReminderLeadOptions)
                      _choice(
                        describeReminderLead(minutes),
                        reminderMinutesBefore == minutes,
                        () => setState(() => reminderMinutesBefore = minutes),
                      ),
                  ],
                ),
              28.verticalSpace,
              Obx(() {
                final isLoading =
                    widget.controller.saveStatus.value == RequestStatus.loading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? "Save changes" : "Create task",
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
