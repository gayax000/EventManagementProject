import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen initial render displays branding and navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

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

    final logInBtn = find.text('Log In').first;
    await tester.tap(logInBtn);
    await tester.pumpAndSettle();

    expect(find.text('Client Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
    expect(find.text('Sign In as Client'), findsOneWidget);
  });

  testWidgets('Submitting empty credentials displays validation warning', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    final logInBtn = find.text('Log In').first;
    await tester.tap(logInBtn);
    await tester.pumpAndSettle();

    // Tap submit button with empty fields
    final submitBtn = find.text('Sign In as Client');
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Top banner or error text displays
    expect(find.text('Please enter your email'), findsAtLeastNWidgets(1));
  });

  testWidgets('Toggle between Sign In and Sign Up switches modal mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Open sheet
    final logInBtn = find.text('Log In').first;
    await tester.tap(logInBtn);
    await tester.pumpAndSettle();

    expect(find.text('Client Sign In'), findsOneWidget);

    // Switch to register mode via bottom link
    final switchToRegister = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains('Sign Up as Client'),
    );
    expect(switchToRegister, findsOneWidget);
    await tester.tap(switchToRegister);
    await tester.pumpAndSettle();

    // Should now display Client Registration
    expect(find.text('Client Registration'), findsOneWidget);
    expect(find.text('Create Client Account'), findsOneWidget);

    // Switch back to login
    final switchToLogin = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains('Sign In'),
    );
    expect(switchToLogin, findsOneWidget);
    await tester.tap(switchToLogin);
    await tester.pumpAndSettle();

    expect(find.text('Client Sign In'), findsOneWidget);
  });
}
