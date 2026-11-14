import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oste/features/doctor_dashboard/edit_doctor_schedule_page.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/services/doctor_schedule_service.dart';
import 'package:oste/services/user_service.dart';

/// Card Jadwal Praktik Saya untuk Beranda Dokter
class DoctorScheduleCard extends StatefulWidget {
  const DoctorScheduleCard({super.key});

  @override
  State<DoctorScheduleCard> createState() => _DoctorScheduleCardState();
}

class _DoctorScheduleCardState extends State<DoctorScheduleCard> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Timer pembaruan countdown real-time setiap 30 detik
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DoctorScheduleService(),
        UserService(),
      ]),
      builder: (context, _) {
        final user = UserService().currentUser;
        final doctorId = (user?.linkedDoctorId.isNotEmpty == true)
            ? user!.linkedDoctorId
            : 'doc_1';
        final doctorName = (user != null && user.name.isNotEmpty)
            ? (user.name.startsWith('dr.') ? user.name : 'dr. ${user.name}')
            : 'dr. Intan Permata, Sp.OT';

        final schedule = DoctorScheduleService().getSchedule(
          doctorId,
          fallbackDoctorName: doctorName,
        );

        // Status badge mengikuti pilihan manual dokter (isActive), bukan jam praktik
        final bool isPracticing = schedule.isActive;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPracticing
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFF1F5F9),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: isPracticing
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Header: Icon Kalender, Judul & Status Badge ──────────
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6D8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '📅',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Jadwal Praktik Saya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: DoctorThemeColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pantau dan sesuaikan jam praktik Anda',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: DoctorThemeColors.textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge: 🟢 Sedang Praktik / 🔴 Tidak Praktik
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPracticing
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPracticing
                              ? const Color(0xFF10B981).withValues(alpha: 0.5)
                              : const Color(0xFFEF4444).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPracticing
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPracticing ? 'Sedang Praktik' : 'Tidak Praktik',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isPracticing
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 14),

                // ── 2. Informasi Tanggal & Jam Praktik ───────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom Tanggal Praktik
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tanggal Praktik',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            schedule.getFormattedDate(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: DoctorThemeColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Kolom Jam Praktik
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Jam Praktik',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${schedule.getFormattedTimeRange()} WIB',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: DoctorThemeColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(${schedule.getRepeatDaysFormatted()})',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tampilkan info status jika dokter menandai Aktif
                if (isPracticing) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: schedule.isPracticingNow()
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: schedule.isPracticingNow()
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF86EFAC),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          schedule.isPracticingNow()
                              ? Icons.hourglass_top_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 18,
                          color: schedule.isPracticingNow()
                              ? const Color(0xFFB45309)
                              : const Color(0xFF047857),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            schedule.isPracticingNow()
                                ? schedule.getRemainingPracticeTime()
                                : 'Status: Aktif – Siap Menerima Pasien',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: schedule.isPracticingNow()
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (schedule.note.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Catatan: ${schedule.note}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── 4. Tombol: ✏️ Edit Jadwal ──────────────────────────────────
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditDoctorSchedulePage(
                          doctorId: schedule.doctorId,
                          doctorName: schedule.doctorName,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '✏️',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Jadwal',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
