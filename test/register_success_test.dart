import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/auth/register_success/register_success_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';

void main() {
  group('RegisterSuccessPage Tests', () {
    testWidgets('RegisterSuccessPage renders all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterSuccessPage(),
        ),
      );

      // Verify title exists
      expect(find.text('Akun Berhasil Dibuat!'), findsOneWidget);

      // Verify description exists
      expect(find.textContaining('Selamat datang di Osteocare'), findsOneWidget);
      expect(find.textContaining('Saatnya mulai menjaga kesehatan'), findsOneWidget);

      // Verify main button exists
      expect(find.text('Mulai Sekarang'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      // Verify footer motto exists
      expect(find.textContaining('Tulang yang Sehat'), findsOneWidget);
    });

    testWidgets('Tapping Mulai Sekarang navigates to DashboardPage', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterSuccessPage(),
        ),
      );

      await tester.tap(find.text('Mulai Sekarang'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });
}
