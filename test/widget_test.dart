import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chaosclinic/main.dart';

void main() {
  testWidgets('ChaosClinicApp loads splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChaosClinicApp());

    // Verify that splash screen is displayed
    expect(find.text('Chaos Clinic'), findsOneWidget);
    expect(find.text('Your companion for emotional wellbeing'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    // Verify app icon is displayed
    expect(find.byIcon(Icons.psychology), findsOneWidget);

    // Verify loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('SplashScreen displays correct elements', (
    WidgetTester tester,
  ) async {
    // Build just the splash screen
    await tester.pumpWidget(const MaterialApp(home: ChaosClinicApp()));

    // Verify all UI elements are present
    expect(find.text('Chaos Clinic'), findsOneWidget);
    expect(find.text('Your companion for emotional wellbeing'), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byIcon(Icons.psychology), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
