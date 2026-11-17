import 'package:flutter/material.dart';
import 'package:oste/features/admin/articles/admin_articles_page.dart';
import 'package:oste/features/admin/chat/admin_doctor_list_page.dart';
import 'package:oste/features/admin/education/admin_education_page.dart';
import 'package:oste/features/admin/profile/admin_profile_page.dart';
import 'package:oste/services/article_repository.dart';
import 'package:oste/services/article_service.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/doctor_repository.dart';
import 'package:oste/services/user_service.dart';

/// Palet warna tema Admin Dashboard Osteo sesuai spesifikasi desain & screenshot
class _AdminDashboardColors {
  // Primary & Aksen Kuning
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowCardBg = Color(0xFFFFF4D2);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color navActivePill = Color(0xFFFDE89C);

  // Background & Kartu
  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFF2ECE1);

  // Tipografi & Ikon
  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDescription = Color(0xFF5A4433);
}

/// Painter logo tulang Osteo miring dengan outline dan fill butter yellow
class _BoneLogoPainter extends CustomPainter {
  final Color outlineColor;
  final Color fillColor;

  const _BoneLogoPainter({
    required this.outlineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-0.65); // Kemiringan proporsional sesuai logo

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.54, height: h * 0.28),
      Radius.circular(h * 0.14),
    );

    final leftX = -w * 0.26;
    final rightX = w * 0.26;
    final bumpR = h * 0.17;
    final bumpY = h * 0.12;

    final path = Path()
      ..addRRect(shaftRect)
      ..addOval(
          Rect.fromCircle(center: Offset(leftX, -bumpY), radius: bumpR))
      ..addOval(Rect.fromCircle(center: Offset(leftX, bumpY), radius: bumpR))
      ..addOval(
          Rect.fromCircle(center: Offset(rightX, -bumpY), radius: bumpR))
      ..addOval(Rect.fromCircle(center: Offset(rightX, bumpY), radius: bumpR));

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoneLogoPainter oldDelegate) =>
      outlineColor != oldDelegate.outlineColor ||
      fillColor != oldDelegate.fillColor;
}

/// Painter ilustrasi laptop dengan logo tulang Osteo bercahaya di layar
class _AdminLaptopPainter extends CustomPainter {
  const _AdminLaptopPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = _AdminDashboardColors.textMain
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final screenFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final yellowSparkPaint = Paint()
      ..color = _AdminDashboardColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // 1. Percikan sinar/radiance di kiri atas laptop
    final sparkOrigin = Offset(w * 0.22, h * 0.20);
    canvas.drawLine(
      sparkOrigin + const Offset(-6, -4),
      sparkOrigin + const Offset(-14, -8),
      yellowSparkPaint,
    );
    canvas.drawLine(
      sparkOrigin + const Offset(-2, -9),
      sparkOrigin + const Offset(-4, -18),
      yellowSparkPaint,
    );
    canvas.drawLine(
      sparkOrigin + const Offset(5, -10),
      sparkOrigin + const Offset(9, -17),
      yellowSparkPaint,
    );

    // 2. Layar Laptop
    final screenLeft = w * 0.22;
    final screenTop = h * 0.22;
    final screenRight = w * 0.88;
    final screenBottom = h * 0.73;

    final screenRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(screenLeft, screenTop, screenRight, screenBottom),
      const Radius.circular(8),
    );

    canvas.drawRRect(screenRRect, screenFillPaint);
    canvas.drawRRect(screenRRect, strokePaint);

    // 3. Logo Tulang Osteo di dalam layar
    final boneCenter = Offset(
      (screenLeft + screenRight) / 2,
      (screenTop + screenBottom) / 2,
    );
    canvas.save();
    canvas.translate(boneCenter.dx, boneCenter.dy);
    canvas.rotate(-0.55);

    final boneYellowPaint = Paint()
      ..color = _AdminDashboardColors.primaryYellow
      ..style = PaintingStyle.fill;
    final boneStrokePaint = Paint()
      ..color = const Color(0xFFE5A817)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const boneW = 20.0;
    const boneH = 6.5;
    const r = 3.2;
    final shaft = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: boneW, height: boneH),
      const Radius.circular(boneH / 2),
    );
    canvas.drawRRect(shaft, boneYellowPaint);
    canvas.drawRRect(shaft, boneStrokePaint);

    // Lobus tulang kiri & kanan
    canvas.drawCircle(const Offset(-boneW / 2, -r * 0.7), r, boneYellowPaint);
    canvas.drawCircle(const Offset(-boneW / 2, r * 0.7), r, boneYellowPaint);
    canvas.drawCircle(const Offset(-boneW / 2, -r * 0.7), r, boneStrokePaint);
    canvas.drawCircle(const Offset(-boneW / 2, r * 0.7), r, boneStrokePaint);

    canvas.drawCircle(const Offset(boneW / 2, -r * 0.7), r, boneYellowPaint);
    canvas.drawCircle(const Offset(boneW / 2, r * 0.7), r, boneYellowPaint);
    canvas.drawCircle(const Offset(boneW / 2, -r * 0.7), r, boneStrokePaint);
    canvas.drawCircle(const Offset(boneW / 2, r * 0.7), r, boneStrokePaint);

    canvas.restore();

    // 4. Base / Keyboard Laptop
    final baseTop = screenBottom;
    final baseBottom = h * 0.83;
    final baseLeft = w * 0.14;
    final baseRight = w * 0.96;

    final basePath = Path()
      ..moveTo(screenLeft - 4, baseTop)
      ..lineTo(baseLeft, baseBottom - 3)
      ..quadraticBezierTo(baseLeft, baseBottom, baseLeft + 4, baseBottom)
      ..lineTo(baseRight - 4, baseBottom)
      ..quadraticBezierTo(baseRight, baseBottom, baseRight, baseBottom - 3)
      ..lineTo(screenRight + 4, baseTop)
      ..close();

    canvas.drawPath(basePath, screenFillPaint);
    canvas.drawPath(basePath, strokePaint);

    // Lekukan bukaan laptop di tengah
    const notchW = 12.0;
    final notchPath = Path()
      ..moveTo((baseLeft + baseRight) / 2 - notchW / 2, baseTop)
      ..lineTo((baseLeft + baseRight) / 2 - notchW / 4, baseTop + 2.5)
      ..lineTo((baseLeft + baseRight) / 2 + notchW / 4, baseTop + 2.5)
      ..lineTo((baseLeft + baseRight) / 2 + notchW / 2, baseTop);
    canvas.drawPath(notchPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter outline stethoscope sesuai ikon acuan
class _StethoscopePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _StethoscopePainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Eartips di bagian atas
    final leftTip = Offset(w * 0.26, h * 0.16);
    final rightTip = Offset(w * 0.74, h * 0.16);
    canvas.drawCircle(leftTip, strokeWidth * 0.85, fillPaint);
    canvas.drawCircle(rightTip, strokeWidth * 0.85, fillPaint);

    // 2. Tabung melengkung ke titik temu
    final path = Path()
      ..moveTo(leftTip.dx, leftTip.dy)
      ..quadraticBezierTo(w * 0.22, h * 0.38, w * 0.50, h * 0.44)
      ..moveTo(rightTip.dx, rightTip.dy)
      ..quadraticBezierTo(w * 0.78, h * 0.38, w * 0.50, h * 0.44)
      ..lineTo(w * 0.50, h * 0.62)
      ..cubicTo(
        w * 0.50,
        h * 0.86,
        w * 0.84,
        h * 0.86,
        w * 0.84,
        h * 0.66,
      )
      ..lineTo(w * 0.84, h * 0.52);

    canvas.drawPath(path, strokePaint);

    // 3. Chestpiece / Diaphragm (lingkaran di ujung selang kanan)
    final chestCenter = Offset(w * 0.84, h * 0.43);
    canvas.drawCircle(chestCenter, w * 0.12, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Widget ikon Stethoscope outline
class _StethoscopeIcon extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const _StethoscopeIcon({
    this.color = _AdminDashboardColors.textMain,
    this.size = 24.0,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StethoscopePainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

/// Painter outline dokumen artikel dengan lipatan sudut kanan atas dan garis teks
class _DocumentIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DocumentIconPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final fold = w * 0.28;
    final left = w * 0.18;
    final top = h * 0.14;
    final right = w * 0.82;
    final bottom = h * 0.86;
    final radius = w * 0.08;

    // Garis outline dokumen dengan lipatan
    final path = Path()
      ..moveTo(left + radius, top)
      ..lineTo(right - fold, top)
      ..lineTo(right, top + fold)
      ..lineTo(right, bottom - radius)
      ..quadraticBezierTo(right, bottom, right - radius, bottom)
      ..lineTo(left + radius, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - radius)
      ..lineTo(left, top + radius)
      ..quadraticBezierTo(left, top, left + radius, top)
      ..close()
      ..moveTo(right - fold, top)
      ..lineTo(right - fold, top + fold)
      ..lineTo(right, top + fold);

    canvas.drawPath(path, strokePaint);

    // 3 garis artikel
    final lineStartX = left + w * 0.14;
    final lineEndX = right - w * 0.14;

    canvas.drawLine(
      Offset(lineStartX, top + h * 0.34),
      Offset(lineEndX, top + h * 0.34),
      strokePaint,
    );
    canvas.drawLine(
      Offset(lineStartX, top + h * 0.48),
      Offset(lineEndX, top + h * 0.48),
      strokePaint,
    );
    canvas.drawLine(
      Offset(lineStartX, top + h * 0.62),
      Offset(lineStartX + (lineEndX - lineStartX) * 0.55, top + h * 0.62),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DocumentIconPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Halaman Dashboard Admin Osteo sesuai rancangan visual acuan
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    final adminUid = UserService().currentUser?.uid ?? 'admin_osteo';
    ChatService().startListeningPatientConversations(adminUid);
    // Sinkronisasi artikel default ke Firestore jika koleksi masih kosong
    ArticleService().seedDefaultArticlesIfEmpty();
    // Sinkronisasi dokter default ke Firestore jika koleksi masih kosong
    DoctorRepository().seedDefaultDoctorsIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminDashboardColors.background,
      body: Stack(
        children: [
          // 1. Gradasi halus butter yellow lembut ke putih di latar belakang atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFFFDEAA8).withValues(alpha: 0.50),
                    const Color(0xFFFFF8E5).withValues(alpha: 0.25),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Konten utama dashboard (Scrollable & Responsive)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // A. Header (Logo Osteo, Dashboard Admin, Garis Aksen)
                  _buildHeader(),

                  const SizedBox(height: 18),

                  // B. Welcome Card (Halo, Admin! & Ilustrasi Laptop)
                  _buildWelcomeCard(),

                  const SizedBox(height: 16),

                  // C. Statistik Dashboard (Total Dokter & Total Artikel Aktual)
                  _buildStatisticsSection(),

                  const SizedBox(height: 22),

                  // D. Menu Pengelolaan (Kelola Dokter, Edukasi, Artikel)
                  _buildManagementSection(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ===========================================================================
  // A. HEADER: Logo Osteo, Judul Dashboard Admin, Garis Pendek Aksen
  // ===========================================================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Logo Osteo (Tulang miring + Teks Osteo)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: _BoneLogoPainter(
                  outlineColor: _AdminDashboardColors.textMain,
                  fillColor: _AdminDashboardColors.primaryYellow,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Osteo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _AdminDashboardColors.textMain,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Judul Dashboard Admin
        const Text(
          'Dashboard Admin',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: _AdminDashboardColors.textMain,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),

        // Garis pendek berwarna butter yellow sebagai aksen
        Container(
          width: 55,
          height: 5,
          decoration: BoxDecoration(
            color: _AdminDashboardColors.primaryYellow,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // B. WELCOME CARD: Halo, Admin! + Ilustrasi Laptop dengan Logo Tulang
  // ===========================================================================
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFBEA),
            Color(0xFFFFF4D2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AdminDashboardColors.yellowBorder.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _AdminDashboardColors.primaryYellow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Teks sapaan & deskripsi
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Admin!',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: _AdminDashboardColors.textMain,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola data dokter, artikel,\ndan konten edukasi\nOsteo di sini.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _AdminDashboardColors.textDescription,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Ilustrasi laptop
          const SizedBox(
            width: 110,
            height: 85,
            child: CustomPaint(
              painter: _AdminLaptopPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // C. STATISTIK DASHBOARD: Total Dokter & Total Artikel (Reaktif Realtime)
  // ===========================================================================
  Widget _buildStatisticsSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        DoctorRepository(),
        ArticleRepository(),
      ]),
      builder: (context, _) {
        final totalDoctors = DoctorRepository().totalCount;
        final totalArticles = ArticleRepository().totalCount;

        return Row(
          children: [
            // 1. Kartu Total Dokter
            Expanded(
              child: _buildStatCard(
                icon: const _StethoscopeIcon(
                  size: 26,
                  color: _AdminDashboardColors.textMain,
                  strokeWidth: 2.0,
                ),
                label: 'Total Dokter',
                value: '$totalDoctors',
              ),
            ),
            const SizedBox(width: 14),

            // 2. Kartu Total Artikel
            Expanded(
              child: _buildStatCard(
                icon: const SizedBox(
                  width: 26,
                  height: 26,
                  child: CustomPaint(
                    painter: _DocumentIconPainter(
                      color: _AdminDashboardColors.textMain,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                label: 'Total Artikel',
                value: '$totalArticles',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AdminDashboardColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wadah ikon rounded square kuning lembut
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _AdminDashboardColors.softYellowBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _AdminDashboardColors.yellowBorder,
                width: 1.2,
              ),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 12),

          // Label Statistik
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _AdminDashboardColors.textMain,
            ),
          ),
          const SizedBox(height: 4),

          // Nilai Angka Aktual
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _AdminDashboardColors.textMain,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // D. MENU PENGELOLAAN: Kelola Dokter, Kelola Edukasi, Kelola Artikel
  // ===========================================================================
  Widget _buildManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Bagian dengan Aksen Garis Kuning Vertikal
        Row(
          children: [
            Container(
              width: 4.5,
              height: 18,
              decoration: BoxDecoration(
                color: _AdminDashboardColors.primaryYellow,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Menu Pengelolaan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _AdminDashboardColors.textMain,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 1. Kelola Dokter
        _buildMenuActionCard(
          icon: const _StethoscopeIcon(
            size: 26,
            color: _AdminDashboardColors.textMain,
            strokeWidth: 2.0,
          ),
          title: 'Kelola Dokter',
          description: 'Tambah, ubah, dan hapus data dokter',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDoctorListPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // 2. Kelola Edukasi
        _buildMenuActionCard(
          icon: const Icon(
            Icons.menu_book_rounded,
            size: 26,
            color: _AdminDashboardColors.textMain,
          ),
          title: 'Kelola Edukasi',
          description:
              'Tambah, ubah, dan hapus materi latihan, nutrisi, dan vitamin',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminEducationPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // 3. Kelola Artikel
        _buildMenuActionCard(
          icon: const SizedBox(
            width: 26,
            height: 26,
            child: CustomPaint(
              painter: _DocumentIconPainter(
                color: _AdminDashboardColors.textMain,
                strokeWidth: 2.0,
              ),
            ),
          ),
          title: 'Kelola Artikel',
          description: 'Tambah, ubah, dan hapus artikel',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminArticlesPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuActionCard({
    required Widget icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AdminDashboardColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Wadah ikon kotak kuning muda
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _AdminDashboardColors.yellowCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _AdminDashboardColors.yellowBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 14),

                // Judul & Deskripsi Singkat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _AdminDashboardColors.textMain,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: _AdminDashboardColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ikon Chevron Kanan
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _AdminDashboardColors.textMain,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // E. BOTTOM NAVIGATION BAR: Beranda, Dokter, Edukasi, Artikel, Profil
  // ===========================================================================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Beranda (Menu Aktif dengan Indikator Butter Yellow)
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.home_rounded,
                  size: 22,
                  color: _AdminDashboardColors.textMain,
                ),
                label: 'Beranda',
                isActive: true,
                onTap: () {
                  // Berada di Beranda
                },
              ),

              // 2. Dokter
              _buildBottomNavItem(
                iconWidget: const _StethoscopeIcon(
                  size: 22,
                  color: _AdminDashboardColors.textMain,
                  strokeWidth: 1.8,
                ),
                label: 'Dokter',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDoctorListPage(),
                    ),
                  );
                },
              ),

              // 3. Edukasi
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.menu_book_outlined,
                  size: 22,
                  color: _AdminDashboardColors.textMain,
                ),
                label: 'Edukasi',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminEducationPage(),
                    ),
                  );
                },
              ),

              // 4. Artikel
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _DocumentIconPainter(
                      color: _AdminDashboardColors.textMain,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                label: 'Artikel',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminArticlesPage(),
                    ),
                  );
                },
              ),

              // 5. Profil
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: _AdminDashboardColors.textMain,
                ),
                label: 'Profil',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required Widget iconWidget,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: _AdminDashboardColors.navActivePill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: iconWidget,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: iconWidget,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: _AdminDashboardColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
