import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/consultation/consultation_page.dart';
import 'package:oste/features/education/articles/article_data.dart';
import 'package:oste/features/education/articles/article_detail_page.dart';
import 'package:oste/features/education/articles/article_model.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/education/tahukah_anda/tahukah_anda_page.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/features/screening/screening_page.dart';
import 'package:oste/services/history_service.dart';
import 'package:oste/services/user_service.dart';

/// Definisi palet warna resmi Osteo Dashboard sesuai spesifikasi
class _DashboardColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color orange = Color(0xFFF59E0B);
  static const Color lightOrange = Color(0xFFFFF7E8);
  static const Color pastelButterYellow = Color(0xFFFFF9E5);
  static const Color softButterYellow = Color(0xFFFFF2B5);
  static const Color abuMuda = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFECECEC);

  // Gradient Soft Butter Yellow lembut & hangat identik untuk Hero Card & Card Tahukah Anda
  static const LinearGradient softButterYellowCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF6C8), // Variasi tone lembut creamy +5%
      softButterYellow, // Warna dasar Soft Butter Yellow (#FFF2B5)
      Color(0xFFFEED9F), // Variasi tone lembut golden -6%
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Warna background referensi
  static const Color bgCreamYellow = Color(0xFFFFF9EA);
  static const Color bgDecorLavender = Color(0xFFEDEBF7);

  // Warna pendukung untuk hierarki visual & tipografi
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color redAlert = Color(0xFFE11D48);
}

/// Halaman Dashboard utama Osteo
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const creamColor = _DashboardColors.bgCreamYellow;
    const decorColor = _DashboardColors.bgDecorLavender;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Base gradient #FFF9EA dan putih menyebar seperti di gambar referensi
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    creamColor,        // Warna #FFF9EA di sudut atas-kiri
                    Color(0xFFFFFDF8), // Transisi lembut
                    Colors.white,      // Putih murni di bagian tengah & bawah
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Bentuk sebaran gradasi organik lembut #FFF9EA di area atas
          Positioned(
            top: -70,
            left: -50,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    creamColor,
                    creamColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    creamColor.withValues(alpha: 0.70),
                    creamColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 3. Elemen dekorasi background sesuai referensi (Warna #EDEBF7, tanpa icon love)
          // Sparkle 4-point star di kanan atas (seperti samping logo ZenZ)
          Positioned(
            top: 85,
            right: 30,
            child: SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: _FourPointStarPainter(color: decorColor),
              ),
            ),
          ),

          // Sparkle 4-point star kecil di kiri atas
          Positioned(
            top: 135,
            left: 36,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _FourPointStarPainter(color: decorColor),
              ),
            ),
          ),

          // Sparkle 4-point star di tengah-kanan
          Positioned(
            top: 430,
            right: 24,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(
                painter: _FourPointStarPainter(color: decorColor),
              ),
            ),
          ),

          // Sparkle 4-point star di bawah-kiri
          Positioned(
            bottom: 160,
            left: 20,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(
                painter: _FourPointStarPainter(color: decorColor),
              ),
            ),
          ),

          // Bola/sphere dekoratif di kanan atas (seperti di referensi)
          Positioned(
            top: 50,
            right: 68,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: decorColor,
                boxShadow: [
                  BoxShadow(
                    color: decorColor.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Aksen balon oval halus di sudut kiri atas
          Positioned(
            top: 30,
            left: -15,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 48,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: decorColor.withValues(alpha: 0.60),
                ),
              ),
            ),
          ),

          // Dot bulat kecil di tengah-kanan
          Positioned(
            top: 350,
            right: 48,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: decorColor,
              ),
            ),
          ),

          // Garis lengkung bergelombang di kanan-bawah (seperti di referensi)
          Positioned(
            bottom: 100,
            right: 8,
            child: SizedBox(
              width: 90,
              height: 80,
              child: CustomPaint(
                painter: _BackgroundWaveArcPainter(color: decorColor),
              ),
            ),
          ),

          // Garis lengkung bergelombang halus di kiri-tengah
          Positioned(
            top: 470,
            left: 8,
            child: SizedBox(
              width: 65,
              height: 65,
              child: CustomPaint(
                painter: _BackgroundWaveArcLeftPainter(color: decorColor),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const _HeaderSection(),
                    const SizedBox(height: 14),
                    const _LatestScreeningSection(),
                    const SizedBox(height: 16),
                    const _MainMenuSection(),
                    const SizedBox(height: 16),
                    const _ArticleCarouselSection(),
                    const SizedBox(height: 16),
                    const _EducationBannerSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          if (index == _currentIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DashboardPage(),
                ),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EducationPage(),
                ),
              );
              break;

            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
              break;
          }
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

/// Painter bintang 4 sudut persis seperti di referensi gambar
class _FourPointStarPainter extends CustomPainter {
  final Color color;

  const _FourPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FourPointStarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter garis lengkung dekoratif di kanan bawah seperti di referensi
class _BackgroundWaveArcPainter extends CustomPainter {
  final Color color;

  const _BackgroundWaveArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.45,
      size.width * 0.65,
      size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundWaveArcPainter oldDelegate) => false;
}

/// Painter garis lengkung dekoratif di kiri tengah
class _BackgroundWaveArcLeftPainter extends CustomPainter {
  final Color color;

  const _BackgroundWaveArcLeftPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      0,
      size.height * 0.85,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundWaveArcLeftPainter oldDelegate) => false;
}

// =============================================================================
// SECTION 1: HEADER
// =============================================================================
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserService(),
      builder: (context, _) {
        final user = UserService().currentUser;
        final displayName = user != null ? user.firstName : 'Pengguna';

        // Ambil huruf pertama nama untuk avatar (identik dengan ProfilePage)
        final String avatarLetter = (displayName.isNotEmpty)
            ? displayName.trim()[0].toUpperCase()
            : '?';

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Soft Butter Yellow identik dengan Card Tahukah Anda
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _DashboardColors.softButterYellowCardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFF6DE8A),
                    width: 1,
                  ),
                  boxShadow: [
                    // Ambient shadow lembut
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                    // Key shadow hangat
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Konten Hero Card (Logo, Nama, Greeting, Deskripsi)
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 140),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 16, 125, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Bar: Avatar & Logo OsteoCare
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF59E0B),
                            ),
                            child: Center(
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Osteo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Care',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF59E0B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Greeting text
                      Text(
                        'Hallo, $displayName! 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _DashboardColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Yuk jaga kesehatan tulangmu\nmulai hari ini!',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: _DashboardColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Positioned bone_character.png di pojok kanan
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/bone_character.png',
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// SECTION 3: HASIL SKRINING TERBARU
// =============================================================================
class _LatestScreeningSection extends StatelessWidget {
  const _LatestScreeningSection();

  static String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final historyService = HistoryService();

    return AnimatedBuilder(
      animation: historyService,
      builder: (context, _) {
        final latest = historyService.latestScreening;

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
            if (latest != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatDate(latest.tanggal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _DashboardColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (latest == null)
              _buildPlaceholder(context)
            else
              _buildResultCard(context, latest),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2937).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Image.asset(
              'assets/images/bone_screening.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belum Ada Hasil Skrining',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _DashboardColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lakukan skrining untuk mengetahui tingkat risiko osteoporosis Anda.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _DashboardColors.textMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScreeningPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _DashboardColors.primaryButterYellow,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: _DashboardColors.primaryButterYellow
                                .withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mulai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _DashboardColors.textDark,
                            ),
                          ),
                          Text(
                            ' Skrining',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _DashboardColors.textDark,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: _DashboardColors.textDark,
                          ),
                        ],
                      ),
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

  Widget _buildResultCard(BuildContext context, dynamic latest) {
    final bool isPos = latest.isPositive;
    final Color borderColor = isPos ? const Color(0xFFFFE4E6) : const Color(0xFFDCFCE7);
    final Color statusColor = isPos ? _DashboardColors.redAlert : const Color(0xFF16A34A);
    final String statusText = isPos ? 'Terindikasi\nOsteoporosis' : 'Tidak Terindikasi\nOsteoporosis';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HasilScreeningPage(
              scorePercentage: latest.probabilitas.toDouble(),
              riskTitle: latest.riskCategory ?? (isPos ? 'risiko sedang' : 'risiko rendah'),
              riskDescription: latest.summary ?? '',
              predictionData: latest.predictionData,
              recommendations: latest.recommendations,
              screeningId: latest.id,
              autoSave: false,
              source: 'history',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gauge lingkaran persentase (lebih kecil)
            SizedBox(
              width: 88,
              height: 88,
              child: CustomPaint(
                painter: _ScreeningGaugePainter(
                  percentage: (latest.probabilitas / 100.0).clamp(0.0, 1.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${latest.probabilitas}%',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: _DashboardColors.orange,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'Probabilitas\nOsteoporosis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w500,
                          color: _DashboardColors.textMuted,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Deskripsi diagnosis
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 30,
                        child: CustomPaint(
                          painter: _RedScreeningMascotPainter(isPositive: isPos),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HASIL SKRINING',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _DashboardColors.textMuted.withValues(alpha: 0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    latest.summary ??
                        'Berdasarkan data yang Anda masukkan, model memprediksi kemungkinan Anda mengalami osteoporosis sebesar ${latest.probabilitas}%.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: _DashboardColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

/// Custom painter maskot merah/hijau kecil di kartu hasil skrining
class _RedScreeningMascotPainter extends CustomPainter {
  final bool isPositive;
  const _RedScreeningMascotPainter({this.isPositive = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..color = isPositive ? const Color(0xFFFF4D6D) : const Color(0xFF4ADE80)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = isPositive ? const Color(0xFFE11D48) : const Color(0xFF16A34A)
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
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.20,
          children: [
            _MenuItemCard(
              title: 'Skrining',
              subtitle: 'Cek risiko osteoporosis',
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFFD97706),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScreeningPage(),
                  ),
                );
              },
            ),
            _MenuItemCard(
              title: 'Konsultasi Dokter',
              subtitle: 'Tanya langsung dengan dokter ahli',
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF2563EB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultationPage(),
                  ),
                );
              },
            ),
            _MenuItemCard(
              title: 'Edukasi',
              subtitle: 'Pelajari lebih banyak tentang kesehatan tulang',
              icon: Icons.menu_book_rounded,
              iconColor: const Color(0xFFF43F5E),
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
              iconColor: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Card individual untuk tiap item Menu Utama
/// Tampilan modern terinspirasi dari referensi dengan background pastel butter yellow,
/// transisi animasi halus menjadi Butter Yellow (#F7C948) saat ditekan,
/// dan icon ditempatkan langsung di card tanpa kotak latar belakang.
class _MenuItemCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _MenuItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  State<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<_MenuItemCard> {
  bool _isPressed = false;

  void _handleTap() async {
    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 140));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color pastelButterYellow = _DashboardColors.pastelButterYellow;
    final Color butterYellowPressed = _DashboardColors.primaryButterYellow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isPressed ? butterYellowPressed : pastelButterYellow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFFE5A91E)
                  : const Color(0xFFF3E7BE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? butterYellowPressed.withValues(alpha: 0.35)
                    : const Color(0xFFD97706).withValues(alpha: 0.05),
                blurRadius: _isPressed ? 14 : 10,
                offset: _isPressed ? const Offset(0, 4) : const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris atas: Icon langsung tanpa kotak latar & menu titik tiga modern seperti referensi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: 26,
                      color: widget.iconColor,
                    ),
                    Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: _isPressed
                          ? const Color(0xFF1F2937).withValues(alpha: 0.6)
                          : const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _DashboardColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _isPressed
                        ? const Color(0xFF374151)
                        : _DashboardColors.textMuted,
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
// SECTION 5: ARTIKEL CAROUSEL (HORIZONTAL LANDSCAPE)
// =============================================================================
class _ArticleCarouselSection extends StatefulWidget {
  const _ArticleCarouselSection();

  @override
  State<_ArticleCarouselSection> createState() =>
      _ArticleCarouselSectionState();
}

class _ArticleCarouselSectionState extends State<_ArticleCarouselSection> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openArticleDetail(ArticleModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailPage(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = ArticleData.articles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Artikel Terkait Osteoporosis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _DashboardColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),

        // Carousel horizontal
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final a = articles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ArticleCard(
                  data: a,
                  onTap: () => _openArticleDetail(a),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(articles.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? _DashboardColors.orange
                    : _DashboardColors.abuMuda,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Card artikel horizontal landscape
class _ArticleCard extends StatelessWidget {
  final ArticleModel data;
  final VoidCallback onTap;

  const _ArticleCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.02),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              // Thumbnail kiri
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: SizedBox(
                  width: 118,
                  height: double.infinity,
                  child: Image.asset(
                    data.heroAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.network(
                      data.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: _DashboardColors.lightOrange,
                        child: const Center(
                          child: Icon(
                            Icons.article_outlined,
                            size: 32,
                            color: _DashboardColors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Info artikel kanan
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo & teks sumber artikel
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: data.sourceColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    data.sourceInitial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data.source,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC89324), // Kuning keemasan muda yang lembut
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Judul artikel (hitam / hitam gelap)
                          Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827), // Hitam gelap
                              height: 1.25,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Deskripsi singkat
                          Text(
                            data.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: _DashboardColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),

                      // Tombol Baca Artikel
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _DashboardColors.primaryButterYellow,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: _DashboardColors.primaryButterYellow
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca Artikel',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _DashboardColors.textDark,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 11,
                              color: _DashboardColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION 6: BANNER EDUKASI (TAHUKAH ANDA)
// =============================================================================
class _EducationBannerSection extends StatelessWidget {
  const _EducationBannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Background Soft Butter Yellow identik dengan Hero Card
        gradient: _DashboardColors.softButterYellowCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF6DE8A),
          width: 1,
        ),
        boxShadow: [
          // Ambient shadow lembut
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          // Key shadow hangat
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ornamen sparkle
            Positioned(
              top: 14,
              right: 110,
              child: Icon(
                Icons.auto_awesome,
                size: 12,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
              ),
            ),
            Positioned(
              bottom: 18,
              right: 100,
              child: Icon(
                Icons.auto_awesome,
                size: 10,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sisi kiri: lampu, teks edukasi & tombol aksi
                Expanded(
                  flex: 12,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFEF08A),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.lightbulb_rounded,
                                  size: 15,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Tahukah Anda?',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _DashboardColors.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kalsium dan vitamin D berperan penting dalam menjaga kepadatan tulang sepanjang hidup.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: _DashboardColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tombol 'Baca Selengkapnya ➔'
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TahukahAndaPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _DashboardColors.primaryButterYellow,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: _DashboardColors.primaryButterYellow
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Selengkapnya',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: _DashboardColors.textDark,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
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
                // Sisi kanan: ilustrasi karakter tulang dengan balon tanya
                Expanded(
                  flex: 8,
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Glow kuning lembut di belakang karakter tulang
                        Positioned(
                          bottom: 4,
                          right: 0,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFDE68A).withValues(alpha: 0.55),
                                  const Color(0xFFFDE68A).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Ilustrasi wanita berolahraga dumbbell
                        Positioned(
                          bottom: 0,
                          right: 6,
                          child: Image.asset(
                            'assets/images/exercise_woman_dumbbell.png',
                            height: 88,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Balon tanda tanya di atas kepala karakter
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


