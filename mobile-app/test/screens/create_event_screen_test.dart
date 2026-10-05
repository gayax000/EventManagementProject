import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/screens/create_event_screen.dart';

void main() {
  testWidgets('CreateEventScreen renders step 1 fundamentals and default inputs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Plan New Event • Step 1 of 4'), findsOneWidget);
    expect(find.text('Event Title'), findsOneWidget);
    expect(find.text('Guest Count'), findsOneWidget);
    expect(find.text('Budget Limit (LKR)'), findsOneWidget);
    expect(find.text('Next: Venue ➔'), findsOneWidget);
  });

  testWidgets('Guest count stepper buttons increment and decrement value', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Default guest count is 250
    expect(find.text('250'), findsOneWidget);

    // Increment guest count
    final addBtn = find.byIcon(Icons.add_rounded);
    expect(addBtn, findsOneWidget);
    await tester.ensureVisible(addBtn);
    await tester.pumpAndSettle();
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Should now be 275
    expect(find.text('275'), findsOneWidget);

    // Decrement guest count
    final removeBtn = find.byIcon(Icons.remove_rounded);
    expect(removeBtn, findsOneWidget);
    await tester.ensureVisible(removeBtn);
    await tester.pumpAndSettle();
    await tester.tap(removeBtn);
    await tester.pumpAndSettle();

    // Should now be 250 again
    expect(find.text('250'), findsOneWidget);
  });

  testWidgets('Empty title triggers validation error when attempting next step', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Find the title text field and clear it
    final titleField = find.widgetWithText(TextFormField, 'Royal Wedding Celebration');
    expect(titleField, findsOneWidget);
    await tester.ensureVisible(titleField);
    await tester.pumpAndSettle();

    await tester.enterText(titleField, '');
    await tester.pumpAndSettle();

    // Tap Next: Venue button
    final nextBtn = find.text('Next: Venue ➔');
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // Form validator should display validation error
    expect(find.text('Please enter a title'), findsOneWidget);
  });

  testWidgets('Toggling outdoor setting enables weather warning and risk advisory', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initially Indoor is selected; tap Outdoor
    final outdoorBtn = find.text('Outdoor');
    expect(outdoorBtn, findsOneWidget);
    await tester.ensureVisible(outdoorBtn);
    await tester.pumpAndSettle();

    await tester.tap(outdoorBtn);
    await tester.pumpAndSettle();

    // Weather risk advisory card should appear
    expect(find.textContaining('AI Weather Agent will compute monsoonal probability'), findsOneWidget);

    // Tap Indoor to revert
    final indoorBtn = find.text('Indoor');
    await tester.ensureVisible(indoorBtn);
    await tester.pumpAndSettle();
    await tester.tap(indoorBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('AI Weather Agent will compute monsoonal probability'), findsNothing);
  });
}
