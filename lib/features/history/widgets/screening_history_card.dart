import 'package:flutter/material.dart';
import 'package:oste/features/history/widgets/history_status_chip.dart';

/// Card item riwayat skrining mandiri sesuai desain Figma
class ScreeningHistoryCard extends StatelessWidget {
  final String tanggal;
  final String waktu;
  final double probabilitas;
  final String status;
  final bool isPositive;
  final VoidCallback? onTap;

  const ScreeningHistoryCard({
    super.key,
    required this.tanggal,
    required this.waktu,
    required this.probabilitas,
    required this.status,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Lingkaran Ikon Kalender ──────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 22,
                    color: Color(0xFF334155),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Info Riwayat Skrining ────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tanggal,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waktu.startsWith('Pukul') ? waktu : 'Pukul $waktu',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Probabilitas: ${probabilitas.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      HistoryStatusChip.screening(
                        label: status,
                        isPositive: isPositive,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Panah Navigasi Kanan ─────────────────────────────
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Color(0xFF334155),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
