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

  testWidgets('AI Event Concierge prompt auto-fills Nuwara Eliya, outdoor, 2.9M budget, 240 guests and excludes car when negated', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final promptField = find.byType(TextFormField).first;
    await tester.enterText(promptField, 'i need to take a wedding at outdoor evet in nuwaraeliya with 2.9M buget for 240 guests in 17th of october, mt wedding car ekk epa');
    await tester.pumpAndSettle();

    final autoFillBtn = find.text('Auto-Fill Event Details with AI');
    await tester.ensureVisible(autoFillBtn);
    await tester.tap(autoFillBtn);
    await tester.pumpAndSettle();

    // Verify budget is Rs. 2,900,000
    expect(find.text('2900000'), findsOneWidget);
    // Verify guests is 240
    expect(find.text('240'), findsOneWidget);
    // Verify outdoor setting was activated by AI vision
    expect(find.textContaining('AI Weather Agent will compute monsoonal probability'), findsOneWidget);
  });

  testWidgets('AI Event Concierge selects Sri Lankan Heritage catering and respects no band/alcohol', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateEventScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final promptField = find.byType(TextFormField).first;
    await tester.enterText(promptField, '25th of november, no live band and no alcohol please, i need sri lankan heritge lunch');
    await tester.pumpAndSettle();

    final autoFillBtn = find.text('Auto-Fill Event Details with AI');
    await tester.ensureVisible(autoFillBtn);
    await tester.tap(autoFillBtn);
    await tester.pumpAndSettle();

    // Verify date is updated to November 25, 2026
    expect(find.textContaining('November 25, 2026'), findsOneWidget);
  });
}
