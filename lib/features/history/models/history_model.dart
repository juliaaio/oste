import 'dart:convert';
import 'package:flutter/material.dart';
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
  final double? modelConfidence;
  final List<PredictionItem>? predictionData;
  final List<String>? recommendations;

  // Detail tambahan khusus riwayat konsultasi
  final ConsultationHistory? consultation;

  // Detail identitas pasien
  final String? patientName;
  final String? patientId;

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
    this.modelConfidence,
    this.predictionData,
    this.recommendations,
    this.consultation,
    this.patientName,
    this.patientId,
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
    double? modelConfidence,
    List<PredictionItem>? predictionData,
    List<String>? recommendations,
    String? patientName,
    String? patientId,
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
      modelConfidence: modelConfidence,
      predictionData: predictionData,
      recommendations: recommendations,
      patientName: patientName,
      patientId: patientId,
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
      patientName: consultation.patientName,
      patientId: consultation.patientId,
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
    double? modelConfidence,
    List<PredictionItem>? predictionData,
    List<String>? recommendations,
    ConsultationHistory? consultation,
    String? patientName,
    String? patientId,
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
      modelConfidence: modelConfidence ?? this.modelConfidence,
      predictionData: predictionData ?? this.predictionData,
      recommendations: recommendations ?? this.recommendations,
      consultation: consultation ?? this.consultation,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
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
      'modelConfidence': modelConfidence,
      'recommendations': recommendations,
      'patientName': patientName,
      'patientId': patientId,
    };
  }

  /// Membuat instance dari Map.
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    final rawProb = map['probability'] ?? map['probabilitas'];
    final probInt = (rawProb as num?)?.toInt() ?? 0;

    List<PredictionItem>? parsedPredictionData;
    if (map['input'] is Map<String, dynamic>) {
      parsedPredictionData = _buildPredictionItemsFromInput(
        map['input'] as Map<String, dynamic>,
      );
    } else if (map['input'] is Map) {
      parsedPredictionData = _buildPredictionItemsFromInput(
        Map<String, dynamic>.from(map['input'] as Map),
      );
    }

    return HistoryModel(
      id: map['id'] as String? ?? '',
      tanggal: map['tanggal'] is String
          ? DateTime.tryParse(map['tanggal'] as String) ?? DateTime.now()
          : (map['tanggal'] as DateTime? ?? DateTime.now()),
      waktu: map['waktu'] as String? ?? '',
      probabilitas: probInt,
      status: (map['statusHasil'] as String?) ??
          (map['status'] as String?) ??
          (probInt >= 50 ? 'Terindikasi Osteoporosis' : 'Tidak Terindikasi Osteoporosis'),
      isPositive: (map['isPositive'] as bool?) ??
          (map['prediction'] != null
              ? ((map['prediction'] as num) == 1)
              : (probInt >= 50)),
      type: map['type'] == 'consultation'
          ? HistoryType.consultation
          : HistoryType.screening,
      riskCategory: (map['riskCategory'] as String?) ?? (map['riskTitle'] as String?),
      summary: (map['riskDescription'] as String?) ?? (map['summary'] as String?),
      modelConfidence: (map['confidence'] as num?)?.toDouble() ??
          (map['modelConfidence'] as num?)?.toDouble(),
      predictionData: parsedPredictionData,
      recommendations: (map['recommendations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      patientName: map['patientName'] as String? ??
          map['userName'] as String? ??
          map['namaPasien'] as String?,
      patientId: map['patientId'] as String? ??
          map['userId'] as String?,
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

/// Helper untuk mengonversi Map input skrining ke daftar PredictionItem untuk detail hasil
List<PredictionItem> _buildPredictionItemsFromInput(Map<String, dynamic> input) {
  final items = <PredictionItem>[];

  if (input['Age'] != null) {
    items.add(PredictionItem(
      icon: Icons.person_outline_rounded,
      label: 'Usia',
      value: '${input['Age']} tahun',
    ));
  }
  if (input['Gender'] != null) {
    items.add(PredictionItem(
      icon: Icons.female_rounded,
      label: 'Jenis kelamin',
      value: input['Gender'].toString(),
    ));
  }
  if (input['Race/Ethnicity'] != null) {
    items.add(PredictionItem(
      icon: Icons.public_rounded,
      label: 'Ras/Etnis',
      value: input['Race/Ethnicity'].toString(),
    ));
  }
  if (input['Body Weight'] != null) {
    items.add(PredictionItem(
      icon: Icons.scale_outlined,
      label: 'Berat badan',
      value: input['Body Weight'].toString(),
    ));
  }
  if (input['Calcium Intake'] != null) {
    items.add(PredictionItem(
      icon: Icons.science_outlined,
      label: 'Asupan kalsium',
      value: input['Calcium Intake'].toString(),
    ));
  }
  if (input['Vitamin D Intake'] != null) {
    items.add(PredictionItem(
      icon: Icons.wb_sunny_outlined,
      label: 'Asupan vitamin D',
      value: input['Vitamin D Intake'].toString(),
    ));
  }
  if (input['Physical Activity'] != null) {
    items.add(PredictionItem(
      icon: Icons.directions_run_rounded,
      label: 'Aktivitas fisik',
      value: input['Physical Activity'].toString(),
    ));
  }
  if (input['Smoking'] != null) {
    final v = input['Smoking'];
    items.add(PredictionItem(
      icon: Icons.smoke_free_rounded,
      label: 'Merokok',
      value: (v == 1 || v == '1' || v == 'Yes') ? 'Ya' : 'Tidak',
    ));
  }
  if (input['Alcohol Consumption'] != null) {
    final v = input['Alcohol Consumption'];
    items.add(PredictionItem(
      icon: Icons.local_bar_outlined,
      label: 'Konsumsi alkohol',
      value: (v == 1 || v == '1' || v == 'Moderate' || v == 'Yes') ? 'Ya' : 'Tidak',
    ));
  }
  if (input['Medical Conditions'] != null) {
    items.add(PredictionItem(
      icon: Icons.medical_services_outlined,
      label: 'Kondisi medis',
      value: input['Medical Conditions'].toString(),
    ));
  }
  if (input['Medications'] != null) {
    items.add(PredictionItem(
      icon: Icons.medication_outlined,
      label: 'Penggunaan obat',
      value: input['Medications'].toString(),
    ));
  }
  if (input['Prior Fractures'] != null) {
    final v = input['Prior Fractures'];
    items.add(PredictionItem(
      icon: Icons.healing_rounded,
      label: 'Riwayat patah tulang',
      value: (v == 1 || v == '1' || v == 'Yes') ? 'Ya' : 'Tidak',
    ));
  }

  return items;
}
