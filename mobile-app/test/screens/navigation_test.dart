import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/screens/home_screen.dart';
import 'package:eventcraft_mobile/screens/packages_screen.dart';
import 'package:eventcraft_mobile/screens/payments_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_name': 'Test Executive',
      'user_role': 'Customer',
    });

    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          return 'mock-jwt-test-token';
        }
        return null;
      },
    );
  });

  testWidgets('BottomNavigationBar contains Home, Packages, and Payments destinations', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify all 3 navigation bar tabs are present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Packages'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
  });

  testWidgets('Tapping Packages tab navigates to PackagesScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Packages tab
    final packagesTab = find.text('Packages');
    await tester.tap(packagesTab);
    await tester.pumpAndSettle();

    // Verify PackagesScreen is pushed
    expect(find.byType(PackagesScreen), findsOneWidget);
    expect(find.text('Catering & Weather Advisory'), findsOneWidget);
  });

  testWidgets('Tapping Payments tab navigates to PaymentsScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Payments tab
    final paymentsTab = find.text('Payments');
    await tester.tap(paymentsTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify PaymentsScreen is pushed
    expect(find.byType(PaymentsScreen), findsOneWidget);
    expect(find.text('Payments & Invoices'), findsOneWidget);
  });
}
