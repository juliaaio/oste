import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/history/models/screening_data_point.dart';
import 'package:oste/features/history/widgets/empty_progress.dart';
import 'package:oste/features/history/widgets/progress_chart.dart';
import 'package:oste/features/history/widgets/progress_summary_card.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/services/user_service.dart';

/// Card utama "Perkembangan Risiko Osteoporosis" yang mendengarkan data
/// Firestore realtime dari `users/{uid}/riwayat_skrining`.
class ScreeningProgressSection extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const ScreeningProgressSection({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ??
        UserService().currentUser?.uid ??
        '';

    return ListenableBuilder(
      listenable: HistoryService(),
      builder: (context, _) {
        final stream = uid.isNotEmpty
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('riwayat_skrining')
                .snapshots(includeMetadataChanges: true)
            : null;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            // Gabungkan data dari Firestore dan HistoryService in-memory
            // agar begitu selesai skrining, grafik langsung ter-update seketika (0ms delay)
            final Map<String, ScreeningDataPoint> pointsMap = {};
            for (final d in docs) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              final pt = ScreeningDataPoint.fromFirestore(data);
              final key = pt.id.isNotEmpty
                  ? pt.id
                  : pt.date.millisecondsSinceEpoch.toString();
              pointsMap[key] = pt;
            }

            for (final h in HistoryService().screeningHistories) {
              final key = h.id.isNotEmpty
                  ? h.id
                  : h.tanggal.millisecondsSinceEpoch.toString();
              if (!pointsMap.containsKey(key)) {
                pointsMap[key] = ScreeningDataPoint(
                  id: h.id,
                  date: h.tanggal,
                  waktu: h.waktu,
                  probability: h.probabilitas.toDouble(),
                  prediction: h.isPositive ? 1 : 0,
                  riskCategory: h.riskCategory ??
                      (h.probabilitas >= 70
                          ? 'Risiko Tinggi'
                          : (h.probabilitas >= 40
                              ? 'Risiko Sedang'
                              : 'Risiko Rendah')),
                  statusHasil: h.status,
                );
              }
            }

            final List<ScreeningDataPoint> dataPoints = pointsMap.values.toList();

            // Urutkan data berdasarkan tanggal dan waktu dari yang paling lama ke terbaru (asc)
            dataPoints.sort((a, b) => a.date.compareTo(b.date));

            // State jika sedang loading pertama kali dan belum ada data lokal
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData &&
                dataPoints.isEmpty) {
              return _buildContainer(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
              );
            }

            return _buildContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Card ───────────────────────────────────────
                  _buildHeader(totalData: dataPoints.length),
                  const SizedBox(height: 16),

              // ── Kondisi Data < 2 : Tampilkan Empty State ───────────
              if (dataPoints.length < 2)
                const EmptyProgress()
              else ...[
                // ── Bonus: 3 Kartu Statistik Singkat di Atas Grafik ────
                _buildQuickStats(dataPoints),
                const SizedBox(height: 16),

                // ── Grafik Garis (Line Chart) ─────────────────────────
                ProgressChart(dataPoints: dataPoints),
                const SizedBox(height: 18),

                // ── Ringkasan Otomatis Perubahan Risiko ────────────────
                ProgressSummaryCard(
                  firstScreening: dataPoints.first,
                  latestScreening: dataPoints.last,
                ),
              ],
            ],
          ),
        );
      },
    );
  },
);
}

  /// Container pembungkus utama dengan style konsisten (Butter Yellow & White)
  Widget _buildContainer({required Widget child}) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Header judul dan deskripsi singkat
  Widget _buildHeader({required int totalData}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFDE68A),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5A124).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.show_chart_rounded,
              color: Color(0xFFD97706),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perkembangan Risiko Osteoporosis',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pantau perubahan tingkat risiko osteoporosis Anda dari waktu ke waktu.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bonus: 3 kartu statistik kecil di atas grafik
  Widget _buildQuickStats(List<ScreeningDataPoint> points) {
    final int total = points.length;
    final ScreeningDataPoint latest = points.last;
    final ScreeningDataPoint first = points.first;
    final double diff = latest.probability - first.probability;

    final String trendLabel;
    final IconData trendIcon;
    final Color trendColor;

    if (diff < -0.1) {
      trendLabel = 'Menurun 📉';
      trendIcon = Icons.arrow_downward_rounded;
      trendColor = const Color(0xFF10B981);
    } else if (diff > 0.1) {
      trendLabel = 'Meningkat 📈';
      trendIcon = Icons.arrow_upward_rounded;
      trendColor = const Color(0xFFEF4444);
    } else {
      trendLabel = 'Stabil ➖';
      trendIcon = Icons.remove_rounded;
      trendColor = const Color(0xFF3B82F6);
    }

    return Row(
      children: [
        // Kartu 1: Total Skrining
        Expanded(
          child: _buildMiniStatCard(
            title: 'Total Skrining',
            value: '$total kali',
            subtitle: 'Tercatat',
            accentColor: const Color(0xFFD97706),
            icon: Icons.checklist_rounded,
          ),
        ),
        const SizedBox(width: 8),

        // Kartu 2: Risiko Terakhir
        Expanded(
          child: _buildMiniStatCard(
            title: 'Risiko Terakhir',
            value: '${latest.probability.toStringAsFixed(0)}%',
            subtitle: latest.riskLabel,
            accentColor: latest.riskColor,
            icon: Icons.shield_outlined,
          ),
        ),
        const SizedBox(width: 8),

        // Kartu 3: Tren
        Expanded(
          child: _buildMiniStatCard(
            title: 'Tren Risiko',
            value: trendLabel,
            subtitle: diff < -0.1
                ? 'Turun ${diff.abs().toStringAsFixed(0)}%'
                : (diff > 0.1 ? 'Naik ${diff.toStringAsFixed(0)}%' : 'Sama'),
            accentColor: trendColor,
            icon: trendIcon,
            isTrend: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
    IconData? icon,
    bool isTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: accentColor),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTrend ? 12 : 15,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
