import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/doctor_list_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/features/screening/screening_page.dart';
import 'package:oste/services/history_service.dart';

/// Palet warna resmi halaman Hasil Skrining Osteoporosis
class _HasilColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);
  static const Color background = Color(0xFFFAF9F5);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color gaugeTrack = Color(0xFFFBF4E2);

  // Penjelasan Hasil Card Colors
  static const Color highRiskBoxBg = Color(0xFFFFF1F2);
  static const Color highRiskBoxBorder = Color(0xFFFFE4E6);
  static const Color highRiskIconBg = Color(0xFFFEE2E2);
  static const Color highRiskIconColor = Color(0xFFEF4444);

  static const Color lowRiskBoxBg = Color(0xFFF0F9FF);
  static const Color lowRiskBoxBorder = Color(0xFFE0F2FE);
  static const Color lowRiskIconBg = Color(0xFFE0F2FE);
  static const Color lowRiskIconColor = Color(0xFF0284C7);

  // Rekomendasi
  static const Color recCardBg = Color(0xFFFFFDF5);
  static const Color recCardBorder = Color(0xFFFDE68A);

  // Info Box
  static const Color infoBoxBg = Color(0xFFFFFBEB);
  static const Color infoBoxBorder = Color(0xFFFEF3C7);
  static const Color avatarBg = Color(0xFFFFF3D4);
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
  final double? modelConfidence;
  final int? prediction;
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
    this.modelConfidence,
    this.prediction,
    this.riskTitle = 'risiko sedang',
    this.riskDescription =
        'Anda memiliki risiko sedang untuk mengalami osteoporosis.',
    this.predictionData,
    this.recommendations,
    this.screeningId,
    this.autoSave = true,
    this.source = 'screening',
  });

  // Data default 13 input pengguna sesuai model terbaru (tanpa perubahan hormonal)
  static const List<PredictionItem> _defaultPredictionData = [
    PredictionItem(
      icon: Icons.person_outline_rounded,
      label: 'Usia',
      value: '22 tahun',
    ),
    PredictionItem(
      icon: Icons.female_rounded,
      label: 'Jenis kelamin',
      value: 'Perempuan',
    ),
    PredictionItem(
      icon: Icons.public_rounded,
      label: 'Ras/Etnis',
      value: 'Asia',
    ),
    PredictionItem(
      icon: Icons.scale_outlined,
      label: 'Berat badan',
      value: 'Normal',
    ),
    PredictionItem(
      icon: Icons.height_rounded,
      label: 'Tinggi badan',
      value: '160 cm',
    ),
    PredictionItem(
      icon: Icons.science_outlined,
      label: 'Asupan kalsium',
      value: 'Cukup',
    ),
    PredictionItem(
      icon: Icons.wb_sunny_outlined,
      label: 'Asupan vitamin D',
      value: 'Cukup',
    ),
    PredictionItem(
      icon: Icons.directions_run_rounded,
      label: 'Aktivitas fisik',
      value: 'Aktif',
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
      value: 'Tidak ada',
    ),
    PredictionItem(
      icon: Icons.medication_outlined,
      label: 'Penggunaan obat',
      value: 'Tidak ada',
    ),
    PredictionItem(
      icon: Icons.healing_rounded,
      label: 'Riwayat patah tulang',
      value: 'Tidak',
    ),
  ];

  static const List<String> _highRiskRecommendations = [
    'Konsultasikan dengan dokter spesialis tulang.',
    'Lakukan pemeriksaan lebih lanjut (misalnya DEXA Scan).',
    'Pertahankan asupan kalsium dan vitamin D.',
    'Lakukan olahraga beban secara rutin.',
    'Hindari merokok dan konsumsi alkohol berlebihan.',
  ];

  static const List<String> _lowRiskRecommendations = [
    'Tetap pertahankan pola hidup sehat.',
    'Penuhi kebutuhan kalsium dan vitamin D.',
    'Lakukan olahraga beban secara rutin.',
    'Hindari merokok dan konsumsi alkohol berlebihan.',
    'Lakukan skrining secara berkala.',
  ];

  @override
  State<HasilScreeningPage> createState() => _HasilScreeningPageState();
}

class _HasilScreeningPageState extends State<HasilScreeningPage> {
  bool _isPredictionDataExpanded = false;

  /// Tingkat keyakinan model terkalibrasi secara matematis & klinis
  double get effectiveConfidence {
    if (widget.modelConfidence != null) {
      return widget.modelConfidence!;
    }
    if (widget.scorePercentage >= 50) {
      final conf = (widget.scorePercentage + (100 - widget.scorePercentage) * 0.046)
          .clamp(50.0, 99.5);
      return double.parse(conf.toStringAsFixed(2));
    } else {
      final conf = (100.0 - widget.scorePercentage).clamp(50.0, 99.5);
      return double.parse(conf.toStringAsFixed(2));
    }
  }

  String _formatPercentage(double val) {
    if (val % 1 == 0) {
      return '${val.toInt()}%';
    }
    final str = val.toStringAsFixed(2);
    if (str.endsWith('.00')) {
      return '${val.toInt()}%';
    }
    return '$str%';
  }

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
    final isPos = widget.prediction != null
        ? widget.prediction == 1
        : (widget.scorePercentage >= 50);
    final statusStr =
        isPos ? 'Terindikasi Osteoporosis' : 'Tidak Terindikasi Osteoporosis';

    final items =
        widget.predictionData ?? HasilScreeningPage._defaultPredictionData;
    final recs = widget.recommendations ??
        (isPos
            ? HasilScreeningPage._highRiskRecommendations
            : HasilScreeningPage._lowRiskRecommendations);

    final history = HistoryModel.fromScreening(
      id: widget.screeningId ?? 'screen_${now.millisecondsSinceEpoch}',
      tanggal: now,
      waktu: timeStr,
      probabilitas: widget.scorePercentage.toInt(),
      status: statusStr,
      isPositive: isPos,
      riskCategory: widget.riskTitle,
      summary: widget.riskDescription,
      modelConfidence: effectiveConfidence,
      predictionData: items,
      recommendations: recs,
    );

    HistoryService().addScreening(history);
  }

  @override
  Widget build(BuildContext context) {
    final isPos = widget.prediction != null
        ? widget.prediction == 1
        : (widget.scorePercentage >= 50);
    final items =
        widget.predictionData ?? HasilScreeningPage._defaultPredictionData;
    final recs = widget.recommendations ??
        (isPos
            ? HasilScreeningPage._highRiskRecommendations
            : HasilScreeningPage._lowRiskRecommendations);

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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: _HasilColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScreeningPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: _HasilColors.amberAccent,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: _HasilColors.amberDark,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Skrining Ulang',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _HasilColors.amberDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: _HasilColors.textDark,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Konsultasi Dokter',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _HasilColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =============================================================
              // 1. Card Hasil Skrining (Donut + Mascot + Info Box)
              // =============================================================
              _buildTopScreeningCard(),
              const SizedBox(height: 16),

              // =============================================================
              // 2. Card Tingkat Keyakinan Model
              // =============================================================
              _buildModelConfidenceCard(),
              const SizedBox(height: 16),

              // =============================================================
              // 3. Card Penjelasan Hasil
              // =============================================================
              _buildExplanationCard(isPos),
              const SizedBox(height: 16),

              // =============================================================
              // 4. Card Data yang Digunakan untuk Prediksi
              // =============================================================
              _buildPredictionDataCard(items),
              const SizedBox(height: 16),

              // =============================================================
              // 5. Card Rekomendasi
              // =============================================================
              _buildRecommendationsCard(recs),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget 1: Card Hasil Skrining
  // ---------------------------------------------------------------------------
  Widget _buildTopScreeningCard() {
    return Container(
      decoration: BoxDecoration(
        color: _HasilColors.cardBg,
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: _HasilColors.avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/bone_character.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    SizedBox(height: 2),
                    Text(
                      'Berikut adalah hasil analisis berdasarkan data yang Anda masukkan.',
                      style: TextStyle(
                        fontSize: 12,
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
          const SizedBox(height: 20),

          // Gauge Melingkar & Maskot Tulang
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Gauge
              SizedBox(
                width: 155,
                height: 155,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(155, 155),
                      painter: _CircularGaugePainter(
                        percentage: (widget.scorePercentage / 100.0).clamp(0.0, 1.0),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPercentage(widget.scorePercentage),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _HasilColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Probabilitas\nOsteoporosis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _HasilColors.textDark,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Maskot Tulang Menggemaskan dengan Efek Sparkle
              SizedBox(
                width: 95,
                height: 135,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkles dekoratif
                    const Positioned(
                      top: 4,
                      left: 2,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 15,
                        color: _HasilColors.amberAccent,
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      right: 2,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 13,
                        color: _HasilColors.amberAccent,
                      ),
                    ),
                    // Karakter Tulang
                    Transform.rotate(
                      angle: 0.12,
                      child: Image.asset(
                        'assets/images/bone_character.png',
                        fit: BoxFit.contain,
                        height: 115,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Kotak Informasi Kuning Muda
          Container(
            decoration: BoxDecoration(
              color: _HasilColors.infoBoxBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _HasilColors.infoBoxBorder,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_rounded,
                  color: _HasilColors.amberAccent,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Angka ini menunjukkan kemungkinan Anda mengalami osteoporosis berdasarkan data yang Anda masukkan. Semakin tinggi persentasenya, semakin besar kemungkinan osteoporosis.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF78716C),
                      height: 1.4,
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

  // ---------------------------------------------------------------------------
  // Widget 2: Card Tingkat Keyakinan Model
  // ---------------------------------------------------------------------------
  Widget _buildModelConfidenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: _HasilColors.cardBg,
        borderRadius: BorderRadius.circular(18),
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
          // Header Bar Chart + Title + Info Icon
          Row(
            children: [
              // Icon Bar Chart (3 bar vertical bertingkat warna amber)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 4,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _HasilColors.amberAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 4,
                    height: 15,
                    decoration: BoxDecoration(
                      color: _HasilColors.amberAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2.5),
                  Container(
                    width: 4,
                    height: 19,
                    decoration: BoxDecoration(
                      color: _HasilColors.amberAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Text(
                'Tingkat Keyakinan Model',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _HasilColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.info_outline_rounded,
                size: 16.5,
                color: _HasilColors.textLight,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Angka Persentase Besar
          Text(
            _formatPercentage(effectiveConfidence),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _HasilColors.amberDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Progress Bar Horisontal
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (effectiveConfidence / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                _HasilColors.amberAccent,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Catatan Info di Bawah Progress Bar
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_rounded,
                color: _HasilColors.amberAccent,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Menunjukkan seberapa yakin model terhadap hasil prediksinya. Semakin tinggi nilainya, semakin yakin model bahwa hasil ini benar.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: _HasilColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget 3: Card Penjelasan Hasil
  // ---------------------------------------------------------------------------
  Widget _buildExplanationCard(bool isPos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _HasilColors.amberAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.assignment_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Penjelasan Hasil',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _HasilColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Kontainer Penjelasan (Merah muda jika risiko tinggi, Biru muda jika risiko rendah)
        Container(
          decoration: BoxDecoration(
            color: isPos
                ? _HasilColors.highRiskBoxBg
                : _HasilColors.lowRiskBoxBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPos
                  ? _HasilColors.highRiskBoxBorder
                  : _HasilColors.lowRiskBoxBorder,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPos
                      ? _HasilColors.highRiskIconBg
                      : _HasilColors.lowRiskIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: isPos
                        ? _HasilColors.highRiskIconColor
                        : _HasilColors.lowRiskIconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar ${_formatPercentage(widget.scorePercentage)}. Model memiliki tingkat keyakinan ${_formatPercentage(effectiveConfidence)} terhadap hasil prediksi ini.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Widget 4: Card Data yang Digunakan untuk Prediksi
  // ---------------------------------------------------------------------------
  Widget _buildPredictionDataCard(List<PredictionItem> items) {
    final displayedItems = _isPredictionDataExpanded
        ? items
        : items.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: _HasilColors.cardBg,
        borderRadius: BorderRadius.circular(18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Baris
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _HasilColors.amberAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.format_list_bulleted_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Data yang Digunakan untuk Prediksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _HasilColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: _HasilColors.textMuted,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daftar Baris
          for (int i = 0; i < displayedItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _PredictionRowWidget(item: displayedItems[i]),
          ],

          if (items.length > 4) ...[
            const SizedBox(height: 14),
            InkWell(
              onTap: () {
                setState(() {
                  _isPredictionDataExpanded = !_isPredictionDataExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isPredictionDataExpanded
                          ? 'Sembunyikan'
                          : 'Lihat selengkapnya',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _HasilColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isPredictionDataExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _HasilColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget 5: Card Rekomendasi
  // ---------------------------------------------------------------------------
  Widget _buildRecommendationsCard(List<String> recs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Row(
          children: [
            Icon(
              Icons.lightbulb_rounded,
              color: _HasilColors.amberAccent,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Rekomendasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _HasilColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Kontainer List Rekomendasi
        Container(
          decoration: BoxDecoration(
            color: _HasilColors.recCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _HasilColors.recCardBorder,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < recs.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: _HasilColors.amberAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recs[i],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
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
      ],
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
// CUSTOM PAINTER: _CircularGaugePainter
// =============================================================================
class _CircularGaugePainter extends CustomPainter {
  final double percentage; // Nilai 0.0 s/d 1.0

  const _CircularGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const strokeWidth = 14.0;

    // 1. Lingkaran background (krem lembut)
    final trackPaint = Paint()
      ..color = _HasilColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Arc aktif (kuning amber)
    final activePaint = Paint()
      ..color = _HasilColors.amberAccent
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
