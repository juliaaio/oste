import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/doctor_dashboard/doctor_dashboard_page.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/services/user_service.dart';

void main() {
  group('Role Akun & UserModel Tests', () {
    test('Default user role is patient and isDoctor is false', () {
      const patient = UserModel(
        uid: 'user_1',
        name: 'Aulia Rahma',
        email: 'aulia@gmail.com',
      );

      expect(patient.role, equals('patient'));
      expect(patient.isDoctor, isFalse);
    });

    test('Doctor role is correctly recognized via isDoctor getter', () {
      const doctor1 = UserModel(
        uid: 'doc_1',
        name: 'dr. Intan Permata, Sp.OT',
        email: 'intan@osteocare.com',
        role: 'doctor',
        specialist: 'Dokter Spesialis Orthopedi',
      );

      const doctor2 = UserModel(
        uid: 'doc_2',
        name: 'dr. Andi Wijaya',
        email: 'andi@osteocare.com',
        role: 'dokter',
      );

      expect(doctor1.isDoctor, isTrue);
      expect(doctor2.isDoctor, isTrue);
      expect(doctor1.specialist, equals('Dokter Spesialis Orthopedi'));
    });

    test('UserModel serialization preserves role and specialist', () {
      const doctor = UserModel(
        uid: 'doc_99',
        name: 'dr. Budi Setiawan',
        email: 'budi.dokter@osteocare.com',
        role: 'doctor',
        specialist: 'Spesialis Bedah Tulang',
      );

      final map = doctor.toFirestore();
      expect(map['role'], equals('doctor'));
      expect(map['specialist'], equals('Spesialis Bedah Tulang'));

      final fromMap = UserModel.fromMap('doc_99', map);
      expect(fromMap.role, equals('doctor'));
      expect(fromMap.specialist, equals('Spesialis Bedah Tulang'));
      expect(fromMap.isDoctor, isTrue);
    });
  });

  group('DoctorDashboardPage Widget Tests', () {
    setUp(() {
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'doc_test',
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

    testWidgets('Renders Doctor Dashboard Home tab with Figma elements',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan teks OsteoCare, Sapaan Dokter, dan Menu Utama muncul
      expect(find.text('Menu Utama'), findsOneWidget);
      expect(find.text('Chat Pasien'), findsWidgets); // di kartu menu & bottom nav
      expect(find.text('Riwayat'), findsWidgets); // di kartu menu & bottom nav
      expect(find.text('Hallo, dr. Intan! 👋'), findsOneWidget);
      expect(
        find.text(
            'Terus berikan pelayanan terbaik untuk kesehatan tulang pasienmu!'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Chat Pasien card switches to Chat Pasien tab',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk kartu "Chat Pasien" di Menu Utama
      final chatMenuCard = find.text('Kelola dan balas pesan dari pasien Anda');
      expect(chatMenuCard, findsOneWidget);
      await tester.tap(chatMenuCard);
      await tester.pumpAndSettle();

      // Memastikan berpindah ke tab Chat Pasien dengan search bar & daftar pasien
      expect(find.text('Cari nama pasien atau pesan...'), findsOneWidget);
      expect(find.text('Siti Rahmawati'), findsOneWidget);
      expect(find.text('Ahmad Maulana'), findsOneWidget);

      // Keterangan status Online dan Offline pada kartu pasien
      expect(find.text('Online'), findsWidgets);
      expect(find.text('Offline'), findsWidgets);
    });

    testWidgets('Tapping bottom nav Riwayat switches to Riwayat tab',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk item navigasi bawah "Riwayat"
      final riwayatNavItem = find.widgetWithText(GestureDetector, 'Riwayat');
      await tester.tap(riwayatNavItem.first);
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Pasien'), findsOneWidget);
      expect(find.text('Skrining Pasien'), findsOneWidget);
      expect(find.text('Konsultasi'), findsOneWidget);
    });

    testWidgets('Tapping bottom nav Profil displays profile page',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk item navigasi bawah "Profil"
      final profilNavItem = find.widgetWithText(GestureDetector, 'Profil');
      await tester.tap(profilNavItem.first);
      await tester.pumpAndSettle();

      // Memastikan halaman profil termuat dengan data dokter
      expect(find.text('Profil'), findsWidgets);
      expect(find.text('dr. Intan Permata, Sp.OT'), findsWidgets);
      expect(find.text('intan@osteocare.com'), findsWidgets);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets(
        'Doctor History displays patient name, is tappable, and opens HasilScreeningPage',
        (tester) async {
      final historyService = HistoryService();
      historyService.clearScreeningHistories();

      // Tambahkan data skrining pasien "Julia Nurul"
      historyService.addScreening(
        HistoryModel.fromScreening(
          id: 'scr_julia_1',
          tanggal: DateTime(2026, 11, 12),
          waktu: '10.30 WIB',
          probabilitas: 75,
          status: 'Terindikasi Osteoporosis',
          isPositive: true,
          riskCategory: 'Risiko Sedang',
          summary: 'Risiko sedang mengalami osteoporosis.',
          modelConfidence: 88.5,
          recommendations: ['Konsultasikan dengan dokter spesialis tulang.'],
          patientName: 'Julia Nurul',
          patientId: 'patient_julia',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorDashboardPage(initialIndex: 1), // Buka tab Riwayat
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan judul tab Riwayat Pasien termuat
      expect(find.text('Riwayat Pasien'), findsOneWidget);

      // Memastikan informasi Nama Pasien muncul
      expect(find.text('Nama Pasien: '), findsWidgets);
      expect(find.text('Julia Nurul'), findsOneWidget);
      expect(find.text('Terindikasi Osteoporosis'), findsOneWidget);
      expect(find.text('Risiko Sedang'), findsOneWidget);
      expect(find.text('Probabilitas: 75%'), findsOneWidget);

      // Riwayat Skrining harus bisa diklik (tap)
      await tester.tap(find.text('Julia Nurul'));
      await tester.pumpAndSettle();

      // Memastikan membuka halaman HasilScreeningPage milik pasien
      expect(find.byType(HasilScreeningPage), findsOneWidget);
      expect(find.text('Skrining Penyakit'), findsOneWidget);
      expect(find.text('75%'), findsWidgets);
      expect(find.text('risiko sedang'), findsWidgets);
      expect(find.text('Penjelasan Hasil'), findsOneWidget);
      expect(find.text('Rekomendasi'), findsOneWidget);

      // Dalam mode baca (read-only), tombol aksi pasien tidak muncul
      expect(find.text('Skrining Ulang'), findsNothing);
      expect(find.text('Konsultasi Dokter'), findsNothing);

      // Kembali ke riwayat
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Pasien'), findsOneWidget);

      // Beralih ke tab Konsultasi
      await tester.tap(find.text('Konsultasi'));
      await tester.pumpAndSettle();

      // Memastikan riwayat konsultasi juga menampilkan Nama Pasien
      expect(find.text('Nama Pasien: '), findsWidgets);
    });
  });
}
