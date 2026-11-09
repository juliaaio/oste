import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/doctor_dashboard/doctor_dashboard_page.dart';
import 'package:oste/models/user_model.dart';
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
  });
}
