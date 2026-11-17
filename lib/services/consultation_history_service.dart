import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/consultation_history_model.dart';
import 'package:oste/services/user_service.dart';

/// Layanan untuk mengelola penyimpanan & riwayat konsultasi medis via Firebase Firestore
class ConsultationHistoryService extends ChangeNotifier {
  static final ConsultationHistoryService _instance =
      ConsultationHistoryService._internal();

  factory ConsultationHistoryService() => _instance;

  ConsultationHistoryService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<ConsultationHistory> _histories = [];

  List<ConsultationHistory> get allConsultations =>
      List.unmodifiable(_histories);

  /// Helper untuk mendapatkan path collection: users/{uid}/riwayat_konsultasi
  CollectionReference<Map<String, dynamic>>? _userHistoryRef(String uid) {
    return _firestore?.collection('users').doc(uid).collection('riwayat_konsultasi');
  }

  /// Helper untuk mendapatkan UID aktif
  String _getActiveUserId() {
    try {
      return FirebaseAuth.instance.currentUser?.uid ??
          UserService().currentUser?.uid ??
          '';
    } catch (_) {
      return UserService().currentUser?.uid ?? '';
    }
  }

  /// Stream riwayat konsultasi untuk user/pasien secara realtime dari Firestore
  Stream<List<ConsultationHistory>> streamUserConsultations([String? userId]) {
    final uid = userId ?? _getActiveUserId();
    final ref = uid.isNotEmpty ? _userHistoryRef(uid) : null;
    if (ref == null) {
      return Stream.value(const []);
    }

    return ref.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ConsultationHistory.fromFirestore(doc);
      }).toList();

      // Urutkan dari yang terbaru (completedAt atau createdAt atau DateTime.now())
      list.sort((a, b) {
        final aTime = a.completedAt ?? a.createdAt;
        final bTime = b.completedAt ?? b.createdAt;
        if (aTime != null && bTime != null) {
          return bTime.compareTo(aTime);
        }
        return b.id.compareTo(a.id);
      });

      // Update cache in-memory untuk listeners lokal
      _histories.clear();
      _histories.addAll(list);

      return list;
    });
  }

  /// Stream riwayat konsultasi untuk dokter via collectionGroup('riwayat_konsultasi')
  Stream<List<ConsultationHistory>> streamDoctorConsultations({String? doctorId}) {
    final fs = _firestore;
    if (fs == null) {
      return Stream.value(const []);
    }

    try {
      Query<Map<String, dynamic>> query =
          fs.collectionGroup('riwayat_konsultasi');

      if (doctorId != null && doctorId.isNotEmpty) {
        query = query.where('doctorId', isEqualTo: doctorId);
      }

      return query.snapshots().map((snapshot) {
        final list = snapshot.docs.map((doc) {
          return ConsultationHistory.fromFirestore(doc);
        }).toList();

        list.sort((a, b) {
          final aTime = a.completedAt ?? a.createdAt;
          final bTime = b.completedAt ?? b.createdAt;
          if (aTime != null && bTime != null) {
            return bTime.compareTo(aTime);
          }
          return b.id.compareTo(a.id);
        });

        return list;
      });
    } catch (e) {
      debugPrint('[ConsultationHistoryService] Error stream doctor history: $e');
      return Stream.value(const []);
    }
  }

  /// Menyimpan riwayat konsultasi ke Firestore: users/{uid}/riwayat_konsultasi/{consultationId}
  Future<void> saveConsultation(
    ConsultationHistory consultation, {
    String? targetUserId,
  }) async {
    final uid = targetUserId ??
        (consultation.patientId.isNotEmpty
            ? consultation.patientId
            : _getActiveUserId());

    if (uid.isEmpty) {
      debugPrint(
          '[ConsultationHistoryService] Gagal simpan: UID pasien tidak ditemukan.');
      return;
    }

    final ref = _userHistoryRef(uid);
    if (ref == null) {
      debugPrint(
          '[ConsultationHistoryService] Firestore belum diinisialisasi.');
      return;
    }

    try {
      final data = consultation.toFirestore();
      await ref.doc(consultation.id).set(
            data,
            SetOptions(merge: true),
          );

      debugPrint(
          '[ConsultationHistoryService] Berhasil menyimpan riwayat konsultasi: ${consultation.id} untuk user: $uid');
    } catch (e, stack) {
      debugPrint(
          '[ConsultationHistoryService] Error saat menyimpan riwayat ke Firestore: $e\n$stack');
    }
  }

  /// Menambahkan riwayat konsultasi baru (update memory lokal & persist ke Firestore)
  void addConsultation(ConsultationHistory consultation) {
    // Perbarui in-memory list
    final existingIndex =
        _histories.indexWhere((item) => item.id == consultation.id);
    if (existingIndex >= 0) {
      _histories[existingIndex] = consultation;
    } else {
      _histories.insert(0, consultation);
    }
    notifyListeners();

    // Simpan ke Firestore
    saveConsultation(consultation);
  }

  /// Mengambil daftar riwayat khusus dokter tertentu (dari memory cache jika ada)
  List<ConsultationHistory> getConsultationsByDoctorId(String doctorId) {
    return _histories
        .where((item) => item.doctorId == doctorId)
        .toList();
  }

  /// Mencari riwayat konsultasi berdasarkan ID
  ConsultationHistory? getById(String id) {
    try {
      return _histories.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus cache lokal
  void clear() {
    _histories.clear();
    notifyListeners();
  }
}
