class SupplementModel {
  final bool? success;
  final String? message;
  final List<SupplementData> data;

  SupplementModel({this.success, this.message, required this.data});

  factory SupplementModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawList = rawData is List
        ? rawData
        : rawData is Map && rawData['supplements'] is List
        ? rawData['supplements'] as List
        : const [];

    return SupplementModel(
      success: json['success'],
      message: json['message']?.toString(),
      data: rawList
          .whereType<Map>()
          .map(
            (item) => SupplementData.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
    );
  }
}

enum SupplementFrequency {
  daily('DAILY'),
  weekly('WEEKLY'),
  interval('INTERVAL');

  const SupplementFrequency(this.apiValue);

  final String apiValue;

  static SupplementFrequency fromApi(Object? value) {
    final raw = value?.toString().toUpperCase();
    return SupplementFrequency.values.firstWhere(
      (item) => item.apiValue == raw,
      orElse: () => SupplementFrequency.daily,
    );
  }
}

/// Weekday labels indexed the way the API stores them: 0 = Sunday ... 6 = Saturday.
const List<String> supplementWeekdayLabels = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

/// Dose key used for "taken" tracking on supplements that have no reminder times.
const String supplementAnyTimeDose = 'any';

class SupplementData {
  final String? id;
  final String? name;
  final String? dosage;
  final bool reminderEnabled;
  final String? reminderTime;
  final SupplementFrequency frequency;

  /// "HH:mm" or "HH:mm:ss", sorted.
  final List<String> reminderTimes;

  /// WEEKLY only. 0 = Sunday ... 6 = Saturday.
  final List<int> daysOfWeek;

  /// INTERVAL only. Every N days counted from [startDate].
  final int? intervalDays;

  /// YYYY-MM-DD.
  final String? startDate;

  /// YYYY-MM-DD, inclusive. Null means the schedule never ends.
  final String? endDate;
  final String? timeZone;
  final DateTime? nextReminderAt;

  SupplementData({
    this.id,
    this.name,
    this.dosage,
    this.reminderEnabled = false,
    this.reminderTime,
    this.frequency = SupplementFrequency.daily,
    List<String>? reminderTimes,
    this.daysOfWeek = const [],
    this.intervalDays,
    this.startDate,
    this.endDate,
    this.timeZone,
    this.nextReminderAt,
  }) : reminderTimes =
           reminderTimes ??
           (reminderTime != null && reminderTime.trim().isNotEmpty
               ? [reminderTime.trim()]
               : const []);

  factory SupplementData.fromJson(Map<String, dynamic> json) {
    final reminderTime = json['reminderTime']?.toString();
    final rawTimes = json['reminderTimes'];
    final times = rawTimes is List
        ? rawTimes
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty)
              .toList()
        : null;
    final rawDays = json['daysOfWeek'];

    return SupplementData(
      id:
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['supplementId']?.toString(),
      name: json['name']?.toString(),
      dosage: json['dosage']?.toString(),
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: reminderTime,
      frequency: SupplementFrequency.fromApi(json['frequency']),
      // Older API responses only carry reminderTime.
      reminderTimes: times != null && times.isNotEmpty ? (times..sort()) : null,
      daysOfWeek: rawDays is List
          ? (rawDays
                .map((item) => int.tryParse(item.toString()))
                .whereType<int>()
                .where((day) => day >= 0 && day <= 6)
                .toSet()
                .toList()
              ..sort())
          : const [],
      intervalDays: int.tryParse(json['intervalDays']?.toString() ?? ''),
      startDate: _cleanString(json['startDate']),
      endDate: _cleanString(json['endDate']),
      timeZone: _cleanString(json['timeZone']),
      nextReminderAt: DateTime.tryParse(
        json['nextReminderAt']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'frequency': frequency.apiValue,
      'reminderTimes': reminderTimes,
      'daysOfWeek': daysOfWeek,
      'intervalDays': intervalDays,
      'startDate': startDate,
      'endDate': endDate,
      'timeZone': timeZone,
      'nextReminderAt': nextReminderAt?.toUtc().toIso8601String(),
    };
  }

  static String? _cleanString(Object? value) {
    final raw = value?.toString().trim();
    return raw == null || raw.isEmpty ? null : raw;
  }

  /// Parses "HH:mm" or "HH:mm:ss".
  static ({int hour, int minute})? parseTime(String? value) {
    final parts = value?.trim().split(':') ?? const [];
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
    return (hour: hour, minute: minute);
  }

  /// Parses YYYY-MM-DD as a local calendar date.
  static DateTime? parseDate(String? value) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$',
    ).firstMatch(value?.trim() ?? '');
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Whole calendar days from [from] to [to], unaffected by DST.
  static int daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(
      to.year,
      to.month,
      to.day,
    ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
  }

  DateTime? get start => parseDate(startDate);
  DateTime? get end => parseDate(endDate);

  /// Whether any dose falls on the calendar day of [date].
  bool isScheduledOn(DateTime date) {
    final startDay = start;
    final endDay = end;
    if (startDay != null && daysBetween(startDay, date) < 0) return false;
    if (endDay != null && daysBetween(date, endDay) < 0) return false;

    switch (frequency) {
      case SupplementFrequency.daily:
        return true;
      case SupplementFrequency.weekly:
        return daysOfWeek.contains(date.weekday % 7);
      case SupplementFrequency.interval:
        final every = intervalDays;
        if (startDay == null || every == null || every < 1) return false;
        return daysBetween(startDay, date) % every == 0;
    }
  }

  /// Dose keys for the day of [date]: its reminder times, or a single
  /// [supplementAnyTimeDose] when the supplement has no times set.
  List<String> doseKeysOn(DateTime date) {
    if (!isScheduledOn(date)) return const [];
    return reminderTimes.isEmpty
        ? const [supplementAnyTimeDose]
        : reminderTimes;
  }

  /// The first [limit] doses strictly after [after], within [horizonDays] days.
  List<({DateTime at, String time})> upcomingDoses(
    DateTime after, {
    int limit = 10,
    int horizonDays = 400,
    bool Function(DateTime day, String time)? skip,
  }) {
    final doses = <({DateTime at, String time})>[];
    final today = DateTime(after.year, after.month, after.day);
    for (var i = 0; i <= horizonDays && doses.length < limit; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      final endDay = end;
      if (endDay != null && daysBetween(day, endDay) < 0) break;
      if (!isScheduledOn(day)) continue;

      for (final time in reminderTimes) {
        final parsed = parseTime(time);
        if (parsed == null) continue;
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          parsed.hour,
          parsed.minute,
        );
        if (!at.isAfter(after)) continue;
        if (skip != null && skip(day, time)) continue;
        doses.add((at: at, time: time));
        if (doses.length >= limit) break;
      }
    }
    return doses;
  }

  /// Short human description, e.g. "Every day", "Mon, Wed, Fri", "Every 3 days".
  String get scheduleSummary {
    final base = switch (frequency) {
      SupplementFrequency.daily => 'Every day',
      SupplementFrequency.weekly =>
        daysOfWeek.length == 7
            ? 'Every day'
            : daysOfWeek.map((day) => supplementWeekdayLabels[day]).join(', '),
      SupplementFrequency.interval =>
        intervalDays == 1 ? 'Every day' : 'Every ${intervalDays ?? '?'} days',
    };
    final endDay = end;
    if (endDay == null) return base;
    return '$base until ${endDay.day}/${endDay.month}/${endDay.year}';
  }
}
