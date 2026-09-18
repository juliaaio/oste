import 'dart:convert';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/models/consultation_history_model.dart';

/// Jenis riwayat untuk membedakan antara hasil skrining mandiri dan sesi konsultasi dokter
enum HistoryType {
  screening,
  consultation,
}

/// Model data untuk riwayat (skrining osteoporosis maupun konsultasi medis).
class HistoryModel {
  final String id;
  final DateTime tanggal;
  final String waktu;
  final int probabilitas;
  final String status;
  final bool isPositive;
  final HistoryType type;

  // Detail tambahan khusus riwayat skrining
  final String? riskCategory;
  final String? summary;
  final List<PredictionItem>? predictionData;
  final List<String>? recommendations;

  // Detail tambahan khusus riwayat konsultasi
  final ConsultationHistory? consultation;

  const HistoryModel({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.probabilitas,
    required this.status,
    required this.isPositive,
    this.type = HistoryType.screening,
    this.riskCategory,
    this.summary,
    this.predictionData,
    this.recommendations,
    this.consultation,
  });

  /// Factory untuk membuat HistoryModel dari hasil skrining mandiri
  factory HistoryModel.fromScreening({
    required String id,
    required DateTime tanggal,
    required String waktu,
    required int probabilitas,
    required String status,
    required bool isPositive,
    String? riskCategory,
    String? summary,
    List<PredictionItem>? predictionData,
    List<String>? recommendations,
  }) {
    return HistoryModel(
      id: id,
      tanggal: tanggal,
      waktu: waktu,
      probabilitas: probabilitas,
      status: status,
      isPositive: isPositive,
      type: HistoryType.screening,
      riskCategory: riskCategory,
      summary: summary,
      predictionData: predictionData,
      recommendations: recommendations,
    );
  }

  /// Factory untuk membuat HistoryModel dari data riwayat konsultasi
  factory HistoryModel.fromConsultation(ConsultationHistory consultation) {
    // Parse tanggal konsultasi jika memungkinkan
    DateTime dateParsed;
    try {
      dateParsed = DateTime.now();
    } catch (_) {
      dateParsed = DateTime.now();
    }

    return HistoryModel(
      id: consultation.id,
      tanggal: dateParsed,
      waktu: consultation.time,
      probabilitas: 0,
      status: consultation.diagnosis,
      isPositive: false,
      type: HistoryType.consultation,
      summary: consultation.summary,
      consultation: consultation,
    );
  }

  /// Mengembalikan salinan instance dengan nilai baru jika diberikan.
  HistoryModel copyWith({
    String? id,
    DateTime? tanggal,
    String? waktu,
    int? probabilitas,
    String? status,
    bool? isPositive,
    HistoryType? type,
    String? riskCategory,
    String? summary,
    List<PredictionItem>? predictionData,
    List<String>? recommendations,
    ConsultationHistory? consultation,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      probabilitas: probabilitas ?? this.probabilitas,
      status: status ?? this.status,
      isPositive: isPositive ?? this.isPositive,
      type: type ?? this.type,
      riskCategory: riskCategory ?? this.riskCategory,
      summary: summary ?? this.summary,
      predictionData: predictionData ?? this.predictionData,
      recommendations: recommendations ?? this.recommendations,
      consultation: consultation ?? this.consultation,
    );
  }

  /// Mengonversi instance ke Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'waktu': waktu,
      'probabilitas': probabilitas,
      'status': status,
      'isPositive': isPositive,
      'type': type.name,
      'riskCategory': riskCategory,
      'summary': summary,
      'recommendations': recommendations,
    };
  }

  /// Membuat instance dari Map.
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as String? ?? '',
      tanggal: map['tanggal'] is String
          ? DateTime.tryParse(map['tanggal'] as String) ?? DateTime.now()
          : (map['tanggal'] as DateTime? ?? DateTime.now()),
      waktu: map['waktu'] as String? ?? '',
      probabilitas: (map['probabilitas'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? '',
      isPositive: map['isPositive'] as bool? ?? false,
      type: map['type'] == 'consultation'
          ? HistoryType.consultation
          : HistoryType.screening,
      riskCategory: map['riskCategory'] as String?,
      summary: map['summary'] as String?,
      recommendations: (map['recommendations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  /// Mengonversi instance ke format JSONString.
  String toJson() => json.encode(toMap());

  /// Membuat instance dari format JSONString.
  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HistoryModel(id: $id, tanggal: $tanggal, waktu: $waktu, probabilitas: $probabilitas, status: $status, isPositive: $isPositive, type: $type)';
  }

  @override
  bool operator ==(covariant HistoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.tanggal == tanggal &&
        other.waktu == waktu &&
        other.probabilitas == probabilitas &&
        other.status == status &&
        other.isPositive == isPositive &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tanggal.hashCode ^
        waktu.hashCode ^
        probabilitas.hashCode ^
        status.hashCode ^
        isPositive.hashCode ^
        type.hashCode;
  }
}
