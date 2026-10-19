import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/features/screening/screening_page.dart';

void main() {
  testWidgets('HasilPage renders all required elements according to the new design and navigates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HasilScreeningPage(
          scorePercentage: 91,
          modelConfidence: 91.42,
        ),
      ),
    );

    // Verify AppBar
    expect(find.text('Skrining Penyakit'), findsOneWidget);

    // Verify Header Hasil Skrining
    expect(find.text('Hasil Skrining'), findsOneWidget);
    expect(
      find.text('Berikut adalah hasil analisis berdasarkan data yang Anda masukkan.'),
      findsOneWidget,
    );

    // Verify Donut Gauge & Mascot
    expect(find.text('91%'), findsOneWidget);
    expect(find.text('Probabilitas\nOsteoporosis'), findsOneWidget);

    // Verify Info Box
    expect(
      find.textContaining('Angka ini menunjukkan kemungkinan Anda mengalami osteoporosis'),
      findsOneWidget,
    );

    // Verify Tingkat Keyakinan Model
    expect(find.text('Tingkat Keyakinan Model'), findsOneWidget);
    expect(find.text('91.42%'), findsOneWidget);
    expect(
      find.textContaining('Menunjukkan seberapa yakin model terhadap hasil prediksinya'),
      findsOneWidget,
    );

    // Verify Penjelasan Hasil
    expect(find.text('Penjelasan Hasil'), findsOneWidget);
    expect(
      find.textContaining('Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar 91%.'),
      findsOneWidget,
    );

    // Verify Data Prediksi Section & Default 4 Items
    expect(find.text('Data yang Digunakan untuk Prediksi'), findsOneWidget);
    expect(find.text('Usia'), findsOneWidget);
    expect(find.text('22 tahun'), findsOneWidget);
    expect(find.text('Jenis kelamin'), findsOneWidget);
    expect(find.text('Perempuan'), findsOneWidget);
    expect(find.text('Perubahan hormonal'), findsOneWidget);
    expect(find.text('Pascamenopause'), findsOneWidget);
    expect(find.text('Ras/Etnis'), findsOneWidget);
    expect(find.text('Asia'), findsOneWidget);

    // Test expanding prediction items
    final expandFinder = find.text('Lihat selengkapnya');
    expect(expandFinder, findsOneWidget);
    await tester.ensureVisible(expandFinder);
    await tester.tap(expandFinder);
    await tester.pumpAndSettle();

    expect(find.text('Sembunyikan'), findsOneWidget);
    expect(find.text('Aktivitas fisik'), findsOneWidget);

    // Verify Rekomendasi
    expect(find.text('Rekomendasi'), findsOneWidget);
    expect(find.text('Konsultasikan dengan dokter spesialis tulang.'), findsOneWidget);
    expect(find.text('Lakukan pemeriksaan lebih lanjut (misalnya DEXA Scan).'), findsOneWidget);

    // Verify Buttons
    expect(find.text('Skrining Ulang'), findsOneWidget);
    final buttonFinder = find.text('Konsultasi Dokter');
    expect(buttonFinder, findsOneWidget);

    // Test Navigation to DoctorListPage
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(DoctorListPage), findsOneWidget);
  });

  testWidgets('HasilPage renders low risk design correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HasilScreeningPage(
          scorePercentage: 19.95,
          modelConfidence: 80.05,
        ),
      ),
    );

    expect(find.text('19.95%'), findsOneWidget);
    expect(find.text('80.05%'), findsOneWidget);
    expect(
      find.textContaining('Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar 19.95%.'),
      findsOneWidget,
    );
    expect(find.text('Tetap pertahankan pola hidup sehat.'), findsOneWidget);
    expect(find.text('Lakukan skrining secara berkala.'), findsOneWidget);
  });
}
