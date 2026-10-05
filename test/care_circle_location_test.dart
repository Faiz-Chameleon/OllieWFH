import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/care_circle_controller.dart';
import 'package:ollie/CareCircle/care_circle_repository.dart';
import 'package:ollie/CareCircle/location/care_explore_screen.dart';
import 'package:ollie/CareCircle/location/care_location_controller.dart';
import 'package:ollie/Models/user_model.dart';

const _lahore = (latitude: 31.5204, longitude: 74.3587, error: null);

Future<({String? label, String? city, String? country})> _names(
  double lat,
  double lng,
) async => lat > 33
    ? (label: 'Islamabad', city: 'Islamabad', country: 'Pakistan')
    : (label: 'Gulberg, Lahore', city: 'Lahore', country: 'Pakistan');

CareLocationController _location({
  ({double? latitude, double? longitude, String? error}) gps = _lahore,
}) => CareLocationController(
  positionLookup: () async => gps,
  placeLookup: _names,
);

/// Records requests and answers from canned pages.
class _FakeRepository extends CareCircleRepository {
  final calls = <String>[];
  List<Map<String, dynamic>> Function(int page) assistancePage = (_) => [];
  List<Map<String, dynamic>> Function(int page) groupsPage = (_) => [];
  List<Map<String, dynamic>> Function(int page) eventsPage = (_) => [];
  bool goingFails = false;

  @override
  Future<Map<String, dynamic>> getOthersCreatedAssistance({
    required Map<String, String> location,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add(
      'assistance $page ${location['latitude']} ${location['radiusKm']} ${location['city']}',
    );
    return {'success': true, 'data': assistancePage(page)};
  }

  @override
  Future<Map<String, dynamic>> getOthersGroups({
    required Map<String, String> location,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('groups $page ${location['latitude']}');
    return {'success': true, 'data': groupsPage(page)};
  }

  @override
  Future<Map<String, dynamic>> getNearesEvent({
    Map<String, String>? location,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('events $page ${location?['latitude']}');
    return {'success': true, 'data': eventsPage(page)};
  }

  @override
  Future<Map<String, dynamic>> getLatesEvent({
    Map<String, String>? location,
  }) async {
    calls.add('latest ${location?['latitude']}');
    final events = eventsPage(1);
    return {'success': true, 'data': events.isEmpty ? {} : events.first};
  }

  @override
  Future<Map<String, dynamic>> onEventMarkAsGoing(eventId) async {
    calls.add('going $eventId');
    return {'success': !goingFails, 'message': goingFails ? 'boom' : 'ok'};
  }

  @override
  Future<Map<String, dynamic>> unmarkGoingOnEvent(String eventId) async {
    calls.add('notGoing $eventId');
    return {'success': true, 'message': 'ok'};
  }
}

Map<String, dynamic> _request(
  String id, {
  String userId = 'other',
  double km = 1,
}) => {
  'id': id,
  'userId': userId,
  'description': 'Need help $id',
  'scheduledAt': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
  'latitude': 31.52,
  'longitude': 74.35,
  'distanceKm': km,
  'status': 'NoRequest',
  'categories': [],
};

Map<String, dynamic> _event(String id, {bool going = false, int count = 3}) => {
  'id': id,
  'eventName': 'Event $id',
  'eventDateAndTime': DateTime.now()
      .add(const Duration(days: 1))
      .toIso8601String(),
  'eventAddress': 'Park',
  'eventCity': 'Lahore',
  'eventCountry': 'Pakistan',
  'eventLatitude': 31.52,
  'eventLongitude': 74.35,
  'distanceKm': 2.5,
  'eventParticipant': count,
  'isMark': going,
  'imageGallery': [],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('CareLocationController', () {
    test('defaults to GPS with place names and a 10 km radius', () async {
      final location = _location();
      final place = await location.ensureLocation();

      expect(place!.isCurrent, isTrue);
      expect(location.radiusKm.value, 10);
      expect(location.summary, 'Near you · Gulberg, Lahore · 10 km');
      expect(location.queryParameters, {
        'latitude': '31.520400',
        'longitude': '74.358700',
        'radiusKm': '10',
        'city': 'Lahore',
        'country': 'Pakistan',
      });
    });

    test('no GPS: unavailable with a reason, and no query', () async {
      final location = _location(
        gps: (latitude: null, longitude: null, error: 'Allow location access'),
      );
      expect(await location.ensureLocation(), isNull);
      expect(location.status.value, CareLocationStatus.unavailable);
      expect(location.errorMessage.value, 'Allow location access');
      expect(location.queryParameters, isNull);
    });

    test(
      'a chosen place and radius are remembered; my location forgets the place',
      () async {
        final first = _location();
        await first.ensureLocation();
        await first.choosePlace(latitude: 33.6844, longitude: 73.0479);
        await first.setRadius(25);
        expect(first.summary, 'Islamabad · 25 km');
        expect(first.isBrowsingElsewhere, isTrue);

        final reopened = _location();
        final place = await reopened.ensureLocation();
        expect(place!.city, 'Islamabad');
        expect(place.isCurrent, isFalse);
        expect(reopened.radiusKm.value, 25);

        await reopened.useMyLocation();
        expect(reopened.location.value!.isCurrent, isTrue);
        final third = _location();
        expect((await third.ensureLocation())!.city, 'Lahore');
      },
    );

    test('every change bumps version', () async {
      final location = _location();
      await location.ensureLocation();
      final v = location.version.value;
      await location.setRadius(5);
      await location.setRadius(5); // unchanged: no bump
      await location.choosePlace(latitude: 33.7, longitude: 73.0, label: 'F-7');
      expect(location.version.value, v + 2);
      expect(location.location.value!.label, 'F-7');
    });
  });

  group('CareCircleController nearby lists', () {
    late _FakeRepository repository;
    late CareCircleController controller;

    setUp(() {
      Get.put(UserController()).setUser(UserData(id: 'me'));
      Get.put<CareLocationController>(_location(), permanent: true);
      repository = _FakeRepository();
      controller = Get.put(CareCircleController(repository: repository));
    });

    test(
      'assistance uses the shared location, hides own requests, pages',
      () async {
        repository.assistancePage = (page) => page == 1
            ? [
                for (var i = 0; i < 19; i++) _request('a$i'),
                _request('mine', userId: 'me'),
              ]
            : [_request('b1')];

        await controller.userFetchOthersCreatedAssitance();
        expect(repository.calls.last, 'assistance 1 31.520400 10 Lahore');
        expect(controller.othersCreatedAssistance.length, 19);
        expect(
          controller.othersCreatedAssistance.any((r) => r.id == 'mine'),
          isFalse,
        );
        expect(controller.assistanceHasMore.value, isTrue);
        expect(controller.postLoadingStatus.length, 19);

        await controller.userFetchOthersCreatedAssitance(loadMore: true);
        expect(repository.calls.last, startsWith('assistance 2'));
        expect(controller.othersCreatedAssistance.length, 20);
        expect(controller.postLoadingStatus.length, 20);
        expect(controller.assistanceHasMore.value, isFalse);

        final before = repository.calls.length;
        await controller.userFetchOthersCreatedAssitance(loadMore: true);
        expect(repository.calls.length, before); // nothing more to load
      },
    );

    test(
      'no location: assistance and groups show the reason instead of loading',
      () async {
        Get.delete<CareLocationController>(force: true);
        Get.put<CareLocationController>(
          _location(
            gps: (latitude: null, longitude: null, error: 'Turn on location'),
          ),
          permanent: true,
        );
        final c = CareCircleController(repository: repository);
        await c.userFetchOthersCreatedAssitance();
        await c.fetchOthersGroups();
        expect(c.assistanceLocationErrorMessage.value, 'Turn on location');
        expect(c.groupLocationErrorMessage.value, 'Turn on location');
        expect(repository.calls, isEmpty);
      },
    );

    test('groups page and append', () async {
      repository.groupsPage = (page) => [
        for (var i = 0; i < (page == 1 ? 20 : 3); i++)
          {
            'id': 'g$page-$i',
            'name': 'Group $i',
            'distanceKm': i.toDouble(),
            'memberCount': 4,
          },
      ];
      await controller.fetchOthersGroups();
      expect(controller.othersGroups.length, 20);
      expect(controller.groupsHasMore.value, isTrue);
      await controller.fetchOthersGroups(loadMore: true);
      expect(controller.othersGroups.length, 23);
      expect(controller.groupsHasMore.value, isFalse);
    });

    test(
      'events: latest and list follow the location; going toggles with counts',
      () async {
        repository.eventsPage = (_) => [
          _event('e1'),
          _event('e2', going: true, count: 5),
        ];
        await controller.userFetchLatestEvents();
        await controller.userFetchNearestEvents();
        expect(repository.calls, ['latest 31.520400', 'events 1 31.520400']);
        expect(controller.latestEvent.value.id, 'e1');
        expect(controller.nearestEvents.first.distanceKm, 2.5);

        await controller.markAsGoingOnEvents('e1');
        expect(controller.latestEvent.value.isMark, isTrue);
        expect(controller.latestEvent.value.eventParticipant, 4);
        expect(controller.nearestEvents.first.isMark, isTrue);

        await controller.unmarkGoingOnEvent('e2');
        expect(controller.nearestEvents[1].isMark, isFalse);
        expect(controller.nearestEvents[1].eventParticipant, 4);
      },
    );

    test('a new place reloads the open tab', () async {
      repository.groupsPage = (_) => [];
      controller.selectedTabIndex.value = 1;
      await controller.careLocation.ensureLocation();
      repository.calls.clear();

      await controller.careLocation.choosePlace(
        latitude: 33.6844,
        longitude: 73.0479,
      );
      await Future<void>.delayed(Duration.zero);
      expect(repository.calls, ['groups 1 33.684400']);
    });

    test(
      'first location resolve does not double-load; choosing a place after a failure does reload',
      () async {
        Get.delete<CareLocationController>(force: true);
        var gps = (
          latitude: null as double?,
          longitude: null as double?,
          error: 'No GPS' as String?,
        );
        final location = CareLocationController(
          positionLookup: () async => gps,
          placeLookup: _names,
        );
        Get.put<CareLocationController>(location, permanent: true);
        final c = CareCircleController(repository: repository);
        c.onInit();
        c.selectedTabIndex.value = 1;

        await c.fetchOthersGroups();
        expect(repository.calls, isEmpty); // no location yet

        await location.choosePlace(latitude: 33.6844, longitude: 73.0479);
        await Future<void>.delayed(Duration.zero);
        expect(repository.calls, ['groups 1 33.684400']);
      },
    );

    test('eventLocationLabel', () {
      expect(
        controller.eventLocationLabel(
          address: 'Park',
          city: 'Lahore',
          country: ' ',
          distanceKm: 2.46,
        ),
        'Park, Lahore · 2.5 km away',
      );
      expect(
        controller.eventLocationLabel(distanceKm: null, city: 'Lahore'),
        'Lahore',
      );
    });
  });

  group('CarePin.fromExplore', () {
    test(
      'parses pins of all three types and skips ones without coordinates',
      () {
        final pins = CarePin.fromExplore({
          'assistance': [
            {
              'id': 'r1',
              'title': 'Groceries',
              'scheduledAt': '2026-10-07T10:00:00Z',
              'latitude': 31.5,
              'longitude': 74.3,
              'distanceKm': 1.2,
            },
            {
              'id': 'r2',
              'title': 'No pin',
              'latitude': null,
              'longitude': 74.3,
            },
          ],
          'groups': [
            {
              'id': 'g1',
              'name': 'Walkers',
              'memberCount': 12,
              'latitude': 31.51,
              'longitude': 74.31,
              'distanceKm': 2,
            },
          ],
          'events': [
            {
              'id': 'e1',
              'eventName': 'Fair',
              'eventDateAndTime': '2026-10-08T09:00:00Z',
              'latitude': 31.49,
              'longitude': 74.29,
            },
          ],
        });

        expect(pins.map((p) => '${p.type.name}:${p.id}'), [
          'assistance:r1',
          'group:g1',
          'event:e1',
        ]);
        expect(pins[1].subtitle, '12 members');
        expect(pins[0].distanceKm, 1.2);
        expect(pins[2].subtitle, isNotEmpty);
      },
    );
  });
}
