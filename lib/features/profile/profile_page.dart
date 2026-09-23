import 'package:flutter/material.dart';
import 'package:oste/features/auth/login/login_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/features/profile/change_password_page.dart';
import 'package:oste/features/profile/edit_page.dart';
import 'package:oste/services/user_service.dart';

// ---------------------------------------------------------------------------
// Palet warna resmi Halaman Profil – tema Butter Yellow + Cream
// ---------------------------------------------------------------------------
class _ProfileColors {
  static const Color background    = Color(0xFFFFF9EF);
  static const Color cardWhite     = Color(0xFFFFFFFF);
  static const Color textDark      = Color(0xFF1F2937);
  static const Color textMuted     = Color(0xFF6B7280);
  static const Color textLight     = Color(0xFF94A3B8);
  static const Color divider       = Color(0xFFF1F5F9);
  static const Color border        = Color(0xFFEAEAEA);
  static const Color orange        = Color(0xFFE8A317);   // butter yellow icon/teks
  static const Color avatarBg      = Color(0xFFF59E0B);   // avatar background
  static const Color iconCircle    = Color(0xFFFFF4CC);   // lingkaran icon data
}

/// Halaman Profil Pengguna Oste.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.background,
      appBar: AppBar(
        backgroundColor: _ProfileColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: _ProfileColors.textDark,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ProfileColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: UserService(),
        builder: (context, _) {
          final user      = UserService().currentUser;
          final name      = user?.name ?? '-';
          final email     = user?.email ?? '-';
          final phone     = user?.phone.isNotEmpty == true ? user!.phone : '-';
          final gender    = user?.gender.isNotEmpty == true ? user!.gender : '-';
          final birthDate = user?.birthDate.isNotEmpty == true ? user!.birthDate : '-';
          final weightStr = user?.weight != null ? '${user!.weight!.toStringAsFixed(0)} kg' : '-';
          final heightStr = user?.height != null ? '${user!.height!.toStringAsFixed(0)} cm' : '-';

          // Ambil huruf pertama nama untuk avatar
          final String avatarLetter =
              (name.isNotEmpty && name != '-') ? name.trim()[0].toUpperCase() : '?';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Card Header Profil (Avatar, Nama, Email, No. HP) ─────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _ProfileColors.cardWhite,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                             color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          // ── Avatar lingkaran dengan huruf pertama nama ──
                          Stack(
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _ProfileColors.avatarBg,
                                ),
                                child: Center(
                                  child: Text(
                                    avatarLetter,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const EditPage(
                                          prefillFromUser: true,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      // updateProfile() já chama notifyListeners() internamente;
                                      // o AnimatedBuilder rebuilda automaticamente.
                                    }
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _ProfileColors.orange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: _ProfileColors.textDark,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: _ProfileColors.textMuted,
                                  ),
                                ),
                                if (phone != '-') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: _ProfileColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Card Data Pribadi ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _ProfileColors.cardWhite,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section: judul + tombol Ubah
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Data Pribadi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _ProfileColors.textDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditPage(
                                        prefillFromUser: true,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    // updateProfile() já chama notifyListeners() internamente;
                                    // o AnimatedBuilder rebuilda automaticamente.
                                  }
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 15,
                                        color: _ProfileColors.orange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ubah',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _ProfileColors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Baris data pribadi dengan icon
                          _buildDataRow(Icons.person_outline_rounded,    'Nama Lengkap', name),
                          _buildDivider(),
                          _buildDataRow(Icons.email_outlined,            'Email',        email),
                          _buildDivider(),
                          _buildDataRow(Icons.phone_outlined,            'Nomor HP',     phone),
                          _buildDivider(),
                          _buildDataRow(Icons.wc_outlined,               'Jenis Kelamin', gender),
                          _buildDivider(),
                          _buildDataRow(Icons.cake_outlined,             'Tanggal Lahir', birthDate),
                          _buildDivider(),
                          _buildDataRow(Icons.monitor_weight_outlined,   'Berat Badan',  weightStr),
                          _buildDivider(),
                          _buildDataRow(Icons.height_rounded,            'Tinggi Badan', heightStr),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Account Section ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _ProfileColors.cardWhite,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ProfileColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Change Password ──
                          _buildAccountTile(
                            context: context,
                            icon: Icons.lock_outline,
                            iconColor: _ProfileColors.orange,
                            iconBgColor: _ProfileColors.iconCircle,
                            title: 'Change Password',
                            subtitle: 'Change your account password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage(),
                                ),
                              );
                            },
                          ),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _ProfileColors.divider,
                          ),

                          // ── Logout ──
                          _buildAccountTile(
                            context: context,
                            icon: Icons.logout,
                            iconColor: const Color(0xFFEF4444),
                            iconBgColor: const Color(0xFFFEE2E2),
                            title: 'Logout',
                            subtitle: 'Sign out from your account',
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Baris data dengan icon lingkaran butter yellow, label, dan nilai
  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Icon di dalam lingkaran butter yellow muda
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _ProfileColors.iconCircle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: _ProfileColors.orange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: _ProfileColors.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _ProfileColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Divider tipis antar baris
  Widget _buildDivider() {
    return const Divider(
      height: 16,
      thickness: 1,
      color: _ProfileColors.divider,
    );
  }

  /// Tile untuk section Account (Change Password, Logout, dsb.)
  Widget _buildAccountTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ProfileColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: _ProfileColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: _ProfileColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog konfirmasi Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _ProfileColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _ProfileColors.textDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _ProfileColors.textMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: _ProfileColors.textMuted,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // tutup dialog
              await UserService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// BottomNavigationBar sesuai navigasi utama aplikasi Oste
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _ProfileColors.border, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 3, // Profil aktif
        onTap: (index) {
          if (index == 3) return; // sudah berada di halaman Profil
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const EducationPage()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _ProfileColors.orange,
        unselectedItemColor: _ProfileColors.textLight,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
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
