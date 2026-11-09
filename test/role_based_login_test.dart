import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/admin/dashboard/admin_dashboard_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/doctor_dashboard/doctor_dashboard_page.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/user_service.dart';

void main() {
  group('Role-Based UserModel Verification Tests', () {
    test('Admin role is correctly recognized via isAdmin getter without hardcoded email', () {
      const admin1 = UserModel(
        uid: 'admin_uid_001',
        name: 'Admin Osteo',
        email: 'custom_admin_email@hospital.org',
        role: 'admin',
      );

      const admin2 = UserModel(
        uid: 'admin_uid_002',
        name: 'System Administrator',
        email: 'superadmin@domain.com',
        role: 'administrator',
      );

      expect(admin1.isAdmin, isTrue);
      expect(admin1.isDoctor, isFalse);
      expect(admin1.isPatient, isFalse);
      expect(admin1.uid, equals('admin_uid_001'));

      expect(admin2.isAdmin, isTrue);
      expect(admin2.isDoctor, isFalse);
      expect(admin2.isPatient, isFalse);
    });

    test('Patient role is default and recognized via isPatient getter', () {
      const patient = UserModel(
        uid: 'patient_uid_001',
        name: 'Siti Rahmawati',
        email: 'siti@gmail.com',
      );

      expect(patient.role, equals('patient'));
      expect(patient.isAdmin, isFalse);
      expect(patient.isDoctor, isFalse);
      expect(patient.isPatient, isTrue);
    });

    test('Doctor role is recognized via isDoctor getter', () {
      const doctor = UserModel(
        uid: 'doctor_uid_001',
        name: 'dr. Andi Sp.OT',
        email: 'andi@osteocare.com',
        role: 'doctor',
      );

      expect(doctor.isDoctor, isTrue);
      expect(doctor.isAdmin, isFalse);
      expect(doctor.isPatient, isFalse);
    });

    test('Unknown or empty role does not default to patient and hasValidRole is false', () {
      const unknownUser = UserModel(
        uid: 'unknown_uid_001',
        name: 'Unknown User',
        email: 'unknown@test.com',
        role: 'unassigned',
      );

      expect(unknownUser.isAdmin, isFalse);
      expect(unknownUser.isDoctor, isFalse);
      expect(unknownUser.isPatient, isFalse);
      expect(unknownUser.hasValidRole, isFalse);
    });

    test('Firestore serialization and deserialization preserves admin role and UID', () {
      const admin = UserModel(
        uid: 'firebase_auth_uid_xyz',
        name: 'Pengelola Osteo',
        email: 'admin.osteo@example.com',
        role: 'admin',
      );

      final map = admin.toFirestore();
      expect(map['role'], equals('admin'));
      expect(map['uid'], equals('firebase_auth_uid_xyz'));

      final fromMap = UserModel.fromMap('firebase_auth_uid_xyz', map);
      expect(fromMap.uid, equals('firebase_auth_uid_xyz'));
      expect(fromMap.role, equals('admin'));
      expect(fromMap.isAdmin, isTrue);
    });
  });

  group('Role-Based Navigation Flow Tests', () {
    tearDown(() {
      UserService().setCurrentUserForTesting(null);
    });

    testWidgets('Admin user is routed to AdminDashboardPage', (tester) async {
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'admin_test_uid',
          name: 'Admin Osteo',
          email: 'admin@osteocare.id',
          role: 'admin',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final user = UserService().currentUser;
              if (user?.isAdmin == true) {
                return const AdminDashboardPage();
              } else if (user?.isDoctor == true) {
                return const DoctorDashboardPage();
              } else {
                return const DashboardPage();
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan Dashboard Admin dirender untuk role Admin
      expect(find.byType(AdminDashboardPage), findsOneWidget);
      expect(find.text('Osteo Admin'), findsOneWidget);
      expect(find.text('Halo, Admin!'), findsOneWidget);
      expect(find.byType(DashboardPage), findsNothing);
      expect(find.byType(DoctorDashboardPage), findsNothing);
    });

    testWidgets('Patient user is routed to DashboardPage (Patient POV)', (tester) async {
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'patient_test_uid',
          name: 'Rina Marlina',
          email: 'rina@gmail.com',
          role: 'patient',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final user = UserService().currentUser;
              if (user?.isAdmin == true) {
                return const AdminDashboardPage();
              } else if (user?.isDoctor == true) {
                return const DoctorDashboardPage();
              } else {
                return const DashboardPage();
              }
            },
          ),
        ),
      );
      await tester.pump();

      // Memastikan Dashboard Pasien dirender untuk role Patient
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(AdminDashboardPage), findsNothing);
      expect(find.byType(DoctorDashboardPage), findsNothing);
    });

    testWidgets('Doctor user is routed to DoctorDashboardPage', (tester) async {
      UserService().setCurrentUserForTesting(
        const UserModel(
          uid: 'doctor_test_uid',
          name: 'dr. Intan Permata',
          email: 'intan@osteocare.com',
          role: 'doctor',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final user = UserService().currentUser;
              if (user?.isAdmin == true) {
                return const AdminDashboardPage();
              } else if (user?.isDoctor == true) {
                return const DoctorDashboardPage();
              } else {
                return const DashboardPage();
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan Dashboard Dokter dirender untuk role Doctor
      expect(find.byType(DoctorDashboardPage), findsOneWidget);
      expect(find.byType(AdminDashboardPage), findsNothing);
      expect(find.byType(DashboardPage), findsNothing);
    });
  });
}

