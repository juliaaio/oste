import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';

/// Palet warna resmi halaman Hasil Skrining Osteoporosis
class _HasilColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color background = Color(0xFFFAF9F5);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color warningBg = Color(0xFFFFF8E7);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color amberScore = Color(0xFFD97706);
  static const Color gaugeTrack = Color(0xFFF5ECD5);
  static const Color greenCheck = Color(0xFF10B981);
  static const Color redHeart = Color(0xFFEF4444);
  static const Color disclaimerBg = Color(0xFFF1F5F9);
  static const Color disclaimerBorder = Color(0xFFE2E8F0);
  static const Color medallionBg = Color(0xFFFFF3D4);
}

/// Model untuk baris data prediksi
class PredictionItem {
  final IconData icon;
  final String label;
  final String value;

  const PredictionItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Halaman Hasil Skrining Osteoporosis
class HasilScreeningPage extends StatefulWidget {
  final double scorePercentage;
  final String riskTitle;
  final String riskDescription;
  final List<PredictionItem>? predictionData;
  final List<String>? recommendations;
  final String? screeningId;
  final bool autoSave;

  /// Asal halaman:
  /// - 'screening' → kembali ke Beranda (Dashboard)
  /// - 'history'   → kembali ke halaman Riwayat
  final String source;

  const HasilScreeningPage({
    super.key,
    this.scorePercentage = 58,
    this.riskTitle = 'risiko sedang',
    this.riskDescription =
        'Anda memiliki risiko sedang untuk mengalami osteoporosis.',
    this.predictionData,
    this.recommendations,
    this.screeningId,
    this.autoSave = true,
    this.source = 'screening',
  });

  // Data default 14 input pengguna sesuai screenshot referensi
  static const List<PredictionItem> _defaultPredictionData = [
    PredictionItem(
      icon: Icons.person_outline_rounded,
      label: 'Usia',
      value: '60 tahun',
    ),
    PredictionItem(
      icon: Icons.female_rounded,
      label: 'Jenis kelamin',
      value: 'Perempuan',
    ),
    PredictionItem(
      icon: Icons.science_outlined,
      label: 'Perubahan hormonal',
      value: 'Ya',
    ),
    PredictionItem(
      icon: Icons.groups_outlined,
      label: 'Riwayat keluarga',
      value: 'Ya',
    ),
    PredictionItem(
      icon: Icons.public_rounded,
      label: 'Ras/Etnis',
      value: 'Kaukasia',
    ),
    PredictionItem(
      icon: Icons.scale_outlined,
      label: 'Berat badan',
      value: 'Rendah',
    ),
    PredictionItem(
      icon: Icons.science_outlined,
      label: 'Asupan kalsium',
      value: 'Rendah',
    ),
    PredictionItem(
      icon: Icons.wb_sunny_outlined,
      label: 'Asupan vitamin D',
      value: 'Rendah',
    ),
    PredictionItem(
      icon: Icons.directions_run_rounded,
      label: 'Aktivitas fisik',
      value: 'Rendah',
    ),
    PredictionItem(
      icon: Icons.smoke_free_rounded,
      label: 'Merokok',
      value: 'Tidak',
    ),
    PredictionItem(
      icon: Icons.local_bar_outlined,
      label: 'Konsumsi alkohol',
      value: 'Tidak',
    ),
    PredictionItem(
      icon: Icons.medical_services_outlined,
      label: 'Kondisi medis',
      value: 'Hipertiroidisme',
    ),
    PredictionItem(
      icon: Icons.medication_outlined,
      label: 'Penggunaan obat',
      value: 'Kortikosteroid',
    ),
    PredictionItem(
      icon: Icons.healing_rounded,
      label: 'Riwayat patah tulang',
      value: 'Ya',
    ),
  ];

  // Rekomendasi default sesuai screenshot referensi
  static const List<String> _defaultRecommendations = [
    'Perbanyak makanan tinggi kalsium',
    'Konsumsi vitamin D sesuai anjuran',
    'Rutin melakukan aktivitas fisik (latihan beban ringan)',
    'Hindari rokok dan kurangi alkohol',
    'Konsultasikan hasil ini dengan dokter untuk evaluasi lebih lanjut',
  ];

  @override
  State<HasilScreeningPage> createState() => _HasilScreeningPageState();
}

class _HasilScreeningPageState extends State<HasilScreeningPage> {
  @override
  void initState() {
    super.initState();
    if (widget.autoSave) {
      _saveToHistory();
    }
  }

  void _saveToHistory() {
    final now = DateTime.now();
    final timeStr =
        'Pukul ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')} WIB';
    final isPos = widget.scorePercentage >= 35;
    final statusStr =
        isPos ? 'Terindikasi Osteoporosis' : 'Tidak Terindikasi Osteoporosis';

    final items =
        widget.predictionData ?? HasilScreeningPage._defaultPredictionData;
    final recs =
        widget.recommendations ?? HasilScreeningPage._defaultRecommendations;

    final history = HistoryModel.fromScreening(
      id: widget.screeningId ?? 'screen_${now.millisecondsSinceEpoch}',
      tanggal: now,
      waktu: timeStr,
      probabilitas: widget.scorePercentage.toInt(),
      status: statusStr,
      isPositive: isPos,
      riskCategory: widget.riskTitle,
      summary: widget.riskDescription,
      predictionData: items,
      recommendations: recs,
    );

    HistoryService().addScreening(history);
  }

  @override
  Widget build(BuildContext context) {
    final items =
        widget.predictionData ?? HasilScreeningPage._defaultPredictionData;
    final recs =
        widget.recommendations ?? HasilScreeningPage._defaultRecommendations;

    return Scaffold(
      backgroundColor: _HasilColors.background,
      appBar: AppBar(
        backgroundColor: _HasilColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
        icon: const Icon(
          Icons.chevron_left_rounded,
          size: 30,
          color: _HasilColors.textDark,
        ),
        onPressed: () {
          if (widget.source == 'history') {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
            );
          }
        },
      ),
        title: const Text(
          'Skrining Penyakit',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _HasilColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // 1. Banner Header "Hasil Skrining" & Ilustrasi Tulang
              // -------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Medallion bulat dengan ilustrasi tulang horizontal
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: _HasilColors.medallionBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: Image.asset(
                          'assets/images/bone_character.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Skrining',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _HasilColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Berikut adalah hasil analisis berdasarkan jawaban yang Anda berikan',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: _HasilColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 2. Indikator Risiko Lingkaran (Circular Percentage Gauge)
              // -------------------------------------------------------------
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gauge melingkar
                      CustomPaint(
                        size: const Size(160, 160),
                        painter: _CircularGaugePainter(
                          percentage: widget.scorePercentage / 100.0,
                        ),
                      ),
                      // Teks persentase & Skor Risiko
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.scorePercentage.toInt()}%',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: _HasilColors.amberScore,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Skor Risiko',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _HasilColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 3. Card Peringatan Risiko Sedang / Tinggi / Rendah
              // -------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: _HasilColors.warningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _HasilColors.warningBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: _HasilColors.amberScore,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.riskDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------------------
              // 4. Header Luar "Data yang Digunakan untuk Prediksi"
              // -------------------------------------------------------------
              const Text(
                'Data yang Digunakan untuk Prediksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _HasilColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar ${widget.scorePercentage.toInt()}%.',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: _HasilColors.textMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),

              // -------------------------------------------------------------
              // 5. Card Putih Berisi Tabel Data Prediksi (14 Baris)
              // -------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: _HasilColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _HasilColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data yang Digunakan untuk Prediksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _HasilColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berikut adalah seluruh data yang Anda masukkan dan digunakan oleh model Decision Tree (C4.5) dalam menghasilkan prediksi.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: _HasilColors.textLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Daftar 14 Baris Data
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _PredictionRowWidget(item: items[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 6. Card "Rekomendasi untuk Anda"
              // -------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: _HasilColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _HasilColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: _HasilColors.redHeart,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasi untuk Anda',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _HasilColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < recs.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: _HasilColors.greenCheck,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              recs[i],
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // -------------------------------------------------------------
              // 7. Tombol Utama "Konsultasi Dokter"
              // -------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorListPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _HasilColors.primaryButterYellow,
                    foregroundColor: _HasilColors.textDark,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: _HasilColors.textDark,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Konsultasi Dokter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _HasilColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // -------------------------------------------------------------
              // 8. Card Disclaimer Abu-Abu Muda
              // -------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: _HasilColors.disclaimerBg.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _HasilColors.disclaimerBorder,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: _HasilColors.textMuted,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hasil skrining ini bukan merupakan diagnosis medis. Untuk memastikan kondisi osteoporosis, diperlukan pemeriksaan lebih lanjut oleh tenaga kesehatan, seperti pemeriksaan Bone Mineral Density (BMD) atau DEXA Scan.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: _HasilColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE WIDGET: _PredictionRowWidget
// =============================================================================
class _PredictionRowWidget extends StatelessWidget {
  final PredictionItem item;

  const _PredictionRowWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          item.icon,
          size: 18,
          color: _HasilColors.textLight,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _HasilColors.textDark,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CUSTOM PAINTER: _CircularGaugePainter (Persentase Skor Risiko)
// =============================================================================
class _CircularGaugePainter extends CustomPainter {
  final double percentage; // Nilai 0.0 s/d 1.0

  const _CircularGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 9;
    const strokeWidth = 15.0;

    // 1. Lingkaran background (krem lembut)
    final trackPaint = Paint()
      ..color = _HasilColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Arc aktif (kuning/emas butter yellow)
    final activePaint = Paint()
      ..color = _HasilColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const startAngle = -math.pi / 2; // Mulai dari atas (jam 12)
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}

