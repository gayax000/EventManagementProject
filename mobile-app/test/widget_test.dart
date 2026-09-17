import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCraftApp());
    expect(find.byType(EventCraftApp), findsOneWidget);
  });
}
