import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oste/features/history/models/screening_data_point.dart';

/// Widget Line Chart yang menampilkan tren risiko osteoporosis dari waktu ke waktu.
class ProgressChart extends StatefulWidget {
  final List<ScreeningDataPoint> dataPoints;

  const ProgressChart({
    super.key,
    required this.dataPoints,
  });

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant ProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints.length != widget.dataPoints.length) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _hasSameDayScreenings(List<ScreeningDataPoint> points) {
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        if (points[i].date.year == points[j].date.year &&
            points[i].date.month == points[j].date.month &&
            points[i].date.day == points[j].date.day) {
          return true;
        }
      }
    }
    return false;
  }

  String _formatPointLabel(ScreeningDataPoint point, bool hasSameDay) {
    final dt = point.date;
    final dateStr = '${dt.day} ${_shortMonths[dt.month - 1]}';
    if (!hasSameDay) return dateStr;
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$dateStr\n$timeStr';
  }

  String _formatFullDate(ScreeningDataPoint point) {
    final dt = point.date;
    final timeStr = point.waktu != null && point.waktu!.isNotEmpty
        ? point.waktu!
        : 'Pukul ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} WIB';
    return '${dt.day} ${_shortMonths[dt.month - 1]} ${dt.year}\n$timeStr';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = widget.dataPoints;
    final bool hasSameDay = _hasSameDayScreenings(points);

    // Buat data spot untuk fl_chart
    final List<FlSpot> spots = [];
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].probability));
    }

    // Warna garis: gradien dari titik pertama hingga titik terakhir
    final List<Color> lineGradientColors = points.length == 1
        ? [points.first.riskColor, points.first.riskColor]
        : points.map((p) => p.riskColor).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Keterangan Level Risiko (Legend) ──────────────────────────
          _buildRiskLegend(),
          const SizedBox(height: 16),

          // ── Area Grafik LineChart ────────────────────────────────────
          SizedBox(
            height: hasSameDay ? 215 : 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 14, left: 4, top: 12),
              child: LineChart(
                key: ValueKey(
                  '${points.length}_${points.last.probability}_${points.last.date.millisecondsSinceEpoch}',
                ),
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  clipData: const FlClipData.none(),

                  // Garis Grid horizontal
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFF1F5F9),
                        strokeWidth: 1.2,
                        dashArray: [4, 4],
                      );
                    },
                  ),

                  // Konfigurasi Label Sumbu X & Y
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    // Sumbu Y (Probability 0 - 100%)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > 100) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          );
                        },
                      ),
                    ),

                    // Sumbu X (Tanggal Skrining)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: hasSameDay ? 38 : 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }

                          // Jika data sangat banyak, tampilkan selang-seling agar tidak bertumpukan
                          if (points.length > 5 &&
                              index % 2 != 0 &&
                              index != points.length - 1) {
                            return const SizedBox.shrink();
                          }

                          final dateStr = _formatPointLabel(points[index], hasSameDay);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              dateStr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9.5,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Garis Batas Bawah dan Kiri
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      left: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      top: BorderSide.none,
                      right: BorderSide.none,
                    ),
                  ),

                  // Interaksi Sentuh (Tooltip)
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => const Color(0xFF1E293B),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      tooltipMargin: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.spotIndex;
                          if (idx < 0 || idx >= points.length) return null;
                          final point = points[idx];
                          final formattedDate = _formatFullDate(point);

                          return LineTooltipItem(
                            '$formattedDate\n',
                            const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(
                                text: '${point.probability.toStringAsFixed(1)}% ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '(${point.riskLabel})',
                                style: TextStyle(
                                  color: point.riskColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),

                  // Data Garis dan Titik
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.28,
                      preventCurveOverShooting: true,
                      barWidth: 3.2,
                      gradient: LinearGradient(
                        colors: lineGradientColors,
                      ),
                      isStrokeCapRound: true,

                      // Kustomisasi Titik/Dot pada Garis
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final color = (index >= 0 && index < points.length)
                              ? points[index].riskColor
                              : const Color(0xFFF59E0B);
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: color,
                          );
                        },
                      ),

                      // Area di bawah garis dengan gradasi lembut
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (points.isNotEmpty
                                    ? points.last.riskColor
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.22),
                            (points.isNotEmpty
                                    ? points.last.riskColor
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indikator Legenda 3 Warna Kategori Risiko
  Widget _buildRiskLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(const Color(0xFF10B981), '0–39% Rendah'),
          _buildLegendDivider(),
          _buildLegendItem(const Color(0xFFF59E0B), '40–69% Sedang'),
          _buildLegendDivider(),
          _buildLegendItem(const Color(0xFFEF4444), '70–100% Tinggi'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDivider() {
    return Container(
      width: 1,
      height: 12,
      color: const Color(0xFFE2E8F0),
    );
  }
}

