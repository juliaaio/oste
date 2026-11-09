import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/chat_page.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/doctor_dashboard/doctor_chat_list_tab.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/patient_presence_service.dart';
import 'package:oste/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PatientPresenceService Unit Tests', () {
    const patientUid = 'patient_test_123';

    setUp(() {
      PatientPresenceService().clearForTesting();
    });

    tearDown(() {
      PatientPresenceService().clearForTesting();
    });

    test('PatientPresenceService is a singleton', () {
      final s1 = PatientPresenceService();
      final s2 = PatientPresenceService();
      expect(identical(s1, s2), isTrue);
    });

    test('isOnline returns fallback if patient not in cache', () {
      expect(PatientPresenceService().isOnline('unknown_patient', fallback: true), isTrue);
      expect(PatientPresenceService().isOnline('unknown_patient', fallback: false), isFalse);
    });

    test('Setting status updates isOnline and triggers notification', () {
      bool notified = false;
      PatientPresenceService().addListener(() {
        notified = true;
      });

      PatientPresenceService().setMockStatus(patientUid, true);
      expect(PatientPresenceService().isOnline(patientUid), isTrue);
      expect(notified, isTrue);

      notified = false;
      PatientPresenceService().setMockStatus(patientUid, false);
      expect(PatientPresenceService().isOnline(patientUid), isFalse);
      expect(notified, isTrue);
    });
  });

  group('DoctorChatListTab & ChatPage Real-time Presence Tests', () {
    const patientId = 'patient_siti';
    const patientName = 'Siti Rahmawati';
    final doctor = doctorList[0];

    setUp(() {
      ChatService().clearForTesting();
      PatientPresenceService().clearForTesting();
      DoctorPresenceService().setOnline(doctor.id);
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'doc_1',
          name: 'dr. Intan Permata, Sp.OT',
          email: 'intan@osteocare.com',
          role: 'doctor',
        ),
      );
    });

    tearDown(() {
      ChatService().clearForTesting();
      PatientPresenceService().clearForTesting();
      UserService().setCurrentUserForTesting(null);
    });

    testWidgets(
        'DoctorChatListTab updates badge and indicator from Offline to Online when patient comes online',
        (tester) async {
      // Pasien awalnya offline
      PatientPresenceService().setMockStatus(patientId, false);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoctorChatListTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chat Pasien'), findsOneWidget);
      expect(find.text(patientName), findsOneWidget);

      // Pasien sekarang online di aplikasi
      PatientPresenceService().setMockStatus(patientId, true);
      await tester.pumpAndSettle();

      // Badge teks Online harus ada
      expect(find.text('Online'), findsWidgets);
    });

    testWidgets(
        'ChatPage in Doctor POV reacts dynamically when patient goes from Online to Offline',
        (tester) async {
      // Pasien awalnya online
      PatientPresenceService().setMockStatus(patientId, true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            doctor: doctor,
            chatId: 'chat_doc_1_$patientId',
            patientId: patientId,
            patientName: patientName,
            patientInitial: 'S',
            isDoctorPOV: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(patientName), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);

      // Pasien menutup aplikasi / keluar (set offline)
      PatientPresenceService().setMockStatus(patientId, false);
      await tester.pumpAndSettle();

      // Status langsung berganti menjadi Offline secara real-time
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Online'), findsNothing);
    });
  });
}

