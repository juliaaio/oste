import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/doctor_card.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/consultation/doctor_profile_page.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/doctor_repository.dart';
import 'package:oste/services/doctor_review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Doctor Architecture Integration & POV Tests', () {
    late DoctorRepository repo;

    setUp(() {
      repo = DoctorRepository();
    });

    test('Point 8: Existing default doctors are loaded accurately with complete fields', () {
      final initialDocs = repo.allDoctors;
      expect(initialDocs.length, greaterThanOrEqualTo(5));

      final firstDoc = repo.getDoctorById('doc_1');
      expect(firstDoc, isNotNull);
      expect(firstDoc!.name, equals('dr. Andi Wijaya, Sp.OT'));
      expect(firstDoc.specialist, equals('Sp. Orthopaedi & Traumatologi'));
      expect(firstDoc.speciality, equals('Sp. Orthopaedi & Traumatologi'));
      expect(firstDoc.photo, equals(firstDoc.imageUrl));
      expect(firstDoc.experience, equals(10));
      expect(firstDoc.experienceYears, equals(10));
      expect(firstDoc.practicePlace, equals('RS Orthopedi & Traumatologi'));
      expect(firstDoc.hospital, equals('RS Orthopedi & Traumatologi'));
      expect(firstDoc.consultationFee, equals(75000));
      expect(firstDoc.isActive, isTrue);
    });

    test('Point 3: Add doctor from POV Admin reflects immediately in POV Pasien', () async {
      const newTestDoctor = DoctorModel(
        id: 'test_doc_admin_new_1',
        name: 'dr. Dokter Baru Integrasi, Sp.OT',
        specialist: 'Spesialis Rekonstruksi Tulang',
        consultationFee: 85000,
        consultationFeeFormatted: 'Rp 85.000',
        imageUrl: 'https://example.com/test_doctor.jpg',
        biography: 'Dokter pengujian integrasi baru.',
        schedules: 'Senin - Rabu, 10:00 - 15:00',
        todaySchedule: ['10.00', '13.00'],
        availableDays: ['Senin', 'Selasa', 'Rabu'],
        isActive: true,
      );

      // Admin adds doctor
      await repo.addDoctor(newTestDoctor);

      // Verify in Admin view (allDoctors)
      final adminCheck = repo.allDoctors.firstWhere((d) => d.id == newTestDoctor.id);
      expect(adminCheck.name, equals('dr. Dokter Baru Integrasi, Sp.OT'));

      // Verify in Patient view (activeDoctors & doctorList)
      final patientCheck = repo.activeDoctors.where((d) => d.id == newTestDoctor.id);
      expect(patientCheck.isNotEmpty, isTrue);
      expect(doctorList.any((d) => d.id == newTestDoctor.id), isTrue);
    });

    test('Point 4: Edit doctor name, speciality, photo, fee, and schedule syncs to Patient view', () async {
      const updatedDoctor = DoctorModel(
        id: 'test_doc_admin_new_1',
        name: 'dr. Dokter Baru Diperbarui, Sp.OT(K)',
        specialist: 'Spesialis Tulang Dewasa & Anak',
        consultationFee: 120000,
        consultationFeeFormatted: 'Rp 120.000',
        imageUrl: 'https://example.com/updated_photo.jpg',
        biography: 'Biografi dokter yang telah diperbarui.',
        schedules: 'Jumat - Sabtu, 08:00 - 12:00',
        todaySchedule: ['08.00', '11.00'],
        availableDays: ['Jumat', 'Sabtu'],
        isActive: true,
      );

      // Admin updates doctor
      await repo.updateDoctor(updatedDoctor);

      // Verify in Patient view
      final patientDoctor = repo.activeDoctors.firstWhere((d) => d.id == 'test_doc_admin_new_1');
      expect(patientDoctor.name, equals('dr. Dokter Baru Diperbarui, Sp.OT(K)'));
      expect(patientDoctor.specialist, equals('Spesialis Tulang Dewasa & Anak'));
      expect(patientDoctor.speciality, equals('Spesialis Tulang Dewasa & Anak'));
      expect(patientDoctor.imageUrl, equals('https://example.com/updated_photo.jpg'));
      expect(patientDoctor.photo, equals('https://example.com/updated_photo.jpg'));
      expect(patientDoctor.consultationFee, equals(120000));
      expect(patientDoctor.schedules, equals('Jumat - Sabtu, 08:00 - 12:00'));
      expect(patientDoctor.schedule, equals('Jumat - Sabtu, 08:00 - 12:00'));
    });

    test('Point 5: Toggle doctor active status (deactivate) hides doctor from Patient view', () async {
      // Deactivate doctor
      await repo.toggleDoctorActiveStatus('test_doc_admin_new_1');

      // Admin still sees the inactive doctor in allDoctors
      final adminCheck = repo.allDoctors.firstWhere((d) => d.id == 'test_doc_admin_new_1');
      expect(adminCheck.isActive, isFalse);

      // Patient does NOT see inactive doctor in activeDoctors or doctorList
      final patientCheck = repo.activeDoctors.where((d) => d.id == 'test_doc_admin_new_1');
      expect(patientCheck.isEmpty, isTrue);
      expect(doctorList.any((d) => d.id == 'test_doc_admin_new_1'), isFalse);
    });

    test('Point 6 & 9: Deleting doctor permanently removes doctor without dummy revival', () async {
      // Delete test doctor
      await repo.deleteDoctor('test_doc_admin_new_1');

      // Verify removed from both Admin and Patient
      expect(repo.allDoctors.any((d) => d.id == 'test_doc_admin_new_1'), isFalse);
      expect(repo.activeDoctors.any((d) => d.id == 'test_doc_admin_new_1'), isFalse);
      expect(doctorList.any((d) => d.id == 'test_doc_admin_new_1'), isFalse);
    });

    test('Point 7: Doctor reviews, rating calculation and doctor profile compatibility', () async {
      final reviewService = DoctorReviewService();
      await reviewService.saveOrUpdateReview(
        doctorId: 'doc_1',
        userId: 'user_test_1',
        userName: 'Pasien Uji',
        rating: 5.0,
        comment: 'Sangat profesional dan membantu.',
      );
      final andiReviews = reviewService.getReviewsForDoctor('doc_1');
      expect(andiReviews.isNotEmpty, isTrue);

      final rating = reviewService.getAverageRating('doc_1');
      expect(rating, greaterThan(0.0));
      expect(rating, lessThanOrEqualTo(5.0));

      final dist = reviewService.getStarDistributionPercentages('doc_1');
      expect(dist.containsKey(5), isTrue);
    });

    testWidgets('Point 2 & 7: DoctorListPage and DoctorProfilePage render with reactive model without runtime error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorListPage(),
        ),
      );
      await tester.pump();

      expect(find.byType(DoctorListPage), findsOneWidget);
      expect(find.byType(DoctorCard), findsWidgets);

      // Render profile page
      final sampleDoctor = repo.activeDoctors.first;
      await tester.pumpWidget(
        MaterialApp(
          home: DoctorProfilePage(doctor: sampleDoctor),
        ),
      );
      await tester.pump();

      expect(find.text(sampleDoctor.name), findsOneWidget);
      expect(find.text(sampleDoctor.specialist), findsOneWidget);
      expect(find.text('Chat Sekarang'), findsOneWidget);
      expect(find.text('Riwayat Konsultasi'), findsOneWidget);
    });
  });
}

