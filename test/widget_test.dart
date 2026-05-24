import 'package:flutter_test/flutter_test.dart';
import 'package:zeus_bolt_dash/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZeusBoltDashApp());
    expect(find.byType(ZeusBoltDashApp), findsOneWidget);
  });
}
