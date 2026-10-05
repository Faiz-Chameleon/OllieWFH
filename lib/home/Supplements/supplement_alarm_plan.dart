import 'package:ollie/Models/supplement_model.dart';

/// How a planned alarm repeats once it has fired.
enum SupplementAlarmRepeat { none, daily, weekly }

class SupplementAlarm {
  const SupplementAlarm({
    required this.slot,
    required this.at,
    required this.time,
    required this.repeat,
  });

  /// Position within the supplement's block of notification ids.
  final int slot;
  final DateTime at;

  /// The reminder time ("HH:mm:ss") this alarm is for.
  final String time;
  final SupplementAlarmRepeat repeat;
}

/// Each supplement owns [supplementAlarmSlotCount] consecutive notification ids:
/// 0-5 daily repeats (one per time), 6-47 weekly repeats (time x weekday),
/// 48-63 one-shots.
const int supplementAlarmSlotCount = 64;
const int _weeklySlotBase = 6;
const int _oneShotSlotBase = 48;
const int _maxOneShots = supplementAlarmSlotCount - _oneShotSlotBase;

/// One-shots cover schedules the OS can't repeat on its own (every N days, an end
/// date, a future start) and doses already taken today. They are topped up every
/// time alarms are re-synced, so a short window is enough.
const int _oneShotsPerSupplement = 12;

int supplementAlarmBaseId(String supplementId) {
  return 1000000 +
      (supplementId.hashCode.abs() % 15000) * supplementAlarmSlotCount;
}

/// Plans local alarms for [supplement] from [now].
///
/// Repeating alarms are used where possible because they keep firing even if
/// the app isn't opened. iOS repeating triggers ignore the start date, so a
/// repeat is only used when it may fire from today on: the schedule has started,
/// has no end, is daily or weekly, and that dose hasn't been taken today.
List<SupplementAlarm> planSupplementAlarms(
  SupplementData supplement, {
  required DateTime now,
  required Set<String> takenToday,
}) {
  if (!supplement.reminderEnabled || supplement.reminderTimes.isEmpty) {
    return const [];
  }

  final today = DateTime(now.year, now.month, now.day);
  final allTakenToday = takenToday.contains(supplementAnyTimeDose);
  bool takenOn(DateTime day, String time) =>
      SupplementData.daysBetween(today, day) == 0 &&
      (allTakenToday || takenToday.contains(time));

  final start = supplement.start;
  final canRepeat =
      supplement.end == null &&
      supplement.frequency != SupplementFrequency.interval &&
      (start == null || SupplementData.daysBetween(start, today) >= 0);

  final alarms = <SupplementAlarm>[];
  final oneShotTimes = <String>{};

  if (canRepeat) {
    final times = supplement.reminderTimes.take(_weeklySlotBase).toList();
    for (var i = 0; i < times.length; i++) {
      final time = times[i];
      if (takenOn(today, time)) {
        oneShotTimes.add(time);
        continue;
      }
      final parsed = SupplementData.parseTime(time);
      if (parsed == null) continue;

      if (supplement.frequency == SupplementFrequency.daily) {
        alarms.add(
          SupplementAlarm(
            slot: i,
            at: _nextAt(now, parsed, (_) => true),
            time: time,
            repeat: SupplementAlarmRepeat.daily,
          ),
        );
      } else {
        for (final weekday in supplement.daysOfWeek) {
          alarms.add(
            SupplementAlarm(
              slot: _weeklySlotBase + i * 7 + weekday,
              at: _nextAt(now, parsed, (day) => day.weekday % 7 == weekday),
              time: time,
              repeat: SupplementAlarmRepeat.weekly,
            ),
          );
        }
      }
    }
  }

  if (canRepeat && oneShotTimes.isEmpty) return alarms;

  final doses = supplement.upcomingDoses(
    now,
    limit: _oneShotsPerSupplement.clamp(0, _maxOneShots),
    skip: (day, time) =>
        takenOn(day, time) || (canRepeat && !oneShotTimes.contains(time)),
  );
  for (var i = 0; i < doses.length; i++) {
    alarms.add(
      SupplementAlarm(
        slot: _oneShotSlotBase + i,
        at: doses[i].at,
        time: doses[i].time,
        repeat: SupplementAlarmRepeat.none,
      ),
    );
  }

  return alarms;
}

DateTime _nextAt(
  DateTime now,
  ({int hour, int minute}) time,
  bool Function(DateTime day) matches,
) {
  for (var i = 0; i < 8; i++) {
    final at = DateTime(
      now.year,
      now.month,
      now.day + i,
      time.hour,
      time.minute,
    );
    if (at.isAfter(now) && matches(at)) return at;
  }
  // Unreachable for a valid weekday; fall back to a week out.
  return DateTime(now.year, now.month, now.day + 7, time.hour, time.minute);
}
