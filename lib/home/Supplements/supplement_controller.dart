import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/home/Dailytask/device_time_zone_service.dart';
import 'package:ollie/home/Supplements/supplement_repository.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/services/firebase_service.dart';

const int maxReminderTimes = 6;

/// What the add/edit sheet collects about when a supplement is taken.
class SupplementScheduleInput {
  SupplementScheduleInput({
    required this.reminderEnabled,
    required this.frequency,
    required this.times,
    this.daysOfWeek = const {},
    this.intervalDays = 2,
    required this.startDate,
    this.endDate,
  });

  final bool reminderEnabled;
  final SupplementFrequency frequency;
  final List<TimeOfDay> times;

  /// 0 = Sunday ... 6 = Saturday.
  final Set<int> daysOfWeek;
  final int intervalDays;
  final DateTime startDate;
  final DateTime? endDate;

  Map<String, dynamic> toPayload(String Function(TimeOfDay) formatTime) {
    final sortedTimes = times.map(formatTime).toSet().toList()..sort();
    return {
      'reminderEnabled': reminderEnabled,
      'frequency': frequency.apiValue,
      'reminderTimes': sortedTimes,
      'daysOfWeek': frequency == SupplementFrequency.weekly
          ? (daysOfWeek.toList()..sort())
          : null,
      'intervalDays': frequency == SupplementFrequency.interval
          ? intervalDays
          : null,
      'startDate': SupplementData.formatDate(startDate),
      'endDate': endDate == null ? null : SupplementData.formatDate(endDate!),
    };
  }
}

class SupplementController extends GetxController {
  final SupplementRepository _repository = SupplementRepository();

  final supplements = <SupplementData>[].obs;

  /// Supplement id -> dose times taken today (see [SupplementData.doseKeysOn]).
  final takenToday = <String, Set<String>>{}.obs;
  final getSupplementsStatus = RequestStatus.idle.obs;
  final saveSupplementStatus = RequestStatus.idle.obs;
  final deleteSupplementStatus = RequestStatus.idle.obs;

  String formatTimeForApi(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? parseReminderTime(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> getMySupplements() async {
    getSupplementsStatus.value = RequestStatus.loading;

    final result = await _repository.getMySupplements();
    if (result['success'] == true) {
      final model = SupplementModel.fromJson(result);
      supplements.assignAll(model.data);
      await _loadTakenTodayState(model.data);
      await FirebaseService.instance.syncSupplementAlarms(model.data);
      getSupplementsStatus.value = RequestStatus.success;
    } else {
      getSupplementsStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Failed to load supplements");
    }
  }

  Future<void> _loadTakenTodayState(List<SupplementData> items) async {
    final taken = <String, Set<String>>{};
    for (final supplement in items) {
      final id = supplement.id?.trim();
      if (id == null || id.isEmpty) continue;
      taken[id] = await FirebaseService.instance.supplementDosesTakenToday(id);
    }
    takenToday.assignAll(taken);
  }

  Future<void> refreshTakenTodayState() async {
    await _loadTakenTodayState(supplements);
  }

  /// Doses due today for [supplement] and how many of them are taken.
  ({int taken, int total}) todayProgress(SupplementData supplement) {
    final doses = supplement.doseKeysOn(DateTime.now());
    final taken = takenToday[supplement.id?.trim()] ?? const <String>{};
    if (taken.contains(supplementAnyTimeDose)) {
      return (taken: doses.length, total: doses.length);
    }
    return (taken: doses.where(taken.contains).length, total: doses.length);
  }

  Future<void> markSupplementTaken(SupplementData supplement) async {
    final supplementId = supplement.id?.trim() ?? '';
    if (supplementId.isEmpty) {
      appSnackbar("Error", "Supplement id is missing.");
      return;
    }

    // Doses are taken in order: mark the earliest one not yet taken today.
    final taken = takenToday[supplementId] ?? const <String>{};
    final dose = supplement
        .doseKeysOn(DateTime.now())
        .where((time) => !taken.contains(time))
        .firstOrNull;
    if (dose == null || taken.contains(supplementAnyTimeDose)) {
      appSnackbar("Done", "No more doses due today.");
      return;
    }

    await FirebaseService.instance.markSupplementDoseTaken(supplement, dose);
    takenToday[supplementId] = {...taken, dose};
    appSnackbar("Done", "${supplement.name ?? "Supplement"} marked as taken");
  }

  Future<void> createSupplement({
    required String name,
    required String dosage,
    required SupplementScheduleInput schedule,
  }) async {
    await _saveSupplement(name: name, dosage: dosage, schedule: schedule);
  }

  Future<void> updateSupplement({
    required String supplementId,
    required String name,
    required String dosage,
    required SupplementScheduleInput schedule,
  }) async {
    if (supplementId.isEmpty) {
      appSnackbar("Error", "Supplement id is missing.");
      return;
    }

    await _saveSupplement(
      supplementId: supplementId,
      name: name,
      dosage: dosage,
      schedule: schedule,
    );
  }

  /// Returns an error message, or null when [schedule] can be saved.
  String? validateSchedule(SupplementScheduleInput schedule) {
    if (schedule.reminderEnabled && schedule.times.isEmpty) {
      return "Please add at least one reminder time.";
    }
    if (schedule.times.length > maxReminderTimes) {
      return "You can add up to $maxReminderTimes reminder times.";
    }
    if (schedule.frequency == SupplementFrequency.weekly &&
        schedule.daysOfWeek.isEmpty) {
      return "Please choose at least one day.";
    }
    if (schedule.frequency == SupplementFrequency.interval &&
        (schedule.intervalDays < 1 || schedule.intervalDays > 365)) {
      return "Repeat interval must be between 1 and 365 days.";
    }
    final endDate = schedule.endDate;
    if (endDate != null &&
        SupplementData.daysBetween(schedule.startDate, endDate) < 0) {
      return "End date cannot be before the start date.";
    }
    return null;
  }

  Future<void> _saveSupplement({
    String? supplementId,
    required String name,
    required String dosage,
    required SupplementScheduleInput schedule,
  }) async {
    final cleanName = name.trim();
    final cleanDosage = dosage.trim();

    if (cleanName.isEmpty) {
      appSnackbar("Error", "Please enter supplement name.");
      return;
    }
    if (cleanDosage.isEmpty) {
      appSnackbar("Error", "Please enter dosage.");
      return;
    }
    final scheduleError = validateSchedule(schedule);
    if (scheduleError != null) {
      appSnackbar("Error", scheduleError);
      return;
    }

    final payload = <String, dynamic>{
      'name': cleanName,
      'dosage': cleanDosage,
      ...schedule.toPayload(formatTimeForApi),
      'timeZone': await DeviceTimeZoneService.getIanaTimeZone(),
    };

    saveSupplementStatus.value = RequestStatus.loading;
    final result = supplementId == null
        ? await _repository.createMySupplement(payload)
        : await _repository.updateMySupplement(supplementId, payload);

    if (result['success'] == true) {
      await getMySupplements();
      saveSupplementStatus.value = RequestStatus.success;
      appSnackbar(
        "Success",
        result['message'] ??
            (supplementId == null ? "Supplement added" : "Supplement updated"),
      );
    } else {
      saveSupplementStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Failed to save supplement");
    }
  }

  Future<void> deleteSupplement(String supplementId) async {
    if (supplementId.isEmpty) {
      appSnackbar("Error", "Supplement id is missing.");
      return;
    }

    deleteSupplementStatus.value = RequestStatus.loading;

    final result = await _repository.deleteMySupplement(supplementId);
    if (result['success'] == true) {
      supplements.removeWhere((item) => item.id == supplementId);
      takenToday.remove(supplementId);
      await FirebaseService.instance.cancelSupplementAlarm(supplementId);
      deleteSupplementStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Supplement deleted");
    } else {
      deleteSupplementStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Failed to delete supplement");
    }
  }
}
