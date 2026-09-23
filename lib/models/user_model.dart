import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data pengguna aplikasi Osteocare.
///
/// Versi ini menggunakan Firebase UID sebagai identitas utama.
/// Password tidak lagi disimpan secara lokal — dikelola sepenuhnya oleh Firebase Auth.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final double? weight;
  final double? height;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.gender = '',
    this.birthDate = '',
    this.weight,
    this.height,
  });

  /// Mengembalikan sapaan singkat berdasarkan nama (kata pertama)
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Buat UserModel dari dokumen Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(doc.id, data);
  }

  /// Buat UserModel dari Map (misalnya dari Firestore data() tanpa DocumentSnapshot).
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: _parseString(data['name']),
      email: _parseString(data['email']),
      phone: _parseString(data['phone']),
      gender: _parseString(data['gender']),
      birthDate: _parseString(data['birth_date'] ?? data['birthDate']),
      weight: _parseNum(data['weight']),
      height: _parseNum(data['height']),
    );
  }

  /// Konversi ke Map untuk disimpan ke Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'weight': weight,
      'height': height,
    };
  }

  /// Konversi ke Map generik.
  Map<String, dynamic> toMap() => toFirestore();

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthDate,
    double? weight,
    double? height,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}
