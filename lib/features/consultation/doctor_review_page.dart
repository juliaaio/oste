import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/features/consultation/write_review_page.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/models/doctor_review_model.dart';
import 'package:oste/services/doctor_review_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Ulasan Pasien untuk Dokter
class DoctorReviewPage extends StatelessWidget {
  final Doctor? doctor;

  const DoctorReviewPage({
    super.key,
    this.doctor,
  });

  static const Color _background = Color(0xFFFFF9EF);
  static const Color _butterYellow = Color(0xFFF7C948);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _starAmber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    // Gunakan dokter yang diterima atau fallback ke dokter pertama
    final currentDoctor = doctor ?? doctorList[0];
    final reviewService = DoctorReviewService();
    final userService = UserService();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textDark,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Ulasan Pasien',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: reviewService,
          builder: (context, _) {
            final reviews = reviewService.getReviewsForDoctor(currentDoctor.id);
            final reviewCount = reviewService.getReviewCount(currentDoctor.id);
            final avgRating = reviewService.getAverageRating(currentDoctor.id);
            final distribution =
                reviewService.getStarDistributionPercentages(currentDoctor.id);

            return ListenableBuilder(
              listenable: userService,
              builder: (context, _) {
                final currentUser = userService.currentUser;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Card Ringkasan Rating ─────────────────────────────
                      _buildRatingSummaryCard(
                        avgRating: avgRating,
                        reviewCount: reviewCount,
                        distribution: distribution,
                      ),
                      const SizedBox(height: 16),

                      // ── 2. Tombol Besar "Beri Ulasan" ───────────────────────
                      _buildAddReviewButton(context, currentDoctor),
                      const SizedBox(height: 18),

                      // ── 3. Daftar Ulasan Pasien ──────────────────────────────
                      if (reviews.isEmpty)
                        _buildEmptyReviewState()
                      else
                        ...reviews.map(
                          (review) => _buildReviewItem(
                            review: review,
                            currentUser: currentUser,
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Card Ringkasan Rating (Rata-rata, Jumlah ulasan, dan Distribusi Bintang 5 - 1)
  Widget _buildRatingSummaryCard({
    required double avgRating,
    required int reviewCount,
    required Map<int, double> distribution,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sisi Kiri: Bintang Besar, Angka Rating, dan Jumlah Ulasan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 38,
                    color: _starAmber,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    avgRating == 0.0 ? '0.0' : avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Berdasarkan\n$reviewCount ulasan',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 22),

          // Sisi Kanan: Distribusi Bintang 5 sampai 1
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int star = 5; star >= 1; star--) ...[
                  _buildDistributionRow(
                    star: star,
                    percentage: distribution[star] ?? 0.0,
                  ),
                  if (star > 1) const SizedBox(height: 5),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Satu baris distribusi bintang dengan progress bar persentase
  Widget _buildDistributionRow({
    required int star,
    required double percentage,
  }) {
    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textMuted,
          ),
        ),
        const SizedBox(width: 3),
        const Icon(
          Icons.star_rounded,
          size: 13,
          color: _starAmber,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6.5,
              color: const Color(0xFFF1F5F9),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _butterYellow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 30,
          child: Text(
            '${percentage.round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ),
      ],
    );
  }

  /// Tombol Besar "Beri Ulasan"
  Widget _buildAddReviewButton(BuildContext context, Doctor currentDoctor) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: _butterYellow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _butterYellow.withValues(alpha: 0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WriteReviewPage(doctor: currentDoctor),
              ),
            );
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mode_edit_outline_rounded,
                  size: 20,
                  color: _textDark,
                ),
                SizedBox(width: 8),
                Text(
                  'Beri Ulasan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tampilan jika belum ada ulasan
  Widget _buildEmptyReviewState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Ulasan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Jadilah yang pertama memberikan ulasan untuk dokter ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Item Ulasan Pasien
  Widget _buildReviewItem({
    required DoctorReview review,
    required dynamic currentUser,
  }) {
    // Sinkronisasi dengan user yang sedang login jika review ditulis oleh user saat ini
    final bool isCurrentUser = currentUser != null &&
        (review.patientId == currentUser.uid ||
            review.patientId == 'patient_current');

    final String displayName = isCurrentUser
        ? (currentUser.name.isNotEmpty ? currentUser.name : review.patientName)
        : review.patientName;

    final String? photoUrl = isCurrentUser
        ? (FirebaseAuth.instance.currentUser?.photoURL ?? review.patientPhoto)
        : review.patientPhoto;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Pemberi Ulasan (Sesuai sistem profil Osteo)
          _buildAvatar(displayName, photoUrl),
          const SizedBox(width: 14),

          // Detail Ulasan: Nama, Waktu, Bintang, dan Isi Komentar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      review.timeAgo,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Baris Bintang Rating (1-5)
                Row(
                  children: List.generate(5, (starIndex) {
                    final isFilled = (starIndex + 1) <= review.rating.round();
                    return Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        isFilled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: isFilled
                            ? _starAmber
                            : const Color(0xFFCBD5E1),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),

                // Isi Komentar Ulasan
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar pemberi ulasan:
  /// - Jika sudah memiliki foto: tampilkan foto profil.
  /// - Jika belum memiliki foto: avatar lingkaran butter yellow (#F7C948)
  ///   dengan huruf pertama nama (uppercase), tulisan putih, bold, di tengah.
  Widget _buildAvatar(String name, String? photoUrl) {
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildLetterAvatar(name),
          ),
        ),
      );
    }

    return _buildLetterAvatar(name);
  }

  /// Avatar default huruf pertama nama
  Widget _buildLetterAvatar(String name) {
    final String letter = (name.trim().isNotEmpty)
        ? name.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _butterYellow,
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
