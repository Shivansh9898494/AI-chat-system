import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeuralAI3DApp());

    // Verify app renders correctly
    expect(find.byType(NeuralAI3DApp), findsOneWidget);
  });
}
