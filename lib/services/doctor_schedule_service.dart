import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:oste/models/doctor_schedule_model.dart';
import 'package:oste/services/user_service.dart';

/// Layanan Real-time Pengelolaan Jadwal Praktik Dokter OsteoCare
class DoctorScheduleService extends ChangeNotifier {
  static final DoctorScheduleService _instance =
      DoctorScheduleService._internal();
  factory DoctorScheduleService() => _instance;

  DoctorScheduleService._internal() {
    startListening();
  }

  final Map<String, DoctorSchedule> _schedules = {};
  DoctorSchedule? _latestDoctorSchedule;
  StreamSubscription<QuerySnapshot>? _schedulesSubscription;
  StreamSubscription<QuerySnapshot>? _presenceSubscription;
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  bool _isListening = false;

  /// Memulai sinkronisasi real-time seluruh jadwal dokter dari Firestore
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    // 1. Saluran Utama: Dengarkan dari koleksi 'doctor_presence'
    // Koleksi ini memiliki izin baca global (isAuthenticated()) dan izin tulis resmi (isOwner())
    try {
      _presenceSubscription = FirebaseFirestore.instance
          .collection('doctor_presence')
          .snapshots(includeMetadataChanges: true)
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final rawSchedule = data['schedule'];
          final docId = data['doctorId']?.toString() ?? '';
          final uid = doc.id;

          if (rawSchedule != null && rawSchedule is Map) {
            final schedule = DoctorSchedule.fromMap(
              rawSchedule,
              defaultId: docId.isNotEmpty ? docId : uid,
            );
            _latestDoctorSchedule = schedule;
            _schedules[schedule.doctorId] = schedule;
            if (docId.isNotEmpty) _schedules[docId] = schedule;
            _schedules[uid] = schedule;
            // Sinkronkan ke 'doc_1' sebagai ID profil dokter utama di katalog
            _schedules['doc_1'] = schedule.copyWith(doctorId: 'doc_1');
          }
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DoctorScheduleService] Error listener doctor_presence: $e');
      });
    } catch (e) {
      debugPrint('[DoctorScheduleService] Gagal subscribe doctor_presence: $e');
    }

    // 2. Saluran Kedua: Dengarkan dari koleksi 'doctor_schedules'
    try {
      _schedulesSubscription = FirebaseFirestore.instance
          .collection('doctor_schedules')
          .snapshots(includeMetadataChanges: true)
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final schedule = DoctorSchedule.fromFirestore(doc);
          _latestDoctorSchedule = schedule;
          _schedules[schedule.doctorId] = schedule;
          _schedules[doc.id] = schedule;
          _schedules['doc_1'] = schedule.copyWith(doctorId: 'doc_1');
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DoctorScheduleService] Note: doctor_schedules fallback to presence: $e');
      });
    } catch (e) {
      debugPrint('[DoctorScheduleService] Gagal subscribe doctor_schedules: $e');
    }

    // 3. Saluran Ketiga: Dengarkan jadwal dari koleksi 'users' dokter
    try {
      _usersSubscription = FirebaseFirestore.instance
          .collection('users')
          .snapshots(includeMetadataChanges: true)
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final rawSchedule = data['schedule'];
          final role = data['role']?.toString().toLowerCase().trim() ?? '';
          final uid = doc.id;

          if (rawSchedule != null && rawSchedule is Map) {
            final schedule = DoctorSchedule.fromMap(
              rawSchedule,
              defaultId: uid,
            );
            _latestDoctorSchedule = schedule;
            _schedules[schedule.doctorId] = schedule;
            _schedules[uid] = schedule;
            _schedules['doc_1'] = schedule.copyWith(doctorId: 'doc_1');
          } else if (role == 'doctor' || role == 'dokter') {
            // Ambil dari field status dan jam jika ada
            final bool? isPracticeActive = data['isPracticeActive'] as bool?;
            if (isPracticeActive != null && _schedules.containsKey('doc_1')) {
              _schedules['doc_1'] = _schedules['doc_1']!.copyWith(
                isActive: isPracticeActive,
              );
            }
          }
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('[DoctorScheduleService] users listener note: $e');
      });
    } catch (e) {
      debugPrint('[DoctorScheduleService] Gagal subscribe users: $e');
    }
  }

  /// Mengambil jadwal praktik dokter berdasarkan doctorId
  DoctorSchedule getSchedule(String doctorId, {String? fallbackDoctorName}) {
    // 1. Cek langsung pada cache map
    if (_schedules.containsKey(doctorId)) {
      return _schedules[doctorId]!;
    }

    // 2. Jika doctorId adalah 'doc_1' dan sudah ada jadwal terbaru yang tersimpan
    if ((doctorId == 'doc_1' || doctorId.isEmpty) && _latestDoctorSchedule != null) {
      return _latestDoctorSchedule!;
    }

    // 3. Cek linkedDoctorId atau UID pengguna aktif
    final currentUser = UserService().currentUser;
    if (currentUser != null) {
      if (currentUser.linkedDoctorId.isNotEmpty &&
          _schedules.containsKey(currentUser.linkedDoctorId)) {
        return _schedules[currentUser.linkedDoctorId]!;
      }
      if (currentUser.uid.isNotEmpty &&
          _schedules.containsKey(currentUser.uid)) {
        return _schedules[currentUser.uid]!;
      }
    }

    // 4. Jika ada jadwal yang telah diedit di aplikasi, gunakan sebagai fallback utama
    if (_latestDoctorSchedule != null && doctorId == 'doc_1') {
      return _latestDoctorSchedule!;
    }

    // 5. Fallback default awal jika belum ada jadwal yang tersimpan di Firestore
    return DoctorSchedule.defaultSchedule(
      doctorId,
      doctorName: fallbackDoctorName ?? currentUser?.name,
    );
  }

  /// Stream jadwal dokter tertentu untuk widget reaktif
  Stream<DoctorSchedule> getScheduleStream(String doctorId,
      {String? fallbackDoctorName}) {
    return FirebaseFirestore.instance
        .collection('doctor_presence')
        .snapshots(includeMetadataChanges: true)
        .map((_) => getSchedule(doctorId, fallbackDoctorName: fallbackDoctorName))
        .handleError((_) {
      return getSchedule(doctorId, fallbackDoctorName: fallbackDoctorName);
    });
  }

  /// Menyimpan dan menyinkronkan jadwal praktik dokter ke Firestore
  Future<void> saveSchedule(DoctorSchedule schedule) async {
    final authUser = FirebaseAuth.instance.currentUser;
    final currentUser = UserService().currentUser;
    final doctorUid = (authUser != null && authUser.uid.isNotEmpty)
        ? authUser.uid
        : (currentUser?.uid ?? '');
    final linkedId = currentUser?.linkedDoctorId.isNotEmpty == true
        ? currentUser!.linkedDoctorId
        : 'doc_1';

    // 1. Update cache lokal seketika agar UI langsung responsif tanpa delay
    _latestDoctorSchedule = schedule;
    _schedules[schedule.doctorId] = schedule;
    if (doctorUid.isNotEmpty) _schedules[doctorUid] = schedule;
    if (linkedId.isNotEmpty) _schedules[linkedId] = schedule;
    // Hubungkan juga ke 'doc_1' yang merupakan dokter utama di katalog pasien & admin
    _schedules['doc_1'] = schedule.copyWith(doctorId: 'doc_1');
    notifyListeners();

    // 2. Saluran 1: Simpan ke 'doctor_presence/{doctorUid}'
    if (doctorUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('doctor_presence')
            .doc(doctorUid)
            .set({
          'schedule': schedule.toMap(),
          'doctorId': 'doc_1',
          'linkedDoctorId': linkedId,
          'doctorUid': doctorUid,
          'isPracticeActive': schedule.isActive,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('[DoctorScheduleService] Sukses simpan jadwal ke doctor_presence/$doctorUid');
      } catch (e) {
        debugPrint('[DoctorScheduleService] Note: doctor_presence write error: $e');
      }
    }

    // 3. Saluran 2: Simpan ke 'users/{doctorUid}'
    if (doctorUid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorUid)
            .set({
          'schedule': schedule.toMap(),
          'schedules':
              '${schedule.getRepeatDaysFormatted()}, ${schedule.getFormattedTimeRange()}',
          'isPracticeActive': schedule.isActive,
        }, SetOptions(merge: true));
        debugPrint('[DoctorScheduleService] Sukses update profil users/$doctorUid');
      } catch (e) {
        debugPrint('[DoctorScheduleService] Note: users write error: $e');
      }
    }

    // 4. Saluran 3: Simpan ke 'doctor_schedules' ('doc_1' dan ID dokter)
    try {
      await FirebaseFirestore.instance
          .collection('doctor_schedules')
          .doc('doc_1')
          .set(schedule.copyWith(doctorId: 'doc_1').toMap(), SetOptions(merge: true));

      if (schedule.doctorId != 'doc_1') {
        await FirebaseFirestore.instance
            .collection('doctor_schedules')
            .doc(schedule.doctorId)
            .set(schedule.toMap(), SetOptions(merge: true))
            .catchError((_) {});
      }
      if (doctorUid.isNotEmpty && doctorUid != schedule.doctorId) {
        await FirebaseFirestore.instance
            .collection('doctor_schedules')
            .doc(doctorUid)
            .set(schedule.copyWith(doctorId: doctorUid).toMap(), SetOptions(merge: true))
            .catchError((_) {});
      }
      debugPrint('[DoctorScheduleService] Sukses simpan ke doctor_schedules');
    } catch (e) {
      debugPrint('[DoctorScheduleService] Note: doctor_schedules write error: $e');
    }

    notifyListeners();
  }

  /// Mengambil seluruh jadwal dokter yang tersimpan
  List<DoctorSchedule> getAllSchedules() {
    return _schedules.values.toList();
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    _presenceSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }
}
