import 'package:flutter/material.dart';
import 'package:oste/features/admin/articles/add_article_page.dart';
import 'package:oste/features/admin/articles/admin_articles_page.dart';
import 'package:oste/features/admin/dashboard/admin_dashboard_page.dart';
import 'package:oste/features/auth/login/login_page.dart';
import 'package:oste/features/profile/change_password_page.dart';
import 'package:oste/features/profile/edit_page.dart';
import 'package:oste/services/user_service.dart';

/// Palet warna tema Profil Admin sesuai acuan desain
class _ProfileColors {
  // Background utama bernuansa krem kuning lembut
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  // Card & Permukaan
  static const Color cardSurface = Colors.white;

  // Aksen Ungu Pastel (Avatar & Badge Role)
  static const Color avatarPurpleBg = Color(0xFFEDE9FE);
  static const Color avatarPurpleIcon = Color(0xFF7C3AED);
  static const Color roleBadgeBg = Color(0xFFF3E8FF);
  static const Color roleBadgeText = Color(0xFF6B21A8);

  // Aksen Kuning Butter & Tombol Navigasi
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color activeNavYellow = Color(0xFFF5A623);
  static const Color amberDark = Color(0xFFF59E0B);
  static const Color editBadgeYellow = Color(0xFFFBBF24);

  // Aksen Ikon Menu
  static const Color menuIconBlue = Color(0xFF3B82F6);
  static const Color logoutRed = Color(0xFFEF4444);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color chevronGrey = Color(0xFFCBD5E1);
  static const Color dividerColor = Color(0xFFF8FAFC);
}

/// Painter dekorasi background lengkungan lembut butter yellow di sudut kanan bawah
class _ProfileBackgroundPainter extends CustomPainter {
  const _ProfileBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background krem kuning dasar #FFF9E8
    final basePaint = Paint()..color = _ProfileColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // 2. Lengkungan lembut di sudut kiri atas
    final wavePaintTop = Paint()
      ..color = _ProfileColors.waveDecor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final pathTop = Path();
    pathTop.moveTo(0, 0);
    pathTop.lineTo(size.width * 0.35, 0);
    pathTop.quadraticBezierTo(
      size.width * 0.30,
      size.height * 0.07,
      0,
      size.height * 0.10,
    );
    pathTop.close();
    canvas.drawPath(pathTop, wavePaintTop);

    // 3. Lengkungan lembut di sudut kanan bawah
    final wavePaintBottom = Paint()
      ..color = _ProfileColors.waveDecor.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;

    final pathBottom = Path();
    pathBottom.moveTo(size.width, size.height * 0.76);
    pathBottom.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.86,
      size.width * 0.70,
      size.height,
    );
    pathBottom.lineTo(size.width, size.height);
    pathBottom.close();
    canvas.drawPath(pathBottom, wavePaintBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman Profil Admin Osteoporosis
/// Menampilkan informasi profil akun admin, menu kelola akun, dan logout autentikasi
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final int _currentNavIndex = 3; // Tab Profil aktif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.background,
      body: Stack(
        children: [
          // 1. Dekorasi Background Ornamen Lengkungan Lembut
          const Positioned.fill(
            child: CustomPaint(
              painter: _ProfileBackgroundPainter(),
            ),
          ),

          // 2. Konten Utama Scrollable
          SafeArea(
            child: AnimatedBuilder(
              animation: UserService(),
              builder: (context, _) {
                final user = UserService().currentUser;

                // Ambil data admin dari sesi login jika tersedia, atau default acuan
                final adminName = (user != null && user.name.trim().isNotEmpty)
                    ? user.name.trim()
                    : 'Admin Osteo';

                final adminEmail = (user != null && user.email.trim().isNotEmpty)
                    ? user.email.trim()
                    : 'adminosteo@gmail.com';

                return Column(
                  children: [
                    const SizedBox(height: 12),

                    // Header: Tombol Kembali, Judul "Profil Admin", & Lonceng Notifikasi
                    _buildHeader(context),

                    // Konten Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Avatar Admin dengan Aksen Ungu Pastel & Badge Edit Kuning
                            _buildAvatarSection(context),

                            const SizedBox(height: 14),

                            // Nama Admin
                            Text(
                              adminName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _ProfileColors.textHeading,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Email Admin
                            Text(
                              adminEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _ProfileColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Badge Role Administrator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _ProfileColors.roleBadgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Role: Admin',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _ProfileColors.roleBadgeText,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Card Menu Profil (Ubah Profil, Ganti Password, Tentang Aplikasi, Keluar Akun)
                            _buildMenuCard(context),

                            const SizedBox(height: 20),

                            // Karakter Maskot Tulang Lucu Sesuai Screenshot
                            Center(
                              child: Image.asset(
                                'assets/images/bone_character.png',
                                height: 115,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(height: 100),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ===========================================================================
  // 1. Header: Back Button, "Profil Admin", & Notification Bell
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
                  color: _ProfileColors.textDark,
                  size: 22,
                ),
              ),
            ),
          ),

          // Judul Halaman
          const Text(
            'Profil Admin',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _ProfileColors.textDark,
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
                  color: _ProfileColors.textDark,
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
  // 2. Avatar Admin dengan Aksen Ungu & Badge Pensil Kuning
  // ===========================================================================
  Widget _buildAvatarSection(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          // Lingkaran Avatar Ungu Pastel
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: _ProfileColors.avatarPurpleBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 56,
                color: _ProfileColors.avatarPurpleIcon,
              ),
            ),
          ),

          // Badge Tombol Pensil Kuning
          Positioned(
            right: 0,
            bottom: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditPage(prefillFromUser: true),
                  ),
                );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _ProfileColors.editBadgeYellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. Card Menu Profil Admin (Ubah Profil, Ganti Password, Tentang, Keluar)
  // ===========================================================================
  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ProfileColors.cardSurface,
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
        children: [
          // 1. Ubah Profil
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: _ProfileColors.menuIconBlue,
            title: 'Ubah Profil',
            isFirst: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditPage(prefillFromUser: true),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1, color: _ProfileColors.dividerColor),

          // 2. Ganti Password
          _buildMenuItem(
            icon: Icons.lock_outline_rounded,
            iconColor: _ProfileColors.menuIconBlue,
            title: 'Ganti Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1, color: _ProfileColors.dividerColor),

          // 3. Tentang Aplikasi
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            iconColor: _ProfileColors.menuIconBlue,
            title: 'Tentang Aplikasi',
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1, thickness: 1, color: _ProfileColors.dividerColor),

          // 4. Keluar Akun
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: _ProfileColors.logoutRed,
            title: 'Keluar Akun',
            isLast: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(22) : Radius.zero,
          bottom: isLast ? const Radius.circular(22) : Radius.zero,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ProfileColors.textHeading,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _ProfileColors.chevronGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. Dialog Tentang Aplikasi
  // ===========================================================================
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.info_outline_rounded,
              color: _ProfileColors.menuIconBlue,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Tentang Aplikasi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ProfileColors.textHeading,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'OsteoCare Admin v1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ProfileColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Platform manajemen edukasi dan informasi kesehatan tulang osteoporosis untuk administrator OsteoCare.',
              style: TextStyle(
                fontSize: 13,
                color: _ProfileColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _ProfileColors.primaryYellow,
              foregroundColor: _ProfileColors.textDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Dialog Konfirmasi Logout Akun
  // ===========================================================================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.logout_rounded,
              color: _ProfileColors.logoutRed,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Keluar Akun?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ProfileColors.textHeading,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun Admin OsteoCare?',
          style: TextStyle(
            fontSize: 13.5,
            color: _ProfileColors.textMuted,
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
                color: _ProfileColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);

              // Jalankan proses logout dari UserService (Firebase Auth)
              await UserService().logout();

              if (!context.mounted) return;

              // Arahkan ke halaman LoginPage dan bersihkan riwayat navigasi
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _ProfileColors.logoutRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. Bottom Navigation Bar: Dashboard, Artikel, Tambah, Profil (Aktif)
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_rounded,
                label: 'Artikel',
                onTap: () {
                  Navigator.pushReplacement(
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
                  // Sudah di halaman Profil
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
    const activeColor = _ProfileColors.activeNavYellow;
    const inactiveColor = _ProfileColors.textLight;

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

