import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/screens/login_screen.dart';
import 'package:eventcraft_mobile/services/auth_service.dart';

void main() {
  testWidgets('LoginScreen initial render displays branding and Log In button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify top branding and navigation buttons
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Log In'), findsAtLeastNWidgets(1));
    expect(find.text('Sign Up'), findsAtLeastNWidgets(1));
  });

  testWidgets('Tapping Log In opens authentication sheet with inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Log In to open modal bottom sheet
    final logInBtn = find.text('Log In').first;
    await tester.tap(logInBtn);
    await tester.pumpAndSettle();

    // Verify modal bottom sheet opens with Client Sign In and text inputs
    expect(find.text('Client Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
    expect(find.text('Sign In as Client'), findsOneWidget);
  });

  test('AuthResult model correctly stores success and error message', () {
    final successResult = AuthResult(success: true);
    expect(successResult.success, isTrue);
    expect(successResult.message, isNull);

    final failedResult = AuthResult(success: false, message: 'Invalid credentials');
    expect(failedResult.success, isFalse);
    expect(failedResult.message, equals('Invalid credentials'));
  });
}
