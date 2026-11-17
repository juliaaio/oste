import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/consultation_history_page.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/services/consultation_history_service.dart';

void main() {
  group('1. Dummy Data Elimination Tests', () {
    test('ConsultationHistoryService has no hardcoded seed data on initialization', () {
      final service = ConsultationHistoryService();
      service.clear();
      expect(service.allConsultations, isEmpty);
      expect(service.getConsultationsByDoctorId('doc_1'), isEmpty);
    });
  });

  group('2. ConsultationHistory Model Firestore Serialization Tests', () {
    test('toFirestore includes all required fields', () {
      final now = DateTime(2026, 11, 17, 12, 30);
      final item = ConsultationHistory(
        id: 'consult_test_123',
        chatId: 'chat_test_123',
        doctorId: 'doc_1',
        doctorName: 'dr. Andi Wijaya, Sp.OT',
        doctorPhoto: 'https://example.com/dr_andi.png',
        patientId: 'user_patient_99',
        patientName: 'Aulia Rahman',
        diagnosis: 'Indikasi Osteoporosis Ringan',
        summary: 'Pemeriksaan lanjutan kepadatan tulang dan postur.',
        doctorNotes: 'Jaga posisi duduk ergonomis.',
        doctorRecommendation: 'Latihan fisik ringan 30 menit sehari.',
        nutritionRecommendation: 'Asupan kalsium 1000 mg/hari.',
        followUpAdvice: 'Kontrol dalam 1 bulan.',
        consultationStatus: 'completed',
        messageCount: 8,
        createdAt: now,
        completedAt: now,
        date: '17 November 2026',
        time: '12:30 WIB',
      );

      final map = item.toFirestore();

      // Periksa field minimal yang disyaratkan user
      expect(map['consultationId'], equals('consult_test_123'));
      expect(map['chatId'], equals('chat_test_123'));
      expect(map['doctorId'], equals('doc_1'));
      expect(map['doctorName'], equals('dr. Andi Wijaya, Sp.OT'));
      expect(map['doctorPhoto'], equals('https://example.com/dr_andi.png'));
      expect(map['patientId'], equals('user_patient_99'));
      expect(map['diagnosis'], equals('Indikasi Osteoporosis Ringan'));
      expect(map['summary'], equals('Pemeriksaan lanjutan kepadatan tulang dan postur.'));
      expect(map['consultationStatus'], equals('completed'));
      expect(map['messageCount'], equals(8));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['completedAt'], isA<Timestamp>());
    });

    test('fromMap restores all fields correctly from Firestore data', () {
      final firestoreData = <String, dynamic>{
        'consultationId': 'consult_rec_456',
        'chatId': 'chat_rec_456',
        'doctorId': 'doc_2',
        'doctorName': 'dr. Siti Rahma, Sp.KFR',
        'doctorPhoto': 'https://example.com/dr_siti.png',
        'doctorSpecialist': 'Spesialis Kedokteran Fisik & Rehabilitasi',
        'doctorHospital': 'RS Siloam',
        'patientId': 'user_patient_88',
        'patientName': 'Budi Santoso',
        'diagnosis': 'Osteopenia dengan spasme otot lumbar',
        'summary': 'Evaluasi mobilitas sendi pinggul dan anjuran fisioterapi.',
        'doctorNotes': 'Koreksi posisi duduk saat bekerja di depan laptop.',
        'doctorRecommendation': 'Latihan peregangan paha belakang dan pinggul 3x sehari.',
        'nutritionRecommendation': 'Tingkatkan asupan magnesium dan vitamin D3.',
        'followUpAdvice': 'Evaluasi kembali jika nyeri berlanjut setelah 2 minggu.',
        'consultationStatus': 'completed',
        'messageCount': 12,
        'date': '15 November 2026',
        'time': '16:00 WIB',
      };

      final parsed = ConsultationHistory.fromMap('consult_rec_456', firestoreData);

      expect(parsed.id, equals('consult_rec_456'));
      expect(parsed.chatId, equals('chat_rec_456'));
      expect(parsed.doctorId, equals('doc_2'));
      expect(parsed.doctorName, equals('dr. Siti Rahma, Sp.KFR'));
      expect(parsed.doctorPhoto, equals('https://example.com/dr_siti.png'));
      expect(parsed.doctorSpecialist, equals('Spesialis Kedokteran Fisik & Rehabilitasi'));
      expect(parsed.doctorHospital, equals('RS Siloam'));
      expect(parsed.patientId, equals('user_patient_88'));
      expect(parsed.patientName, equals('Budi Santoso'));
      expect(parsed.diagnosis, equals('Osteopenia dengan spasme otot lumbar'));
      expect(parsed.summary, equals('Evaluasi mobilitas sendi pinggul dan anjuran fisioterapi.'));
      expect(parsed.consultationStatus, equals('completed'));
      expect(parsed.messageCount, equals(12));
      expect(parsed.date, equals('15 November 2026'));
      expect(parsed.time, equals('16:00 WIB'));

      // Verifikasi backward-compatibility getter .doctor
      expect(parsed.doctor.name, equals('dr. Siti Rahma, Sp.KFR'));
      expect(parsed.doctor.id, equals('doc_2'));
    });
  });

  group('3. Empty State & Realtime UI Tests', () {
    testWidgets('ConsultationHistoryPage renders Empty State with correct message when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsultationHistoryPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada riwayat konsultasi'), findsOneWidget);
      expect(
        find.text('Konsultasi yang telah selesai akan tersimpan secara otomatis di sini.'),
        findsOneWidget,
      );
    });

    testWidgets('HistoryPage consultation tab renders Empty State when no consultation data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HistoryPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Pindah ke tab Konsultasi Dokter
      await tester.tap(find.text('Konsultasi Dokter'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada riwayat konsultasi'), findsOneWidget);
    });

    testWidgets('ConsultationSummaryPage displays given consultation properly without dummy data', (tester) async {
      final doc = doctorList.first;
      final item = ConsultationHistory(
        id: 'hist_summary_test',
        doctor: doc,
        date: '17 November 2026',
        time: '11:00 WIB',
        summary: 'Uji coba ringkasan',
        diagnosis: 'Diagnosis Uji Konsultasi',
        doctorNotes: 'Catatan uji dokter.',
        doctorRecommendation: 'Rekomendasi uji dokter.',
        nutritionRecommendation: 'Rekomendasi gizi uji.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ConsultationSummaryPage(consultation: item),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ringkasan Konsultasi'), findsOneWidget);
      expect(find.text('Diagnosis Uji Konsultasi'), findsOneWidget);
      expect(find.text('Catatan uji dokter.'), findsOneWidget);
      expect(find.text('Rekomendasi uji dokter.'), findsOneWidget);
    });
  });
}

