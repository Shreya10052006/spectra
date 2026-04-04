import 'package:flutter_test/flutter_test.dart';
import 'package:spectra/app.dart';

void main() {
  testWidgets('SPECTRA app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SpectraApp());
    expect(find.text('Home'), findsWidgets);
  });
}
