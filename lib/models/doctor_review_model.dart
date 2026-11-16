import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data untuk ulasan pasien terhadap dokter pada Firestore:
/// doctors/{doctorId}/reviews/{userId}
class DoctorReview {
  final String userId;
  final String doctorId;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorReview({
    String? userId,
    required this.doctorId,
    String? userName,
    String? userPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    // Parameter kompatibilitas lama
    String? patientId,
    String? patientName,
    String? patientPhoto,
    String? reviewId,
  })  : userId = userId ?? patientId ?? reviewId ?? '',
        userName = userName ?? patientName ?? 'Pasien',
        userPhoto = userPhoto ?? patientPhoto;

  /// Getter untuk kompatibilitas kode lama
  String get patientId => userId;
  String get patientName => userName;
  String? get patientPhoto => userPhoto;
  String get reviewId => userId;

  /// Deserialisasi dari dokumen Firestore
  factory DoctorReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String doctorId,
  ) {
    final data = doc.data() ?? {};
    return DoctorReview.fromMap(data, doc.id, doctorId);
  }

  /// Deserialisasi dari Map data
  factory DoctorReview.fromMap(
    Map<String, dynamic> data,
    String docId,
    String doctorId,
  ) {
    final rawCreatedAt = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    }

    final rawUpdatedAt = data['updatedAt'];
    DateTime? updatedAt;
    if (rawUpdatedAt is Timestamp) {
      updatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is DateTime) {
      updatedAt = rawUpdatedAt;
    } else if (rawUpdatedAt is int) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt);
    } else if (rawUpdatedAt is String) {
      updatedAt = DateTime.tryParse(rawUpdatedAt);
    }

    final userId = data['userId'] as String? ?? docId;
    final userName = data['userName'] as String? ??
        data['patientName'] as String? ??
        'Pasien';
    final userPhoto =
        data['userPhoto'] as String? ?? data['patientPhoto'] as String?;
    final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;
    final comment = data['comment'] as String? ?? '';

    return DoctorReview(
      userId: userId,
      doctorId: doctorId,
      userName: userName,
      userPhoto: userPhoto,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Serialisasi untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
    };
  }

  /// Format tanggal rapi dan ramah pengguna
  String get formattedDate {
    final effectiveDate = updatedAt ?? createdAt;
    const List<String> months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final day = effectiveDate.day;
    final month = months[effectiveDate.month];
    final year = effectiveDate.year;
    return '$day $month $year';
  }

  /// Format waktu relatif dalam bahasa Indonesia
  String get timeAgo {
    final now = DateTime.now();
    final effectiveDate = updatedAt ?? createdAt;
    final difference = now.difference(effectiveDate);

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
    String? userId,
    String? doctorId,
    String? userName,
    String? userPhoto,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reviewId,
    String? patientId,
    String? patientName,
    String? patientPhoto,
  }) {
    return DoctorReview(
      userId: userId ?? reviewId ?? patientId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      userName: userName ?? patientName ?? this.userName,
      userPhoto: userPhoto ?? patientPhoto ?? this.userPhoto,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
