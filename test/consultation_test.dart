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
    test('ConsultationHistory has no dummy data initially', () {
      final service = ConsultationHistoryService();
      service.clear();
      expect(service.allConsultations.isEmpty, isTrue);
    });

    test('ConsultationHistory converts to and from Firestore map properly', () {
      final now = DateTime(2026, 11, 17, 10, 0);
      final item = ConsultationHistory(
        id: 'test_c_1',
        chatId: 'chat_123',
        doctorId: 'doc_1',
        doctorName: 'dr. Andi Wijaya, Sp.OT',
        doctorPhoto: 'https://example.com/doc.jpg',
        patientId: 'patient_456',
        patientName: 'Aulia',
        diagnosis: 'Pemulihan Kepadatan Tulang',
        summary: 'Ringkasan konsultasi kesehatan tulang.',
        doctorNotes: 'Kondisi membaik.',
        doctorRecommendation: 'Rutin jalan pagi.',
        nutritionRecommendation: 'Kalsium cukup.',
        consultationStatus: 'completed',
        messageCount: 5,
        createdAt: now,
        completedAt: now,
        date: '17 November 2026',
        time: '10:00 WIB',
      );

      final map = item.toFirestore();
      expect(map['consultationId'], 'test_c_1');
      expect(map['chatId'], 'chat_123');
      expect(map['doctorId'], 'doc_1');
      expect(map['doctorName'], 'dr. Andi Wijaya, Sp.OT');
      expect(map['doctorPhoto'], 'https://example.com/doc.jpg');
      expect(map['patientId'], 'patient_456');
      expect(map['diagnosis'], 'Pemulihan Kepadatan Tulang');
      expect(map['summary'], 'Ringkasan konsultasi kesehatan tulang.');
      expect(map['consultationStatus'], 'completed');
      expect(map['messageCount'], 5);

      final fromMapItem = ConsultationHistory.fromMap('test_c_1', {
        'consultationId': 'test_c_1',
        'chatId': 'chat_123',
        'doctorId': 'doc_1',
        'doctorName': 'dr. Andi Wijaya, Sp.OT',
        'doctorPhoto': 'https://example.com/doc.jpg',
        'patientId': 'patient_456',
        'patientName': 'Aulia',
        'diagnosis': 'Pemulihan Kepadatan Tulang',
        'summary': 'Ringkasan konsultasi kesehatan tulang.',
        'doctorNotes': 'Kondisi membaik.',
        'doctorRecommendation': 'Rutin jalan pagi.',
        'nutritionRecommendation': 'Kalsium cukup.',
        'consultationStatus': 'completed',
        'messageCount': 5,
        'date': '17 November 2026',
        'time': '10:00 WIB',
      });

      expect(fromMapItem.id, 'test_c_1');
      expect(fromMapItem.doctorId, 'doc_1');
      expect(fromMapItem.doctorName, 'dr. Andi Wijaya, Sp.OT');
      expect(fromMapItem.doctorPhoto, 'https://example.com/doc.jpg');
      expect(fromMapItem.patientId, 'patient_456');
      expect(fromMapItem.patientName, 'Aulia');
      expect(fromMapItem.diagnosis, 'Pemulihan Kepadatan Tulang');
      expect(fromMapItem.summary, 'Ringkasan konsultasi kesehatan tulang.');
      expect(fromMapItem.consultationStatus, 'completed');
      expect(fromMapItem.messageCount, 5);
      expect(fromMapItem.date, '17 November 2026');
      expect(fromMapItem.time, '10:00 WIB');
    });

    test('ConsultationHistoryService adds new consultation properly', () {
      final service = ConsultationHistoryService();
      service.clear();
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
      expect(find.text('Cari nama dokter atau spesialisasi'), findsOneWidget);
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

    testWidgets('ConsultationHistoryPage renders empty state when no consultations exist', (tester) async {
      final testDoctor = doctorList[0];

      await tester.pumpWidget(
        MaterialApp(
          home: ConsultationHistoryPage(doctor: testDoctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Riwayat: ${testDoctor.name}'), findsOneWidget);
      expect(find.text('Belum ada riwayat konsultasi dengan ${testDoctor.name}'), findsOneWidget);
    });

    testWidgets('ConsultationSummaryPage displays stored consultation details with follow-up advice', (tester) async {
      final testDoctor = doctorList[0];
      final storedItem = ConsultationHistory(
        id: 'test_hist_summary',
        doctor: testDoctor,
        date: '20 September 2026',
        time: '14:15 WIB',
        summary: 'Evaluasi respon terapi suplemen kalsium.',
        diagnosis: 'Pemulihan Kepadatan Tulang Terkontrol',
        doctorNotes: 'Kondisi kepadatan tulang terpantau membaik.',
        doctorRecommendation: 'Lanjutkan latihan beban tubuh ringan.',
        nutritionRecommendation: 'Pertahankan konsumsi kalsium 1000 mg/hari.',
      );

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
