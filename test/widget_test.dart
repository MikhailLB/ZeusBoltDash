import 'package:flutter_test/flutter_test.dart';

import 'package:zeus_bolt_dash/aegis_app.dart';

void main() {
  testWidgets('AegisApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const AegisApp());
    // The boot screen should be present on first frame.
    expect(find.byType(AegisApp), findsOneWidget);
  });
}
