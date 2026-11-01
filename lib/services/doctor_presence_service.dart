import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Layanan singleton untuk mengelola status online/offline dokter secara real-time
/// menggunakan Cloud Firestore sebagai backend presence.
///
/// Struktur Firestore:
///   doctor_presence/{doctorUid}
///     - isOnline: bool
///     - lastSeen: Timestamp
///     - doctorId: String  (doc_1, doc_2, dst.)
///
class DoctorPresenceService extends ChangeNotifier {
  static final DoctorPresenceService _instance =
      DoctorPresenceService._internal();
  factory DoctorPresenceService() => _instance;
  DoctorPresenceService._internal();

  static const _collection = 'doctor_presence';

  // Cache status online per doctorId (bukan UID, karena client pakai doctorId seperti 'doc_1')
  final Map<String, bool> _onlineStatus = {};

  // Subscription stream per doctorId
  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};

  // ── SISI DOKTER (set status) ────────────────────────────────────────────────

  /// Set status dokter menjadi Online di Firestore.
  /// Dipanggil saat DoctorDashboardPage dibuka / dokter login.
  Future<void> setOnline(String doctorUid, {String doctorId = ''}) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(doctorUid)
          .set({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'doctorUid': doctorUid,
        'doctorId': doctorId,
      }, SetOptions(merge: true));
      debugPrint('[DoctorPresence] $doctorUid set ONLINE');
    } catch (e) {
      debugPrint('[DoctorPresence] Gagal set online: $e');
    }
  }

  /// Set status dokter menjadi Offline di Firestore.
  /// Dipanggil saat DoctorDashboardPage di-dispose / dokter logout.
  Future<void> setOffline(String doctorUid) async {
    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(doctorUid)
          .set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[DoctorPresence] $doctorUid set OFFLINE');
    } catch (e) {
      debugPrint('[DoctorPresence] Gagal set offline: $e');
    }
  }

  // ── SISI PASIEN (listen status) ──────────────────────────────────────────────

  /// Mulai mendengarkan status online semua dokter secara real-time.
  /// Mendengarkan seluruh koleksi doctor_presence sekaligus.
  void startListeningAllDoctors() {
    if (_subscriptions.containsKey('_all')) return;

    try {
      final sub = FirebaseFirestore.instance
          .collection(_collection)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final doctorId = data['doctorId']?.toString() ?? '';
          final doctorUid = doc.id;
          final isOnline = data['isOnline'] as bool? ?? false;

          // Simpan di cache dengan kedua key (UID dan doctorId)
          if (doctorId.isNotEmpty) {
            _onlineStatus[doctorId] = isOnline;
          }
          _onlineStatus[doctorUid] = isOnline;
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DoctorPresence] Error stream: $e');
      });

      _subscriptions['_all'] = sub;
      debugPrint('[DoctorPresence] Mulai mendengarkan status semua dokter');
    } catch (e) {
      debugPrint('[DoctorPresence] Gagal memulai listener: $e');
    }
  }

  /// Hentikan semua listener
  void stopListeningAllDoctors() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Ambil status online dokter dari cache.
  /// [doctorId] bisa berupa 'doc_1', 'doc_2', atau UID Firebase.
  bool isOnline(String doctorId) {
    if (!_subscriptions.containsKey('_all')) {
      startListeningAllDoctors();
    }
    return _onlineStatus[doctorId] ?? false;
  }

  /// Stream status online untuk satu dokter tertentu (berdasarkan UID dokter).
  Stream<bool> onlineStream(String doctorUid) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(doctorUid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      return doc.data()?['isOnline'] as bool? ?? false;
    });
  }
}
