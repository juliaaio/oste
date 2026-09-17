import 'package:oste/models/chat_message.dart';
import 'package:oste/models/doctor_model.dart';

/// Model representasi data riwayat konsultasi medis yang telah selesai
class ConsultationHistory {
  final String id;
  final Doctor doctor;
  final String date;
  final String time;
  final String summary;
  final String diagnosis;
  final String doctorNotes;
  final String doctorRecommendation;
  final String nutritionRecommendation;
  final String followUpAdvice;
  final List<ChatMessage> messages;

  const ConsultationHistory({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.summary,
    required this.diagnosis,
    required this.doctorNotes,
    required this.doctorRecommendation,
    required this.nutritionRecommendation,
    this.followUpAdvice =
        'Lakukan kontrol berkala atau evaluasi lanjutan dalam 1-3 bulan ke depan.',
    this.messages = const [],
  });

  ConsultationHistory copyWith({
    String? id,
    Doctor? doctor,
    String? date,
    String? time,
    String? summary,
    String? diagnosis,
    String? doctorNotes,
    String? doctorRecommendation,
    String? nutritionRecommendation,
    String? followUpAdvice,
    List<ChatMessage>? messages,
  }) {
    return ConsultationHistory(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      summary: summary ?? this.summary,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      doctorRecommendation:
          doctorRecommendation ?? this.doctorRecommendation,
      nutritionRecommendation:
          nutritionRecommendation ?? this.nutritionRecommendation,
      followUpAdvice: followUpAdvice ?? this.followUpAdvice,
      messages: messages ?? this.messages,
    );
  }
}
