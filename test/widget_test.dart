import 'package:flutter_test/flutter_test.dart';
import 'package:arzz_bakery/main.dart';

void main() {
  testWidgets('Arzz Bakery app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Arzz Bakery'), findsOneWidget);
  });
}
