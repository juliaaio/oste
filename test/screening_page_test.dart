import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/screening/screening_page.dart';

void main() {
  testWidgets('ScreeningPage renders all elements and calculates BMI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScreeningPage(),
      ),
    );

    // Verify AppBar
    expect(find.text('Skrining Osteoporosis'), findsOneWidget);

    // Verify Banner
    expect(find.text('Kenali Risikomu,\nJaga Tulangmu'), findsOneWidget);

    // Verify Question 1 - Umur
    expect(find.text('1.  Umur'), findsOneWidget);
    expect(find.text('tahun'), findsOneWidget);

    // Verify Question 2 - Jenis Kelamin
    expect(find.text('2.  Jenis kelamin'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('Laki-laki'), findsOneWidget);

    // Verify Question 3 - Tinggi Badan
    expect(find.text('3.  Tinggi badan'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);

    // Verify Question 4 - Berat Badan & BMI card
    expect(find.text('4.  Berat badan'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('Indeks Massa Tubuh (BMI)'), findsOneWidget);

    // Test BMI calculation
    await tester.enterText(find.widgetWithText(TextField, 'Masukkan tinggi badan'), '170');
    await tester.enterText(find.widgetWithText(TextField, 'Masukkan berat badan'), '65');
    await tester.pump();

    // 65 / (1.7 * 1.7) = 22.49 -> 22.5 (Normal)
    expect(find.textContaining('BMI: 22.5 (Normal)'), findsOneWidget);

    // Verify "Mulai Skrining" button
    expect(find.text('Mulai Skrining'), findsOneWidget);
  });
}
