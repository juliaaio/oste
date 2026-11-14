import 'package:flutter/material.dart';
import 'package:oste/features/admin/articles/admin_articles_page.dart';
import 'package:oste/features/admin/articles/add_article_page.dart';
import 'package:oste/features/admin/articles/admin_article_store.dart';
import 'package:oste/features/admin/chat/admin_doctor_list_page.dart';
import 'package:oste/features/admin/profile/admin_profile_page.dart';
import 'package:oste/features/education/articles/article_data.dart';
import 'package:oste/features/education/articles/article_detail_page.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/user_service.dart';

/// Palet warna tema Admin Dashboard Osteoporosis sesuai acuan desain
class _AdminColors {
  // Background utama bernuansa krem kuning lembut
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  // Card & Permukaan
  static const Color cardSurface = Colors.white;
  static const Color cardBorder = Color(0xFFF8FAFC);

  // Aksen Kuning & Oranye (identik dengan aplikasi pasien)
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color amberDark = Color(0xFFF59E0B);
  static const Color amberFolder = Color(0xFFFBBF24);
  static const Color activeNavYellow = Color(0xFFF5A623);
  static const Color pastelYellowBtn = Color(0xFFFEF3C7);
  static const Color pastelYellowPill = Color(0xFFFFF3C2);

  // Aksen Hijau Publikasi
  static const Color badgeGreenBg = Color(0xFFE8F8EE);
  static const Color badgeGreenText = Color(0xFF16A34A);
  static const Color checkmarkGreen = Color(0xFF22C55E);

  // Aksen Biru Tambah Artikel
  static const Color calendarBlue = Color(0xFF3B82F6);
  static const Color calendarBlueDeep = Color(0xFF2563EB);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Painter dekorasi background lengkungan lembut butter yellow di sudut kiri atas & kanan bawah
class _AdminBackgroundPainter extends CustomPainter {
  const _AdminBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Latar belakang dasar krem kuning lembut #FFF9E8
    final basePaint = Paint()..color = _AdminColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 2. Ornamen lengkungan lembut di sudut kiri atas
    final wavePaintTop = Paint()
      ..color = _AdminColors.waveDecor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final pathTop = Path();
    pathTop.moveTo(0, 0);
    pathTop.lineTo(size.width * 0.44, 0);
    pathTop.quadraticBezierTo(
      size.width * 0.38,
      size.height * 0.08,
      size.width * 0.12,
      size.height * 0.09,
    );
    pathTop.quadraticBezierTo(
      0,
      size.height * 0.10,
      0,
      size.height * 0.13,
    );
    pathTop.close();
    canvas.drawPath(pathTop, wavePaintTop);

    // 3. Ornamen lengkungan lembut di sudut kanan bawah
    final wavePaintBottom = Paint()
      ..color = _AdminColors.waveDecor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final pathBottom = Path();
    pathBottom.moveTo(size.width, size.height * 0.78);
    pathBottom.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.88,
      size.width * 0.72,
      size.height,
    );
    pathBottom.lineTo(size.width, size.height);
    pathBottom.close();
    canvas.drawPath(pathBottom, wavePaintBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman Dashboard Admin Osteoporosis
/// Mereplikasi desain mobile (360 x 800 px) secara presisi dan responsif
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final adminUid = UserService().currentUser?.uid ?? 'admin_osteo';
    ChatService().startListeningPatientConversations(adminUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      body: Stack(
        children: [
          // 1. Background ornamen lengkungan krem kuning lembut
          const Positioned.fill(
            child: CustomPaint(
              painter: _AdminBackgroundPainter(),
            ),
          ),

          // 2. Konten utama yang scrollable dan responsif
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Header: "Osteo Admin" & Tombol Notifikasi Bell
                  _buildHeader(context),

                  const SizedBox(height: 8),

                  // Sapaan: "Halo, Admin! 👋" + Maskot Tulang Osteo
                  _buildGreetingSection(),

                  const SizedBox(height: 8),

                  // Statistik: Total Artikel (05) & Dipublikasikan (05)
                  _buildStatisticsSection(),

                  const SizedBox(height: 22),

                  // Menu Pengelolaan: Kelola Artikel & Tambah Artikel
                  _buildManagementMenuSection(context),

                  const SizedBox(height: 22),

                  // Artikel Terbaru + Tombol "Lihat Semua ->"
                  _buildRecentArticleSection(context),

                  // Jarak ekstra di bawah agar konten nyaman di-scroll sebelum bottom nav
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
  // 1. Header: Osteo Admin & Notification Bell
  // ===========================================================================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Osteo Admin',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _AdminColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
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
  // 2. Greeting Section: Sapaan Halo Admin & Maskot Tulang
  // ===========================================================================
  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Teks sapaan dan subteks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Halo, Admin!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _AdminColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '👋',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kelola informasi osteoporosis\ndi sini.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: _AdminColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Karakter maskot tulang membawa papan clipboard
          SizedBox(
            width: 100,
            height: 110,
            child: Image.asset(
              'assets/images/bone_character.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.medical_services_rounded,
                size: 64,
                color: _AdminColors.primaryYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. Statistik: Total Artikel (05) & Dipublikasikan (05)
  // ===========================================================================
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: AdminArticleStore(),
        builder: (context, _) {
          final total = AdminArticleStore().totalCount.toString().padLeft(2, '0');
          final published =
              AdminArticleStore().publishedCount.toString().padLeft(2, '0');

          return Row(
            children: [
              // Card 1: Total Artikel
              Expanded(
                child: _buildStatCard(
                  iconWidget: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      color: _AdminColors.amberDark,
                      size: 22,
                    ),
                  ),
                  count: total,
                  label: 'Total Artikel',
                ),
              ),
              const SizedBox(width: 14),

              // Card 2: Dipublikasikan
              Expanded(
                child: _buildStatCard(
                  iconWidget: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: _AdminColors.checkmarkGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  count: published,
                  label: 'Dipublikasikan',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required Widget iconWidget,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: _AdminColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _AdminColors.textHeading,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _AdminColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. Menu Pengelolaan: Kelola Artikel & Tambah Artikel
  // ===========================================================================
  Widget _buildManagementMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Pengelolaan',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: _AdminColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Card Kelola Artikel -> Navigasi ke AdminArticlesPage
              Expanded(
                child: _buildActionMenuCard(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.folder_rounded,
                        size: 42,
                        color: _AdminColors.amberFolder,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: _AdminColors.amberDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: 'Kelola Artikel',
                  subtitle: 'Edit dan hapus artikel',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminArticlesPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Card Tambah Artikel -> Navigasi ke AddArticlePage
              Expanded(
                child: _buildActionMenuCard(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 40,
                        color: _AdminColors.calendarBlue,
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: _AdminColors.calendarBlueDeep,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: 'Tambah Artikel',
                  subtitle: 'Buat artikel baru',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddArticlePage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card Chat Dokter -> Navigasi ke AdminDoctorListPage
          _buildDoctorChatActionCard(context),
        ],
      ),
    );
  }

  Widget _buildDoctorChatActionCard(BuildContext context) {
    return AnimatedBuilder(
      animation: ChatService(),
      builder: (context, _) {
        final unreadCount = ChatService().totalPatientUnreadCount;

        return Container(
          decoration: BoxDecoration(
            color: _AdminColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: unreadCount > 0
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFF1F5F9),
              width: unreadCount > 0 ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
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
                    builder: (_) => const AdminDoctorListPage(),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.forum_rounded,
                          color: _AdminColors.amberDark,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Chat Dokter',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: _AdminColors.textHeading,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadCount baru',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Kirim pesan & koordinasi langsung dengan dokter',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _AdminColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: _AdminColors.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionMenuCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _AdminColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _AdminColors.textHeading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: _AdminColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. Artikel Terbaru: Header dengan Tombol "Lihat Semua ->" & Card Artikel
  // ===========================================================================
  Widget _buildRecentArticleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris judul & tombol "Lihat Semua ->"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: _AdminColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Material(
                color: _AdminColors.pastelYellowBtn,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminArticlesPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _AdminColors.textDark,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: _AdminColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card Artikel "Mengenal Osteoporosis"
          _buildArticleCard(context),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AdminColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            // Jika data artikel tersedia, buka detail artikel
            if (ArticleData.articles.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailPage(
                    article: ArticleData.articles.first,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Gambar Tulang Belakang (Osteoporosis Hero)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/osteoporosis_hero.jpg',
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: _AdminColors.textLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Judul Artikel & Badge Status Dipublikasikan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mengenal\nOsteoporosis',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _AdminColors.textHeading,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: _AdminColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: _AdminColors.checkmarkGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Dipublikasikan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _AdminColors.badgeGreenText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ikon Chevron Panah Kanan
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _AdminColors.textDark,
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
  // 6. Bottom Navigation Bar: Dashboard (Aktif), Artikel, Tambah, Profil
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
                  // Sudah di Dashboard
                },
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_rounded,
                label: 'Artikel',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminArticlesPage(),
                    ),
                  );
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
    final isSelected = _currentIndex == index;
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
