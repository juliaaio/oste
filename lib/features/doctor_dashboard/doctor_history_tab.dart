import 'package:flutter/material.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/services/consultation_history_service.dart';
import 'package:oste/services/history_service.dart';

/// Tab Riwayat untuk Dokter
class DoctorHistoryTab extends StatefulWidget {
  const DoctorHistoryTab({super.key});

  @override
  State<DoctorHistoryTab> createState() => _DoctorHistoryTabState();
}

class _DoctorHistoryTabState extends State<DoctorHistoryTab> {
  int _selectedTabIndex = 0; // 0 = Skrining Pasien, 1 = Riwayat Konsultasi

  // Riwayat skrining bawaan jika pengguna belum melakukan skrining baru
  static final List<Map<String, dynamic>> _seededScreenings = [
    {
      'patientName': 'Siti Rahmawati (48 th)',
      'date': '24 Oktober 2026',
      'probabilitas': 72,
      'kategori': 'Risiko Tinggi',
      'categoryColor': const Color(0xFFE11D48),
      'keterangan':
          'Skor risiko osteoporosis tinggi karena riwayat fraktur dan asupan kalsium rendah.',
    },
    {
      'patientName': 'Ahmad Maulana (52 th)',
      'date': '22 Oktober 2026',
      'probabilitas': 48,
      'kategori': 'Risiko Sedang',
      'categoryColor': const Color(0xFFF59E0B),
      'keterangan':
          'Kepadatan tulang terindikasi osteopenia ringan dengan gaya hidup minim olahraga.',
    },
    {
      'patientName': 'Budi Santoso (38 th)',
      'date': '19 Oktober 2026',
      'probabilitas': 15,
      'kategori': 'Risiko Rendah',
      'categoryColor': const Color(0xFF10B981),
      'keterangan':
          'Kepadatan tulang terpantau normal. Rekomendasi pertahankan pola makan seimbang.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final historyService = HistoryService();
    final consultationService = ConsultationHistoryService();

    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([historyService, consultationService]),
        builder: (context, _) {
          final liveScreenings = historyService.screeningHistories;
          final consultations = consultationService.allConsultations;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Riwayat Dokter ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Riwayat Pasien',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: DoctorThemeColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pantau riwayat skrining dan konsultasi pasien',
                      style: TextStyle(
                        fontSize: 13,
                        color: DoctorThemeColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Tab Bar (Skrining Pasien vs Konsultasi) ───────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          title: 'Skrining Pasien',
                          isSelected: _selectedTabIndex == 0,
                          onTap: () => setState(() => _selectedTabIndex = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          title: 'Konsultasi',
                          isSelected: _selectedTabIndex == 1,
                          onTap: () => setState(() => _selectedTabIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Daftar Riwayat Berdasarkan Tab Terpilih ─────────────
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildScreeningHistoryList(liveScreenings)
                    : _buildConsultationHistoryList(consultations),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? DoctorThemeColors.textDark
                  : DoctorThemeColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  /// Daftar riwayat skrining pasien
  Widget _buildScreeningHistoryList(List<HistoryModel> liveScreenings) {
    if (liveScreenings.isNotEmpty) {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: liveScreenings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = liveScreenings[index];
          final color = item.isPositive
              ? const Color(0xFFE11D48)
              : const Color(0xFF10B981);
          final category = item.riskCategory ?? item.status;

          return _buildScreeningCard(
            title: item.status,
            date:
                '${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}',
            probability: '${item.probabilitas}%',
            category: category,
            categoryColor: color,
            description: item.summary ??
                'Riwayat analisis skrining risiko osteoporosis pasien.',
          );
        },
      );
    }

    // Tampilkan data seeded jika belum ada riwayat live
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _seededScreenings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = _seededScreenings[index];
        return _buildScreeningCard(
          title: data['patientName'] as String,
          date: data['date'] as String,
          probability: '${data['probabilitas']}%',
          category: data['kategori'] as String,
          categoryColor: data['categoryColor'] as Color,
          description: data['keterangan'] as String,
        );
      },
    );
  }

  Widget _buildScreeningCard({
    required String title,
    required String date,
    required String probability,
    required String category,
    required Color categoryColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: DoctorThemeColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.analytics_outlined,
                  size: 13, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                'Probabilitas: $probability',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: DoctorThemeColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Daftar riwayat konsultasi pasien
  Widget _buildConsultationHistoryList(dynamic consultations) {
    if (consultations == null || consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history_toggle_off_rounded,
                size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 8),
            Text(
              'Belum ada riwayat konsultasi',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: consultations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = consultations[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConsultationSummaryPage(
                  doctor: c.doctor,
                  messages: c.messages,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.diagnosis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: DoctorThemeColors.textDark,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      '${c.date} · ${c.time}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  c.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: DoctorThemeColors.textMuted,
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
