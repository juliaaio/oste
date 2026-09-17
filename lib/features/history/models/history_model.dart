import 'dart:convert';

/// Model data untuk riwayat skrining osteoporosis.
class HistoryModel {
  final String id;
  final DateTime tanggal;
  final String waktu;
  final int probabilitas;
  final String status;
  final bool isPositive;

  const HistoryModel({
    required this.id,
    required this.tanggal,
    required this.waktu,
    required this.probabilitas,
    required this.status,
    required this.isPositive,
  });

  /// Mengembalikan salinan instance dengan nilai baru jika diberikan.
  HistoryModel copyWith({
    String? id,
    DateTime? tanggal,
    String? waktu,
    int? probabilitas,
    String? status,
    bool? isPositive,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      probabilitas: probabilitas ?? this.probabilitas,
      status: status ?? this.status,
      isPositive: isPositive ?? this.isPositive,
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
    );
  }

  /// Mengonversi instance ke format JSONString.
  String toJson() => json.encode(toMap());

  /// Membuat instance dari format JSONString.
  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HistoryModel(id: $id, tanggal: $tanggal, waktu: $waktu, probabilitas: $probabilitas, status: $status, isPositive: $isPositive)';
  }

  @override
  bool operator ==(covariant HistoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.tanggal == tanggal &&
        other.waktu == waktu &&
        other.probabilitas == probabilitas &&
        other.status == status &&
        other.isPositive == isPositive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tanggal.hashCode ^
        waktu.hashCode ^
        probabilitas.hashCode ^
        status.hashCode ^
        isPositive.hashCode;
  }
}
