import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Palet warna sesuai DashboardPage
// ---------------------------------------------------------------------------
class _CardColors {
  static const Color textDark       = Color(0xFF1E293B);
  static const Color textMuted      = Color(0xFF64748B);
  static const Color textLight      = Color(0xFF94A3B8);
  static const Color border         = Color(0xFFEAEAEA);
  static const Color abuMuda        = Color(0xFFF5F5F5);
  static const Color orange         = Color(0xFFF59E0B);

  // Badge positif (terindikasi osteoporosis)
  static const Color badgePosBg     = Color(0xFFFFE8EC);
  static const Color badgePosText   = Color(0xFFE11D48);

  // Badge negatif (tidak terindikasi)
  static const Color badgeNegBg     = Color(0xFFDCFCE7);
  static const Color badgeNegText   = Color(0xFF16A34A);
}

/// Card satu entri riwayat skrining osteoporosis.
///
/// Menampilkan ikon kalender, tanggal, waktu, probabilitas,
/// badge status, dan panah navigasi.
class HistoryCard extends StatelessWidget {
  /// Tanggal skrining, mis. "12 September 2025".
  final String tanggal;

  /// Waktu skrining, mis. "Pukul 14.30 WIB".
  final String waktu;

  /// Nilai probabilitas dalam persen (0–100), mis. 58.
  final double probabilitas;

  /// Label status singkat, mis. "Terindikasi Osteoporosis".
  final String status;

  /// true  → badge merah (terindikasi).
  /// false → badge hijau (tidak terindikasi).
  final bool isPositive;

  /// Dipanggil ketika card ditekan.
  final VoidCallback? onTap;

  const HistoryCard({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _CardColors.border,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Ikon kalender (kiri) ────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _CardColors.abuMuda,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 22,
                color: _CardColors.orange,
              ),
            ),

            const SizedBox(width: 14),

            // ── Konten tengah ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal
                  Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _CardColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Waktu
                  Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _CardColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Probabilitas
                  Text(
                    'Probabilitas: ${probabilitas.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _CardColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Badge status
                  _StatusBadge(
                    label: status,
                    isPositive: isPositive,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Panah kanan ────────────────────────────────────────
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: _CardColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge status (internal widget)
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isPositive;

  const _StatusBadge({
    required this.label,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor   = isPositive ? _CardColors.badgePosBg   : _CardColors.badgeNegBg;
    final textColor = isPositive ? _CardColors.badgePosText  : _CardColors.badgeNegText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
