import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Palet warna resmi Halaman Detail Riwayat (konsisten dengan Dashboard & History)
// ---------------------------------------------------------------------------
class _DetailColors {
  static const Color background         = Colors.white;
  static const Color textDark           = Color(0xFF1E293B);
  static const Color textMuted          = Color(0xFF64748B);
  static const Color textLight          = Color(0xFF94A3B8);
  static const Color borderLight        = Color(0xFFF1F5F9);
  static const Color orange             = Color(0xFFF59E0B);
  static const Color amberScore         = Color(0xFFD97706);
  static const Color gaugeTrack         = Color(0xFFFEF3C7);

  // Card Hasil Skrining
  static const Color screeningPosBg     = Color(0xFFFFF5F6);
  static const Color screeningPosBorder = Color(0xFFFFCCD3);
  static const Color redResult          = Color(0xFFE11D48);

  // Card Rekomendasi & Konsultasi
  static const Color yellowCardBg       = Color(0xFFFFFDF5);
  static const Color yellowCardBorder   = Color(0xFFFDE68A);
  static const Color bulbCircleBg       = Color(0xFFFEF08A);
}

/// Model untuk data prediksi pada tabel
class _DetailPredictionItem {
  final IconData icon;
  final String label;
  final String value;

  const _DetailPredictionItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Halaman Detail Riwayat Skrining Osteoporosis.
class HistoryDetailPage extends StatelessWidget {
  final String tanggal;
  final String waktu;
  final double probabilitas;
  final String statusHasil;
  final String deskripsiHasil;
  final String namaDokter;
  final String spesialisDokter;
  final String tanggalKonsultasi;
  final String keluhan;
  final String? fotoDokterUrl;
  final VoidCallback? onRingkasanKonsultasiTap;

  const HistoryDetailPage({
    super.key,
    this.tanggal = '12 September 2025',
    this.waktu = 'Pukul 14.30 WIB',
    this.probabilitas = 58,
    this.statusHasil = 'Terindikasi Osteoporosis',
    this.deskripsiHasil =
        'Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar 58%.',
    this.namaDokter = 'dr. Andi Wijaya, Sp.OT',
    this.spesialisDokter = 'Spesialis: Bedah Panggul & Lutut',
    this.tanggalKonsultasi = '12 September 2026 • 10.45 WIB',
    this.keluhan =
        'Keluhan: Nyeri pada pinggang sejak beberapa bulan terakhir',
    this.fotoDokterUrl =
        'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=400&q=80',
    this.onRingkasanKonsultasiTap,
  });

  static const List<_DetailPredictionItem> _predictionItems = [
    _DetailPredictionItem(
      icon: Icons.person_outline_rounded,
      label: 'Usia',
      value: '60 tahun',
    ),
    _DetailPredictionItem(
      icon: Icons.female_rounded,
      label: 'Jenis kelamin',
      value: 'Perempuan',
    ),
    _DetailPredictionItem(
      icon: Icons.science_outlined,
      label: 'Perubahan hormonal',
      value: 'Ya',
    ),
    _DetailPredictionItem(
      icon: Icons.people_outline_rounded,
      label: 'Riwayat keluarga',
      value: 'Ya',
    ),
    _DetailPredictionItem(
      icon: Icons.public_rounded,
      label: 'Ras/Etnis',
      value: 'Kaukasia',
    ),
    _DetailPredictionItem(
      icon: Icons.scale_outlined,
      label: 'Berat badan',
      value: 'Rendah',
    ),
    _DetailPredictionItem(
      icon: Icons.accessibility_new_rounded,
      label: 'Asupan kalsium',
      value: 'Rendah',
    ),
    _DetailPredictionItem(
      icon: Icons.wb_sunny_outlined,
      label: 'Asupan vitamin D',
      value: 'Rendah',
    ),
    _DetailPredictionItem(
      icon: Icons.directions_walk_rounded,
      label: 'Aktivitas fisik',
      value: 'Rendah',
    ),
    _DetailPredictionItem(
      icon: Icons.smoke_free_rounded,
      label: 'Merokok',
      value: 'Tidak',
    ),
    _DetailPredictionItem(
      icon: Icons.local_bar_outlined,
      label: 'Konsumsi alkohol',
      value: 'Tidak',
    ),
    _DetailPredictionItem(
      icon: Icons.medical_services_outlined,
      label: 'Kondisi medis',
      value: 'Hipertiroidisme',
    ),
    _DetailPredictionItem(
      icon: Icons.medication_outlined,
      label: 'Penggunaan obat',
      value: 'Kortikosteroid',
    ),
    _DetailPredictionItem(
      icon: Icons.link_rounded,
      label: 'Riwayat patah tulang',
      value: 'Ya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DetailColors.background,
      appBar: AppBar(
        backgroundColor: _DetailColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: _DetailColors.textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _DetailColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // 1. Card Informasi Tanggal Skrining
              // -------------------------------------------------------------
              _buildDateCard(),

              const SizedBox(height: 16),

              // -------------------------------------------------------------
              // 2. Card Hasil Skrining
              // -------------------------------------------------------------
              _buildScreeningResultCard(),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 3. Card Data yang Digunakan untuk Prediksi
              // -------------------------------------------------------------
              _buildPredictionDataCard(),

              const SizedBox(height: 16),

              // -------------------------------------------------------------
              // 4. Card Rekomendasi
              // -------------------------------------------------------------
              _buildRecommendationCard(),

              const SizedBox(height: 22),

              // -------------------------------------------------------------
              // 5. Card Ringkasan Konsultasi
              // -------------------------------------------------------------
              _buildConsultationSection(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Card tanggal & waktu skrining
  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DetailColors.borderLight,
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 22,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tanggal,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _DetailColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                waktu,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _DetailColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card hasil skrining (gauge + keterangan risiko)
  Widget _buildScreeningResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DetailColors.screeningPosBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DetailColors.screeningPosBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Gauge
          SizedBox(
            width: 106,
            height: 106,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(106, 106),
                  painter: _DetailCircularGaugePainter(
                    percentage: probabilitas / 100.0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _DetailColors.orange,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Probabilitas\nOsteoporosis',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _DetailColors.textMuted,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.speed_outlined,
                      size: 13,
                      color: _DetailColors.textLight,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Teks Keterangan Hasil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 14,
                      color: _DetailColors.redResult,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'HASIL SKRINING',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _DetailColors.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  statusHasil,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _DetailColors.redResult,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  deskripsiHasil,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card data input yang digunakan untuk prediksi model C4.5
  Widget _buildPredictionDataCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DetailColors.borderLight,
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
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: _DetailColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Berikut adalah seluruh data yang Anda masukkan dan digunakan oleh model Decision Tree (C4.5) dalam menghasilkan prediksi.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: _DetailColors.textLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _predictionItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 13),
            _buildPredictionRow(_predictionItems[i]),
          ],
        ],
      ),
    );
  }

  /// Baris item data prediksi
  Widget _buildPredictionRow(_DetailPredictionItem item) {
    return Row(
      children: [
        Icon(
          item.icon,
          size: 19,
          color: _DetailColors.textLight,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _DetailColors.textDark,
          ),
        ),
      ],
    );
  }

  /// Card Rekomendasi
  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DetailColors.yellowCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DetailColors.yellowCardBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _DetailColors.bulbCircleBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb_rounded,
                size: 20,
                color: _DetailColors.amberScore,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _DetailColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Jaga pola makan tinggi kalsium, rutin beraktivitas fisik, dan konsultasikan hasil ini ke dokter untuk evaluasi lebih lanjut.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian Ringkasan Konsultasi
  Widget _buildConsultationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Konsultasi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _DetailColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _DetailColors.yellowCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _DetailColors.yellowCardBorder,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: fotoDokterUrl != null
                        ? Image.network(
                            fotoDokterUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDoctorFallbackAvatar(),
                          )
                        : _buildDoctorFallbackAvatar(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaDokter,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _DetailColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spesialisDokter,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: _DetailColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: _DetailColors.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tanggalKonsultasi,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: _DetailColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          keluhan,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: _DetailColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: onRingkasanKonsultasiTap ?? () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: _DetailColors.orange,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: _DetailColors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ringkasan Konsultasi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _DetailColors.orange,
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
    );
  }

  Widget _buildDoctorFallbackAvatar() {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFFE2E8F0),
      child: const Icon(
        Icons.person,
        size: 28,
        color: _DetailColors.textMuted,
      ),
    );
  }
}

/// CustomPainter untuk Circular Progress Gauge probabilitas
class _DetailCircularGaugePainter extends CustomPainter {
  final double percentage; // 0.0 - 1.0

  const _DetailCircularGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    // Track lingkaran belakang
    final trackPaint = Paint()
      ..color = _DetailColors.gaugeTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      trackPaint,
    );

    // Active progress arc
    final progressPaint = Paint()
      ..color = _DetailColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DetailCircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
