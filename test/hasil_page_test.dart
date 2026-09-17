import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/screening/hasil_page.dart';

void main() {
  testWidgets('HasilPage renders all required elements and navigates to DoctorListPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HasilPage(),
      ),
    );

    // Verify AppBar
    expect(find.text('Skrining Penyakit'), findsOneWidget);

    // Verify Banner
    expect(find.text('Hasil Skrining'), findsOneWidget);
    expect(
      find.text('Berikut adalah hasil analisis berdasarkan jawaban yang Anda berikan'),
      findsOneWidget,
    );

    // Verify Circular Gauge Score
    expect(find.text('58%'), findsOneWidget);
    expect(find.text('Skor Risiko'), findsOneWidget);

    // Verify Warning Card
    expect(
      find.text('Anda memiliki risiko sedang untuk mengalami osteoporosis.'),
      findsOneWidget,
    );

    // Verify Data Prediksi Section
    expect(find.text('Data yang Digunakan untuk Prediksi'), findsNWidgets(2));
    expect(find.text('Usia'), findsOneWidget);
    expect(find.text('60 tahun'), findsOneWidget);
    expect(find.text('Jenis kelamin'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('Hipertiroidisme'), findsOneWidget);
    expect(find.text('Kortikosteroid'), findsOneWidget);

    // Verify Rekomendasi
    expect(find.text('Rekomendasi untuk Anda'), findsOneWidget);
    expect(find.text('Perbanyak makanan tinggi kalsium'), findsOneWidget);
    expect(find.text('Konsumsi vitamin D sesuai anjuran'), findsOneWidget);
    expect(find.text('Hindari rokok dan kurangi alkohol'), findsOneWidget);

    // Verify Button "Konsultasi Dokter"
    final buttonFinder = find.text('Konsultasi Dokter');
    expect(buttonFinder, findsOneWidget);

    // Verify Disclaimer
    expect(
      find.textContaining('Hasil skrining ini bukan merupakan diagnosis medis.'),
      findsOneWidget,
    );

    // Test Navigation to DoctorListPage with ensureVisible
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DoctorListPage), findsOneWidget);
  });
}
