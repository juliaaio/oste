import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/welcome/welcome_page.dart';
import 'package:oste/main.dart';

void main() {
  testWidgets('App smoke test loads WelcomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
