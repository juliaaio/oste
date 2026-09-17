import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/chat_page.dart';
import 'package:oste/features/consultation/consultation_history_card.dart';
import 'package:oste/features/consultation/consultation_history_page.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/features/consultation/doctor_card.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/consultation/doctor_profile_page.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/services/consultation_history_service.dart';

void main() {
  group('Consultation Models & Service Tests', () {
    test('ConsultationHistoryService maintains initial seed and supports doctor filtering', () {
      final service = ConsultationHistoryService();
      final all = service.allConsultations;
      expect(all.isNotEmpty, isTrue);

      final andiHistories = service.getConsultationsByDoctorId('doc_1');
      expect(andiHistories.length, greaterThanOrEqualTo(3));
      expect(andiHistories.every((item) => item.doctor.id == 'doc_1'), isTrue);
    });

    test('ConsultationHistoryService adds new consultation properly', () {
      final service = ConsultationHistoryService();
      final initialCount = service.allConsultations.length;

      final testConsultation = ConsultationHistory(
        id: 'test_hist_${DateTime.now().millisecondsSinceEpoch}',
        doctor: doctorList[1], // dr. Edwin
        date: '17 September 2026',
        time: '15:00 WIB',
        summary: 'Uji riwayat konsultasi',
        diagnosis: 'Pemeriksaan Lutut Normal',
        doctorNotes: 'Kondisi baik.',
        doctorRecommendation: 'Rutin jalan santai.',
        nutritionRecommendation: 'Minum air dan kalsium cukup.',
        followUpAdvice: 'Kontrol ulang dalam 1 bulan.',
        messages: const [
          ChatMessage(
            id: 'm_test',
            text: 'Halo dok',
            time: '14:55',
            isFromDoctor: false,
          ),
        ],
      );

      service.addConsultation(testConsultation);
      expect(service.allConsultations.length, equals(initialCount + 1));
      expect(service.allConsultations.first.id, equals(testConsultation.id));

      final edwinHistories = service.getConsultationsByDoctorId(doctorList[1].id);
      expect(edwinHistories.any((h) => h.id == testConsultation.id), isTrue);
    });
  });

  group('Consultation Widget Tests', () {
    testWidgets('DoctorListPage renders top-left back button, search, and doctor cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorListPage(),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Daftar Dokter'), findsOneWidget);
      expect(find.text('Cari dokter atau spesialisasi'), findsOneWidget);
      expect(find.byType(DoctorCard), findsWidgets);
    });

    testWidgets('DoctorProfilePage displays doctor info, schedule, chat button and history button', (tester) async {
      final testDoctor = doctorList[0]; // dr. Andi Wijaya

      await tester.pumpWidget(
        MaterialApp(
          home: DoctorProfilePage(doctor: testDoctor),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Profil Dokter'), findsOneWidget);
      expect(find.text(testDoctor.name), findsOneWidget);
      expect(find.text(testDoctor.specialist), findsOneWidget);
      expect(find.text('Tentang Dokter'), findsOneWidget);
      expect(find.text('Jadwal Praktik'), findsOneWidget);
      expect(find.text('Chat Sekarang'), findsOneWidget);
      expect(find.text('Riwayat Konsultasi'), findsOneWidget);
    });

    testWidgets('ChatPage initial state shows only greeting and interactive input', (tester) async {
      final testDoctor = doctorList[0];
      final startTime = DateTime(2026, 9, 17, 10, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            doctor: testDoctor,
            consultationStartTime: startTime,
          ),
        ),
      );

      // Verify greeting message and timestamp
      expect(find.text('10:30'), findsOneWidget);
      expect(find.textContaining('Selamat pagi, Aulia'), findsOneWidget);

      // Verify summary card is NOT visible yet
      expect(find.text('Lihat Ringkasan Konsultasi'), findsNothing);

      // Verify input is enabled
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ChatPage completes after turns, disables input, and shows summary card', (tester) async {
      final testDoctor = doctorList[0];

      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(doctor: testDoctor),
        ),
      );

      // Send message 1
      await tester.enterText(find.byType(TextField), 'Halo dok');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 850));

      // Send message 2
      await tester.enterText(find.byType(TextField), 'Bagaimana solusinya dok?');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 850));

      // Send message 3
      await tester.enterText(find.byType(TextField), 'Terima kasih dok');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 850));

      // Wait for closing notice and summary card
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Summary card should now appear
      expect(find.text('Lihat Ringkasan Konsultasi'), findsOneWidget);

      // Input should be disabled with hint "Konsultasi telah selesai"
      expect(find.text('Konsultasi telah selesai'), findsOneWidget);
    });

    testWidgets('ConsultationHistoryPage renders list of cards for doctor', (tester) async {
      final testDoctor = doctorList[0];

      await tester.pumpWidget(
        MaterialApp(
          home: ConsultationHistoryPage(doctor: testDoctor),
        ),
      );

      expect(find.text('Riwayat: ${testDoctor.name}'), findsOneWidget);
      expect(find.byType(ConsultationHistoryCard), findsWidgets);
    });

    testWidgets('ConsultationSummaryPage displays stored consultation details with follow-up advice', (tester) async {
      final service = ConsultationHistoryService();
      final storedItem = service.allConsultations.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ConsultationSummaryPage(consultation: storedItem),
        ),
      );

      expect(find.text('Ringkasan Konsultasi'), findsOneWidget);
      expect(find.text(storedItem.doctor.name), findsOneWidget);
      expect(find.text('Diagnosis Medis'), findsOneWidget);
      expect(find.text('Rekomendasi Dokter'), findsOneWidget);
      expect(find.text('Rekomendasi Nutrisi & Pola Hidup'), findsOneWidget);
      expect(find.text('Catatan Dokter'), findsOneWidget);
      expect(find.text('Saran Tindak Lanjut'), findsOneWidget);
      expect(find.text('Kembali Ke Beranda'), findsOneWidget);
    });
  });
}
