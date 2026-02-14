import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifepanel/app.dart';

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LifePanelApp()),
    );
    await tester.pumpAndSettle();

    // Dashboard should show LIFEPANEL title on center screen
    expect(find.text('LIFEPANEL'), findsOneWidget);
  });
}
