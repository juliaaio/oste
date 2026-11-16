import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model tunggal dan terpadu untuk data dokter di OSTEOCARE.
/// Digunakan bersama oleh POV Admin (CRUD & Manajemen Dokter)
/// dan POV Pasien (Daftar Dokter, Profil, Jadwal, Rating, dan Konsultasi).
class DoctorModel {
  final String id;
  final String name;
  final String specialist;
  final String imageUrl;
  final String biography;
  final String email;
  final String phone;
  final String schedules;
  final double rating;
  final int reviewCount;
  final int patientCount;
  final bool isActive;
  final bool isOnline;
  final int experienceYears;
  final String hospital;
  final List<String> availableDays;
  final List<String> todaySchedule;
  final int consultationFee;
  final String consultationFeeFormatted;

  const DoctorModel({
    required this.id,
    required this.name,
    String? specialist,
    String? speciality,
    double? rating,
    bool? isOnline,
    String? imageUrl,
    String? photo,
    int? experienceYears,
    int? experience,
    int? patientCount,
    int? reviewCount,
    String? hospital,
    String? practicePlace,
    String? biography,
    String? about,
    this.email = '',
    this.phone = '',
    this.consultationFee = 50000,
    this.consultationFeeFormatted = 'Rp 50.000',
    String? schedules,
    String? schedule,
    List<String>? todaySchedule,
    List<String>? availableHours,
    this.availableDays = const [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat'
    ],
    this.isActive = true,
  })  : specialist = specialist ?? speciality ?? 'Sp. Orthopaedi & Traumatologi',
        imageUrl = imageUrl ??
            photo ??
            'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=400&q=80',
        rating = rating ?? 4.8,
        isOnline = isOnline ?? false,
        experienceYears = experienceYears ?? experience ?? 8,
        patientCount = patientCount ?? reviewCount ?? 1000,
        reviewCount = reviewCount ?? patientCount ?? 1000,
        hospital = hospital ?? practicePlace ?? 'RS Orthopedi & Traumatologi',
        biography = biography ??
            about ??
            'Dokter spesialis ortopedi berpengalaman dalam penanganan kesehatan tulang, sendi, dan pencegahan osteoporosis.',
        schedules = schedules ?? schedule ?? 'Senin - Jumat, 09:00 - 16:00',
        todaySchedule = availableHours ??
            todaySchedule ??
            const ['09.00', '13.00', '19.00'];

  // ===========================================================================
  // ALIAS GETTER UNTUK KONSISTENSI DUA ARAH (ADMIN & PASIEN)
  // ===========================================================================

  /// Alias speciality <-> specialist
  String get speciality => specialist;

  /// Alias photo <-> imageUrl
  String get photo => imageUrl;

  /// Alias about <-> biography
  String get about => biography;

  /// Alias schedule <-> schedules
  String get schedule => schedules;

  /// Alias experience <-> experienceYears
  int get experience => experienceYears;

  /// Alias practicePlace <-> hospital
  String get practicePlace => hospital;

  /// Alias availableHours <-> todaySchedule
  List<String> get availableHours => todaySchedule;

  /// Format tarif konsultasi
  String get feeFormatted => consultationFeeFormatted.isNotEmpty
      ? consultationFeeFormatted
      : 'Rp ${consultationFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  // ===========================================================================
  // COPYWITH, TO MAP, & FACTORY CONSTRUCTORS
  // ===========================================================================

  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialist,
    String? speciality,
    double? rating,
    bool? isOnline,
    String? imageUrl,
    String? photo,
    int? experienceYears,
    int? experience,
    int? patientCount,
    int? reviewCount,
    String? hospital,
    String? practicePlace,
    String? biography,
    String? about,
    String? email,
    String? phone,
    int? consultationFee,
    String? consultationFeeFormatted,
    String? schedules,
    String? schedule,
    List<String>? todaySchedule,
    List<String>? availableHours,
    List<String>? availableDays,
    bool? isActive,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialist: specialist ?? speciality ?? this.specialist,
      rating: rating ?? this.rating,
      isOnline: isOnline ?? this.isOnline,
      imageUrl: imageUrl ?? photo ?? this.imageUrl,
      experienceYears: experienceYears ?? experience ?? this.experienceYears,
      patientCount: patientCount ?? this.patientCount,
      reviewCount: reviewCount ?? this.reviewCount,
      hospital: hospital ?? practicePlace ?? this.hospital,
      biography: biography ?? about ?? this.biography,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      consultationFee: consultationFee ?? this.consultationFee,
      consultationFeeFormatted:
          consultationFeeFormatted ?? this.consultationFeeFormatted,
      schedules: schedules ?? schedule ?? this.schedules,
      todaySchedule: availableHours ?? todaySchedule ?? this.todaySchedule,
      availableDays: availableDays ?? this.availableDays,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialist': specialist,
      'speciality': specialist,
      'imageUrl': imageUrl,
      'photo': imageUrl,
      'rating': rating,
      'isOnline': isOnline,
      'experienceYears': experienceYears,
      'experience': experienceYears,
      'patientCount': patientCount,
      'reviewCount': reviewCount,
      'hospital': hospital,
      'practicePlace': hospital,
      'biography': biography,
      'about': biography,
      'email': email,
      'phone': phone,
      'consultationFee': consultationFee,
      'consultationFeeFormatted': consultationFeeFormatted,
      'schedules': schedules,
      'schedule': schedules,
      'todaySchedule': todaySchedule,
      'availableHours': todaySchedule,
      'availableDays': availableDays,
      'isActive': isActive,
    };
  }

  factory DoctorModel.fromMap(String id, Map<String, dynamic> map) {
    return DoctorModel(
      id: id,
      name: (map['name'] as String? ?? '').trim(),
      specialist: (map['specialist'] as String? ??
              map['speciality'] as String? ??
              'Sp. Orthopaedi & Traumatologi')
          .trim(),
      imageUrl: (map['imageUrl'] as String? ??
              map['photo'] as String? ??
              'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=400&q=80')
          .trim(),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      isOnline: map['isOnline'] as bool? ?? false,
      experienceYears: (map['experienceYears'] as num? ??
              map['experience'] as num? ??
              8)
          .toInt(),
      patientCount: (map['patientCount'] as num? ??
              map['reviewCount'] as num? ??
              1000)
          .toInt(),
      reviewCount: (map['reviewCount'] as num? ??
              map['patientCount'] as num? ??
              1000)
          .toInt(),
      hospital: (map['hospital'] as String? ??
              map['practicePlace'] as String? ??
              'RS Orthopedi & Traumatologi')
          .trim(),
      biography: (map['biography'] as String? ??
              map['about'] as String? ??
              'Dokter spesialis ortopedi berpengalaman dalam penanganan kesehatan tulang, sendi, dan pencegahan osteoporosis.')
          .trim(),
      email: (map['email'] as String? ?? '').trim(),
      phone: (map['phone'] as String? ?? '').trim(),
      consultationFee: (map['consultationFee'] as num?)?.toInt() ?? 50000,
      consultationFeeFormatted:
          (map['consultationFeeFormatted'] as String? ?? 'Rp 50.000').trim(),
      schedules: (map['schedules'] as String? ??
              map['schedule'] as String? ??
              'Senin - Jumat, 09:00 - 16:00')
          .trim(),
      todaySchedule: (map['todaySchedule'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (map['availableHours'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['09.00', '13.00', '19.00'],
      availableDays: (map['availableDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'],
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return DoctorModel.fromMap(doc.id, data);
  }
}

/// Type alias untuk mempertahankan kompatibilitas kode dokter yang lama
typedef Doctor = DoctorModel;
