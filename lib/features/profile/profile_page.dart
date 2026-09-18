import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/history/history_page.dart';
import 'package:oste/services/user_service.dart';

// ---------------------------------------------------------------------------
// Palet warna resmi Halaman Profil (konsisten dengan tema Oste)
// ---------------------------------------------------------------------------
class _ProfileColors {
  static const Color textDark     = Color(0xFF1E293B);
  static const Color textMuted    = Color(0xFF64748B);
  static const Color textLight    = Color(0xFF94A3B8);
  static const Color divider      = Color(0xFFF1F5F9);
  static const Color border       = Color(0xFFEAEAEA);
  static const Color orange       = Color(0xFFF59E0B);
}

/// Halaman Profil Pengguna Oste.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          final user = UserService().currentUser;
          final name = user?.name ?? '-';
          final email = user?.email ?? '-';
          final phone = user?.phone.isNotEmpty == true ? user!.phone : '-';
          final gender = user?.gender.isNotEmpty == true ? user!.gender : '-';
          final birthDate = user?.birthDate.isNotEmpty == true ? user!.birthDate : '-';
          final weightStr = user?.weight != null ? '${user!.weight!.toStringAsFixed(0)} kg' : '-';
          final heightStr = user?.height != null ? '${user!.height!.toStringAsFixed(0)} cm' : '-';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Header Profil (Foto, Nama, Email, No. HP) ────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
                                  width: 74,
                                  height: 74,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: const Color(0xFFE2E8F0),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: _ProfileColors.textLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
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

                  const SizedBox(height: 8),

                  // ── Garis Pemisah Penuh ──────────────────────────────────
                  const Divider(
                    height: 24,
                    thickness: 1,
                    color: _ProfileColors.divider,
                  ),

                  const SizedBox(height: 8),

                  // ── Bagian Data Pribadi ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              onTap: () {
                                // UI Only - fungsi ubah data pribadi akan ditambahkan nanti
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

                        const SizedBox(height: 18),

                        _buildDataRow('Nama Lengkap', name),
                        _buildDivider(),
                        _buildDataRow('Email', email),
                        _buildDivider(),
                        _buildDataRow('Nomor HP', phone),
                        _buildDivider(),
                        _buildDataRow('Jenis Kelamin', gender),
                        _buildDivider(),
                        _buildDataRow('Tanggal Lahir', birthDate),
                        _buildDivider(),
                        _buildDataRow('Berat Badan', weightStr),
                        _buildDivider(),
                        _buildDataRow('Tinggi Badan', heightStr),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Baris data label & nilai
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: _ProfileColors.textLight,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
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
      height: 22,
      thickness: 1,
      color: _ProfileColors.divider,
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
