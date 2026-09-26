/// Model data untuk ulasan pasien terhadap dokter
class DoctorReview {
  final String reviewId;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String? patientPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const DoctorReview({
    required this.reviewId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    this.patientPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Format waktu relatif dalam bahasa Indonesia
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  DoctorReview copyWith({
    String? reviewId,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? patientPhoto,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return DoctorReview(
      reviewId: reviewId ?? this.reviewId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhoto: patientPhoto ?? this.patientPhoto,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
