import 'package:flutter/material.dart';
import 'admin_article_model.dart';
import 'admin_article_store.dart';
import 'edit_article_page.dart';

/// Palet warna tema Detail Artikel Admin sesuai acuan desain
class _DetailColors {
  // Background utama bernuansa krem kuning lembut
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  // Card & Permukaan
  static const Color cardSurface = Colors.white;
  static const Color sourceCardBg = Color(0xFFFFF7DC);

  // Aksen Kuning Butter & Oranye
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color amberDark = Color(0xFFF59E0B);

  // Aksen Hijau & Merah
  static const Color badgeGreenBg = Color(0xFFE8F8EE);
  static const Color badgeGreenText = Color(0xFF16A34A);
  static const Color checkmarkGreen = Color(0xFF22C55E);
  static const Color badgeDraftBg = Color(0xFFFEF3C7);
  static const Color badgeDraftText = Color(0xFFD97706);
  static const Color deleteRed = Color(0xFFEF4444);

  // Aksen Ungu
  static const Color categoryPurpleBg = Color(0xFFEDE9FE);
  static const Color categoryPurpleText = Color(0xFF7C3AED);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Painter dekorasi background lengkungan lembut butter yellow
class _DetailBackgroundPainter extends CustomPainter {
  const _DetailBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = _DetailColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final wavePaintTop = Paint()
      ..color = _DetailColors.waveDecor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final pathTop = Path();
    pathTop.moveTo(size.width * 0.55, 0);
    pathTop.lineTo(size.width, 0);
    pathTop.lineTo(size.width, size.height * 0.12);
    pathTop.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.09,
      size.width * 0.55,
      0,
    );
    pathTop.close();
    canvas.drawPath(pathTop, wavePaintTop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman Detail Artikel Admin Osteoporosis
/// Menampilkan pratinjau detail artikel lengkap sesuai screenshot desain
class AdminArticleDetailPage extends StatelessWidget {
  final AdminArticleItem article;

  const AdminArticleDetailPage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AdminArticleStore(),
      builder: (context, _) {
        // Ambil data terbaru dari store jika ada pembaruan
        final current = AdminArticleStore().getArticleById(article.id) ?? article;

        return Scaffold(
          backgroundColor: _DetailColors.background,
          body: Stack(
            children: [
              // 1. Dekorasi Background Krem Lembut
              const Positioned.fill(
                child: CustomPaint(
                  painter: _DetailBackgroundPainter(),
                ),
              ),

              // 2. Konten Utama yang Dapat Di-scroll
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Header: Tombol Kembali, Judul "Detail Artikel", & Bell
                    _buildHeader(context),

                    const SizedBox(height: 14),

                    // Isi Konten Artikel
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Gambar Utama Artikel (Sudut Rounded Sesuai Screenshot)
                            _buildHeroImage(current),

                            const SizedBox(height: 18),

                            // 2. Judul Artikel
                            Text(
                              current.title,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _DetailColors.textHeading,
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 3. Status Publikasi, Tanggal, dan Kategori
                            _buildMetaInfoRow(current),

                            const SizedBox(height: 18),

                            // 4. Ringkasan & Isi Artikel Lengkap
                            _buildArticleBody(current),

                            const SizedBox(height: 20),

                            // 5. Card Informasi Sumber / Referensi
                            _buildSourceCard(current),

                            const SizedBox(height: 28),

                            // 6. Tombol Aksi: Edit Artikel & Hapus Artikel
                            _buildActionButtons(context, current),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 1. Header: Back Button, "Detail Artikel", & Notification Bell
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
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _DetailColors.textDark,
                  size: 22,
                ),
              ),
            ),
          ),

          // Judul Halaman
          const Text(
            'Detail Artikel',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _DetailColors.textDark,
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
                  color: _DetailColors.textDark,
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
  // 2. Gambar Utama Artikel (Hero Image)
  // ===========================================================================
  Widget _buildHeroImage(AdminArticleItem current) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          current.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE2E8F0),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: _DetailColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. Status Publikasi, Tanggal, dan Kategori Artikel
  // ===========================================================================
  Widget _buildMetaInfoRow(AdminArticleItem current) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Status Publikasi Badge (Dipublikasikan / Draft)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: current.isPublished
                ? _DetailColors.badgeGreenBg
                : _DetailColors.badgeDraftBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: current.isPublished
                      ? _DetailColors.checkmarkGreen
                      : _DetailColors.amberDark,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                current.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: current.isPublished
                      ? _DetailColors.badgeGreenText
                      : _DetailColors.badgeDraftText,
                ),
              ),
            ],
          ),
        ),

        // Tanggal Artikel
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: _DetailColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              current.date,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _DetailColors.textDark,
              ),
            ),
          ],
        ),

        // Kategori Tag (Aksen Ungu Pastel)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: _DetailColors.categoryPurpleBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            current.category,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _DetailColors.categoryPurpleText,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. Ringkasan & Isi Artikel Lengkap
  // ===========================================================================
  Widget _buildArticleBody(AdminArticleItem current) {
    final textToShow = current.content.isNotEmpty
        ? current.content
        : current.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jika ada deskripsi/ringkasan yang berbeda dengan konten utama
        if (current.description.isNotEmpty &&
            current.content.isNotEmpty &&
            current.description != current.content) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              current.description,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _DetailColors.textMuted,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Paragraf Isi Artikel
        Text(
          textToShow,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _DetailColors.textBody,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. Card Informasi Sumber / Referensi Sesuai Screenshot
  // ===========================================================================
  Widget _buildSourceCard(AdminArticleItem current) {
    final sourceText = current.source.isNotEmpty
        ? current.source
        : 'Alodokter, 2024';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _DetailColors.sourceCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Ikon Buku Terbuka Warna Kuning Oranye
          const Icon(
            Icons.menu_book_rounded,
            color: _DetailColors.amberDark,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Sumber: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _DetailColors.textDark,
                    ),
                  ),
                  TextSpan(
                    text: sourceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. Tombol Aksi Bawah: Edit Artikel & Hapus Artikel
  // ===========================================================================
  Widget _buildActionButtons(BuildContext context, AdminArticleItem current) {
    return Row(
      children: [
        // Tombol Edit Artikel (Kuning Butter)
        Expanded(
          flex: 6,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _DetailColors.primaryYellow,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _DetailColors.primaryYellow.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditArticlePage(article: current),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: _DetailColors.textDark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Edit Artikel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _DetailColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Hapus Artikel (Garis Merah)
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFCA5A5),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _confirmDelete(context, current),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: _DetailColors.deleteRed,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _DetailColors.deleteRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Dialog Konfirmasi Hapus Artikel
  // ===========================================================================
  void _confirmDelete(BuildContext context, AdminArticleItem current) {
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
              color: _DetailColors.deleteRed,
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'Hapus Artikel?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _DetailColors.textHeading,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus artikel "${current.title}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            fontSize: 13.5,
            color: _DetailColors.textMuted,
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
                color: _DetailColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Hapus dari store
              AdminArticleStore().deleteArticle(current.id);
              // Tutup dialog
              Navigator.pop(dialogCtx);
              // Kembali ke halaman Kelola Artikel
              Navigator.pop(context);
              // Tampilkan snackbar notifikasi sukses
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Artikel "${current.title}" berhasil dihapus.'),
                  backgroundColor: _DetailColors.deleteRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _DetailColors.deleteRed,
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
}
