import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/your_post_screen.dart';

void main() {
  // Phone sizes: small Android, iPhone SE, iPhone 15, large Android.
  const sizes = [
    Size(320, 568),
    Size(375, 667),
    Size(393, 852),
    Size(412, 915),
  ];

  for (final size in sizes) {
    testWidgets(
      'Tic Tac Toe board fits and stays put when swiped (${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        Get.testMode = true;
        Get.put(UserController());
        addTearDown(Get.reset);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => const GetMaterialApp(home: YourPostsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // All nine cells fit inside the board, and the board on screen.
        final board = find.byType(GridView);
        final boardRect = tester.getRect(board);
        final cells = find.descendant(
          of: board,
          matching: find.byType(GestureDetector),
        );
        expect(cells, findsNWidgets(9));
        expect(boardRect.bottom, lessThanOrEqualTo(size.height));
        expect(
          tester.getRect(cells.last).bottom,
          lessThanOrEqualTo(boardRect.bottom + 0.5),
        );
        expect(find.text('New Round'), findsOneWidget);

        // Swiping the board doesn't move it, during or after the swipe
        // (Android stretch overscroll and iOS bounce included).
        final before = tester.getTopLeft(cells.first);
        final gesture = await tester.startGesture(tester.getCenter(board));
        await gesture.moveBy(const Offset(0, -150));
        await gesture.moveBy(const Offset(0, -150));
        await tester.pump();
        expect(tester.getTopLeft(cells.first), before);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(cells.first), before);

        // Let a pending bot move (randomly the bot starts) finish.
        await tester.pump(const Duration(seconds: 1));
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  }
}
