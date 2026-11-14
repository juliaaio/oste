import 'package:flutter/material.dart';
import 'package:oste/features/history/models/screening_data_point.dart';

/// Card ringkasan otomatis perubahan risiko osteoporosis
/// membandingkan skrining pertama dan skrining terbaru.
class ProgressSummaryCard extends StatelessWidget {
  final ScreeningDataPoint firstScreening;
  final ScreeningDataPoint latestScreening;

  const ProgressSummaryCard({
    super.key,
    required this.firstScreening,
    required this.latestScreening,
  });

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  String _formatDate(ScreeningDataPoint point) {
    final dt = point.date;
    final timeStr = point.waktu != null && point.waktu!.isNotEmpty
        ? ' (${point.waktu!.replaceFirst('Pukul ', '')})'
        : ' (${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB)';
    return '${dt.day} ${_shortMonths[dt.month - 1]} ${dt.year}$timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final double firstProb = firstScreening.probability;
    final double latestProb = latestScreening.probability;
    final double diff = latestProb - firstProb;
    final double absDiff = diff.abs();

    final bool isDecreased = diff < -0.1; // Risiko turun (Bagus)
    final bool isIncreased = diff > 0.1;  // Risiko naik (Perlu waspada)

    final Color statusColor = isDecreased
        ? const Color(0xFF10B981) // Hijau
        : (isIncreased ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)); // Merah / Biru

    final IconData statusIcon = isDecreased
        ? Icons.trending_down_rounded
        : (isIncreased ? Icons.trending_up_rounded : Icons.trending_flat_rounded);

    final String statusBadgeText = isDecreased
        ? 'Menurun 📉'
        : (isIncreased ? 'Meningkat 📈' : 'Stabil ➖');

    final String summaryHeadline = isDecreased
        ? 'Terjadi penurunan risiko sebesar ${absDiff.toStringAsFixed(1)}%.'
        : (isIncreased
            ? 'Risiko meningkat sebesar ${absDiff.toStringAsFixed(1)}%.'
            : 'Tingkat risiko stabil (tanpa perubahan signifikan).');

    final String summaryRecommendation = isIncreased
        ? 'Disarankan berkonsultasi dengan dokter untuk evaluasi kesehatan tulang lebih lanjut.'
        : 'Pertahankan pola hidup sehat dan lakukan skrining berkala.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris Judul & Badge Tren ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Perubahan Risiko',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusBadgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Kotak Perbandingan: Pertama vs Terbaru ───────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Skrining Pertama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skrining pertama :',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${firstProb.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: firstScreening.riskColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _formatDate(firstScreening),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Panah Penghubung
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),

                // Skrining Terbaru
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Skrining terbaru :',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${latestProb.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: latestScreening.riskColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        _formatDate(latestScreening),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Narasi Rekomendasi Otomatis ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  isDecreased
                      ? Icons.check_circle_rounded
                      : (isIncreased
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded),
                  size: 16,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Color(0xFF475569),
                    ),
                    children: [
                      TextSpan(
                        text: '$summaryHeadline ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      TextSpan(
                        text: summaryRecommendation,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
