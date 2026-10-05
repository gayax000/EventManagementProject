import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/main.dart';
import 'package:eventcraft_mobile/screens/packages_screen.dart';
import 'package:eventcraft_mobile/screens/payments_screen.dart';

void main() {
  testWidgets('EventCraft Mobile App smoke and widget structure test', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCraftApp());
    // Pump past splash timer so no timers remain pending
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(EventCraftApp), findsOneWidget);
  });

  testWidgets('PackagesScreen renders catering menus and weather radar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PackagesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and Weather Risk Agent radar card
    expect(find.text('Catering & Weather Advisory'), findsOneWidget);
    expect(find.text('Weather Risk Agent'), findsOneWidget);
    expect(find.text('Curated Catering Menus'), findsOneWidget);
    expect(find.text('International Hotel Buffet'), findsOneWidget);
  });

  testWidgets('PaymentsScreen renders billing metrics and transaction view', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PaymentsScreen(),
      ),
    );
    await tester.pump();

    // Verify header and Billing KPI metrics
    expect(find.text('Payments & Invoices'), findsOneWidget);
    expect(find.text('Billing Transactions'), findsOneWidget);
  });
}
