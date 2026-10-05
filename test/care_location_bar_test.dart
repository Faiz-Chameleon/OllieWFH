import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/CareCircle/location/care_location_bar.dart';
import 'package:ollie/CareCircle/location/care_location_controller.dart';

const _lahore = (latitude: 31.5204, longitude: 74.3587, error: null);

Future<({String? label, String? city, String? country})> _names(
  double lat,
  double lng,
) async => (label: 'Gulberg, Lahore', city: 'Lahore', country: 'Pakistan');

CareLocationController _location({
  ({double? latitude, double? longitude, String? error}) gps = _lahore,
}) => CareLocationController(
  positionLookup: () async => gps,
  placeLookup: _names,
);

void main() {
  setUp(() {
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(Get.reset);

  group('CareLocationBar', () {
    Future<void> pump(
      WidgetTester tester,
      CareLocationController location,
    ) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => GetMaterialApp(
            home: Scaffold(body: CareLocationBar(location: location)),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows the place and radius', (tester) async {
      final location = _location();
      await location.ensureLocation();
      await pump(tester, location);
      expect(find.text('Near you · Gulberg, Lahore · 10 km'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('without a location, explains why and offers to choose one', (
      tester,
    ) async {
      final location = _location(
        gps: (
          latitude: null,
          longitude: null,
          error: 'Allow location access, or choose a place to browse.',
        ),
      );
      await location.ensureLocation();
      await pump(tester, location);
      expect(
        find.text('Allow location access, or choose a place to browse.'),
        findsOneWidget,
      );
      expect(find.text('Choose a place'), findsOneWidget);
    });
  });
}
