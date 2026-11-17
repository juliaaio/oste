import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/consultation/doctor_profile_page.dart';
import 'package:oste/features/consultation/doctor_review_page.dart';
import 'package:oste/features/consultation/write_review_page.dart';
import 'package:oste/models/doctor_review_model.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/doctor_review_service.dart';
import 'package:oste/services/user_service.dart';

void main() {
  final testDoctor = doctorList[0]; // doc_1
  final testUser = UserModel(
    uid: 'user_tester_99',
    name: 'Budi Test',
    email: 'budi@test.com',
    role: 'patient',
  );

  setUp(() {
    UserService().setCurrentUserForTesting(testUser);
  });

  tearDown(() {
    UserService().setCurrentUserForTesting(null);
  });

  test('DoctorReview model serializes and deserializes to/from Firestore format with userId as ID', () {
    final now = DateTime.now();
    final review = DoctorReview(
      userId: 'user_123',
      doctorId: 'doc_1',
      userName: 'Siti Rahma',
      userPhoto: 'https://example.com/photo.png',
      rating: 4.5,
      comment: 'Pelayanan sangat bagus dan ramah.',
      createdAt: now,
      updatedAt: now,
    );

    expect(review.userId, 'user_123');
    expect(review.patientId, 'user_123');
    expect(review.userName, 'Siti Rahma');
    expect(review.patientName, 'Siti Rahma');
    expect(review.rating, 4.5);

    final map = review.toFirestore();
    expect(map['userId'], 'user_123');
    expect(map['userName'], 'Siti Rahma');
    expect(map['rating'], 4.5);
    expect(map['comment'], 'Pelayanan sangat bagus dan ramah.');

    final fromMap = DoctorReview.fromMap(map, 'user_123', 'doc_1');
    expect(fromMap.userId, 'user_123');
    expect(fromMap.userName, 'Siti Rahma');
    expect(fromMap.rating, 4.5);
    expect(fromMap.comment, 'Pelayanan sangat bagus dan ramah.');
  });

  test('DoctorReviewService enforces 1 review per user and updates without duplicating', () async {
    final service = DoctorReviewService();
    const docId = 'doc_test_unique';
    const uId = 'user_alpha';

    // 1. Simpan ulasan baru
    final isNew = await service.saveOrUpdateReview(
      doctorId: docId,
      userId: uId,
      userName: 'Alpha',
      rating: 5.0,
      comment: 'Ulasan pertama kali',
    );
    expect(isNew, isTrue);
    expect(service.getReviewCount(docId), 1);
    expect(service.getAverageRating(docId), 5.0);

    // 2. Perbarui ulasan yang sama oleh user yang sama
    final isUpdated = await service.saveOrUpdateReview(
      doctorId: docId,
      userId: uId,
      userName: 'Alpha Updated',
      rating: 4.0,
      comment: 'Ulasan diedit jadi bintang 4',
    );
    expect(isUpdated, isFalse);
    expect(service.getReviewCount(docId), 1, reason: 'Jumlah review tidak boleh bertambah');
    expect(service.getAverageRating(docId), 4.0, reason: 'Rating rata-rata harus terhitung otomatis');

    final updated = await service.getUserReview(docId, uId);
    expect(updated?.comment, 'Ulasan diedit jadi bintang 4');
    expect(updated?.rating, 4.0);
    expect(updated?.userName, 'Alpha Updated');
  });

  test('DoctorReview formattedDate and timeAgo provide clean date formatting', () {
    final fixedDate = DateTime(2026, 5, 20);
    final review = DoctorReview(
      userId: 'u_1',
      doctorId: 'd_1',
      userName: 'John Doe',
      rating: 5.0,
      comment: 'Bagus',
      createdAt: fixedDate,
    );

    expect(review.formattedDate, '20 Mei 2026');
    expect(review.timeAgo, isNotEmpty);
  });

  testWidgets('WriteReviewPage displays empty form for new review and switches to Perbarui Ulasan when existing review exists', (tester) async {
    final service = DoctorReviewService();
    const docId = 'doc_ui_test';
    final uId = testUser.uid;

    // A. User belum pernah review -> form kosong & tombol Simpan
    await tester.pumpWidget(
      MaterialApp(
        home: WriteReviewPage(
          doctor: testDoctor.copyWith(id: docId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beri Ulasan'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    final textFieldFinder = find.byType(TextField);
    expect(tester.widget<TextField>(textFieldFinder).controller?.text, '');

    // B. User sudah pernah review -> form prefilled & tombol Perbarui Ulasan
    await service.saveOrUpdateReview(
      doctorId: docId,
      userId: uId,
      userName: testUser.name,
      rating: 4.0,
      comment: 'Komentar sebelumnya',
    );

    final existingReview = await service.getUserReview(docId, uId);

    await tester.pumpWidget(
      MaterialApp(
        home: WriteReviewPage(
          key: const ValueKey('edit_page'),
          doctor: testDoctor.copyWith(id: docId),
          existingReview: existingReview,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perbarui Ulasan'), findsWidgets);
    expect(find.text('Komentar sebelumnya'), findsOneWidget);
  });

  testWidgets('Submitting review updates list and displays correct SnackBar message', (tester) async {
    final service = DoctorReviewService();
    const docId = 'doc_submit_test';
    final uId = testUser.uid;

    // Gunakan Navigator dengan 2 rute agar Navigator.pop() kembali ke parent Scaffold
    // dan SnackBar dapat diobservasi pada ScaffoldMessenger.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WriteReviewPage(
                      doctor: testDoctor.copyWith(id: docId),
                    ),
                  ),
                );
              },
              child: const Text('Open Review'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Simpan review baru
    await tester.tap(find.text('Open Review'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Dokter sangat membantu');
    await tester.tap(find.widgetWithText(InkWell, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Ulasan berhasil disimpan.'), findsOneWidget);
    expect(service.getReviewCount(docId), 1);

    // Pastikan snackbar lama hilang sebelum melangkah ke test berikutnya
    tester.binding.scheduleFrame();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. Buka lagi dan update review yang sama
    final existing = await service.getUserReview(docId, uId);
    expect(existing, isNotNull);

    await tester.tap(find.text('Open Review'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Dokter sangat membantu (diedit)');
    await tester.tap(find.widgetWithText(InkWell, 'Perbarui Ulasan'));
    await tester.pumpAndSettle();

    expect(find.text('Ulasan berhasil diperbarui.'), findsOneWidget);
    expect(service.getReviewCount(docId), 1, reason: 'Tetap 1 ulasan untuk user yang sama');
  });

  testWidgets('DoctorReviewPage renders reviews and auto-calculates average rating and review count', (tester) async {
    final service = DoctorReviewService();
    const docId = 'doc_page_calc_test';

    // Tambah 2 ulasan
    await service.saveOrUpdateReview(
      doctorId: docId,
      userId: 'user_1',
      userName: 'Pasien 1',
      rating: 5.0,
      comment: 'Bagus sekali',
    );
    await service.saveOrUpdateReview(
      doctorId: docId,
      userId: 'user_2',
      userName: 'Pasien 2',
      rating: 3.0,
      comment: 'Cukup bagus',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DoctorReviewPage(
          doctor: testDoctor.copyWith(id: docId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Rata-rata (5.0 + 3.0) / 2 = 4.0
    expect(find.text('4.0'), findsOneWidget);
    // Jumlah ulasan: 2
    expect(find.text('Berdasarkan\n2 ulasan'), findsOneWidget);
    // Konten ulasan ditampilkan
    expect(find.text('Bagus sekali'), findsOneWidget);
    expect(find.text('Cukup bagus'), findsOneWidget);
  });

  testWidgets('Validation prevents submitting review with comment under 10 chars or over 500 chars', (tester) async {
    const docId = 'doc_validation_test';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WriteReviewPage(
            doctor: testDoctor.copyWith(id: docId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Komentar terlalu pendek (< 10 karakter)
    await tester.enterText(find.byType(TextField), 'Pendek');
    await tester.tap(find.widgetWithText(InkWell, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Komentar ulasan minimal 10 karakter.'), findsOneWidget);

    // Tunggu SnackBar pertama hilang
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. Komentar terlalu panjang (> 500 karakter)
    final longComment = 'A' * 501;
    await tester.enterText(find.byType(TextField), longComment);
    await tester.tap(find.widgetWithText(InkWell, 'Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Komentar ulasan maksimal 500 karakter.'), findsOneWidget);
  });

  testWidgets('Empty reviews state displays "—" and "Belum ada ulasan" without dummy rating fallback', (tester) async {
    const docId = 'doc_empty_test';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DoctorProfilePage(
            doctor: testDoctor.copyWith(id: docId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('—'), findsOneWidget);
    expect(find.text('Belum ada ulasan'), findsOneWidget);
  });
}
