import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomTextField supports password visibility toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            hintText: 'Password',
            obscureText: true,
            showPasswordToggle: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}
