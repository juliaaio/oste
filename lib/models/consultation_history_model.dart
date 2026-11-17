import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oste/features/consultation/doctor_data.dart';
import 'package:oste/models/chat_message.dart';
import 'package:oste/models/doctor_model.dart';

/// Model representasi data riwayat konsultasi medis yang telah selesai
class ConsultationHistory {
  final String id;

  // Informasi dokter
  final String doctorId;
  final String doctorName;
  final String doctorSpecialist;
  final String doctorImageUrl;
  final String doctorHospital;
  final String doctorPhoto;

  // Informasi pasien
  final String patientId;
  final String patientName;

  // Konten konsultasi
  final String summary;
  final String diagnosis;
  final String doctorNotes;
  final String doctorRecommendation;
  final String nutritionRecommendation;
  final String followUpAdvice;

  // Pesan chat lokal/in-memory (opsional)
  final List<ChatMessage> messages;

  // Metadata percakapan & waktu
  final String chatId;
  final String consultationStatus;
  final int messageCount;
  final DateTime? createdAt;
  final DateTime? completedAt;

  // Waktu format teks untuk tampilan langsung
  final String date;
  final String time;

  final Doctor? _doctor;

  ConsultationHistory({
    required this.id,
    Doctor? doctor,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialist,
    String? doctorImageUrl,
    String? doctorHospital,
    String? doctorPhoto,
    this.patientId = '',
    this.patientName = '',
    this.summary = '',
    this.diagnosis = 'Konsultasi Selesai',
    this.doctorNotes = '',
    this.doctorRecommendation = '',
    this.nutritionRecommendation = '',
    this.followUpAdvice =
        'Lakukan kontrol berkala atau evaluasi lanjutan dalam 1-3 bulan ke depan.',
    this.messages = const [],
    this.chatId = '',
    this.consultationStatus = 'completed',
    this.messageCount = 0,
    this.createdAt,
    this.completedAt,
    String? date,
    String? time,
  })  : _doctor = doctor,
        doctorId = doctorId ?? doctor?.id ?? '',
        doctorName = doctorName ?? doctor?.name ?? '',
        doctorSpecialist = doctorSpecialist ?? doctor?.specialist ?? '',
        doctorImageUrl = doctorImageUrl ?? doctor?.imageUrl ?? doctorPhoto ?? '',
        doctorHospital = doctorHospital ?? doctor?.hospital ?? '',
        doctorPhoto = doctorPhoto ?? doctorImageUrl ?? doctor?.imageUrl ?? '',
        date = date ??
            (completedAt != null
                ? _formatDate(completedAt)
                : (createdAt != null ? _formatDate(createdAt) : _formatDate(DateTime.now()))),
        time = time ??
            (completedAt != null
                ? _formatTime(completedAt)
                : (createdAt != null ? _formatTime(createdAt) : _formatTime(DateTime.now())));

  /// Getter Doctor untuk kompatibilitas UI yang mengakses `consultation.doctor`
  Doctor get doctor {
    if (_doctor != null) return _doctor!;
    final match = doctorList.where((d) => d.id == doctorId).toList();
    if (match.isNotEmpty) {
      final d = match.first;
      if (doctorName.isNotEmpty && d.name != doctorName) {
        return d.copyWith(
          name: doctorName,
          specialist: doctorSpecialist.isNotEmpty ? doctorSpecialist : d.specialist,
          imageUrl: doctorPhoto.isNotEmpty ? doctorPhoto : d.imageUrl,
          hospital: doctorHospital.isNotEmpty ? doctorHospital : d.hospital,
        );
      }
      return d;
    }
    return Doctor(
      id: doctorId,
      name: doctorName.isNotEmpty ? doctorName : 'dr. Spesialis',
      specialist:
          doctorSpecialist.isNotEmpty ? doctorSpecialist : 'Spesialis Ortopedi',
      rating: 5.0,
      imageUrl: doctorPhoto.isNotEmpty ? doctorPhoto : doctorImageUrl,
      hospital:
          doctorHospital.isNotEmpty ? doctorHospital : 'RS Orthopedi & Traumatologi',
    );
  }

  /// Serialize ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'consultationId': id,
      'chatId': chatId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhoto': doctorPhoto.isNotEmpty ? doctorPhoto : doctorImageUrl,
      'doctorSpecialist': doctorSpecialist,
      'doctorHospital': doctorHospital,
      'patientId': patientId,
      'patientName': patientName,
      'diagnosis': diagnosis,
      'summary': summary,
      'doctorNotes': doctorNotes,
      'doctorRecommendation': doctorRecommendation,
      'nutritionRecommendation': nutritionRecommendation,
      'followUpAdvice': followUpAdvice,
      'consultationStatus': consultationStatus,
      'messageCount': messageCount,
      'date': date,
      'time': time,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Deserialize dari Firestore DocumentSnapshot
  factory ConsultationHistory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ConsultationHistory.fromMap(doc.id, data);
  }

  /// Deserialize dari raw Map
  factory ConsultationHistory.fromMap(String docId, Map<String, dynamic> data) {
    DateTime? createdAt;
    DateTime? completedAt;

    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt'] as String);
    }

    if (data['completedAt'] is Timestamp) {
      completedAt = (data['completedAt'] as Timestamp).toDate();
    } else if (data['completedAt'] is String) {
      completedAt = DateTime.tryParse(data['completedAt'] as String);
    }

    final id = (data['consultationId'] as String?)?.isNotEmpty == true
        ? data['consultationId'] as String
        : docId;

    final refTime = completedAt ?? createdAt ?? DateTime.now();
    final defaultDate = _formatDate(refTime);
    final defaultTime = _formatTime(refTime);

    final rawDate = data['date']?.toString();
    final rawTime = data['time']?.toString();

    final photo = (data['doctorPhoto'] ?? data['doctorImageUrl'])?.toString() ?? '';

    return ConsultationHistory(
      id: id,
      chatId: data['chatId']?.toString() ?? '',
      doctorId: data['doctorId']?.toString() ?? '',
      doctorName: data['doctorName']?.toString() ?? '',
      doctorSpecialist: data['doctorSpecialist']?.toString() ?? '',
      doctorImageUrl: photo,
      doctorHospital: data['doctorHospital']?.toString() ?? '',
      doctorPhoto: photo,
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      summary: data['summary']?.toString() ?? '',
      diagnosis: data['diagnosis']?.toString() ?? 'Konsultasi Selesai',
      doctorNotes: data['doctorNotes']?.toString() ?? '',
      doctorRecommendation: data['doctorRecommendation']?.toString() ?? '',
      nutritionRecommendation:
          data['nutritionRecommendation']?.toString() ?? '',
      followUpAdvice: data['followUpAdvice']?.toString() ??
          'Lakukan kontrol berkala atau evaluasi lanjutan dalam 1-3 bulan ke depan.',
      consultationStatus: data['consultationStatus']?.toString() ?? 'completed',
      messageCount: (data['messageCount'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      completedAt: completedAt,
      date: (rawDate != null && rawDate.isNotEmpty) ? rawDate : defaultDate,
      time: (rawTime != null && rawTime.isNotEmpty) ? rawTime : defaultTime,
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  ConsultationHistory copyWith({
    String? id,
    Doctor? doctor,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialist,
    String? doctorImageUrl,
    String? doctorHospital,
    String? doctorPhoto,
    String? patientId,
    String? patientName,
    String? summary,
    String? diagnosis,
    String? doctorNotes,
    String? doctorRecommendation,
    String? nutritionRecommendation,
    String? followUpAdvice,
    List<ChatMessage>? messages,
    String? chatId,
    String? consultationStatus,
    int? messageCount,
    DateTime? createdAt,
    DateTime? completedAt,
    String? date,
    String? time,
  }) {
    return ConsultationHistory(
      id: id ?? this.id,
      doctor: doctor ?? _doctor,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialist: doctorSpecialist ?? this.doctorSpecialist,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      doctorHospital: doctorHospital ?? this.doctorHospital,
      doctorPhoto: doctorPhoto ?? this.doctorPhoto,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      summary: summary ?? this.summary,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      doctorRecommendation:
          doctorRecommendation ?? this.doctorRecommendation,
      nutritionRecommendation:
          nutritionRecommendation ?? this.nutritionRecommendation,
      followUpAdvice: followUpAdvice ?? this.followUpAdvice,
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      consultationStatus: consultationStatus ?? this.consultationStatus,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}
