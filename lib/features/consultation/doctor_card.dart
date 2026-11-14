import 'package:flutter/material.dart';
import 'package:oste/models/doctor_model.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/doctor_review_service.dart';
import 'package:oste/services/doctor_schedule_service.dart';

/// Reusable card component for displaying doctor information in a list
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ChatService(),
        DoctorPresenceService(), // re-build saat status online berubah
        DoctorScheduleService(), // re-build saat status praktik dokter berubah
      ]),
      builder: (context, _) {
        final unreadCount =
            ChatService().getPatientUnreadCountForDoctor(doctor.id);
        final isOnline = DoctorPresenceService().isOnline(doctor.id);
        final schedule = DoctorScheduleService().getSchedule(
          doctor.id,
          fallbackDoctorName: doctor.name,
        );
        final isPracticing = schedule.isActive; // Gunakan isActive (pilihan manual dokter)

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: unreadCount > 0
                ? const Color(0xFFFFFBEB)
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: unreadCount > 0
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFE8EBF1),
              width: unreadCount > 0 ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: unreadCount > 0
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                    : const Color(0xFF14213D).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    // Foto avatar dokter dengan badge notifikasi jika ada balasan belum dibaca
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8EBF1),
                            border: Border.all(
                              color: unreadCount > 0
                                  ? const Color(0xFFF7C948)
                                  : const Color(0xFFE8EBF1),
                              width: unreadCount > 0 ? 2 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              doctor.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: Color(0xFF8A9AB5),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFFD34E),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Info dokter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama dokter
                          Text(
                            doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.8,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF14213D),
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Spesialisasi
                          Text(
                            doctor.specialist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8A9AB5),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rating & Status Online
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFFB703),
                              ),
                              const SizedBox(width: 3),
                              ListenableBuilder(
                                listenable: DoctorReviewService(),
                                builder: (context, _) {
                                  final avg = DoctorReviewService()
                                      .getAverageRating(doctor.id);
                                  final ratingText = avg == 0.0
                                      ? doctor.rating.toStringAsFixed(1)
                                      : avg.toStringAsFixed(1);
                                  return Text(
                                    ratingText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFFB703),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8A9AB5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isOnline) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5F9EC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF16B86A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Online',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF16B86A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF94A3B8),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Offline',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Badge Status Praktik Dokter Realtime
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPracticing
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPracticing
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCA5A5),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isPracticing
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPracticing
                                      ? 'Sedang Praktik'
                                      : 'Tidak Praktik',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isPracticing
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol "Lihat Profil" kapsul pastel yellow
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: unreadCount > 0
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFFFF0BD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            unreadCount > 0 ? 'Balasan ($unreadCount)' : 'Lihat Profil',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF14213D),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF14213D),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
