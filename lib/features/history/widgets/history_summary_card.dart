import 'package:flutter/material.dart';

/// Card Ringkasan Riwayat sesuai desain Figma
class HistorySummaryCard extends StatelessWidget {
  final int totalScreening;
  final String latestResult;
  final String latestDate;

  const HistorySummaryCard({
    super.key,
    required this.totalScreening,
    required this.latestResult,
    required this.latestDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFEF3C7),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Judul Ringkasan Riwayat ──────────────────────────────
          Row(
            children: const [
              Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Ringkasan Riwayat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Box Putih Berisi 3 Metrik ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Metrik 1: Total Skrining
                Expanded(
                  child: _MetricItem(
                    value: totalScreening == 0 ? '-' : totalScreening.toString(),
                    label: 'Total\nSkrining',
                  ),
                ),
                _buildDivider(),
                // Metrik 2: Hasil Terakhir
                Expanded(
                  child: _MetricItem(
                    value: latestResult,
                    label: 'Hasil\nTerakhir',
                  ),
                ),
                _buildDivider(),
                // Metrik 3: Skrining Terakhir
                Expanded(
                  child: _MetricItem(
                    value: latestDate,
                    label: 'Skrining\nTerakhir',
                    isDate: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFF1F5F9),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDate;

  const _MetricItem({
    required this.value,
    required this.label,
    this.isDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isDate ? 13.5 : 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
