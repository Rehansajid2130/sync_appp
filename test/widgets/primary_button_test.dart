import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_app/widgets/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('PrimaryButton renders correctly and triggers onPressed', (WidgetTester tester) async {
      bool isPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {
                isPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify text is rendered
      expect(find.text('Click Me'), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify callback is triggered
      expect(isPressed, true);
    });
  });
}
