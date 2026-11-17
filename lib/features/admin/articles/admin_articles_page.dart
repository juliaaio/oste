import 'package:flutter/material.dart';
import '../../../services/article_repository.dart';
import '../../education/articles/article_model.dart';
import '../chat/admin_doctor_list_page.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../education/admin_education_page.dart';
import '../profile/admin_profile_page.dart';
import 'add_article_page.dart';
import 'admin_article_detail_page.dart';
import 'admin_article_store.dart';
import 'edit_article_page.dart';

/// Palet warna tema Admin Kelola Artikel sesuai spesifikasi desain & screenshot
class _AdminArticleColors {
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowCardBg = Color(0xFFFFF4D2);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color navActivePill = Color(0xFFFDE89C);

  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7DE);
  static const Color searchBorder = Color(0xFFE2DCD5);

  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF6B635B);
  static const Color textMuted = Color(0xFF8A827A);

  // Tombol Aksi
  static const Color editIcon = Color(0xFF332011);
  static const Color deleteIcon = Color(0xFFEF4444);
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
    canvas.rotate(-0.65);

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

/// Painter outline stetoskop untuk Bottom Navigation
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

    final leftTip = Offset(w * 0.26, h * 0.16);
    final rightTip = Offset(w * 0.74, h * 0.16);
    canvas.drawCircle(leftTip, strokeWidth * 0.85, fillPaint);
    canvas.drawCircle(rightTip, strokeWidth * 0.85, fillPaint);

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

    final chestCenter = Offset(w * 0.84, h * 0.43);
    canvas.drawCircle(chestCenter, w * 0.12, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Painter outline dokumen artikel untuk Bottom Navigation
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

/// Halaman Admin Kelola Artikel OSTEOCARE
/// Mengacu 1:1 pada desain visual screenshot Menu Kelola Artikel.
class AdminArticlesPage extends StatefulWidget {
  const AdminArticlesPage({super.key});

  @override
  State<AdminArticlesPage> createState() => _AdminArticlesPageState();
}

class _AdminArticlesPageState extends State<AdminArticlesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog konfirmasi hapus artikel
  void _confirmDeleteArticle(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: _AdminArticleColors.deleteIcon,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                'Hapus Artikel?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _AdminArticleColors.textMain,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus artikel "${article.title}"? Data akan dihapus dari Cloud Firestore.',
            style: const TextStyle(
              fontSize: 13.5,
              color: _AdminArticleColors.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: _AdminArticleColors.textSecondary,
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ArticleRepository().deleteArticle(article.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Artikel "${article.title}" berhasil dihapus dari sistem.'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _AdminArticleColors.deleteIcon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ArticleRepository();

    return Scaffold(
      backgroundColor: _AdminArticleColors.background,
      body: Stack(
        children: [
          // 1. Latar belakang gradasi butter yellow lembut di sudut kanan atas
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
                    const Color(0xFFFDEAA8).withValues(alpha: 0.55),
                    const Color(0xFFFFF8E5).withValues(alpha: 0.25),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Konten utama halaman
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // A. Bagian Header (Logo Osteo, Judul Kelola Artikel, Deskripsi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
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
                                outlineColor: _AdminArticleColors.textMain,
                                fillColor: _AdminArticleColors.primaryYellow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Osteo',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _AdminArticleColors.textMain,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Baris Tombol Kembali & Judul "Kelola Artikel"
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminDashboardPage(),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 6, top: 2, bottom: 2),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 30,
                                color: _AdminArticleColors.textMain,
                              ),
                            ),
                          ),
                          const Text(
                            'Kelola Artikel',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _AdminArticleColors.textMain,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Deskripsi Singkat
                      const Text(
                        'Kelola artikel kesehatan seputar osteoporosis.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: _AdminArticleColors.textMain,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // B. Search Bar ("Cari judul artikel...")
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _AdminArticleColors.searchBorder,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: _AdminArticleColors.textMain,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari judul artikel...',
                            hintStyle: const TextStyle(
                              color: _AdminArticleColors.textMuted,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _AdminArticleColors.textSecondary,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _AdminArticleColors.textMuted,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // C. Tombol "+ Tambah Artikel" (Butter Yellow Pill Button)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddArticlePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _AdminArticleColors.primaryYellow,
                            foregroundColor: _AdminArticleColors.textMain,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 22,
                                color: _AdminArticleColors.textMain,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Artikel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _AdminArticleColors.textMain,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // D. Daftar Artikel Berbentuk Card (Scrollable & Realtime)
                Expanded(
                  child: AnimatedBuilder(
                    animation: repo,
                    builder: (context, _) {
                      final allArticles = repo.allArticles;
                      final filtered = _searchQuery.isEmpty
                          ? allArticles
                          : allArticles.where((a) {
                              final q = _searchQuery.toLowerCase();
                              return a.title.toLowerCase().contains(q) ||
                                  a.category.toLowerCase().contains(q) ||
                                  a.source.toLowerCase().contains(q);
                            }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: _AdminArticleColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada artikel dengan judul "$_searchQuery"'
                                      : 'Belum ada data artikel',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _AdminArticleColors.textMain,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Silakan tekan tombol Tambah Artikel di atas untuk menambahkan artikel baru.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _AdminArticleColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildArticleCard(context, item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Card Artikel sesuai acuan visual screenshot
  Widget _buildArticleCard(BuildContext context, ArticleModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AdminArticleColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminArticleDetailPage(article: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // 1. Thumbnail Artikel (Rounded Rect 64x64)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEFEAE2),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _buildThumbnailImage(item),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Info Artikel (Judul & Tanggal Publish)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Artikel
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _AdminArticleColors.textMain,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Tanggal Publish dengan Ikon Kalender
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: _AdminArticleColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.date.isNotEmpty ? item.date : '10 Nov 2026',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _AdminArticleColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Tombol Aksi: Edit (Pensil) & Hapus (Tempat Sampah Merah)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditArticlePage(article: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 22,
                          color: _AdminArticleColors.editIcon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Tombol Hapus
                    InkWell(
                      onTap: () => _confirmDeleteArticle(context, item),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 22,
                          color: _AdminArticleColors.deleteIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(ArticleModel item) {
    if (item.heroAssetPath.isNotEmpty) {
      return Image.asset(
        item.heroAssetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
      );
    } else if (item.thumbnailUrl.startsWith('http://') ||
        item.thumbnailUrl.startsWith('https://')) {
      return Image.network(
        item.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
      );
    } else {
      return _buildFallbackThumbnail();
    }
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      color: const Color(0xFFF2ECE1),
      child: const Center(
        child: Icon(
          Icons.article_outlined,
          size: 28,
          color: Color(0xFF9E948A),
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR: Beranda, Dokter, Edukasi, Artikel (AKTIF), Profil
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
              // 1. Beranda
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.home_outlined,
                  size: 22,
                  color: _AdminArticleColors.textMain,
                ),
                label: 'Beranda',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardPage(),
                    ),
                  );
                },
              ),

              // 2. Dokter
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _StethoscopePainter(
                      color: _AdminArticleColors.textMain,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                label: 'Dokter',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
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
                  color: _AdminArticleColors.textMain,
                ),
                label: 'Edukasi',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminEducationPage(),
                    ),
                  );
                },
              ),

              // 4. Artikel (Menu Aktif dengan Indikator Butter Yellow Pill)
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _DocumentIconPainter(
                      color: _AdminArticleColors.textMain,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                label: 'Artikel',
                isActive: true,
                onTap: () {
                  // Berada di tab Artikel
                },
              ),

              // 5. Profil
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: _AdminArticleColors.textMain,
                ),
                label: 'Profil',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
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
                  color: _AdminArticleColors.navActivePill,
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
                color: _AdminArticleColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
