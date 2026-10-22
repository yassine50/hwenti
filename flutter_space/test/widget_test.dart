import 'package:flutter_test/flutter_test.dart';
import 'package:hwenti_flutter/main.dart';

void main() {
  testWidgets('HwentiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HwentiApp());
    expect(find.byType(HwentiApp), findsOneWidget);
  });
}
