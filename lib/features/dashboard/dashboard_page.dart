import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/education/education_page.dart';


/// Definisi palet warna resmi Osteo Dashboard sesuai spesifikasi
class _DashboardColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color orange = Color(0xFFF59E0B);
  static const Color lightOrange = Color(0xFFFFF7E8);
  static const Color pink = Color(0xFFFFE8EC);
  static const Color abuMuda = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFEAEAEA);

  // Warna pendukung untuk hierarki visual & tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color redAlert = Color(0xFFE11D48);
}

/// Halaman Dashboard utama Osteo
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                _HeaderSection(),
                SizedBox(height: 18),
                _BannerSection(),
                SizedBox(height: 22),
                _LatestScreeningSection(),
                SizedBox(height: 22),
                _MainMenuSection(),
                SizedBox(height: 18),
                _EducationBannerSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: _DashboardColors.border,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _DashboardColors.orange,
        unselectedItemColor: _DashboardColors.textLight,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.home_rounded, size: 24),
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.calendar_today_outlined, size: 21),
            ),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.menu_book_rounded, size: 22),
            ),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.person_rounded, size: 24),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION 1: HEADER
// =============================================================================
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar foto profil Risma
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _DashboardColors.abuMuda,
            border: Border.all(
              color: _DashboardColors.border,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: _DashboardColors.textMuted,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _DashboardColors.primaryButterYellow,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Nama pengguna & teks penyemangat
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, Risma 👋',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _DashboardColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Semangat jaga kesehatan tulangmu!',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: _DashboardColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECTION 2: BANNER KESEHATAN
// =============================================================================
class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _DashboardColors.lightOrange,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Tulang yang sehat,\nmasa depan yang lebih\nkuat 💛',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: _DashboardColors.textDark,
                height: 1.35,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 86,
            height: 90,
            child: CustomPaint(
              painter: _CuteBoneMascotPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk menggambar maskot tulang tersenyum dengan kilau bintang
class _CuteBoneMascotPainter extends CustomPainter {
  const _CuteBoneMascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Kilau bintang kuning di sekitar tulang
    final sparklePaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    _drawSparkle(canvas, Offset(size.width * 0.15, size.height * 0.28), 7, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.22), 9, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.86, size.height * 0.62), 6, sparklePaint);

    // Garis lengkung kuning di samping tulang
    final arcPaint = Paint()
      ..color = _DashboardColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final arcPath = Path();
    arcPath.moveTo(size.width * 0.32, size.height * 0.82);
    arcPath.quadraticBezierTo(
      size.width * 0.22,
      size.height * 0.88,
      size.width * 0.28,
      size.height * 0.95,
    );
    canvas.drawPath(arcPath, arcPaint);

    final smallArcPath = Path();
    smallArcPath.moveTo(size.width * 0.70, size.height * 0.90);
    smallArcPath.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.92,
      size.width * 0.82,
      size.height * 0.86,
    );
    canvas.drawPath(smallArcPath, arcPaint);

    // Posisi tulang di tengah dengan rotasi miring natural
    canvas.save();
    canvas.translate(size.width * 0.58, size.height * 0.50);
    canvas.rotate(0.12);

    // Bentuk tulang
    final boneFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boneStrokePaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    // Kepala atas tulang
    bonePath.moveTo(-10, -28);
    bonePath.cubicTo(-18, -36, -3, -40, 0, -32);
    bonePath.cubicTo(3, -40, 18, -36, 10, -28);
    // Batang kanan
    bonePath.cubicTo(8, -14, 8, 14, 10, 28);
    // Kepala bawah tulang
    bonePath.cubicTo(18, 36, 3, 40, 0, 32);
    bonePath.cubicTo(-3, 40, -18, 36, -10, 28);
    // Batang kiri
    bonePath.cubicTo(-8, 14, -8, -14, -10, -28);
    bonePath.close();

    canvas.drawPath(bonePath, boneFillPaint);
    canvas.drawPath(bonePath, boneStrokePaint);

    // Wajah lucu (mata, pipi merona, senyuman)
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(-4.5, -4), 1.8, eyePaint);
    canvas.drawCircle(const Offset(4.5, -4), 1.8, eyePaint);

    final eyeShinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-4.0, -4.5), 0.6, eyeShinePaint);
    canvas.drawCircle(const Offset(5.0, -4.5), 0.6, eyeShinePaint);

    final blushPaint = Paint()
      ..color = const Color(0xFFFFB4C0).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-7.5, -1.5), 2.2, blushPaint);
    canvas.drawCircle(const Offset(7.5, -1.5), 2.2, blushPaint);

    final smilePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(-2.5, -0.5);
    smilePath.quadraticBezierTo(0, 1.8, 2.5, -0.5);
    canvas.drawPath(smilePath, smilePaint);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// SECTION 3: HASIL SKRINING TERBARU
// =============================================================================
class _LatestScreeningSection extends StatelessWidget {
  const _LatestScreeningSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul section dan tanggal
        const Text(
          'Hasil Skrining Terbaru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _DashboardColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '20 Mei 2025',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _DashboardColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        // Card Hasil Skrining
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFDDE3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gauge lingkaran persentase 58%
              const SizedBox(
                width: 104,
                height: 104,
                child: CustomPaint(
                  painter: _ScreeningGaugePainter(percentage: 0.58),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '58%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _DashboardColors.orange,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Probabilitas\nOsteoporosis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: _DashboardColors.textMuted,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 11,
                          color: _DashboardColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Deskripsi diagnosis
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Maskot kecil merah
                        const SizedBox(
                          width: 28,
                          height: 34,
                          child: CustomPaint(
                            painter: _RedScreeningMascotPainter(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HASIL SKRINING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _DashboardColors.textMuted.withValues(alpha: 0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Terindikasi\nOsteoporosis',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _DashboardColors.redAlert,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar 58%.',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: _DashboardColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter untuk lingkaran gauge 58%
class _ScreeningGaugePainter extends CustomPainter {
  final double percentage;

  const _ScreeningGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 11.0;

    // Track lingkaran belakang berwarna kuning pastel muda
    final bgPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress aktif melengkung di bagian bawah seperti di desain gambar
    final progressPaint = Paint()
      ..color = _DashboardColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi * 0.75;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScreeningGaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}

/// Custom painter maskot merah kecil di kartu hasil skrining
class _RedScreeningMascotPainter extends CustomPainter {
  const _RedScreeningMascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = const Color(0xFFFF4D6D)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Badan maskot
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.20, size.height * 0.18, size.width * 0.60, size.height * 0.58),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paintFill);
    canvas.drawRRect(bodyRect, paintStroke);

    // Tangan kecil
    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.40),
      Offset(size.width * 0.05, size.height * 0.46),
      paintStroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.80, size.height * 0.40),
      Offset(size.width * 0.95, size.height * 0.46),
      paintStroke,
    );

    // Kaki kecil
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.76),
      Offset(size.width * 0.32, size.height * 0.92),
      paintStroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.76),
      Offset(size.width * 0.68, size.height * 0.92),
      paintStroke,
    );

    // Mata ekspresif
    final eyeWhite = Paint()..color = Colors.white;
    final eyeBlack = Paint()..color = const Color(0xFF1E293B);

    canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.40), 3.0, eyeWhite);
    canvas.drawCircle(Offset(size.width * 0.60, size.height * 0.40), 3.0, eyeWhite);
    canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.40), 1.4, eyeBlack);
    canvas.drawCircle(Offset(size.width * 0.60, size.height * 0.40), 1.4, eyeBlack);

    // Mulut 'o'
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.55),
        width: 3.5,
        height: 4.5,
      ),
      mouthPaint,
    );

    // Tetesan keringat cemas
    final sweatPaint = Paint()
      ..color = const Color(0xFF60A5FA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.22), 1.6, sweatPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// SECTION 4: MENU UTAMA (GRID 2x2)
// =============================================================================
class _MainMenuSection extends StatelessWidget {
  const _MainMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _DashboardColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.98,
          children: [
            _MenuItemCard(
              title: 'Skrining',
              subtitle: 'Cek risiko osteoporosis sekarang',
              icon: Icons.assignment_outlined,
              iconColor: _DashboardColors.orange,
              iconBgColor: _DashboardColors.lightOrange,
            ),
            _MenuItemCard(
              title: 'Konsultasi Dokter',
              subtitle: 'Tanya langsung dengan dokter ahli',
              icon: Icons.person_pin_outlined,
              iconColor: Color(0xFF3B82F6),
              iconBgColor: Color(0xFFEFF6FF),
            ),
            _MenuItemCard(
              title: 'Edukasi',
              subtitle: 'Pelajari lebih banyak tentang kesehatan tulang',
              icon: Icons.menu_book_rounded,
              iconColor: Color(0xFFF43F5E),
              iconBgColor: _DashboardColors.pink,
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EducationPage(),
                ),
              );
            },
          ),

            _MenuItemCard(
              title: 'Riwayat',
              subtitle: 'Lihat hasil skrining dan aktivitasmu',
              icon: Icons.access_time_filled_rounded,
              iconColor: Color(0xFF8B5CF6),
              iconBgColor: Color(0xFFF3E8FF),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual untuk tiap item Menu Utama
class _MenuItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  const _MenuItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,     
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _DashboardColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wadah icon berlatar warna pastel
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 26,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Judul menu
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _DashboardColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Keterangan menu
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: _DashboardColors.textLight,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 5: BANNER EDUKASI (TAHUKAH ANDA)
// =============================================================================
class _EducationBannerSection extends StatelessWidget {
  const _EducationBannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _DashboardColors.lightOrange,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sisi kiri: teks edukasi & tombol aksi
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahukah anda?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _DashboardColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Setelah usia 50 tahun, kepadatan tulang mulai berkurang secara alami.',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: _DashboardColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tombol 'Baca selengkapnya >'
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _DashboardColors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca selengkapnya',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _DashboardColors.textDark,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 15,
                              color: _DashboardColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sisi kanan: ilustrasi wanita berolahraga dumbbell
            const Expanded(
              flex: 9,
              child: SizedBox(
                height: 130,
                child: CustomPaint(
                  painter: _FitnessWomanPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter ilustrasi wanita berolahraga mengangkat dumbbell
class _FitnessWomanPainter extends CustomPainter {
  const _FitnessWomanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Latar belakang oval hijau muda lembut
    final bgGlowPaint = Paint()
      ..color = const Color(0xFFE8F5E9).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.78),
        width: size.width * 0.72,
        height: size.height * 0.45,
      ),
      bgGlowPaint,
    );

    // Kilau energi kuning di sekitar barbel
    final sparkPaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.28),
      Offset(size.width * 0.85, size.height * 0.25),
      sparkPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.79, size.height * 0.33),
      Offset(size.width * 0.86, size.height * 0.33),
      sparkPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.38),
      Offset(size.width * 0.83, size.height * 0.41),
      sparkPaint,
    );

    // Kaki legging hitam dengan pose lunge
    final leggingPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Kaki belakang
    final backLeg = Path();
    backLeg.moveTo(size.width * 0.60, size.height * 0.68);
    backLeg.quadraticBezierTo(
      size.width * 0.48,
      size.height * 0.76,
      size.width * 0.34,
      size.height * 0.82,
    );
    canvas.drawPath(backLeg, leggingPaint);

    // Kaki depan
    final frontLeg = Path();
    frontLeg.moveTo(size.width * 0.60, size.height * 0.68);
    frontLeg.lineTo(size.width * 0.74, size.height * 0.78);
    frontLeg.lineTo(size.width * 0.72, size.height * 0.88);
    canvas.drawPath(frontLeg, leggingPaint);

    // Sepatu kuning
    final shoePaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.30, size.height * 0.84),
          width: 14,
          height: 6,
        ),
        const Radius.circular(3),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.74, size.height * 0.90),
          width: 15,
          height: 6,
        ),
        const Radius.circular(3),
      ),
      shoePaint,
    );

    // Baju olahraga kuning (crop tank top)
    final topPaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.60, size.height * 0.52),
        width: 19,
        height: 18,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(torsoRect, topPaint);

    // Warna kulit tubuh
    final skinPaint = Paint()
      ..color = const Color(0xFFFDDCB4)
      ..style = PaintingStyle.fill;

    final skinStrokePaint = Paint()
      ..color = const Color(0xFFFDDCB4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    // Leher & perut
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.56, size.height * 0.40, 6, 6),
      skinPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.54, size.height * 0.60, 11, 4),
      skinPaint,
    );

    // Wajah
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.61, size.height * 0.35),
        width: 15,
        height: 17,
      ),
      skinPaint,
    );

    // Rambut gelap & kuncir kuda
    final hairPaint = Paint()
      ..color = const Color(0xFF271D18)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.60, size.height * 0.33),
        width: 16,
        height: 16,
      ),
      math.pi,
      math.pi,
      true,
      hairPaint,
    );

    final ponytailPath = Path();
    ponytailPath.moveTo(size.width * 0.56, size.height * 0.32);
    ponytailPath.cubicTo(
      size.width * 0.44,
      size.height * 0.28,
      size.width * 0.40,
      size.height * 0.42,
      size.width * 0.50,
      size.height * 0.44,
    );
    ponytailPath.close();
    canvas.drawPath(ponytailPath, hairPaint);

    // Lengan kiri & kanan
    canvas.drawLine(
      Offset(size.width * 0.53, size.height * 0.48),
      Offset(size.width * 0.46, size.height * 0.53),
      skinStrokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.53),
      Offset(size.width * 0.48, size.height * 0.43),
      skinStrokePaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.67, size.height * 0.48),
      Offset(size.width * 0.74, size.height * 0.53),
      skinStrokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, size.height * 0.53),
      Offset(size.width * 0.72, size.height * 0.43),
      skinStrokePaint,
    );

    // Dumbbell kuning
    final dumbbellPaint = Paint()
      ..color = _DashboardColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.48, size.height * 0.42), width: 7, height: 11),
        const Radius.circular(2),
      ),
      dumbbellPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.72, size.height * 0.42), width: 7, height: 11),
        const Radius.circular(2),
      ),
      dumbbellPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
