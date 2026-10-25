import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/chat_bubble.dart';
import 'package:oste/features/consultation/chat_page.dart';
import 'package:oste/features/consultation/doctor_card.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/user_service.dart';

void main() {
  group('ChatBubble POV Tests', () {
    testWidgets('Patient POV renders doctor message on left and patient on right',
        (tester) async {
      const docMsg = ChatMessage(
        id: 'msg_1',
        text: 'Pesan dari dokter',
        time: '10:00',
        isFromDoctor: true,
      );

      const patientMsg = ChatMessage(
        id: 'msg_2',
        text: 'Pesan dari pasien',
        time: '10:01',
        isFromDoctor: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                ChatBubble(
                  message: docMsg,
                  doctorAvatarUrl: '',
                  isDoctorPOV: false,
                ),
                ChatBubble(
                  message: patientMsg,
                  doctorAvatarUrl: '',
                  isDoctorPOV: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Di POV Pasien: pesan dokter memakai DoctorChatBubble (kiri)
      expect(find.byType(DoctorChatBubble), findsOneWidget);
      // Pesan pasien memakai UserChatBubble (kanan)
      expect(find.byType(UserChatBubble), findsOneWidget);
      expect(find.byType(PatientChatBubble), findsNothing);
    });

    testWidgets('Doctor POV renders patient message on left and doctor on right',
        (tester) async {
      const patientMsg = ChatMessage(
        id: 'msg_1',
        text: 'Dok, punggung saya sakit',
        time: '08:20',
        isFromDoctor: false, // dari pasien
      );

      const docMsg = ChatMessage(
        id: 'msg_2',
        text: 'Baik, silakan istirahat dulu',
        time: '08:22',
        isFromDoctor: true, // dari dokter
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                ChatBubble(
                  message: patientMsg,
                  doctorAvatarUrl: '',
                  isDoctorPOV: true,
                  patientInitial: 'S',
                ),
                ChatBubble(
                  message: docMsg,
                  doctorAvatarUrl: '',
                  isDoctorPOV: true,
                  patientInitial: 'S',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Di POV Dokter: pesan masuk pasien memakai PatientChatBubble (kiri) dengan inisial 'S'
      expect(find.byType(PatientChatBubble), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      // Pesan balasan dokter memakai UserChatBubble (kanan)
      expect(find.byType(UserChatBubble), findsOneWidget);
      expect(find.byType(DoctorChatBubble), findsNothing);
    });
  });

  group('ChatPage Doctor Mode (POV Dokter) Tests', () {
    setUp(() {
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'doc_intan',
          name: 'dr. Intan Permata, Sp.OT',
          email: 'intan@osteocare.com',
          role: 'doctor',
          specialist: 'Dokter Spesialis Orthopedi',
        ),
      );
    });

    tearDown(() {
      UserService().setCurrentUserForTesting(null);
    });

    testWidgets(
        'Doctor POV header displays Patient Name, not Doctor Name, and no auto greeting',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            doctor: doctorList[0],
            chatId: 'chat_siti',
            patientId: 'patient_siti',
            patientName: 'Siti Rahmawati',
            patientInitial: 'S',
            isPatientOnline: true,
            isDoctorPOV: true, // Mode dokter
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header AppBar menampilkan nama Pasien
      expect(find.text('Siti Rahmawati'), findsOneWidget);
      expect(find.text('Pasien OsteoCare'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      // Nama dokter TIDAK tampil di judul AppBar lawan bicara
      expect(find.text(doctorList[0].name), findsNothing);

      // Sapaan otomatis dokter bot ("Selamat pagi, Aulia...") TIDAK boleh muncul
      expect(find.textContaining('Selamat pagi, Aulia'), findsNothing);

      // Pesan pasien seeded 'chat_siti' tampil di sisi kiri
      expect(
        find.textContaining('Dok, saya masih merasakan nyeri'),
        findsOneWidget,
      );
      expect(find.byType(PatientChatBubble), findsOneWidget);
    });

    testWidgets(
        'Doctor sends message manually without triggering any bot automated reply',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            doctor: doctorList[0],
            chatId: 'chat_test_manual',
            patientId: 'patient_test',
            patientName: 'Ahmad Maulana',
            patientInitial: 'A',
            isPatientOnline: true,
            isDoctorPOV: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ketik pesan balasan dokter
      await tester.enterText(
        find.byType(TextField),
        'Halo Ahmad, silakan kurangi beban latihan.',
      );
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Pesan dokter tampil di layar
      expect(
        find.text('Halo Ahmad, silakan kurangi beban latihan.'),
        findsOneWidget,
      );

      // Pastikan pesan dokter tampil di sisi kanan (UserChatBubble)
      expect(find.byType(UserChatBubble), findsOneWidget);

      // TIDAK ADA balasan bot otomatis
      expect(
        find.textContaining('Dari data kamu, coba atur pola makan'),
        findsNothing,
      );
      expect(find.text('Lihat Ringkasan Konsultasi'), findsNothing);

      // Verifikasi pesan tersimpan di ChatService
      final savedMessages = ChatService().getMessages('chat_test_manual');
      expect(savedMessages.isNotEmpty, isTrue);
      expect(savedMessages.last.text,
          equals('Halo Ahmad, silakan kurangi beban latihan.'));
      expect(savedMessages.last.isFromDoctor, isTrue);
    });

    testWidgets(
        'Patient POV still displays Doctor in header and supports patient consultation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            doctor: doctorList[0],
            isDoctorPOV: false, // Mode pasien
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header AppBar menampilkan nama Dokter
      expect(find.text(doctorList[0].name), findsOneWidget);
      expect(find.text(doctorList[0].specialist), findsOneWidget);
    });
  });

  group('Patient Notification & Unread Indicator Tests', () {
    const patientUid = 'patient_budi_123';
    const docId = 'doc_1';
    final chatId = ChatService.formatChatId(doctorId: docId, patientId: patientUid);

    setUp(() {
      ChatService().clearForTesting();
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: patientUid,
          name: 'Budi Hartono',
          email: 'budi@gmail.com',
          role: 'patient',
        ),
      );
    });

    tearDown(() {
      ChatService().clearForTesting();
      UserService().setCurrentUserForTesting(null);
    });

    test('ChatService.formatChatId produces consistent deterministic chatId', () {
      final id1 = ChatService.formatChatId(doctorId: 'doc_1', patientId: 'patient_budi_123');
      final id2 = ChatService.formatChatId(doctorId: 'doc_1', patientId: 'patient_budi_123');
      expect(id1, equals('chat_doc_1_patient_budi_123'));
      expect(id1, equals(id2));
    });

    test('Doctor sending reply updates patient unreadCount and message sender/receiver IDs', () async {
      // 1. Pasien kirim pesan ke dokter
      await ChatService().sendMessage(
        chatId: chatId,
        text: 'Halo dok, apakah suplemen kalsium aman?',
        isFromDoctor: false,
        senderId: patientUid,
        receiverId: docId,
        patientName: 'Budi Hartono',
        patientId: patientUid,
        doctorId: docId,
      );

      var messages = ChatService().getMessages(chatId);
      expect(messages.last.senderId, equals(patientUid));
      expect(messages.last.receiverId, equals(docId));
      expect(messages.last.isFromDoctor, isFalse);

      // 2. Dokter membalas pesan pasien
      await ChatService().sendMessage(
        chatId: chatId,
        text: 'Aman jika dikonsumsi sesuai dosis harian ya Pak Budi.',
        isFromDoctor: true,
        senderId: docId,
        receiverId: patientUid,
        patientName: 'Budi Hartono',
        patientId: patientUid,
        doctorId: docId,
      );

      messages = ChatService().getMessages(chatId);
      final docReply = messages.last;
      expect(docReply.senderId, equals(docId));
      expect(docReply.receiverId, equals(patientUid));
      expect(docReply.isFromDoctor, isTrue);
      expect(docReply.isRead, isFalse);

      // 3. Indikator balasan belum dibaca bertambah untuk pasien
      final unreadForDoc = ChatService().getPatientUnreadCountForDoctor(docId);
      expect(unreadForDoc, greaterThanOrEqualTo(1));
      expect(ChatService().totalPatientUnreadCount, greaterThanOrEqualTo(1));
    });

    test('Patient opening conversation updates isRead only for messages to patient and resets unread count', () async {
      // Kirim pesan balasan dokter yang belum dibaca
      await ChatService().sendMessage(
        chatId: chatId,
        text: 'Silakan jadwalkan konsultasi lanjutan jika nyeri bertambah.',
        isFromDoctor: true,
        senderId: docId,
        receiverId: patientUid,
        patientName: 'Budi Hartono',
        patientId: patientUid,
        doctorId: docId,
      );

      // Pastikan ada pesan belum dibaca
      expect(ChatService().getPatientUnreadCountForDoctor(docId), greaterThanOrEqualTo(1));

      // Pasien membuka percakapan
      await ChatService().markConversationAsReadByPatient(chatId, patientUid);

      // Unread count untuk pasien ter-reset ke 0
      expect(ChatService().getPatientUnreadCountForDoctor(docId), equals(0));

      // Pesan dari dokter berubah menjadi isRead = true
      final messages = ChatService().getMessages(chatId);
      final docMsgs = messages.where((m) => m.isFromDoctor);
      for (final m in docMsgs) {
        expect(m.isRead, isTrue);
      }
    });

    testWidgets('DoctorCard displays unread badge when doctor has replied', (tester) async {
      // Set ada 2 pesan balasan dokter belum dibaca
      await ChatService().sendMessage(
        chatId: chatId,
        text: 'Pesan balasan dokter 1',
        isFromDoctor: true,
        senderId: docId,
        receiverId: patientUid,
        patientName: 'Budi Hartono',
        patientId: patientUid,
        doctorId: docId,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoctorCard(
              doctor: doctorList[0],
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Badge unread muncul di DoctorCard
      expect(find.textContaining('Balasan ('), findsOneWidget);

      // Reset setelah dibaca
      await ChatService().markConversationAsReadByPatient(chatId, patientUid);
      await tester.pumpAndSettle();

      // Setelah dibaca, teks kembali ke 'Lihat Profil'
      expect(find.text('Lihat Profil'), findsOneWidget);
    });
  });
}
