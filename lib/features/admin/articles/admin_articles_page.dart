import 'package:flutter/material.dart';
import 'admin_article_model.dart';
import 'admin_article_store.dart';
import 'admin_article_detail_page.dart';
import 'edit_article_page.dart';
import 'add_article_page.dart';
import 'package:oste/features/admin/dashboard/admin_dashboard_page.dart';
import 'package:oste/features/admin/profile/admin_profile_page.dart';

/// Palet warna tema Admin sesuai acuan desain
class _AdminColors {
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  static const Color cardSurface = Colors.white;

  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color amberDark = Color(0xFFF59E0B);
  static const Color activeNavYellow = Color(0xFFF5A623);

  // Status Badge
  static const Color badgeGreenBg = Color(0xFFE8F8EE);
  static const Color badgeGreenText = Color(0xFF16A34A);
  static const Color checkmarkGreen = Color(0xFF22C55E);

  static const Color badgeDraftBg = Color(0xFFFEF3C7);
  static const Color badgeDraftText = Color(0xFFD97706);

  // Aksi Edit & Hapus
  static const Color editBlue = Color(0xFF3B82F6);
  static const Color deleteRed = Color(0xFFEF4444);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Painter latar belakang bernuansa butter yellow lembut
class _AdminBackgroundPainter extends CustomPainter {
  const _AdminBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background krem kuning dasar #FFF9E8
    final basePaint = Paint()..color = _AdminColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 2. Lengkungan lembut di sudut kiri atas
    final wavePaintTop = Paint()
      ..color = _AdminColors.waveDecor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final pathTop = Path();
    pathTop.moveTo(0, 0);
    pathTop.lineTo(size.width * 0.40, 0);
    pathTop.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.08,
      0,
      size.height * 0.12,
    );
    pathTop.close();
    canvas.drawPath(pathTop, wavePaintTop);

    // 3. Lengkungan lembut di sudut kanan bawah
    final wavePaintBottom = Paint()
      ..color = _AdminColors.waveDecor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final pathBottom = Path();
    pathBottom.moveTo(size.width, size.height * 0.82);
    pathBottom.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.90,
      size.width * 0.75,
      size.height,
    );
    pathBottom.lineTo(size.width, size.height);
    pathBottom.close();
    canvas.drawPath(pathBottom, wavePaintBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman Kelola Artikel Admin Osteoporosis
/// Menampilkan daftar artikel, pencarian, menu detail, edit, dan hapus konfirmasi
class AdminArticlesPage extends StatefulWidget {
  const AdminArticlesPage({super.key});

  @override
  State<AdminArticlesPage> createState() => _AdminArticlesPageState();
}

class _AdminArticlesPageState extends State<AdminArticlesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 1; // Tab Artikel aktif

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      body: Stack(
        children: [
          // 1. Background ornamen lengkungan lembut
          const Positioned.fill(
            child: CustomPaint(
              painter: _AdminBackgroundPainter(),
            ),
          ),

          // 2. Konten utama yang scrollable dan responsif
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Top Header: Tombol Back, Judul "Kelola Artikel", dan Bell Notification
                _buildHeader(context),

                const SizedBox(height: 14),

                // Search Bar "Cari artikel..."
                _buildSearchBar(),

                const SizedBox(height: 14),

                // Daftar Artikel yang Terhubung ke AdminArticleStore
                Expanded(
                  child: AnimatedBuilder(
                    animation: AdminArticleStore(),
                    builder: (context, _) {
                      final allArticles = AdminArticleStore().articles;
                      final filtered = _searchQuery.isEmpty
                          ? allArticles
                          : allArticles.where((a) {
                              final q = _searchQuery.toLowerCase();
                              return a.title.toLowerCase().contains(q) ||
                                  a.category.toLowerCase().contains(q) ||
                                  a.source.toLowerCase().contains(q);
                            }).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  // ===========================================================================
  // 1. Header: Back Button, "Kelola Artikel", & Bell Notification
  // ===========================================================================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali melingkar warna putih
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
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
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _AdminColors.textDark,
                  size: 22,
                ),
              ),
            ),
          ),

          // Judul "Kelola Artikel"
          const Text(
            'Kelola Artikel',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _AdminColors.textDark,
              letterSpacing: -0.2,
            ),
          ),

          // Tombol Lonceng Notifikasi melingkar warna putih
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Belum ada notifikasi baru untuk Admin.'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: _AdminColors.textDark,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. Search Bar: "Cari artikel..."
  // ===========================================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14,
            color: _AdminColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari artikel...',
            hintStyle: const TextStyle(
              color: _AdminColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                color: _AdminColors.textLight,
                size: 22,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _AdminColors.textLight,
                      size: 18,
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. Card Artikel: Gambar, Judul, Kategori/Tanggal, Badge Status, Edit, Hapus
  // ===========================================================================
  Widget _buildArticleCard(BuildContext context, AdminArticleItem item) {
    return Container(
      decoration: BoxDecoration(
        color: _AdminColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          // Ketuk card menuju ke halaman Detail Artikel Admin
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminArticleDetailPage(article: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Gambar Artikel
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    item.imageAsset,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: _AdminColors.textLight,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Judul, Kategori & Tanggal, Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Artikel
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _AdminColors.textHeading,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Kategori & Tanggal
                      Text(
                        '${item.category} • ${item.date}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _AdminColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Status Badge (Dipublikasikan / Draft)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: item.isPublished
                              ? _AdminColors.badgeGreenBg
                              : _AdminColors.badgeDraftBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                color: item.isPublished
                                    ? _AdminColors.checkmarkGreen
                                    : _AdminColors.amberDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.isPublished
                                    ? _AdminColors.badgeGreenText
                                    : _AdminColors.badgeDraftText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol Aksi: Edit (Pensil Biru) & Hapus (Tong Sampah Merah)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: _AdminColors.editBlue,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Artikel',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditArticlePage(article: item),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),

                    // Tombol Hapus dengan Konfirmasi Terlebih Dahulu
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: _AdminColors.deleteRed,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      tooltip: 'Hapus Artikel',
                      onPressed: () => _confirmDelete(context, item),
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

  // ===========================================================================
  // 4. Dialog Konfirmasi Hapus Artikel
  // ===========================================================================
  void _confirmDelete(BuildContext context, AdminArticleItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              color: _AdminColors.deleteRed,
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus Artikel?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _AdminColors.textHeading,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus artikel "${item.title}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            fontSize: 13.5,
            color: _AdminColors.textMuted,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _AdminColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              AdminArticleStore().deleteArticle(item.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Artikel "${item.title}" berhasil dihapus.'),
                  backgroundColor: _AdminColors.deleteRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _AdminColors.deleteRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Empty State ketika hasil pencarian kosong
  // ===========================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: _AdminColors.amberDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Artikel Tidak Ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _AdminColors.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba gunakan kata kunci pencarian yang lain atau tambahkan artikel baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _AdminColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. Bottom Navigation Bar: Dashboard, Artikel (Aktif), Tambah, Profil
  // ===========================================================================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Dashboard',
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
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_rounded,
                label: 'Artikel',
                onTap: () {
                  // Sudah di halaman artikel
                },
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_circle_outline_rounded,
                label: 'Tambah',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddArticlePage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'Profil',
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

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentNavIndex == index;
    const activeColor = _AdminColors.activeNavYellow;
    const inactiveColor = _AdminColors.textLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

