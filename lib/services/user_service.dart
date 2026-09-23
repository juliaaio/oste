import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/user_model.dart';

// ---------------------------------------------------------------------------
// Konstanta nama koleksi Firestore
// ---------------------------------------------------------------------------
const _kUsersCollection = 'users';

// ---------------------------------------------------------------------------
// Helper: terjemahkan Firebase error code ke pesan ramah pengguna
// ---------------------------------------------------------------------------
String _friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Email sudah digunakan. Gunakan email lain atau masuk ke akun Anda.';
    case 'invalid-email':
      return 'Format email tidak valid. Contoh: user@gmail.com';
    case 'weak-password':
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    case 'user-not-found':
      return 'Email belum terdaftar. Silakan daftar terlebih dahulu.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau password salah. Silakan periksa kembali.';
    case 'user-disabled':
      return 'Akun Anda telah dinonaktifkan. Hubungi dukungan.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Silakan coba beberapa saat lagi.';
    case 'network-request-failed':
      return 'Koneksi jaringan gagal. Periksa koneksi internet Anda.';
    case 'operation-not-allowed':
      return 'Metode login ini tidak diizinkan. Hubungi dukungan.';
    case 'requires-recent-login':
      return 'Sesi telah kedaluwarsa. Silakan login kembali.';
    case 'account-exists-with-different-credential':
      return 'Akun dengan email ini sudah ada dengan metode login berbeda.';
    default:
      return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

/// Layanan singleton untuk otentikasi dan manajemen profil pengguna.
///
/// Secara internal menggunakan Firebase Authentication dan Cloud Firestore.
/// API publik dipertahankan agar tidak ada perubahan pada page-page yang menggunakannya.
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal() {
    // Pantau perubahan sesi Firebase secara real-time (abaikan jika belum diinisialisasi seperti saat testing)
    try {
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    } catch (_) {}
  }

  // ── State ─────────────────────────────────────────────────────────────────

  UserModel? _currentUser;
  bool _isRegistering = false;

  /// User yang sedang login. Null jika belum login.
  UserModel? get currentUser => _currentUser;

  /// Apakah ada user yang sedang login.
  bool get isLoggedIn => _currentUser != null;

  /// Menyetel _currentUser untuk keperluan testing tanpa jaringan/Firebase.
  @visibleForTesting
  void setCurrentUserForTesting(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // ── Auth State Listener ───────────────────────────────────────────────────

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_isRegistering) return;
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
    } else {
      // Selalu muat profil dari Firestore berdasarkan UID
      await _loadUserFromFirestore(firebaseUser.uid);
    }
  }

  /// Muat dokumen Firestore berdasarkan UID dan simpan ke _currentUser.
  Future<UserModel?> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_kUsersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
        return _currentUser;
      } else {
        // Dokumen belum ada di Firestore — inisialisasi dokumen baru di Firestore
        final fbUser = FirebaseAuth.instance.currentUser;
        final initialUser = UserModel(
          uid: uid,
          name: fbUser?.displayName ?? '',
          email: fbUser?.email ?? '',
        );
        await FirebaseFirestore.instance
            .collection(_kUsersCollection)
            .doc(uid)
            .set({
          ...initialUser.toFirestore(),
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _currentUser = initialUser;
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      // Jika Firestore gagal (misal koneksi/test), jangan timpa _currentUser jika sudah terisi
      if (_currentUser == null) {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null && fbUser.uid == uid) {
          _currentUser = UserModel(
            uid: fbUser.uid,
            name: fbUser.displayName ?? '',
            email: fbUser.email ?? '',
          );
          notifyListeners();
        }
      }
      return _currentUser;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  /// Mendaftarkan pengguna baru ke Firebase Auth dan membuat dokumen Firestore.
  ///
  /// Mengembalikan `null` jika berhasil, atau pesan error jika gagal.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String gender = '',
    String birthDate = '',
    double? weight,
    double? height,
  }) async {
    _isRegistering = true;
    try {
      // 1. Buat akun Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Perbarui displayName di Firebase Auth
      try {
        await credential.user!.updateDisplayName(name.trim());
      } catch (_) {}

      // 3. Buat dokumen Firestore di koleksi 'users'
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        gender: gender,
        birthDate: birthDate,
        weight: weight,
        height: height,
      );

      await FirebaseFirestore.instance
          .collection(_kUsersCollection)
          .doc(uid)
          .set({
        ...newUser.toFirestore(),
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Muat profil dari Firestore untuk sinkronisasi UserModel
      await _loadUserFromFirestore(uid);

      if (_currentUser == null) {
        _currentUser = newUser;
        notifyListeners();
      }

      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
    } finally {
      _isRegistering = false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Login dengan email dan password menggunakan Firebase Auth.
  ///
  /// Mengembalikan `null` jika berhasil, atau pesan error jika gagal.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Muat profil dari Firestore
      await _loadUserFromFirestore(credential.user!.uid);
      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
    }
  }

  // ── Login Direct (Google Sign-In / SSO) ───────────────────────────────────

  /// Login langsung dengan UserModel yang sudah terautentikasi (Google Sign-In).
  Future<void> loginDirect(UserModel user) async {
    final uid = user.uid.isNotEmpty
        ? user.uid
        : 'google_${user.email.replaceAll('@', '_').replaceAll('.', '_')}';
    final effectiveUser = user.uid.isEmpty ? user.copyWith(uid: uid) : user;

    try {
      final docRef = FirebaseFirestore.instance
          .collection(_kUsersCollection)
          .doc(effectiveUser.uid);

      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          ...effectiveUser.toFirestore(),
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'name': effectiveUser.name,
          'email': effectiveUser.email,
        }, SetOptions(merge: true));
      }
      await _loadUserFromFirestore(effectiveUser.uid);
    } catch (_) {
      _currentUser = effectiveUser;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  /// Keluar dari sesi Firebase dan bersihkan data lokal.
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  // ── Update Profile ────────────────────────────────────────────────────────

  /// Memperbarui profil pengguna di Firestore dan sinkronisasi _currentUser.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthDate,
    double? weight,
    double? height,
  }) async {
    final uid = _currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name.trim();
    if (email != null) data['email'] = email.trim();
    if (phone != null) data['phone'] = phone.trim();
    if (gender != null) data['gender'] = gender.trim();
    if (birthDate != null) data['birth_date'] = birthDate.trim();
    if (weight != null) data['weight'] = weight;
    if (height != null) data['height'] = height;

    if (data.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(_kUsersCollection)
            .doc(uid)
            .set(data, SetOptions(merge: true));

        if (name != null && name.trim().isNotEmpty) {
          try {
            await FirebaseAuth.instance.currentUser?.updateDisplayName(name.trim());
          } catch (_) {}
        }

        // Refresh UserModel langsung dari Firestore
        await _loadUserFromFirestore(uid);
      } catch (_) {
        // Fallback update memori jika Firestore offline
        _currentUser = _currentUser?.copyWith(
          name: name,
          email: email,
          phone: phone,
          gender: gender,
          birthDate: birthDate,
          weight: weight,
          height: height,
        );
        notifyListeners();
      }
    }
  }
}
