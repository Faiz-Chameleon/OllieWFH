import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie/Models/supplement_model.dart';
import 'package:ollie/Models/user_model.dart';
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
}
