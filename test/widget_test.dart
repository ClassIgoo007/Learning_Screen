import 'package:flutter_test/flutter_test.dart';

import 'package:phonics_worksheets/main.dart';

void main() {
  testWidgets('Welcome screen renders headline and start button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PhonicsApp());
    await tester.pump();

    expect(find.text('Phonics'), findsOneWidget);
    expect(find.text("Let's Get a Fresh Start"), findsOneWidget);
  });
}
