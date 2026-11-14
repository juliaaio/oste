import 'package:cloud_firestore/cloud_firestore.dart';

/// Model Jadwal Praktik Dokter OsteoCare
class DoctorSchedule {
  final String doctorId;
  final String doctorName;
  final bool isActive; // Status praktik: true = Aktif, false = Tidak Aktif
  final String date; // Format: 'yyyy-MM-dd' (contoh: '2026-11-14')
  final String startTime; // Format: 'HH:mm' (contoh: '08:00')
  final String endTime; // Format: 'HH:mm' (contoh: '12:00')
  final List<int> repeatDays; // 1 = Senin, 2 = Selasa, ..., 7 = Minggu
  final String note; // Catatan opsional
  final DateTime? updatedAt;

  const DoctorSchedule({
    required this.doctorId,
    required this.doctorName,
    this.isActive = true,
    required this.date,
    this.startTime = '08:00',
    this.endTime = '12:00',
    this.repeatDays = const [1, 2, 3, 4, 5, 6], // Default: Senin - Sabtu
    this.note = '',
    this.updatedAt,
  });

  /// Daftar nama hari dalam Bahasa Indonesia (Senin = index 0)
  static const List<String> dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Daftar nama bulan dalam Bahasa Indonesia (Januari = index 0)
  static const List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Mendapatkan nama hari dari nilai integer (1-7)
  static String getDayName(int weekday) {
    if (weekday >= 1 && weekday <= 7) {
      return dayNames[weekday - 1];
    }
    return 'Hari';
  }

  /// Mendapatkan nama bulan dari nilai integer (1-12)
  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }

  /// Default jadwal awal jika dokter belum mengatur jadwal di Firestore
  factory DoctorSchedule.defaultSchedule(String doctorId, {String? doctorName}) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return DoctorSchedule(
      doctorId: doctorId,
      doctorName: doctorName ?? 'dr. Intan Permata, Sp.OT',
      isActive: true,
      date: dateStr,
      startTime: '08:00',
      endTime: '12:00',
      repeatDays: const [1, 2, 3, 4, 5, 6],
      note: 'Konsultasi osteoporosis & pencegahan kerapuhan tulang',
      updatedAt: now,
    );
  }

  /// Konversi dari Map (bisa dari sub-field atau DocumentSnapshot)
  factory DoctorSchedule.fromMap(Map data, {String? defaultId}) {
    final rawRepeat = data['repeatDays'];
    List<int> parsedRepeat = [1, 2, 3, 4, 5, 6];
    if (rawRepeat is List) {
      parsedRepeat = rawRepeat
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 1 && e <= 7)
          .toList();
      if (parsedRepeat.isEmpty) parsedRepeat = [1, 2, 3, 4, 5, 6];
    }

    DateTime? updated;
    final rawUpdated = data['updatedAt'];
    if (rawUpdated is Timestamp) {
      updated = rawUpdated.toDate();
    } else if (rawUpdated is String) {
      updated = DateTime.tryParse(rawUpdated);
    }

    final now = DateTime.now();
    final defaultDateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return DoctorSchedule(
      doctorId: data['doctorId']?.toString() ?? defaultId ?? '',
      doctorName: data['doctorName']?.toString() ?? '',
      isActive: data['isActive'] == true || data['isActive'] == 'true',
      date: data['date']?.toString() ?? defaultDateStr,
      startTime: data['startTime']?.toString() ?? '08:00',
      endTime: data['endTime']?.toString() ?? '12:00',
      repeatDays: parsedRepeat,
      note: data['note']?.toString() ?? '',
      updatedAt: updated,
    );
  }

  /// Konversi dari Firestore DocumentSnapshot
  factory DoctorSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DoctorSchedule.fromMap(data, defaultId: doc.id);
  }

  /// Konversi ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'isActive': isActive,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'repeatDays': repeatDays,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Salin objek dengan modifikasi nilai tertentu
  DoctorSchedule copyWith({
    String? doctorId,
    String? doctorName,
    bool? isActive,
    String? date,
    String? startTime,
    String? endTime,
    List<int>? repeatDays,
    String? note,
    DateTime? updatedAt,
  }) {
    return DoctorSchedule(
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      isActive: isActive ?? this.isActive,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeatDays: repeatDays ?? this.repeatDays,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper untuk mem-parsing jam dan menit dari format 'HH:mm'
  int _parseHour(String timeStr) {
    final parts = timeStr.split(':');
    return int.tryParse(parts[0]) ?? 8;
  }

  int _parseMinute(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length > 1) {
      return int.tryParse(parts[1]) ?? 0;
    }
    return 0;
  }

  /// Mengecek apakah hari ini ada jadwal praktik
  bool hasPracticeToday({DateTime? currentTime}) {
    if (!isActive) return false;
    final now = currentTime ?? DateTime.now();
    return repeatDays.contains(now.weekday);
  }

  /// Mengecek apakah saat ini dokter sedang dalam jam praktik
  bool isPracticingNow({DateTime? currentTime}) {
    if (!isActive) return false;
    final now = currentTime ?? DateTime.now();

    // Pastikan hari ini adalah salah satu hari jadwal berulang
    if (!repeatDays.contains(now.weekday)) return false;

    final startHour = _parseHour(startTime);
    final startMinute = _parseMinute(startTime);
    final endHour = _parseHour(endTime);
    final endMinute = _parseMinute(endTime);

    final startToday =
        DateTime(now.year, now.month, now.day, startHour, startMinute);
    final endToday = DateTime(now.year, now.month, now.day, endHour, endMinute);

    return (now.isAfter(startToday) || now.isAtSameMomentAs(startToday)) &&
        now.isBefore(endToday);
  }

  /// Teks countdown jika sedang praktik: "Sisa waktu praktik: 1 jam 20 menit"
  String getRemainingPracticeTime({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final endHour = _parseHour(endTime);
    final endMinute = _parseMinute(endTime);
    final endToday = DateTime(now.year, now.month, now.day, endHour, endMinute);

    final diff = endToday.difference(now);
    if (diff.isNegative || diff.inMinutes <= 0) {
      return 'Sisa waktu praktik: 0 menit';
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return 'Sisa waktu praktik: $hours jam $minutes menit';
    } else if (hours > 0) {
      return 'Sisa waktu praktik: $hours jam';
    } else {
      return 'Sisa waktu praktik: $minutes menit';
    }
  }

  /// Teks countdown jika sedang tidak praktik: "Praktik berikutnya dalam 12 jam"
  String getNextPracticeCountdown({DateTime? currentTime}) {
    if (!isActive) {
      return 'Status saat ini: Tidak Aktif';
    }

    final now = currentTime ?? DateTime.now();
    final startHour = _parseHour(startTime);
    final startMinute = _parseMinute(startTime);

    // Kasus 1: Hari ini terjadwal dan jam praktik belum dimulai
    if (repeatDays.contains(now.weekday)) {
      final startToday =
          DateTime(now.year, now.month, now.day, startHour, startMinute);
      if (now.isBefore(startToday)) {
        final diff = startToday.difference(now);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        if (hours > 0 && minutes > 0) {
          return 'Praktik berikutnya dalam $hours jam $minutes menit';
        } else if (hours > 0) {
          return 'Praktik berikutnya dalam $hours jam';
        } else {
          return 'Praktik berikutnya dalam $minutes menit';
        }
      }
    }

    // Kasus 2: Cari hari jadwal berikutnya dari besok (1 s/d 7 hari ke depan)
    for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
      final candidateDate = now.add(Duration(days: dayOffset));
      if (repeatDays.contains(candidateDate.weekday)) {
        final nextStart = DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          startHour,
          startMinute,
        );
        final diff = nextStart.difference(now);
        final hours = diff.inHours;

        if (hours <= 24) {
          return 'Praktik berikutnya dalam $hours jam';
        } else {
          final days = (hours / 24).ceil();
          return 'Praktik berikutnya dalam $days hari (${getDayName(candidateDate.weekday)})';
        }
      }
    }

    return 'Belum ada jadwal praktik berikutnya';
  }

  /// Jadwal praktik berikutnya lengkap (hari, tanggal, jam)
  String getNextPracticeFullString({DateTime? currentTime}) {
    if (!isActive) return 'Praktik Tidak Aktif';
    final now = currentTime ?? DateTime.now();
    final startHour = _parseHour(startTime);
    final startMinute = _parseMinute(startTime);

    // Cek apakah hari ini ada jadwal dan belum lewat
    if (repeatDays.contains(now.weekday)) {
      final startToday =
          DateTime(now.year, now.month, now.day, startHour, startMinute);
      if (now.isBefore(startToday)) {
        return 'Hari ini, ${getFormattedTimeRange()}';
      }
    }

    // Cari hari berikutnya
    for (int dayOffset = 1; dayOffset <= 7; dayOffset++) {
      final nextDate = now.add(Duration(days: dayOffset));
      if (repeatDays.contains(nextDate.weekday)) {
        final dayName = getDayName(nextDate.weekday);
        final monthName = getMonthName(nextDate.month);
        return '$dayName, ${nextDate.day} $monthName (${getFormattedTimeRange()})';
      }
    }
    return 'Belum dijadwalkan';
  }

  /// Format tanggal praktik: "Sabtu, 14 November 2026"
  String getFormattedDate() {
    try {
      DateTime dt = DateTime.tryParse(date) ?? DateTime.now();
      final dayName = getDayName(dt.weekday);
      final monthName = getMonthName(dt.month);
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (_) {
      final now = DateTime.now();
      return '${getDayName(now.weekday)}, ${now.day} ${getMonthName(now.month)} ${now.year}';
    }
  }

  /// Format jam praktik: "08.00 - 12.00"
  String getFormattedTimeRange() {
    final start = startTime.replaceAll(':', '.');
    final end = endTime.replaceAll(':', '.');
    return '$start - $end';
  }

  /// Format daftar hari berulang: contoh "Senin - Sabtu" atau "Senin, Rabu, Jumat"
  String getRepeatDaysFormatted() {
    if (repeatDays.isEmpty) return 'Tidak berulang';
    if (repeatDays.length == 7) return 'Setiap Hari';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Senin - Jumat';
    }
    if (repeatDays.length == 6 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5) &&
        repeatDays.contains(6)) {
      return 'Senin - Sabtu';
    }

    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => getDayName(d)).join(', ');
  }
}

