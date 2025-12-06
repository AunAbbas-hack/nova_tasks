// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:nova_tasks/main.dart';

void main() {
  testWidgets('Splash transitions to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(NovaTasksApp(initialLocale: Locale("en"),));

    expect(find.text('TaskFlow'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Effortless Task Creation'), findsOneWidget);
  });
}
