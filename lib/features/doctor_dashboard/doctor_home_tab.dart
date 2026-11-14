import 'package:flutter/material.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_schedule_card.dart';
import 'package:oste/services/doctor_presence_service.dart';
import 'package:oste/services/user_service.dart';

/// Tab Beranda Dokter sesuai Desain Figma
class DoctorHomeTab extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const DoctorHomeTab({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserService(),
      builder: (context, _) {
        final user = UserService().currentUser;
        
        // Identitas dokter login (default dokter spesialis orthopedi)
        final doctorName = (user != null && user.name.isNotEmpty)
            ? (user.name.startsWith('dr.') ? user.name : 'dr. ${user.name}')
            : 'dr. Intan Permata, Sp.OT';
            
        final specialist = (user != null && user.specialist.isNotEmpty)
            ? user.specialist
            : 'Dokter Spesialis Orthopedi';

        // Sapaan nama panggilan (contoh: "Hallo, dr. Intan! 👋")
        String greetingTitle;
        if (doctorName.contains('dr.')) {
          final parts = doctorName.replaceAll('dr.', '').trim().split(' ');
          greetingTitle = 'dr. ${parts.first}';
        } else {
          greetingTitle = user?.firstName ?? 'dr. Intan';
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Card Dokter Sesuai Figma ────────────────────────
                _buildDoctorHeroCard(
                  context: context,
                  doctorName: doctorName,
                  specialist: specialist,
                  greetingTitle: greetingTitle,
                ),

                const SizedBox(height: 28),

                // ── Section Title "Menu Utama" ───────────────────────────
                const Text(
                  'Menu Utama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DoctorThemeColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 16),

                // ── 2 Kartu Menu Utama: Chat Pasien & Riwayat ────────────
                Row(
                  children: [
                    // Kartu 1: Chat Pasien
                    Expanded(
                      child: _buildMenuCard(
                        title: 'Chat Pasien',
                        subtitle: 'Kelola dan balas pesan dari pasien Anda',
                        icon: Icons.chat_bubble_rounded,
                        iconColor: DoctorThemeColors.orange,
                        iconBgColor: const Color(0xFFFFF6D8),
                        borderColor: const Color(0xFFFDE68A),
                        decorColor: const Color(0xFFFFFBEA),
                        onTap: () => onNavigateToTab(2), // Buka Tab Chat Pasien
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Kartu 2: Riwayat
                    Expanded(
                      child: _buildMenuCard(
                        title: 'Riwayat',
                        subtitle: 'Lihat riwayat konsultasi dan aktivitas pasien',
                        icon: Icons.access_time_filled_rounded,
                        iconColor: const Color(0xFF7C3AED),
                        iconBgColor: const Color(0xFFEDE9FE),
                        borderColor: const Color(0xFFE2E8F0),
                        decorColor: const Color(0xFFF5F3FF),
                        onTap: () => onNavigateToTab(1), // Buka Tab Riwayat
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Card Jadwal Praktik Dokter ───────────────────────────
                const DoctorScheduleCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header Card Dokter dengan ilustrasi 3D dan sapaan hangat
  Widget _buildDoctorHeroCard({
    required BuildContext context,
    required String doctorName,
    required String specialist,
    required String greetingTitle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.4,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF7),
            Color(0xFFFFFBEA),
            Color(0xFFFFF6D3),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ornamen lingkaran lembut di dalam card
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDE68A).withValues(alpha: 0.25),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri: Identitas OsteoCare, Nama Dokter, Sapaan & Motivasi
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header kecil: Foto dokter bulat + Teks OsteoCare + Status Online
                      ListenableBuilder(
                        listenable: DoctorPresenceService(),
                        builder: (context, _) {
                          final uid = UserService().currentUser?.uid ?? '';
                          final isOnline = DoctorPresenceService().isOnline(uid);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isOnline
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF7C948),
                                        width: 2,
                                      ),
                                      color: const Color(0xFFFEF3C7),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1594824813620-6d43ecbb6251?auto=format&fit=crop&w=400&q=80',
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, st) =>
                                            const Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFFB45309),
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -1,
                                    bottom: -1,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF94A3B8),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Osteo',
                                                style: TextStyle(
                                                    color: Color(0xFF1E293B)),
                                              ),
                                              TextSpan(
                                                text: 'Care',
                                                style: TextStyle(
                                                    color: Color(0xFFF59E0B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Badge toggle Online/Offline
                                        GestureDetector(
                                          onTap: () {
                                            if (uid.isEmpty) return;
                                            if (isOnline) {
                                              DoctorPresenceService()
                                                  .setOffline(uid);
                                            } else {
                                              final linkedId = UserService()
                                                      .currentUser
                                                      ?.linkedDoctorId ??
                                                  '';
                                              DoctorPresenceService().setOnline(
                                                uid,
                                                doctorId: linkedId.isNotEmpty
                                                    ? linkedId
                                                    : uid,
                                              );
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isOnline
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isOnline
                                                    ? const Color(0xFF86EFAC)
                                                    : const Color(0xFFCBD5E1),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: isOnline
                                                        ? const Color(
                                                            0xFF16A34A)
                                                        : const Color(
                                                            0xFF94A3B8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isOnline
                                                      ? 'Online'
                                                      : 'Offline',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: isOnline
                                                        ? const Color(
                                                            0xFF15803D)
                                                        : const Color(
                                                            0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      doctorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      specialist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Sapaan dokter: "Hallo, dr. Intan! 👋"
                      Text(
                        'Hallo, $greetingTitle! 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Teks motivasi pelayanan
                      const Text(
                        'Terus berikan pelayanan terbaik untuk kesehatan tulang pasienmu!',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.42,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Kolom Kanan: Ilustrasi 3D Dokter & Aksen Hati Kuning
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        // Ornamen hati kuning lembut di samping dokter
                        Positioned(
                          top: 18,
                          right: 12,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Ilustrasi 3D Dokter
                        Image.asset(
                          'assets/images/doctor_header_illustration.png',
                          height: 155,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.medical_services_rounded,
                            size: 64,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Menu Utama (Chat Pasien & Riwayat) dengan tombol navigasi melingkar
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color borderColor,
    required Color decorColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 172,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon menu dengan lingkaran aksen
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),

            // Teks judul & deskripsi singkat
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DoctorThemeColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: DoctorThemeColors.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Tombol navigasi bulat dengan icon panah
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF3C9),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
