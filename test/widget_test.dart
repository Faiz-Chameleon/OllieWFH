import 'package:flutter_test/flutter_test.dart';

import 'package:ollie/Splash.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App renders the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Splash_Screen(enableNavigation: false)),
    );

    expect(find.byType(Splash_Screen), findsOneWidget);
  });
}
