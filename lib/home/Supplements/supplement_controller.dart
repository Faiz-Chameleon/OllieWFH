import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/common/common.dart';
import 'package:ollie/home/Supplements/supplement_repository.dart';
import 'package:ollie/request_status.dart';
import 'package:ollie/services/firebase_service.dart';

class SupplementController extends GetxController {
  final SupplementRepository _repository = SupplementRepository();

  final supplements = <SupplementData>[].obs;
  final takenTodayIds = <String>{}.obs;
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
    final takenIds = <String>{};
    for (final supplement in items) {
      final id = supplement.id?.trim();
      if (id == null || id.isEmpty) continue;
      if (await FirebaseService.instance.isSupplementTakenToday(id)) {
        takenIds.add(id);
      }
    }
    takenTodayIds.assignAll(takenIds);
  }

  Future<void> refreshTakenTodayState() async {
    await _loadTakenTodayState(supplements);
  }

  bool isTakenToday(String? supplementId) {
    final id = supplementId?.trim();
    return id != null && id.isNotEmpty && takenTodayIds.contains(id);
  }

  Future<void> markSupplementTaken(SupplementData supplement) async {
    final supplementId = supplement.id?.trim() ?? '';
    if (supplementId.isEmpty) {
      appSnackbar("Error", "Supplement id is missing.");
      return;
    }

    await FirebaseService.instance.markSupplementTakenToday(supplementId);
    takenTodayIds.add(supplementId);
    takenTodayIds.refresh();
    await FirebaseService.instance.syncSupplementAlarms(supplements);
    appSnackbar("Done", "${supplement.name ?? "Supplement"} marked as taken");
  }

  Future<void> createSupplement({
    required String name,
    required String dosage,
    required bool reminderEnabled,
    TimeOfDay? reminderTime,
  }) async {
    await _saveSupplement(
      name: name,
      dosage: dosage,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  Future<void> updateSupplement({
    required String supplementId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    TimeOfDay? reminderTime,
  }) async {
    if (supplementId.isEmpty) {
      appSnackbar("Error", "Supplement id is missing.");
      return;
    }

    await _saveSupplement(
      supplementId: supplementId,
      name: name,
      dosage: dosage,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  Future<void> _saveSupplement({
    String? supplementId,
    required String name,
    required String dosage,
    required bool reminderEnabled,
    TimeOfDay? reminderTime,
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
    if (reminderEnabled && reminderTime == null) {
      appSnackbar("Error", "Please choose reminder time.");
      return;
    }

    final payload = <String, dynamic>{
      'name': cleanName,
      'dosage': cleanDosage,
      'reminderEnabled': reminderEnabled,
      if (reminderEnabled) 'reminderTime': formatTimeForApi(reminderTime!),
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
      takenTodayIds.remove(supplementId);
      await FirebaseService.instance.cancelSupplementAlarm(supplementId);
      deleteSupplementStatus.value = RequestStatus.success;
      appSnackbar("Success", result['message'] ?? "Supplement deleted");
    } else {
      deleteSupplementStatus.value = RequestStatus.error;
      appSnackbar("Error", result['message'] ?? "Failed to delete supplement");
    }
  }
}
