import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/user_model.dart';
import 'package:oste/services/doctor_presence_service.dart';

// ---------------------------------------------------------------------------
// Konstanta nama koleksi Firestore
// ---------------------------------------------------------------------------
const _kUsersCollection = 'users';
const _kAdminsCollection = 'admins';

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
/// Identitas dokumen pengguna berbasis UID Firebase Authentication.
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
  Future<UserModel?>? _activeLoadFuture;
  String? _activeLoadingUid;

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
  Future<UserModel?> loadUserFromFirestore(String uid) async {
    return _loadUserFromFirestore(uid);
  }

  /// Memuat ulang data pengguna dari Firestore untuk memastikan data role terkini
  Future<UserModel?> refreshUser() async {
    final uid = _currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _loadUserFromFirestore(uid);
  }

  /// Muat dokumen Firestore internal berdasarkan UID dan simpan ke _currentUser.
  ///
  /// Verifikasi role dilakukan secara ketat berdasarkan data dokumen Firestore:
  /// 1. Prioritas 1: Memeriksa dokumen di koleksi 'admins/{uid}' (ID dokumen = UID).
  /// 2. Prioritas 1b: Pencarian cadangan jika ID dokumen di 'admins' belum disesuaikan dengan UID.
  /// 3. Prioritas 2: Memeriksa dokumen di koleksi 'users/{uid}' (Pasien, Dokter, atau Admin cadangan).
  /// 4. Jika role tidak ditemukan, mengembalikan null tanpa membuat data dummy.
  Future<UserModel?> _loadUserFromFirestore(String uid) async {
    // Mencegah multiple concurrent fetch untuk UID yang sama
    if (_activeLoadFuture != null && _activeLoadingUid == uid) {
      return _activeLoadFuture;
    }
    _activeLoadingUid = uid;
    _activeLoadFuture = _doLoadUserFromFirestore(uid);
    try {
      return await _activeLoadFuture;
    } finally {
      _activeLoadFuture = null;
      _activeLoadingUid = null;
    }
  }

  Future<UserModel?> _doLoadUserFromFirestore(String uid) async {
    debugPrint('[AUTH-TRACE] Memulai verifikasi role untuk UID: $uid');
    try {
      // 1. Prioritas 1: Periksa koleksi 'admins/{uid}' dan 'admin/{uid}' (jamak & tunggal)
      for (final col in [_kAdminsCollection, 'admin']) {
        try {
          debugPrint('[AUTH-TRACE] Memeriksa dokumen di koleksi "$col/$uid" ...');
          final adminDoc = await FirebaseFirestore.instance
              .collection(col)
              .doc(uid)
              .get();

          debugPrint('[AUTH-TRACE] Hasil $col/$uid: exists=${adminDoc.exists}');
          if (adminDoc.exists && adminDoc.data() != null) {
            final adminData = adminDoc.data()!;
            final roleVal = adminData['role']?.toString().toLowerCase().trim() ?? '';
            debugPrint('[AUTH-TRACE] Data $col/$uid ditemukan: role="$roleVal"');

            final isDocAdmin = roleVal == 'admin' || roleVal == 'administrator' || roleVal.isEmpty;

            if (isDocAdmin) {
              final fbUser = FirebaseAuth.instance.currentUser;
              final adminName = (adminData['name'] != null && adminData['name'].toString().isNotEmpty)
                  ? adminData['name'].toString()
                  : (fbUser?.displayName ?? 'Admin Osteo');
              final adminEmail = (adminData['email'] != null && adminData['email'].toString().isNotEmpty)
                  ? adminData['email'].toString()
                  : (fbUser?.email ?? '');

              _currentUser = UserModel(
                uid: uid,
                name: adminName,
                email: adminEmail,
                role: 'admin',
              );
              debugPrint('[AUTH-TRACE] Berhasil diverifikasi sebagai ADMIN dari koleksi $col!');
              notifyListeners();
              return _currentUser;
            }
          }
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
            debugPrint(
              '[AUTH-TRACE] ⚠️ PERMISSION-DENIED saat mengakses "$col/$uid". '
              'Firestore Security Rules di Firebase Console memblokir akses ke koleksi "$col".',
            );
          } else {
            debugPrint('[AUTH-TRACE] FirebaseException pada $col/$uid: ${e.code} - ${e.message}');
          }
        } catch (e) {
          debugPrint('[AUTH-TRACE] Error lain saat memeriksa $col/$uid: $e');
        }
      }

      // 2. Prioritas 1b: Pencarian cadangan jika ID dokumen di 'admins' belum menggunakan UID
      for (final col in [_kAdminsCollection, 'admin']) {
        try {
          final queryByUid = await FirebaseFirestore.instance
              .collection(col)
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();

          if (queryByUid.docs.isNotEmpty) {
            final adminDoc = queryByUid.docs.first;
            final adminData = adminDoc.data();
            final roleVal = adminData['role']?.toString().toLowerCase().trim() ?? '';
            final isDocAdmin = roleVal == 'admin' || roleVal == 'administrator' || roleVal.isEmpty;

            if (isDocAdmin) {
              debugPrint(
                '[AUTH-TRACE] Dokumen admin ditemukan dengan custom ID "${adminDoc.id}" di $col.',
              );

              final fbUser = FirebaseAuth.instance.currentUser;
              final adminName = (adminData['name'] != null && adminData['name'].toString().isNotEmpty)
                  ? adminData['name'].toString()
                  : (fbUser?.displayName ?? 'Admin Osteo');
              final adminEmail = (adminData['email'] != null && adminData['email'].toString().isNotEmpty)
                  ? adminData['email'].toString()
                  : (fbUser?.email ?? '');

              _currentUser = UserModel(
                uid: uid,
                name: adminName,
                email: adminEmail,
                role: 'admin',
              );

              // Sinkronkan dokumen dengan ID = UID
              try {
                await FirebaseFirestore.instance
                    .collection(_kAdminsCollection)
                    .doc(uid)
                    .set({
                  ...adminData,
                  'uid': uid,
                  'role': 'admin',
                }, SetOptions(merge: true));
              } catch (_) {}

              debugPrint('[AUTH-TRACE] Berhasil diverifikasi sebagai ADMIN via fallback query!');
              notifyListeners();
              return _currentUser;
            }
          }
        } catch (_) {}
      }

      // 3. Prioritas 2: Periksa koleksi 'users/{uid}'
      try {
        debugPrint('[AUTH-TRACE] Memeriksa koleksi "users/$uid" ...');
        final userDoc = await FirebaseFirestore.instance
            .collection(_kUsersCollection)
            .doc(uid)
            .get();

        debugPrint('[AUTH-TRACE] Hasil users/$uid: exists=${userDoc.exists}');
        if (userDoc.exists && userDoc.data() != null) {
          final loadedUser = UserModel.fromFirestore(userDoc);
          debugPrint('[AUTH-TRACE] Data users/$uid: role="${loadedUser.role}"');

          // Jika pada users memiliki role admin
          if (loadedUser.isAdmin) {
            _currentUser = loadedUser;

            // Sinkronkan ke koleksi admins jika rules mengizinkan
            try {
              await FirebaseFirestore.instance
                  .collection(_kAdminsCollection)
                  .doc(uid)
                  .set({
                'uid': uid,
                'name': loadedUser.name,
                'email': loadedUser.email,
                'role': 'admin',
              }, SetOptions(merge: true));
            } catch (_) {}

            debugPrint('[AUTH-TRACE] Berhasil diverifikasi sebagai ADMIN dari koleksi users!');
            notifyListeners();
            return _currentUser;
          }

          // Pasien atau Dokter terverifikasi
          _currentUser = loadedUser;
          debugPrint('[AUTH-TRACE] Terverifikasi sebagai non-admin: role="${loadedUser.role}"');
          notifyListeners();
          return _currentUser;
        }
      } catch (e) {
        debugPrint('[AUTH-TRACE] Error memeriksa users/$uid: $e');
      }

      // Role tidak ditemukan pada admins maupun users
      debugPrint('[AUTH-TRACE] ⚠️ Dokumen tidak ditemukan di admins maupun users untuk UID: $uid');
      _currentUser = null;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('[AUTH-TRACE] Error tidak terduga saat memuat user: $e');
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

      final uid = credential.user!.uid;

      // Muat profil dan verifikasi role dari Firestore
      final user = await _loadUserFromFirestore(uid);

      if (user == null || !user.hasValidRole) {
        // Role pengguna tidak ditemukan atau tidak valid di Firestore
        await FirebaseAuth.instance.signOut();
        _currentUser = null;
        notifyListeners();
        return 'Akun Anda berhasil masuk autentikasi, namun role pengguna tidak ditemukan pada koleksi Firestore. Pastikan akun terdaftar di koleksi "admins" (untuk Admin) atau "users" (untuk Pasien).';
      }

      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (e) {
      return 'Terjadi kesalahan saat masuk: $e';
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
    // Jika dokter, set offline terlebih dahulu
    if (_currentUser?.isDoctor == true) {
      final uid = _currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        await DoctorPresenceService().setOffline(uid);
      }
    }
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
