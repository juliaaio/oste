import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/education_model.dart';

/// Single source of truth untuk materi edukasi Osteo (Latihan, Nutrisi, Vitamin).
/// Terhubung secara realtime dengan Cloud Firestore koleksi `education`
/// sekaligus reaktif lokal via [ChangeNotifier].
class EducationRepository extends ChangeNotifier {
  static final EducationRepository _instance =
      EducationRepository._internal();
  factory EducationRepository() => _instance;

  EducationRepository._internal() {
    _initLocalEducations();
    _setupAuthListener();
    _initFirestoreListener();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('[EDUCATION-TRACE] FirebaseFirestore.instance belum siap: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _educationRef {
    final fs = _firestore;
    if (fs == null) return null;
    return fs.collection('education');
  }

  final List<EducationModel> _educations = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  StreamSubscription<User?>? _authSubscription;
  bool _hasSyncedWithFirestore = false;

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Semua materi edukasi (Latihan, Nutrisi, Vitamin)
  List<EducationModel> get allEducations => List.unmodifiable(_educations);

  /// Jumlah total materi edukasi
  int get totalCount => _educations.length;

  /// Status apakah repository sudah berhasil disinkronisasi dengan Firestore
  bool get hasSyncedWithFirestore => _hasSyncedWithFirestore;

  /// Filter materi edukasi berdasarkan kategori ('Semua', 'Latihan', 'Nutrisi', 'Vitamin')
  List<EducationModel> getEducationsByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'semua') {
      return allEducations;
    }
    return List.unmodifiable(
      _educations
          .where(
            (e) => e.category.toLowerCase().trim() == category.toLowerCase().trim(),
          )
          .toList(),
    );
  }

  // ===========================================================================
  // INISIALISASI & SINKRONISASI FIRESTORE
  // ===========================================================================

  void _initLocalEducations() {
    _educations.clear();
    _educations.addAll(initialEducationList);
    debugPrint('[EDUCATION-TRACE] Data lokal awal dimuat: ${_educations.length} materi edukasi.');
  }

  /// Reset data lokal ke initialEducationList (berguna untuk pengujian widget & unit test)
  @visibleForTesting
  void resetForTesting() {
    _initLocalEducations();
    _hasSyncedWithFirestore = false;
    notifyListeners();
  }

  void _setupAuthListener() {
    try {
      _authSubscription?.cancel();
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        debugPrint(
            '[EDUCATION-TRACE] Auth state terdeteksi: uid=${user?.uid ?? "(belum login)"}, email=${user?.email ?? "-"}');
        // Sambungkan ulang listener Firestore setiap kali status autentikasi berubah
        _initFirestoreListener();
      });
    } catch (e) {
      debugPrint('[EDUCATION-TRACE] FirebaseAuth authStateChanges tidak tersedia: $e');
    }
  }

  /// Memastikan listener Firestore aktif (dapat dipanggil saat halaman dibuka)
  void ensureListener() {
    if (_subscription == null && _educationRef != null) {
      _initFirestoreListener();
    }
  }

  void _initFirestoreListener() {
    _subscription?.cancel();
    final ref = _educationRef;
    if (ref == null) {
      debugPrint(
          '[EDUCATION-TRACE] [WARN] _educationRef bernilai null. Firestore belum siap atau Firebase belum diinisialisasi.');
      return;
    }

    debugPrint(
        '[EDUCATION-TRACE] Memulai Firestore snapshots listener pada koleksi "education"...');

    try {
      _subscription = ref.snapshots().listen((snapshot) {
        _hasSyncedWithFirestore = true;
        debugPrint(
            '[EDUCATION-TRACE] Snapshot diterima dari Firestore koleksi "education": ${snapshot.docs.length} dokumen.');

        final List<EducationModel> remoteItems = [];

        // Urutkan dokumen: terbaru di atas berdasarkan createdAt
        final docs = snapshot.docs.toList()
          ..sort((a, b) {
            final ca = a.data()['createdAt'];
            final cb = b.data()['createdAt'];
            if (ca is Timestamp && cb is Timestamp) {
              return cb.compareTo(ca);
            }
            return 0;
          });

        for (final doc in docs) {
          remoteItems.add(EducationModel.fromFirestore(doc));
        }

        _educations.clear();
        _educations.addAll(remoteItems);
        notifyListeners();

        debugPrint(
            '[EDUCATION-TRACE] ✅ Cache lokal EducationRepository disinkronkan dengan Firestore (${_educations.length} item).');
      }, onError: (e, stack) {
        debugPrint(
            '[EDUCATION-TRACE] ❌ Error pada Firestore listener koleksi "education": $e');
        debugPrint('[EDUCATION-TRACE] Stack trace listener: $stack');
      });
    } catch (e, stack) {
      debugPrint('[EDUCATION-TRACE] ❌ Gagal inisialisasi listener Firestore: $e');
      debugPrint('[EDUCATION-TRACE] Stack trace init: $stack');
    }
  }

  // ===========================================================================
  // OPERASI CRUD ADMIN (TERHUBUNG KE FIRESTORE DAN LOKAL REAKTIF)
  // ===========================================================================

  /// Menambah materi edukasi baru (Admin)
  Future<String> addEducation(EducationModel item) async {
    final ref = _educationRef;
    final finalId = item.id.isNotEmpty
        ? item.id
        : (ref != null
            ? ref.doc().id
            : 'edu_${DateTime.now().millisecondsSinceEpoch}');

    final toSave = item.copyWith(
      id: finalId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint(
        '[EDUCATION-TRACE] [ADD] Memulai penambahan edukasi: ID=$finalId, Judul="${toSave.title}", Kategori="${toSave.category}"');

    // 1. Simpan di memori lokal agar UI responsif seketika
    _educations.removeWhere((e) => e.id == finalId);
    _educations.insert(0, toSave);
    notifyListeners();

    // 2. Simpan ke koleksi Firestore `education`
    if (ref != null) {
      try {
        debugPrint(
            '[EDUCATION-TRACE] [ADD] Menulis dokumen ke Firestore path: "education/$finalId"...');
        await ref.doc(finalId).set({
          ...toSave.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint(
            '[EDUCATION-TRACE] [ADD] ✅ Berhasil menulis dokumen "education/$finalId" ke Firestore!');
      } catch (e, stack) {
        debugPrint('[EDUCATION-TRACE] [ADD] ❌ GAGAL menyimpan ke Firestore: $e');
        debugPrint('[EDUCATION-TRACE] [ADD] Stack trace: $stack');
        rethrow;
      }
    } else {
      debugPrint(
          '[EDUCATION-TRACE] [ADD] ⚠️ Koleksi Firestore tidak tersedia (ref == null). Disimpan hanya di memori lokal.');
    }

    return finalId;
  }

  /// Memperbarui materi edukasi (Admin)
  Future<void> updateEducation(EducationModel updated) async {
    final toSave = updated.copyWith(updatedAt: DateTime.now());
    debugPrint(
        '[EDUCATION-TRACE] [UPDATE] Memulai pembaruan edukasi: ID=${toSave.id}, Judul="${toSave.title}", Kategori="${toSave.category}"');

    // 1. Perbarui di memori lokal
    final index = _educations.indexWhere((e) => e.id == toSave.id);
    if (index != -1) {
      _educations[index] = toSave;
    } else {
      _educations.insert(0, toSave);
    }
    notifyListeners();

    // 2. Simpan ke Firestore
    final ref = _educationRef;
    if (ref != null) {
      try {
        debugPrint(
            '[EDUCATION-TRACE] [UPDATE] Menulis pembaruan ke Firestore path: "education/${toSave.id}"...');
        await ref.doc(toSave.id).set({
          ...toSave.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint(
            '[EDUCATION-TRACE] [UPDATE] ✅ Berhasil memperbarui dokumen "education/${toSave.id}" di Firestore!');
      } catch (e, stack) {
        debugPrint(
            '[EDUCATION-TRACE] [UPDATE] ❌ GAGAL memperbarui di Firestore: $e');
        debugPrint('[EDUCATION-TRACE] [UPDATE] Stack trace: $stack');
        rethrow;
      }
    } else {
      debugPrint(
          '[EDUCATION-TRACE] [UPDATE] ⚠️ Koleksi Firestore tidak tersedia (ref == null).');
    }
  }

  /// Menghapus materi edukasi (Admin)
  Future<void> deleteEducation(String id) async {
    debugPrint('[EDUCATION-TRACE] [DELETE] Memulai penghapusan edukasi: ID=$id');

    // 1. Hapus dari memori lokal
    _educations.removeWhere((e) => e.id == id);
    notifyListeners();

    // 2. Hapus dari Firestore
    final ref = _educationRef;
    if (ref != null) {
      try {
        debugPrint(
            '[EDUCATION-TRACE] [DELETE] Menghapus dokumen dari Firestore path: "education/$id"...');
        await ref.doc(id).delete();
        debugPrint(
            '[EDUCATION-TRACE] [DELETE] ✅ Berhasil menghapus dokumen "education/$id" dari Firestore!');
      } catch (e, stack) {
        debugPrint(
            '[EDUCATION-TRACE] [DELETE] ❌ GAGAL menghapus dari Firestore: $e');
        debugPrint('[EDUCATION-TRACE] [DELETE] Stack trace: $stack');
        rethrow;
      }
    } else {
      debugPrint(
          '[EDUCATION-TRACE] [DELETE] ⚠️ Koleksi Firestore tidak tersedia (ref == null).');
    }
  }

  /// Mengambil materi edukasi berdasarkan ID
  EducationModel? getEducationById(String id) {
    try {
      return _educations.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
