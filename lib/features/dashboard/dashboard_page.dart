import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oste/features/consultation/consultation_page.dart';
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
  static const Color pink = Color(0xFFFFE8EC);
  static const Color abuMuda = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFECECEC);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft cream gradient di bagian atas untuk area header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF7DB).withValues(alpha: 0.65),
                    const Color(0xFFFFFDF5),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Aksen butter yellow halus di sudut kiri atas
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF7C948).withValues(alpha: 0.08),
                    const Color(0xFFF7C948).withValues(alpha: 0.0),
                  ],
                ),
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
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFF9E6).withValues(alpha: 0.6),
                      const Color(0xFFFFF3CC).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Greeting text (Align.centerLeft)
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 140),
                child: Padding(
                  padding: const EdgeInsets.only(right: 140, top: 4, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Bar: Avatar & Logo OsteoCare
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF59E0B),
                            ),
                            child: Center(
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(
                                  fontSize: 17,
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
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Care',
                                  style: TextStyle(
                                    fontSize: 19,
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
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: _DashboardColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yuk jaga kesehatan tulangmu\nmulai hari ini!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _DashboardColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Positioned bone_character.png di pojok kanan atas
            Positioned(
              right: 0,
              top: 0,
              child: Image.asset(
                'assets/images/bone_character.png',
                height: 140,
                fit: BoxFit.contain,
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
              iconBgColor: const Color(0xFFFEF3C7),
              arrowColor: const Color(0xFFD97706),
              arrowBgColor: const Color(0xFFFEF08A),
              backgroundColor: const Color(0xFFFFFDF5),
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
              iconBgColor: const Color(0xFFDBEAFE),
              arrowColor: const Color(0xFF2563EB),
              arrowBgColor: const Color(0xFFBFDBFE),
              backgroundColor: const Color(0xFFF0F7FF),
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
              iconBgColor: _DashboardColors.pink,
              arrowColor: const Color(0xFFE11D48),
              arrowBgColor: const Color(0xFFFECDD3),
              backgroundColor: const Color(0xFFFFF9FA),
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
              iconBgColor: const Color(0xFFEDE9FE),
              arrowColor: const Color(0xFF7C3AED),
              arrowBgColor: const Color(0xFFDDD6FE),
              backgroundColor: const Color(0xFFFAF8FF),
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
class _MenuItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color arrowColor;
  final Color arrowBgColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _MenuItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.arrowColor,
    required this.arrowBgColor,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Card selalu putih bersih; warna pastel hanya pada kotak icon
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF2F2F2),
          width: 1,
        ),
        boxShadow: [
          // Ambient shadow – lembut menyebar
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Key shadow – terarah tipis
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.03),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Stack(
            children: [
              // Highlight putih lembut di tepi atas card (inner top glow)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Baris atas: Icon & tombol panah
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 22,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: arrowBgColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: arrowColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _DashboardColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: _DashboardColors.textMuted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ],
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

  static const List<_ArticleData> _articles = [
    _ArticleData(
      source: 'Alodokter',
      sourceColor: Color(0xFF0A7AFF),
      sourceInitial: 'A',
      title: 'Mengenal Osteoporosis',
      description:
          'Kenali penyebab, gejala, faktor risiko, dan cara mencegah osteoporosis.',
      url: 'https://www.alodokter.com/osteoporosis',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1530026186672-2cd00ffc50fe?auto=format&fit=crop&w=400&q=80',
    ),
    _ArticleData(
      source: 'Alodokter',
      sourceColor: Color(0xFF0A7AFF),
      sourceInitial: 'A',
      title: 'Pengobatan Osteoporosis',
      description:
          'Pilihan terapi, obat, vitamin, serta perubahan gaya hidup untuk kesehatan tulang.',
      url:
          'https://www.alodokter.com/osteoporosis/pengobatan',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&q=80',
    ),
    _ArticleData(
      source: 'Halodoc',
      sourceColor: Color(0xFF1DC36E),
      sourceInitial: 'H',
      title: 'Gejala dan Cara Mencegah',
      description:
          'Informasi lengkap mengenai gejala awal dan cara mencegah osteoporosis.',
      url:
          'https://www.halodoc.com/artikel/kenali-arti-osteoporosis-gejala-dan-cara-mencegahnya',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=400&q=80',
    ),
    _ArticleData(
      source: 'HelloSehat',
      sourceColor: Color(0xFF6C63FF),
      sourceInitial: 'H',
      title: 'Pengertian Osteoporosis',
      description:
          'Pelajari apa itu osteoporosis, gejala-gejalanya, serta cara pencegahannya.',
      url:
          'https://hellosehat.com/muskuloskeletal/osteoporosis/pengertian-osteoporosis/',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=400&q=80',
    ),
    _ArticleData(
      source: 'Siloam',
      sourceColor: Color(0xFF00AEEF),
      sourceInitial: 'S',
      title: 'Apa Itu Osteoporosis?',
      description:
          'Penjelasan lengkap tentang osteoporosis, penyebab, gejala, serta langkah pencegahannya.',
      url:
          'https://www.siloamhospitals.com/informasi-siloam/artikel/apa-itu-osteoporosis',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            itemCount: _articles.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final a = _articles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ArticleCard(
                  data: a,
                  onTap: () => _openArticle(a.url),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_articles.length, (i) {
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

/// Data model artikel
class _ArticleData {
  final String source;
  final Color sourceColor;
  final String sourceInitial;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;

  const _ArticleData({
    required this.source,
    required this.sourceColor,
    required this.sourceInitial,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
  });
}

/// Card artikel horizontal landscape
class _ArticleCard extends StatelessWidget {
  final _ArticleData data;
  final VoidCallback onTap;

  const _ArticleCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF2F2F2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.03),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
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
                  child: Image.network(
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
                          // Logo sumber
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
                              Text(
                                data.source,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: data.sourceColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Judul artikel
                          Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _DashboardColors.textDark,
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
        // Background butter yellow lembut menyeluruh dengan gradient halus
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFFDF6),
            Color(0xFFFFF7D6),
            Color(0xFFFFF3BF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF5E6B8),
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


