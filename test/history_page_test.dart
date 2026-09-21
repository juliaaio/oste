import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/features/history/widgets/history_header.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/services/history_service.dart';

void main() {
  testWidgets('HistoryPage renders header, summary, and switches tabs properly', (tester) async {
    // Clear screening histories for predictable test state
    final historyService = HistoryService();
    historyService.clearScreeningHistories();

    await tester.pumpWidget(
      const MaterialApp(
        home: HistoryPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and summary card
    expect(find.widgetWithText(HistoryHeader, 'Riwayat'), findsOneWidget);
    expect(find.text('Ringkasan Riwayat'), findsOneWidget);
    expect(find.text('Daftar Riwayat'), findsOneWidget);
    expect(find.text('Skrining'), findsOneWidget);
    expect(find.text('Konsultasi Dokter'), findsOneWidget);

    // Initial state (tab 0: Skrining) is empty
    expect(find.text('Belum ada riwayat'), findsOneWidget);
    expect(find.text('Mulai Skrining'), findsOneWidget);

    // Add a screening entry to HistoryService
    final testScreening = HistoryModel.fromScreening(
      id: 'test_scr_1',
      tanggal: DateTime(2025, 9, 12),
      waktu: '14.30 WIB',
      probabilitas: 58,
      status: 'Terindikasi Osteoporosis',
      isPositive: true,
    );
    historyService.addScreening(testScreening);
    await tester.pumpAndSettle();

    // Verify summary card updated
    expect(find.text('1'), findsOneWidget); // Total skrining: 1
    expect(find.text('58%'), findsWidgets); // Latest score in summary card & list card
    expect(find.text('12 Sep 2025'), findsOneWidget); // Short date in summary

    // Verify screening card rendered in tab 0
    expect(find.text('12 September 2025'), findsOneWidget);
    expect(find.text('Pukul 14.30 WIB'), findsOneWidget);
    expect(find.text('Probabilitas: 58%'), findsOneWidget);
    expect(find.text('Terindikasi Osteoporosis'), findsOneWidget);

    // Switch to Konsultasi Dokter tab
    await tester.tap(find.text('Konsultasi Dokter'));
    await tester.pumpAndSettle();

    // Consultation list should be displayed (seeded by ConsultationHistoryService)
    expect(find.text('Topik Konsultasi'), findsWidgets);
    expect(find.text('Selesai'), findsWidgets);
  });
}
