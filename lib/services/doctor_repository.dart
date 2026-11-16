import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/consultation/doctor_data.dart';
import '../models/doctor_model.dart';

/// Single source of truth untuk manajemen data dokter Osteo.
/// Digunakan bersama oleh POV Admin (CRUD dokter) dan POV Pasien (daftar, profil, jadwal, konsultasi).
/// Mendukung sinkronisasi realtime melalui Cloud Firestore koleksi `doctors`
/// sekaligus reaktif lokal via [ChangeNotifier].
class DoctorRepository extends ChangeNotifier {
  static final DoctorRepository _instance = DoctorRepository._internal();
  factory DoctorRepository() => _instance;

  DoctorRepository._internal() {
    _initLocalDoctors();
    _initFirestoreListener();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _doctorsRef =>
      _firestore?.collection('doctors');

  final List<DoctorModel> _doctors = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _hasSyncedWithFirestore = false;

  // ===========================================================================
  // GETTERS UNTUK ADMIN & PASIEN
  // ===========================================================================

  /// Semua dokter (Admin: mencakup dokter aktif dan nonaktif)
  List<DoctorModel> get allDoctors => List.unmodifiable(_doctors);

  /// Kompatibilitas untuk kode yang memanggil `.doctors`
  List<DoctorModel> get doctors => allDoctors;

  /// Dokter aktif (Pasien: hanya menampilkan dokter yang aktif di sistem)
  List<DoctorModel> get activeDoctors =>
      List.unmodifiable(_doctors.where((d) => d.isActive).toList());

  /// Metrik dokter untuk Dashboard Admin
  int get totalCount => _doctors.length;
  int get activeCount => activeDoctors.length;
  int get inactiveCount => _doctors.where((d) => !d.isActive).length;

  // ===========================================================================
  // INISIALISASI & SINKRONISASI
  // ===========================================================================

  /// Memuat data dokter awal dari [initialDoctorList] tanpa duplikasi definisi
  void _initLocalDoctors() {
    _doctors.clear();
    _doctors.addAll(initialDoctorList);
  }

  /// Mendengarkan perubahan koleksi `doctors` di Firestore secara realtime.
  /// Menjadikan Cloud Firestore sebagai Single Source of Truth mutlak.
  void _initFirestoreListener() {
    _subscription?.cancel();
    final ref = _doctorsRef;
    if (ref == null) return;

    try {
      _subscription = ref.snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _hasSyncedWithFirestore = true;
          final List<DoctorModel> remoteDoctors = [];

          for (final doc in snapshot.docs) {
            final item = DoctorModel.fromFirestore(doc);
            remoteDoctors.add(item);
          }

          _doctors.clear();
          _doctors.addAll(remoteDoctors);
          notifyListeners();
        } else if (_hasSyncedWithFirestore) {
          // Jika koleksi di Firestore sudah disinkronisasi dan kemudian dikosongkan
          _doctors.clear();
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint('[DoctorRepository] Firestore snapshot error: $e');
      });
    } catch (e) {
      debugPrint('[DoctorRepository] Error starting listener: $e');
    }
  }

  // ===========================================================================
  // OPERASI CRUD ADMIN (TERHUBUNG KE FIRESTORE DAN LOKAL REAKTIF)
  // ===========================================================================

  /// Menambah dokter baru (Admin)
  Future<String> addDoctor(DoctorModel doctor) async {
    final ref = _doctorsRef;
    final finalId = doctor.id.isNotEmpty
        ? doctor.id
        : (ref != null
            ? ref.doc().id
            : 'doc_${DateTime.now().millisecondsSinceEpoch}');
    final toSave = doctor.copyWith(id: finalId);

    // 1. Tambahkan ke memori lokal seketika agar UI Admin & Pasien langsung reaktif
    _doctors.removeWhere((d) => d.id == finalId);
    _doctors.insert(0, toSave);
    notifyListeners();

    // 2. Simpan ke koleksi Firestore `doctors` jika Firestore aktif
    if (ref != null) {
      try {
        await ref.doc(finalId).set({
          ...toSave.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('[DoctorRepository] Error saving doctor to Firestore: $e');
      }
    }
    return finalId;
  }

  /// Memperbarui data dokter (Admin)
  Future<void> updateDoctor(DoctorModel updated) async {
    // 1. Perbarui di memori lokal seketika
    final index = _doctors.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _doctors[index] = updated;
    } else {
      _doctors.insert(0, updated);
    }
    notifyListeners();

    // 2. Simpan ke Firestore jika aktif
    final ref = _doctorsRef;
    if (ref != null) {
      try {
        await ref.doc(updated.id).set({
          ...updated.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[DoctorRepository] Error updating doctor in Firestore: $e');
      }
    }
  }

  /// Menghapus dokter (Admin)
  Future<void> deleteDoctor(String id) async {
    // 1. Hapus dari memori lokal seketika
    _doctors.removeWhere((d) => d.id == id);
    notifyListeners();

    // 2. Hapus dokumen dari Firestore jika aktif
    final ref = _doctorsRef;
    if (ref != null) {
      try {
        await ref.doc(id).delete();
      } catch (e) {
        debugPrint('[DoctorRepository] Error deleting doctor in Firestore: $e');
      }
    }
  }

  /// Mengaktifkan atau menonaktifkan dokter (Admin)
  Future<void> toggleDoctorActiveStatus(String id) async {
    final index = _doctors.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated =
          _doctors[index].copyWith(isActive: !_doctors[index].isActive);
      await updateDoctor(updated);
    }
  }

  /// Mencari dokter berdasarkan ID
  DoctorModel? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Seeding dokter default ke Firestore jika koleksi masih kosong
  Future<void> seedDefaultDoctorsIfEmpty() async {
    final ref = _doctorsRef;
    final fs = _firestore;
    if (ref == null || fs == null) return;

    try {
      final snapshot = await ref.limit(1).get();
      if (snapshot.docs.isNotEmpty) return;

      final batch = fs.batch();
      for (final item in initialDoctorList) {
        final docRef = ref.doc(item.id);
        batch.set(docRef, {
          ...item.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('[DoctorRepository] Seeded default doctors to Firestore.');
    } catch (e) {
      debugPrint('[DoctorRepository] Error seeding default doctors: $e');
    }
  }

  /// Stream daftar dokter aktif untuk POV Pasien
  Stream<List<DoctorModel>> streamActiveDoctors() {
    final ref = _doctorsRef;
    if (ref == null) {
      return Stream.value(activeDoctors);
    }
    return ref.snapshots().map((snapshot) {
      return activeDoctors;
    }).handleError((_) => activeDoctors);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

