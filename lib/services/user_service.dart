import 'package:flutter/foundation.dart';
import 'package:oste/models/user_model.dart';

enum LoginResult {
  success,
  emailNotFound,
  wrongPassword,
}

/// Layanan singleton untuk menyimpan dan mengelola data pengguna yang sedang login.
///
/// Mendukung register, login (verifikasi email + password), dan akses profil.
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal() {
    const defaultUser = UserModel(
      name: 'Risma Putri',
      email: 'risma.putri@email.com',
      phone: '0812-3456-7890',
      password: 'Password123!',
      gender: 'Perempuan',
      birthDate: '15 Mei 1998',
      weight: 52,
      height: 160,
    );
    _registeredUsers.add(defaultUser);
    _currentUser = defaultUser;
  }

  // Daftar akun yang sudah terdaftar (simulasi in-memory database)
  final List<UserModel> _registeredUsers = [];

  // User yang sedang aktif / login
  UserModel? _currentUser;

  /// User yang sedang login. Null jika belum login.
  UserModel? get currentUser => _currentUser;

  /// Apakah ada user yang sedang login
  bool get isLoggedIn => _currentUser != null;

  /// Mendaftarkan user baru. Mengembalikan [true] jika berhasil.
  /// Mengembalikan [false] jika email sudah digunakan.
  bool register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String gender = '',
    String birthDate = '',
    double? weight,
    double? height,
  }) {
    final newUser = UserModel(
      name: name,
      email: email,
      phone: phone,
      password: password,
      gender: gender,
      birthDate: birthDate,
      weight: weight,
      height: height,
    );

    final existingIndex = _registeredUsers.indexWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existingIndex >= 0) {
      _registeredUsers[existingIndex] = newUser;
    } else {
      _registeredUsers.add(newUser);
    }

    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  /// Autentikasi kredensial login pengguna.
  /// Mengembalikan [LoginResult.success], [LoginResult.emailNotFound], atau [LoginResult.wrongPassword].
  LoginResult authenticate({required String email, required String password}) {
    final cleanEmail = email.trim().toLowerCase();
    final userIdx = _registeredUsers.indexWhere(
      (u) => u.email.trim().toLowerCase() == cleanEmail,
    );

    if (userIdx < 0) {
      return LoginResult.emailNotFound;
    }

    final user = _registeredUsers[userIdx];
    if (user.password != password) {
      return LoginResult.wrongPassword;
    }

    _currentUser = user;
    notifyListeners();
    return LoginResult.success;
  }

  /// Login dengan email dan password.
  /// Mengembalikan [true] jika berhasil, [false] jika kredensial salah atau tidak terdaftar.
  bool login({required String email, required String password}) {
    return authenticate(email: email, password: password) == LoginResult.success;
  }

  /// Login langsung tanpa verifikasi (untuk Google Sign-In / demo flow).
  void loginDirect(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Memperbarui data profil user yang sedang login.
  void updateProfile({
    String? name,
    String? phone,
    String? gender,
    String? birthDate,
    double? weight,
    double? height,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
      weight: weight,
      height: height,
    );

    // Perbarui juga di list registrasi
    final idx = _registeredUsers.indexWhere(
      (u) => u.email == _currentUser!.email,
    );
    if (idx >= 0) {
      _registeredUsers[idx] = _currentUser!;
    }

    notifyListeners();
  }

  /// Logout — hapus sesi aktif.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
