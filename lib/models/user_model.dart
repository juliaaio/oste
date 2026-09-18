/// Model data pengguna aplikasi Osteocare.
class UserModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String birthDate;
  final double? weight;
  final double? height;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
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

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? gender,
    String? birthDate,
    double? weight,
    double? height,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}
