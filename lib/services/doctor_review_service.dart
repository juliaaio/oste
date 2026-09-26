import 'package:flutter/foundation.dart';
import 'package:oste/models/doctor_review_model.dart';

/// Layanan singleton reaktif untuk mengelola ulasan dokter
class DoctorReviewService extends ChangeNotifier {
  static final DoctorReviewService _instance = DoctorReviewService._internal();

  factory DoctorReviewService() => _instance;

  DoctorReviewService._internal() {
    _seedInitialReviews();
  }

  final List<DoctorReview> _reviews = [];

  /// Mengambil semua ulasan untuk dokter tertentu, diurutkan dari yang terbaru
  List<DoctorReview> getReviewsForDoctor(String doctorId) {
    return _reviews.where((r) => r.doctorId == doctorId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Mengambil jumlah ulasan untuk dokter tertentu
  int getReviewCount(String doctorId) {
    return _reviews.where((r) => r.doctorId == doctorId).length;
  }

  /// Menghitung rating rata-rata untuk dokter tertentu (skala 0.0 - 5.0)
  double getAverageRating(String doctorId) {
    final doctorReviews =
        _reviews.where((r) => r.doctorId == doctorId).toList();
    if (doctorReviews.isEmpty) return 0.0;
    final total = doctorReviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    final avg = total / doctorReviews.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  /// Menghitung persentase distribusi bintang 1-5 untuk dokter tertentu
  Map<int, double> getStarDistributionPercentages(String doctorId) {
    final doctorReviews =
        _reviews.where((r) => r.doctorId == doctorId).toList();
    if (doctorReviews.isEmpty) {
      return {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
    }

    final total = doctorReviews.length;
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in doctorReviews) {
      final roundedStar = review.rating.round().clamp(1, 5);
      counts[roundedStar] = (counts[roundedStar] ?? 0) + 1;
    }

    final Map<int, double> percentages = {};
    counts.forEach((star, count) {
      percentages[star] = (count / total) * 100.0;
    });

    return percentages;
  }

  /// Menambahkan ulasan baru
  void addReview(DoctorReview review) {
    _reviews.insert(0, review);
    notifyListeners();
  }

  /// Inisialisasi data bawaan untuk dokter
  void _seedInitialReviews() {
    final now = DateTime.now();

    // ── Ulasan untuk doc_1 (dr. Andi Wijaya, Sp.OT) ──
    // 5 Ulasan utama persis seperti pada desain referensi:
    _reviews.addAll([
      DoctorReview(
        reviewId: 'rev_andi_1',
        doctorId: 'doc_1',
        patientId: 'patient_sinta',
        patientName: 'Sinta A.',
        rating: 5.0,
        comment:
            'Dokternya sangat ramah dan penjelasannya mudah dipahami. Penanganannya juga sangat baik.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      DoctorReview(
        reviewId: 'rev_andi_2',
        doctorId: 'doc_1',
        patientId: 'patient_rizky',
        patientName: 'Rizky M.',
        rating: 5.0,
        comment:
            'Pelayanan sangat baik, dokter menjelaskan kondisi dengan detail dan sabar. Highly recommended!',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      DoctorReview(
        reviewId: 'rev_andi_3',
        doctorId: 'doc_1',
        patientId: 'patient_lina',
        patientName: 'Lina P.',
        rating: 5.0,
        comment:
            'Konsultasi berjalan nyaman dan jelas. Dokter sangat perhatian dengan keluhan pasien.',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      DoctorReview(
        reviewId: 'rev_andi_4',
        doctorId: 'doc_1',
        patientId: 'patient_dewi',
        patientName: 'Dewi K.',
        rating: 4.0,
        comment:
            'Penjelasan sangat membantu, diberikan latihan yang sesuai dengan kondisi saya.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      DoctorReview(
        reviewId: 'rev_andi_5',
        doctorId: 'doc_1',
        patientId: 'patient_budi',
        patientName: 'Budi H.',
        rating: 5.0,
        comment: 'Sangat profesional dan ramah. Terima kasih dokter!',
        createdAt: now.subtract(const Duration(days: 31)),
      ),
    ]);

    // Tambahan 115 ulasan historis untuk doc_1 agar total mencapai tepat 120 ulasan
    // dengan distribusi persis desain referensi: 92% (5 bintang), 6% (4 bintang), 2% (3 bintang)
    // 4 review bintang 5 + 1 review bintang 4 sudah ditambahkan di atas.
    // Kita tambahkan 106 bintang 5, 6 bintang 4, dan 3 bintang 3.
    // Total bintang 5: 4 + 106 = 110 (91.67% -> 92%)
    // Total bintang 4: 1 + 6 = 7 (5.83% -> 6%)
    // Total bintang 3: 3 (2.5% -> 2%)
    // Total: 120 ulasan. Rata-rata: (110*5 + 7*4 + 3*3)/120 = 587/120 = 4.8916 -> 4.9!
    for (int i = 0; i < 106; i++) {
      _reviews.add(
        DoctorReview(
          reviewId: 'rev_andi_gen_5_$i',
          doctorId: 'doc_1',
          patientId: 'patient_hist_5_$i',
          patientName: 'Pasien ${i + 6}',
          rating: 5.0,
          comment: 'Sangat puas dengan konsultasi dan penjelasannya.',
          createdAt: now.subtract(Duration(days: 35 + (i * 2))),
        ),
      );
    }
    for (int i = 0; i < 6; i++) {
      _reviews.add(
        DoctorReview(
          reviewId: 'rev_andi_gen_4_$i',
          doctorId: 'doc_1',
          patientId: 'patient_hist_4_$i',
          patientName: 'Pasien B4_${i + 1}',
          rating: 4.0,
          comment: 'Pelayanan baik dan ramah.',
          createdAt: now.subtract(Duration(days: 40 + (i * 5))),
        ),
      );
    }
    for (int i = 0; i < 3; i++) {
      _reviews.add(
        DoctorReview(
          reviewId: 'rev_andi_gen_3_$i',
          doctorId: 'doc_1',
          patientId: 'patient_hist_3_$i',
          patientName: 'Pasien B3_${i + 1}',
          rating: 3.0,
          comment: 'Cukup membantu untuk konsultasi awal.',
          createdAt: now.subtract(Duration(days: 50 + (i * 7))),
        ),
      );
    }

    // ── Ulasan untuk doc_2 (dr. Edwin Ardianta) ──
    _reviews.addAll([
      DoctorReview(
        reviewId: 'rev_edwin_1',
        doctorId: 'doc_2',
        patientId: 'patient_ahmad',
        patientName: 'Ahmad S.',
        rating: 5.0,
        comment: 'Sangat teliti dalam pemeriksaan lutut dan panggul saya.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      DoctorReview(
        reviewId: 'rev_edwin_2',
        doctorId: 'doc_2',
        patientId: 'patient_yuni',
        patientName: 'Yuni W.',
        rating: 5.0,
        comment: 'Dokter Edwin sangat sabar mendengarkan keluhan orang tua saya.',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      DoctorReview(
        reviewId: 'rev_edwin_3',
        doctorId: 'doc_2',
        patientId: 'patient_fajar',
        patientName: 'Fajar K.',
        rating: 5.0,
        comment: 'Penjelasan mengenai rekonstruksi sendi sangat detail dan menenangkan.',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      DoctorReview(
        reviewId: 'rev_edwin_4',
        doctorId: 'doc_2',
        patientId: 'patient_hendra',
        patientName: 'Hendra M.',
        rating: 5.0,
        comment: 'Operasi panggul ibu saya berjalan lancar berkat penanganan dr. Edwin.',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      DoctorReview(
        reviewId: 'rev_edwin_5',
        doctorId: 'doc_2',
        patientId: 'patient_ratna',
        patientName: 'Ratna D.',
        rating: 4.0,
        comment: 'Pelayanan sangat memuaskan, antrean agak ramai tapi sebanding.',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ]);

    // ── Ulasan untuk doc_3 (dr. Hanna Widiana) ──
    _reviews.addAll([
      DoctorReview(
        reviewId: 'rev_hanna_1',
        doctorId: 'doc_3',
        patientId: 'patient_anisa',
        patientName: 'Anisa R.',
        rating: 5.0,
        comment: 'Edukasi pencegahan osteoporosis sejak dini sangat membuka wawasan saya.',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      DoctorReview(
        reviewId: 'rev_hanna_2',
        doctorId: 'doc_3',
        patientId: 'patient_ratih',
        patientName: 'Ratih M.',
        rating: 5.0,
        comment: 'Dokter sangat ramah dan responsif saat sesi konsultasi berlangsung.',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      DoctorReview(
        reviewId: 'rev_hanna_3',
        doctorId: 'doc_3',
        patientId: 'patient_donny',
        patientName: 'Donny P.',
        rating: 5.0,
        comment: 'Saran penanganan patah tulang kerapuhan sangat tepat dan bertahap.',
        createdAt: now.subtract(const Duration(days: 22)),
      ),
      DoctorReview(
        reviewId: 'rev_hanna_4',
        doctorId: 'doc_3',
        patientId: 'patient_mega',
        patientName: 'Mega W.',
        rating: 5.0,
        comment: 'Sangat komunikatif dan solutif untuk masalah kepadatan tulang wanita.',
        createdAt: now.subtract(const Duration(days: 26)),
      ),
      DoctorReview(
        reviewId: 'rev_hanna_5',
        doctorId: 'doc_3',
        patientId: 'patient_taufiq',
        patientName: 'Taufiq L.',
        rating: 4.0,
        comment: 'Penjelasan baik, saran suplemen kalsium membantu proses pemulihan.',
        createdAt: now.subtract(const Duration(days: 32)),
      ),
    ]);

    // ── Ulasan untuk doc_4 (dr. Dian Amelia) ──
    _reviews.addAll([
      DoctorReview(
        reviewId: 'rev_dian_1',
        doctorId: 'doc_4',
        patientId: 'patient_nurul',
        patientName: 'Nurul H.',
        rating: 5.0,
        comment: 'Rekomendasi suplemen kalsium dan vitamin D dari dokter sangat cocok untuk saya.',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      DoctorReview(
        reviewId: 'rev_dian_2',
        doctorId: 'doc_4',
        patientId: 'patient_maya',
        patientName: 'Maya T.',
        rating: 5.0,
        comment: 'Konsultasi osteopenia sangat memuaskan, dokternya komunikatif sekali.',
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      DoctorReview(
        reviewId: 'rev_dian_3',
        doctorId: 'doc_4',
        patientId: 'patient_tari',
        patientName: 'Tari A.',
        rating: 5.0,
        comment: 'Dokter Dian sangat detail dan sabar menjawab pertanyaan saya.',
        createdAt: now.subtract(const Duration(days: 24)),
      ),
      DoctorReview(
        reviewId: 'rev_dian_4',
        doctorId: 'doc_4',
        patientId: 'patient_indah',
        patientName: 'Indah P.',
        rating: 5.0,
        comment: 'Penjelasan gaya hidup sehat tulang sangat aplikatif.',
        createdAt: now.subtract(const Duration(days: 29)),
      ),
      DoctorReview(
        reviewId: 'rev_dian_5',
        doctorId: 'doc_4',
        patientId: 'patient_widya',
        patientName: 'Widya S.',
        rating: 4.0,
        comment: 'Sangat membantu dan ramah dalam memberikan konsultasi.',
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ]);

    // ── Ulasan untuk doc_5 (dr. Martin Hartono) ──
    _reviews.addAll([
      DoctorReview(
        reviewId: 'rev_martin_1',
        doctorId: 'doc_5',
        patientId: 'patient_indra',
        patientName: 'Indra B.',
        rating: 5.0,
        comment: 'Sangat ahli di bidang ortopedi anak, anak saya merasa nyaman diperiksa.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_2',
        doctorId: 'doc_5',
        patientId: 'patient_citra',
        patientName: 'Citra K.',
        rating: 5.0,
        comment: 'Penjelasan tentang kelainan pertumbuhan tulang sangat lengkap dan jelas.',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_3',
        doctorId: 'doc_5',
        patientId: 'patient_bayu',
        patientName: 'Bayu R.',
        rating: 5.0,
        comment: 'Dokter sangat mengayomi pasien anak, penanganannya profesional.',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_4',
        doctorId: 'doc_5',
        patientId: 'patient_desi',
        patientName: 'Desi F.',
        rating: 5.0,
        comment: 'Saran pencegahan osteoporosis keluarga sangat bermanfaat.',
        createdAt: now.subtract(const Duration(days: 21)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_5',
        doctorId: 'doc_5',
        patientId: 'patient_eko',
        patientName: 'Eko W.',
        rating: 5.0,
        comment: 'Pemeriksaan menyeluruh dan diagnosa akurat.',
        createdAt: now.subtract(const Duration(days: 27)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_6',
        doctorId: 'doc_5',
        patientId: 'patient_gina',
        patientName: 'Gina M.',
        rating: 5.0,
        comment: 'Dokter Martin sangat komunikatif dan informatif.',
        createdAt: now.subtract(const Duration(days: 31)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_7',
        doctorId: 'doc_5',
        patientId: 'patient_hari',
        patientName: 'Hari T.',
        rating: 5.0,
        comment: 'Penanganan skoliosis anak saya terpantau membaik dengan arahan beliau.',
        createdAt: now.subtract(const Duration(days: 36)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_8',
        doctorId: 'doc_5',
        patientId: 'patient_irma',
        patientName: 'Irma L.',
        rating: 5.0,
        comment: 'Sangat recommended untuk konsultasi tulang anak.',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_9',
        doctorId: 'doc_5',
        patientId: 'patient_joko',
        patientName: 'Joko P.',
        rating: 5.0,
        comment: 'Dokter berpengalaman dan sangat ramah.',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      DoctorReview(
        reviewId: 'rev_martin_10',
        doctorId: 'doc_5',
        patientId: 'patient_kartika',
        patientName: 'Kartika N.',
        rating: 4.0,
        comment: 'Konsultasi memuaskan dan solutif.',
        createdAt: now.subtract(const Duration(days: 50)),
      ),
    ]);
  }
}
