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
                      takenToday: controller.isTakenToday(supplement.id),
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
    required this.takenToday,
    required this.onTaken,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplementData supplement;
  final bool takenToday;
  final VoidCallback onTaken;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
          14.verticalSpace,
          Row(
            children: [
              _ReminderChip(supplement: supplement),
              const Spacer(),
              TextButton.icon(
                onPressed: takenToday ? () {} : onTaken,
                style: TextButton.styleFrom(
                  foregroundColor: takenToday ? Colors.green : HeadingColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: Icon(
                  takenToday ? Icons.check_circle : Icons.check_circle_outline,
                  size: 20,
                  color: takenToday ? Colors.green : HeadingColor,
                ),
                label: Text(
                  takenToday ? "Taken" : "Take",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: takenToday ? Colors.green : HeadingColor,
                  ),
                ),
              ),
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
          Text(
            enabled ? supplement.reminderTime ?? "Reminder on" : "Reminder off",
            style: GoogleFonts.darkerGrotesque(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: HeadingColor,
            ),
          ),
        ],
      ),
    );
  }
}

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
  TimeOfDay? reminderTime;

  bool get isEditing => widget.supplement != null;

  @override
  void initState() {
    super.initState();
    final supplement = widget.supplement;
    if (supplement != null) {
      nameController.text = supplement.name ?? '';
      dosageController.text = supplement.dosage ?? '';
      reminderEnabled = supplement.reminderEnabled;
      reminderTime = widget.controller.parseReminderTime(
        supplement.reminderTime,
      );
    } else {
      reminderTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (isEditing) {
      await widget.controller.updateSupplement(
        supplementId: widget.supplement!.id ?? '',
        name: nameController.text,
        dosage: dosageController.text,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
      );
    } else {
      await widget.controller.createSupplement(
        name: nameController.text,
        dosage: dosageController.text,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
      );
    }

    if (!mounted) return;
    if (widget.controller.saveSupplementStatus.value == RequestStatus.success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.92,
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: reminderEnabled,
                activeThumbColor: ksecondaryColor,
                title: Text(
                  "Reminder",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: HeadingColor,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    reminderEnabled = value;
                    reminderTime ??= TimeOfDay.now();
                  });
                },
              ),
              if (reminderEnabled) ...[
                8.verticalSpace,
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: reminderTime ?? TimeOfDay.now(),
                      initialEntryMode: TimePickerEntryMode.inputOnly,
                    );
                    if (picked != null) {
                      setState(() => reminderTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: HeadingColor),
                        10.horizontalSpace,
                        Text(
                          reminderTime == null
                              ? "Choose reminder time"
                              : reminderTime!.format(context),
                          style: GoogleFonts.darkerGrotesque(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: HeadingColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
