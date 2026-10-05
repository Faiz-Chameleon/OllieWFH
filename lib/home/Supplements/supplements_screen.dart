import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/home/Supplements/supplement_controller.dart';
import 'package:ollie/request_status.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen>
    with WidgetsBindingObserver {
  final SupplementController controller = Get.put(SupplementController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMySupplements();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.refreshTakenTodayState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BackgroundColor,
        elevation: 0,
        leading: const BackButton(color: Black),
        title: Text(
          "Supplements",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: HeadingColor,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        onPressed: () => _openSupplementSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final isInitialLoading =
            controller.getSupplementsStatus.value == RequestStatus.loading &&
            controller.supplements.isEmpty;

        if (isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          color: buttonColor,
          onRefresh: controller.getMySupplements,
          child: controller.supplements.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: [
                    SizedBox(height: 220.h),
                    Text(
                      "No supplements yet",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: HeadingColor,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                  itemCount: controller.supplements.length,
                  separatorBuilder: (_, __) => 12.verticalSpace,
                  itemBuilder: (context, index) {
                    final supplement = controller.supplements[index];
                    return _SupplementCard(
                      supplement: supplement,
                      progress: controller.todayProgress(supplement),
                      onTaken: () => controller.markSupplementTaken(supplement),
                      onEdit: () => _openSupplementSheet(context, supplement),
                      onDelete: () =>
                          controller.deleteSupplement(supplement.id ?? ''),
                    );
                  },
                ),
        );
      }),
    );
  }

  void _openSupplementSheet(
    BuildContext context, [
    SupplementData? supplement,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SupplementSheet(controller: controller, supplement: supplement),
    );
  }
}

class _SupplementCard extends StatelessWidget {
  const _SupplementCard({
    required this.supplement,
    required this.progress,
    required this.onTaken,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementData supplement;
  final ({int taken, int total}) progress;
  final VoidCallback onTaken;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dueToday = progress.total > 0;
    final takenToday = dueToday && progress.taken >= progress.total;
    final takeLabel = !dueToday
        ? "Not today"
        : takenToday
        ? "Taken"
        : progress.total > 1
        ? "Take ${progress.taken}/${progress.total}"
        : "Take";
    final takeColor = takenToday
        ? Colors.green
        : dueToday
        ? HeadingColor
        : Colors.black38;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAD89A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: kprimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: HeadingColor,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name ?? "Supplement",
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: HeadingColor,
                      ),
                    ),
                    Text(
                      supplement.dosage ?? "",
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,
          Text(
            _scheduleText(context, supplement),
            style: GoogleFonts.darkerGrotesque(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          8.verticalSpace,
          _ReminderChip(supplement: supplement),
          4.verticalSpace,
          Row(
            children: [
              Flexible(
                child: TextButton.icon(
                  onPressed: takenToday || !dueToday ? null : onTaken,
                  style: TextButton.styleFrom(
                    foregroundColor: takeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  icon: Icon(
                    takenToday
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 20,
                    color: takeColor,
                  ),
                  label: Text(
                    takeLabel,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: takeColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: HeadingColor),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({required this.supplement});

  final SupplementData supplement;

  @override
  Widget build(BuildContext context) {
    final enabled = supplement.reminderEnabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFFFE4A6) : Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            size: 16,
            color: HeadingColor,
          ),
          6.horizontalSpace,
          Flexible(
            child: Text(
              enabled ? _nextReminderText(context, supplement) : "Reminder off",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.darkerGrotesque(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: HeadingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(BuildContext context, String time) {
  final parsed = SupplementData.parseTime(time);
  if (parsed == null) return time;
  return TimeOfDay(hour: parsed.hour, minute: parsed.minute).format(context);
}

String _scheduleText(BuildContext context, SupplementData supplement) {
  final times = supplement.reminderTimes
      .map((time) => _formatTime(context, time))
      .join(', ');
  return times.isEmpty
      ? supplement.scheduleSummary
      : '${supplement.scheduleSummary} · $times';
}

String _formatDay(DateTime day) {
  final today = DateTime.now();
  final diff = SupplementData.daysBetween(today, day);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  final weekday = supplementWeekdayLabels[day.weekday % 7];
  return diff < 7 ? weekday : '$weekday ${day.day}/${day.month}';
}

String _nextReminderText(BuildContext context, SupplementData supplement) {
  final next = supplement.upcomingDoses(DateTime.now(), limit: 1);
  if (next.isEmpty) return "Schedule ended";
  final dose = next.first;
  return 'Next: ${_formatDay(dose.at)} ${_formatTime(context, dose.time)}';
}

/// Weekdays in display order, Monday first, as API values (0 = Sunday).
const List<int> _weekdayDisplayOrder = [1, 2, 3, 4, 5, 6, 0];

class _SupplementSheet extends StatefulWidget {
  const _SupplementSheet({required this.controller, this.supplement});

  final SupplementController controller;
  final SupplementData? supplement;

  @override
  State<_SupplementSheet> createState() => _SupplementSheetState();
}

class _SupplementSheetState extends State<_SupplementSheet> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  bool reminderEnabled = true;
  SupplementFrequency frequency = SupplementFrequency.daily;
  List<TimeOfDay> times = [];
  Set<int> daysOfWeek = {};
  int intervalDays = 2;
  late DateTime startDate;
  DateTime? endDate;

  bool get isEditing => widget.supplement != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final supplement = widget.supplement;
    if (supplement != null) {
      nameController.text = supplement.name ?? '';
      dosageController.text = supplement.dosage ?? '';
      reminderEnabled = supplement.reminderEnabled;
      frequency = supplement.frequency;
      times = supplement.reminderTimes
          .map(widget.controller.parseReminderTime)
          .whereType<TimeOfDay>()
          .toList();
      daysOfWeek = supplement.daysOfWeek.toSet();
      intervalDays = supplement.intervalDays ?? 2;
      startDate = supplement.start ?? today;
      endDate = supplement.end;
    } else {
      times = [TimeOfDay.now()];
      daysOfWeek = {today.weekday % 7};
      startDate = today;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    super.dispose();
  }

  SupplementScheduleInput get _schedule => SupplementScheduleInput(
    reminderEnabled: reminderEnabled,
    frequency: frequency,
    times: times,
    daysOfWeek: daysOfWeek,
    intervalDays: intervalDays,
    startDate: startDate,
    endDate: endDate,
  );

  Future<void> _save() async {
    if (isEditing) {
      await widget.controller.updateSupplement(
        supplementId: widget.supplement!.id ?? '',
        name: nameController.text,
        dosage: dosageController.text,
        schedule: _schedule,
      );
    } else {
      await widget.controller.createSupplement(
        name: nameController.text,
        dosage: dosageController.text,
        schedule: _schedule,
      );
    }

    if (!mounted) return;
    if (widget.controller.saveSupplementStatus.value == RequestStatus.success) {
      Navigator.pop(context);
    }
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked == null) return;
    setState(() {
      if (!times.contains(picked)) times.add(picked);
      times.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    });
  }

  Future<void> _editTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: times[index],
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked == null) return;
    setState(() {
      times[index] = picked;
      times = times.toSet().toList()
        ..sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
    });
  }

  Future<DateTime?> _pickDate(DateTime initial, {DateTime? first}) {
    final firstDate = first ?? DateTime(DateTime.now().year - 1);
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 5),
    );
  }

  TextStyle get _chipStyle => GoogleFonts.darkerGrotesque(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: HeadingColor,
  );

  Widget _choiceChip(String label, SupplementFrequency value) {
    return ChoiceChip(
      label: Text(label, style: _chipStyle),
      selected: frequency == value,
      selectedColor: const Color(0xFFFFE4A6),
      backgroundColor: Colors.white,
      showCheckmark: false,
      onSelected: (_) => setState(() => frequency = value),
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: HeadingColor),
            10.horizontalSpace,
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: HeadingColor,
                ),
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
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
              18.verticalSpace,
              Text(
                isEditing ? "Edit Supplement" : "Add Supplement",
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: HeadingColor,
                ),
              ),
              20.verticalSpace,
              _InputLabel(text: "Supplement name"),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: "Vitamin D3"),
              ),
              16.verticalSpace,
              _InputLabel(text: "Dosage"),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(hintText: "1 tablet"),
              ),
              20.verticalSpace,
              _InputLabel(text: "How often"),
              8.verticalSpace,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _choiceChip("Every day", SupplementFrequency.daily),
                  _choiceChip("Specific days", SupplementFrequency.weekly),
                  _choiceChip("Every few days", SupplementFrequency.interval),
                ],
              ),
              if (frequency == SupplementFrequency.weekly) ...[
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
                        selectedColor: const Color(0xFFFFE4A6),
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
              if (frequency == SupplementFrequency.interval) ...[
                12.verticalSpace,
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
              20.verticalSpace,
              _InputLabel(text: "Starts"),
              8.verticalSpace,
              _dateTile(
                icon: Icons.event,
                label: _formatDate(startDate),
                onTap: () async {
                  final picked = await _pickDate(startDate);
                  if (picked == null) return;
                  setState(() {
                    startDate = picked;
                    if (endDate != null && endDate!.isBefore(picked)) {
                      endDate = null;
                    }
                  });
                },
              ),
              12.verticalSpace,
              _InputLabel(text: "Ends"),
              8.verticalSpace,
              _dateTile(
                icon: Icons.event_busy,
                label: endDate == null ? "No end date" : _formatDate(endDate!),
                onTap: () async {
                  final picked = await _pickDate(
                    endDate ?? startDate,
                    first: startDate,
                  );
                  if (picked != null) setState(() => endDate = picked);
                },
                onClear: endDate == null
                    ? null
                    : () => setState(() => endDate = null),
              ),
              20.verticalSpace,
              _InputLabel(text: "Times"),
              8.verticalSpace,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < times.length; i++)
                    InputChip(
                      avatar: const Icon(
                        Icons.access_time,
                        size: 18,
                        color: HeadingColor,
                      ),
                      label: Text(times[i].format(context), style: _chipStyle),
                      backgroundColor: Colors.white,
                      onPressed: () => _editTime(i),
                      onDeleted: () => setState(() => times.removeAt(i)),
                    ),
                  if (times.length < maxReminderTimes)
                    ActionChip(
                      avatar: const Icon(
                        Icons.add,
                        size: 18,
                        color: HeadingColor,
                      ),
                      label: Text("Add time", style: _chipStyle),
                      backgroundColor: Colors.white,
                      onPressed: _addTime,
                    ),
                ],
              ),
              12.verticalSpace,
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
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: HeadingColor,
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    reminderEnabled = value;
                    if (value && times.isEmpty) times = [TimeOfDay.now()];
                  }),
                ),
              ),
              30.verticalSpace,
              Obx(() {
                final isLoading =
                    widget.controller.saveSupplementStatus.value ==
                    RequestStatus.loading;
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
                          isEditing ? "Update" : "Save",
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

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.darkerGrotesque(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: HeadingColor,
      ),
    );
  }
}
