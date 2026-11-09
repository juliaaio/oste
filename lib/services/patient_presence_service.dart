import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Layanan singleton untuk mengelola status online/offline pasien secara real-time
/// menggunakan Cloud Firestore sebagai backend presence.
///
/// Struktur Firestore:
///   patient_presence/{patientUid}
///     - isOnline: bool
///     - lastSeen: Timestamp
///     - patientUid: String
///     - patientName: String
///
class PatientPresenceService extends ChangeNotifier {
  static final PatientPresenceService _instance =
      PatientPresenceService._internal();
  factory PatientPresenceService() => _instance;
  PatientPresenceService._internal();

  static const _collection = 'patient_presence';

  // Cache status online per patientUid (misal 'patient_123', 'user_abc', dst.)
  final Map<String, bool> _onlineStatus = {};

  // Subscription stream untuk koleksi penuh atau per dokumen
  StreamSubscription<QuerySnapshot>? _allSubscription;
  final Map<String, StreamSubscription<DocumentSnapshot>> _docSubscriptions = {};

  // ── SISI PASIEN (set status) ────────────────────────────────────────────────

  /// Set status pasien menjadi Online di Firestore.
  /// Dipanggil saat pasien login, membuka Dashboard, membuka chat, atau aplikasi resume.
  Future<void> setOnline(String patientUid, {String patientName = ''}) async {
    if (patientUid.isEmpty) return;

    _onlineStatus[patientUid] = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(patientUid)
          .set({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'patientUid': patientUid,
        if (patientName.isNotEmpty) 'patientName': patientName,
      }, SetOptions(merge: true));
      debugPrint('[PatientPresence] $patientUid set ONLINE');
    } catch (e) {
      debugPrint('[PatientPresence] Gagal set online: $e');
    }
  }

  /// Set status pasien menjadi Offline di Firestore.
  /// Dipanggil saat pasien logout, app ke background (paused), atau aplikasi ditutup.
  Future<void> setOffline(String patientUid) async {
    if (patientUid.isEmpty) return;

    _onlineStatus[patientUid] = false;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(patientUid)
          .set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[PatientPresence] $patientUid set OFFLINE');
    } catch (e) {
      debugPrint('[PatientPresence] Gagal set offline: $e');
    }
  }

  // ── SISI DOKTER (listen status) ──────────────────────────────────────────────

  /// Mulai mendengarkan status online seluruh pasien secara real-time.
  /// Dipanggil saat tab daftar percakapan pasien (DoctorChatListTab) aktif.
  void startListeningAllPatients() {
    if (_allSubscription != null) return;

    try {
      _allSubscription = FirebaseFirestore.instance
          .collection(_collection)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final patientUid = doc.id;
          final isOnline = data['isOnline'] as bool? ?? false;
          _onlineStatus[patientUid] = isOnline;
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[PatientPresence] Error stream all: $e');
      });
      debugPrint('[PatientPresence] Mulai mendengarkan status seluruh pasien');
    } catch (e) {
      debugPrint('[PatientPresence] Gagal memulai all listener: $e');
    }
  }

  /// Mulai mendengarkan status online untuk satu pasien spesifik secara real-time.
  /// Dipanggil saat dokter berada di dalam ruang chat (ChatPage) dengan pasien tersebut.
  void startListeningPatient(String patientUid) {
    if (patientUid.isEmpty || _docSubscriptions.containsKey(patientUid)) return;

    try {
      final sub = FirebaseFirestore.instance
          .collection(_collection)
          .doc(patientUid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          _onlineStatus[patientUid] = data['isOnline'] as bool? ?? false;
        } else {
          _onlineStatus[patientUid] = _onlineStatus[patientUid] ?? false;
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[PatientPresence] Error stream patient $patientUid: $e');
      });

      _docSubscriptions[patientUid] = sub;
      debugPrint('[PatientPresence] Mulai mendengarkan pasien: $patientUid');
    } catch (e) {
      debugPrint('[PatientPresence] Gagal memulai listener pasien $patientUid: $e');
    }
  }

  /// Hentikan listener satu pasien tertentu.
  void stopListeningPatient(String patientUid) {
    _docSubscriptions[patientUid]?.cancel();
    _docSubscriptions.remove(patientUid);
  }

  /// Hentikan semua listener pasien.
  void stopListeningAllPatients() {
    _allSubscription?.cancel();
    _allSubscription = null;

    for (final sub in _docSubscriptions.values) {
      sub.cancel();
    }
    _docSubscriptions.clear();
  }

  /// Mengecek apakah pasien sedang online berdasarkan cache realtime Firestore.
  /// Jika belum ada di Firestore cache, nilai [fallback] akan digunakan.
  bool isOnline(String patientId, {bool? fallback}) {
    if (patientId.isEmpty) return fallback ?? false;

    if (_onlineStatus.containsKey(patientId)) {
      return _onlineStatus[patientId]!;
    }

    // Jika belum ada listener aktif, daftarkan listener dokumen pasien ini secara otomatis
    if (_allSubscription == null && !_docSubscriptions.containsKey(patientId)) {
      startListeningPatient(patientId);
    }

    return fallback ?? false;
  }

  /// Stream status online untuk satu pasien tertentu (berdasarkan UID pasien).
  Stream<bool> onlineStream(String patientUid) {
    if (patientUid.isEmpty) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(patientUid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final online = doc.data()?['isOnline'] as bool? ?? false;
      _onlineStatus[patientUid] = online;
      notifyListeners();
      return online;
    });
  }

  // ── UNTUK TESTING / MOCK ────────────────────────────────────────────────────

  @visibleForTesting
  void setMockStatus(String patientUid, bool isOnline) {
    _onlineStatus[patientUid] = isOnline;
    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _onlineStatus.clear();
    stopListeningAllPatients();
  }
}

