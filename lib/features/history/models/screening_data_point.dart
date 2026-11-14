import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model representasi data poin untuk grafik perkembangan risiko osteoporosis.
class ScreeningDataPoint {
  final String id;
  final DateTime date;
  final String? waktu;
  final double probability;
  final int prediction;
  final String riskCategory;
  final String statusHasil;

  const ScreeningDataPoint({
    this.id = '',
    required this.date,
    this.waktu,
    required this.probability,
    required this.prediction,
    required this.riskCategory,
    required this.statusHasil,
  });

  /// Warna representasi risiko berdasarkan rentang probabilitas:
  /// - 0–39%  : Hijau (Rendah)
  /// - 40–69% : Kuning/Amber (Sedang)
  /// - 70–100%: Merah (Tinggi)
  Color get riskColor {
    if (probability < 40) {
      return const Color(0xFF10B981); // Hijau
    } else if (probability < 70) {
      return const Color(0xFFF59E0B); // Kuning / Amber
    } else {
      return const Color(0xFFEF4444); // Merah
    }
  }

  /// Label kategori risiko
  String get riskLabel {
    if (probability < 40) {
      return 'Risiko Rendah';
    } else if (probability < 70) {
      return 'Risiko Sedang';
    } else {
      return 'Risiko Tinggi';
    }
  }

  /// Factory untuk mem-parsing dokumen Firestore
  factory ScreeningDataPoint.fromFirestore(Map<String, dynamic> data) {
    DateTime parsedDate = DateTime.now();
    final rawDate = data['tanggal'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    }

    double prob = 0.0;
    if (data['probability'] != null) {
      prob = (data['probability'] as num).toDouble();
    } else if (data['probabilitas'] != null) {
      prob = (data['probabilitas'] as num).toDouble();
    }

    final int pred = (data['prediction'] as num?)?.toInt() ?? (prob >= 50 ? 1 : 0);
    final String cat = data['riskCategory'] as String? ??
        data['riskTitle'] as String? ??
        (prob >= 70 ? 'Risiko Tinggi' : (prob >= 40 ? 'Risiko Sedang' : 'Risiko Rendah'));

    return ScreeningDataPoint(
      id: data['id'] as String? ?? '',
      date: parsedDate,
      waktu: data['waktu'] as String?,
      probability: prob,
      prediction: pred,
      riskCategory: cat,
      statusHasil: data['statusHasil'] as String? ?? '',
    );
  }
}

