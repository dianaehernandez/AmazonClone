
import 'package:flutter_test/flutter_test.dart';

import 'package:amazon/main.dart';

void main() {
  testWidgets('Amazon app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Just verify that the app builds without errors
    // We expect to find at least one widget (the app scaffold/container)
    expect(find.byType(tester.widget<MyApp>(find.byType(MyApp)).runtimeType), findsOneWidget);
  });
}
