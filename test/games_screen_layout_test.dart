import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ollie/CareCircle/assistance/games_selection_screen.dart';

void main() {
  // Phone sizes: small Android, iPhone SE, iPhone 15, large Android.
  const sizes = [
    Size(320, 568),
    Size(375, 667),
    Size(393, 852),
    Size(412, 915),
  ];
  const titles = ['Tic Tac Toe', 'Pac-Man', 'Tetris', '2048'];

  for (final size in sizes) {
    testWidgets(
      'Games screen fits above the bottom bar and does not move when swiped '
      '(${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        Get.testMode = true;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        // Like HomeMain: the tab is drawn under a floating bottom bar that
        // covers the bottom 14% of the screen (8% bar + 6% padding).
        final barTop = size.height * (1 - 0.14);
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => GetMaterialApp(
              home: Scaffold(
                extendBody: true,
                body: const GameSelectionScreen(),
                bottomNavigationBar: SizedBox(height: size.height * 0.14),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Every tile, label included, is fully visible above the bar.
        for (final title in titles) {
          expect(
            tester.getRect(find.text(title)).bottom,
            lessThanOrEqualTo(barTop),
          );
        }

        // A swipe moves nothing, during or after it (Android stretch overscroll
        // and iOS bounce included).
        Offset where(String title) => tester.getTopLeft(find.text(title));
        final before = {for (final title in titles) title: where(title)};
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Tetris')),
        );
        await gesture.moveBy(const Offset(0, -150));
        await gesture.moveBy(const Offset(0, -150));
        await tester.pump();
        for (final title in titles) {
          expect(
            where(title),
            before[title],
            reason: '$title moved during the swipe',
          );
        }
        await gesture.up();
        await tester.pumpAndSettle();
        for (final title in titles) {
          expect(
            where(title),
            before[title],
            reason: '$title moved after the swipe',
          );
        }
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  }
}
