import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/main.dart';

void main() {
  testWidgets('EventCraft Mobile App smoke and widget structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EventCraftApp());

    // Verify that EventCraftApp widget initializes cleanly.
    expect(find.byType(EventCraftApp), findsOneWidget);
  });
}
