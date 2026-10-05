import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/user_model.dart';
import 'package:ollie/home/Supplements/supplement_alarm_plan.dart';
import 'package:ollie/home/Supplements/supplement_controller.dart';

void main() {
  group('SupplementModel', () {
    test('parses supplements from a direct data list', () {
      final model = SupplementModel.fromJson({
        'success': true,
        'message': 'ok',
        'data': [
          {
            'id': 'supplement-1',
            'name': 'Vitamin D3',
            'dosage': '1 tablet',
            'reminderEnabled': true,
            'reminderTime': '09:00',
          },
        ],
      });

      expect(model.success, isTrue);
      expect(model.data, hasLength(1));
      expect(model.data.first.id, 'supplement-1');
      expect(model.data.first.name, 'Vitamin D3');
      expect(model.data.first.dosage, '1 tablet');
      expect(model.data.first.reminderEnabled, isTrue);
      expect(model.data.first.reminderTime, '09:00');
    });

    test('parses supplements from nested data.supplements list', () {
      final model = SupplementModel.fromJson({
        'success': true,
        'data': {
          'supplements': [
            {
              'id': 7,
              'name': 'Magnesium',
              'dosage': '200 mg',
              'reminderEnabled': false,
              'reminderTime': null,
            },
          ],
        },
      });

      expect(model.data, hasLength(1));
      expect(model.data.first.id, '7');
      expect(model.data.first.name, 'Magnesium');
      expect(model.data.first.reminderEnabled, isFalse);
      expect(model.data.first.reminderTime, isNull);
    });
  });

  group('UserData', () {
    test('parses userSupplements from getMe/login payload', () {
      final user = UserData.fromJson({
        'id': 'user-1',
        'userName': 'Hamza',
        'userSupplements': [
          {
            'id': 'supplement-2',
            'name': 'Omega 3',
            'dosage': '1 capsule',
            'reminderEnabled': true,
            'reminderTime': '21:05:00',
          },
        ],
      });

      expect(user.userSupplements, hasLength(1));
      expect(user.userSupplements!.first.name, 'Omega 3');
      expect(user.userSupplements!.first.reminderTime, '21:05:00');
    });
  });

  group('SupplementController reminder time helpers', () {
    final controller = SupplementController();

    test('formats TimeOfDay for API as HH:mm', () {
      expect(
        controller.formatTimeForApi(const TimeOfDay(hour: 9, minute: 5)),
        '09:05',
      );
      expect(
        controller.formatTimeForApi(const TimeOfDay(hour: 21, minute: 0)),
        '21:00',
      );
    });

    test('parses HH:mm and HH:mm:ss reminder times', () {
      expect(
        controller.parseReminderTime('09:05'),
        const TimeOfDay(hour: 9, minute: 5),
      );
      expect(
        controller.parseReminderTime('21:05:00'),
        const TimeOfDay(hour: 21, minute: 5),
      );
    });

    test('rejects invalid reminder times', () {
      expect(controller.parseReminderTime(null), isNull);
      expect(controller.parseReminderTime(''), isNull);
      expect(controller.parseReminderTime('25:00'), isNull);
      expect(controller.parseReminderTime('09:75'), isNull);
      expect(controller.parseReminderTime('soon'), isNull);
    });
  });

  group('SupplementData recurrence', () {
    test('parses recurrence fields', () {
      final supplement = SupplementData.fromJson({
        'id': 's1',
        'reminderEnabled': true,
        'reminderTime': '08:00:00',
        'frequency': 'WEEKLY',
        'reminderTimes': ['20:00:00', '08:00:00'],
        'daysOfWeek': [5, 1, 3],
        'startDate': '2026-10-01',
        'endDate': null,
        'timeZone': 'Asia/Karachi',
        'nextReminderAt': '2026-10-05T03:00:00.000Z',
      });

      expect(supplement.frequency, SupplementFrequency.weekly);
      expect(supplement.reminderTimes, ['08:00:00', '20:00:00']);
      expect(supplement.daysOfWeek, [1, 3, 5]);
      expect(supplement.start, DateTime(2026, 10, 1));
      expect(supplement.end, isNull);
      expect(supplement.timeZone, 'Asia/Karachi');
      expect(supplement.nextReminderAt?.toUtc(), DateTime.utc(2026, 10, 5, 3));
    });

    test('older responses fall back to a daily reminderTime', () {
      final supplement = SupplementData.fromJson({
        'id': 's1',
        'reminderEnabled': true,
        'reminderTime': '09:30:00',
      });

      expect(supplement.frequency, SupplementFrequency.daily);
      expect(supplement.reminderTimes, ['09:30:00']);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 5)), isTrue);
    });

    test('toJson round-trips', () {
      final original = SupplementData(
        id: 's1',
        name: 'Iron',
        reminderEnabled: true,
        frequency: SupplementFrequency.interval,
        reminderTimes: const ['07:00:00'],
        intervalDays: 3,
        startDate: '2026-10-01',
        endDate: '2026-12-31',
      );
      final copy = SupplementData.fromJson(original.toJson());

      expect(copy.frequency, SupplementFrequency.interval);
      expect(copy.intervalDays, 3);
      expect(copy.endDate, '2026-12-31');
      expect(copy.reminderTimes, ['07:00:00']);
    });

    test('weekly schedule only runs on chosen weekdays', () {
      final supplement = SupplementData(
        frequency: SupplementFrequency.weekly,
        daysOfWeek: const [1, 3], // Mon, Wed
        reminderTimes: const ['08:00:00'],
      );

      expect(supplement.isScheduledOn(DateTime(2026, 10, 5)), isTrue); // Mon
      expect(supplement.isScheduledOn(DateTime(2026, 10, 6)), isFalse); // Tue
      expect(supplement.isScheduledOn(DateTime(2026, 10, 7)), isTrue); // Wed
      expect(supplement.isScheduledOn(DateTime(2026, 10, 11)), isFalse); // Sun
      expect(supplement.doseKeysOn(DateTime(2026, 10, 6)), isEmpty);
    });

    test('interval schedule counts from startDate and respects endDate', () {
      final supplement = SupplementData(
        frequency: SupplementFrequency.interval,
        intervalDays: 3,
        reminderTimes: const ['08:00:00'],
        startDate: '2026-10-01',
        endDate: '2026-10-10',
      );

      expect(supplement.isScheduledOn(DateTime(2026, 9, 28)), isFalse);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 1)), isTrue);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 2)), isFalse);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 4)), isTrue);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 10)), isTrue);
      expect(supplement.isScheduledOn(DateTime(2026, 10, 13)), isFalse);
    });

    test('upcomingDoses lists doses in order and stops at endDate', () {
      final supplement = SupplementData(
        reminderTimes: const ['08:00:00', '20:00:00'],
        startDate: '2026-10-01',
        endDate: '2026-10-06',
      );
      final doses = supplement.upcomingDoses(DateTime(2026, 10, 5, 9));

      expect(doses.map((dose) => dose.at), [
        DateTime(2026, 10, 5, 20),
        DateTime(2026, 10, 6, 8),
        DateTime(2026, 10, 6, 20),
      ]);
    });

    test('doses with no reminder times count as one any-time dose', () {
      final supplement = SupplementData(name: 'Zinc');
      expect(supplement.doseKeysOn(DateTime(2026, 10, 5)), [
        supplementAnyTimeDose,
      ]);
    });

    test('scheduleSummary describes the schedule', () {
      expect(SupplementData().scheduleSummary, 'Every day');
      expect(
        SupplementData(
          frequency: SupplementFrequency.weekly,
          daysOfWeek: const [1, 3, 5],
        ).scheduleSummary,
        'Mon, Wed, Fri',
      );
      expect(
        SupplementData(
          frequency: SupplementFrequency.interval,
          intervalDays: 3,
          endDate: '2026-11-01',
        ).scheduleSummary,
        'Every 3 days until 1/11/2026',
      );
    });
  });

  group('planSupplementAlarms', () {
    final now = DateTime(2026, 10, 5, 9); // Monday 09:00

    test('daily schedule uses one repeating alarm per time', () {
      final alarms = planSupplementAlarms(
        SupplementData(
          reminderEnabled: true,
          reminderTimes: const ['08:00:00', '20:00:00'],
        ),
        now: now,
        takenToday: const {},
      );

      expect(alarms.map((alarm) => alarm.repeat).toSet(), {
        SupplementAlarmRepeat.daily,
      });
      expect(alarms.map((alarm) => alarm.at), [
        DateTime(2026, 10, 6, 8),
        DateTime(2026, 10, 5, 20),
      ]);
      expect(alarms.map((alarm) => alarm.slot), [0, 1]);
    });

    test('weekly schedule repeats per weekday', () {
      final alarms = planSupplementAlarms(
        SupplementData(
          reminderEnabled: true,
          frequency: SupplementFrequency.weekly,
          daysOfWeek: const [1, 3],
          reminderTimes: const ['08:00:00'],
        ),
        now: now,
        takenToday: const {},
      );

      expect(alarms, hasLength(2));
      expect(
        alarms.every((a) => a.repeat == SupplementAlarmRepeat.weekly),
        isTrue,
      );
      expect(alarms.map((alarm) => alarm.at), [
        DateTime(2026, 10, 12, 8), // next Monday; today's 08:00 has passed
        DateTime(2026, 10, 7, 8),
      ]);
    });

    test('a dose taken today switches to one-shots starting tomorrow', () {
      final alarms = planSupplementAlarms(
        SupplementData(
          reminderEnabled: true,
          reminderTimes: const ['08:00:00', '20:00:00'],
        ),
        now: now,
        takenToday: const {'20:00:00'},
      );

      final repeating = alarms.where(
        (a) => a.repeat != SupplementAlarmRepeat.none,
      );
      final oneShots = alarms.where(
        (a) => a.repeat == SupplementAlarmRepeat.none,
      );
      expect(repeating.map((a) => a.time), ['08:00:00']);
      expect(oneShots.map((a) => a.time).toSet(), {'20:00:00'});
      expect(oneShots.first.at, DateTime(2026, 10, 6, 20));
      expect(oneShots.every((a) => a.slot >= 48 && a.slot < 64), isTrue);
    });

    test('interval and end-dated schedules use capped one-shots', () {
      final alarms = planSupplementAlarms(
        SupplementData(
          reminderEnabled: true,
          frequency: SupplementFrequency.interval,
          intervalDays: 2,
          startDate: '2026-10-05',
          reminderTimes: const ['08:00:00', '20:00:00'],
        ),
        now: now,
        takenToday: const {},
      );

      expect(
        alarms.every((a) => a.repeat == SupplementAlarmRepeat.none),
        isTrue,
      );
      expect(alarms, hasLength(12));
      expect(alarms.first.at, DateTime(2026, 10, 5, 20));
      expect(alarms[1].at, DateTime(2026, 10, 7, 8));
    });

    test('a future start date is not repeated early', () {
      final alarms = planSupplementAlarms(
        SupplementData(
          reminderEnabled: true,
          reminderTimes: const ['08:00:00'],
          startDate: '2026-10-10',
        ),
        now: now,
        takenToday: const {},
      );

      expect(alarms.first.repeat, SupplementAlarmRepeat.none);
      expect(alarms.first.at, DateTime(2026, 10, 10, 8));
    });

    test('nothing is planned when reminders are off', () {
      expect(
        planSupplementAlarms(
          SupplementData(reminderTimes: const ['08:00:00']),
          now: now,
          takenToday: const {},
        ),
        isEmpty,
      );
    });

    test('notification ids stay inside the supplement block', () {
      final base = supplementAlarmBaseId('some-supplement-id');
      expect(base, greaterThanOrEqualTo(1000000));
      expect(base + supplementAlarmSlotCount, lessThan(0x7fffffff));
    });
  });

  group('SupplementScheduleInput', () {
    final controller = SupplementController();

    test('builds the API payload', () {
      final payload = SupplementScheduleInput(
        reminderEnabled: true,
        frequency: SupplementFrequency.weekly,
        times: const [
          TimeOfDay(hour: 20, minute: 0),
          TimeOfDay(hour: 8, minute: 0),
        ],
        daysOfWeek: {5, 1},
        startDate: DateTime(2026, 10, 5),
      ).toPayload(controller.formatTimeForApi);

      expect(payload, {
        'reminderEnabled': true,
        'frequency': 'WEEKLY',
        'reminderTimes': ['08:00', '20:00'],
        'daysOfWeek': [1, 5],
        'intervalDays': null,
        'startDate': '2026-10-05',
        'endDate': null,
      });
    });

    test('validateSchedule catches incomplete schedules', () {
      SupplementScheduleInput input({
        bool enabled = true,
        SupplementFrequency frequency = SupplementFrequency.daily,
        List<TimeOfDay> times = const [TimeOfDay(hour: 8, minute: 0)],
        Set<int> days = const {},
        DateTime? end,
      }) => SupplementScheduleInput(
        reminderEnabled: enabled,
        frequency: frequency,
        times: times,
        daysOfWeek: days,
        startDate: DateTime(2026, 10, 5),
        endDate: end,
      );

      expect(controller.validateSchedule(input()), isNull);
      expect(controller.validateSchedule(input(times: const [])), isNotNull);
      expect(
        controller.validateSchedule(input(enabled: false, times: const [])),
        isNull,
      );
      expect(
        controller.validateSchedule(
          input(frequency: SupplementFrequency.weekly),
        ),
        isNotNull,
      );
      expect(
        controller.validateSchedule(input(end: DateTime(2026, 10, 1))),
        isNotNull,
      );
    });
  });
}
