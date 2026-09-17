import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/history/widgets/empty_history_widget.dart';
import 'package:oste/features/history/widgets/history_card.dart';
import 'package:oste/features/history/widgets/history_header.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/features/screening/screening_page.dart';
import 'package:oste/features/history/history_detail_page.dart';

// ---------------------------------------------------------------------------
// Model data dummy riwayat skrining
// ---------------------------------------------------------------------------
class _HistoryEntry {
  final String tanggal;
  final String waktu;
  final double probabilitas;
  final String status;
  final bool isPositive;

  const _HistoryEntry({
    required this.tanggal,
    required this.waktu,
    required this.probabilitas,
    required this.status,
    required this.isPositive,
  });
}

/// Data dummy riwayat skrining – ganti dengan data nyata dari API/database nanti.
const List<_HistoryEntry> _dummyHistory = [
  _HistoryEntry(
    tanggal: '12 September 2025',
    waktu: 'Pukul 14.30 WIB',
    probabilitas: 58,
    status: 'Terindikasi Osteoporosis',
    isPositive: true,
  ),
  _HistoryEntry(
    tanggal: '15 Agustus 2025',
    waktu: 'Pukul 09.12 WIB',
    probabilitas: 32,
    status: 'Tidak Terindikasi Osteoporosis',
    isPositive: false,
  ),
  _HistoryEntry(
    tanggal: '10 Juli 2025',
    waktu: 'Pukul 16.20 WIB',
    probabilitas: 76,
    status: 'Terindikasi Osteoporosis',
    isPositive: true,
  ),
  _HistoryEntry(
    tanggal: '05 Juni 2025',
    waktu: 'Pukul 10.05 WIB',
    probabilitas: 28,
    status: 'Tidak Terindikasi Osteoporosis',
    isPositive: false,
  ),
];

// ---------------------------------------------------------------------------
// Palet warna lokal (konsisten dengan DashboardPage)
// ---------------------------------------------------------------------------
class _HistoryPageColors {
  static const Color textDark   = Color(0xFF1E293B);
  static const Color textMuted  = Color(0xFF64748B);
  static const Color textLight  = Color(0xFF94A3B8);
  static const Color border     = Color(0xFFEAEAEA);
  static const Color orange     = Color(0xFFF59E0B);
}

/// Halaman Riwayat Skrining Osteoporosis.
///
/// Menampilkan [HistoryHeader] di bagian atas, diikuti daftar [HistoryCard]
/// jika ada riwayat, atau [EmptyHistoryWidget] jika belum ada riwayat.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  /// Ganti nilai ini ke `false` untuk melihat tampilan kosong.
  static const bool hasHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            const HistoryHeader(),

            const SizedBox(height: 24),

            // ── Konten utama ─────────────────────────────────────────
            Expanded(
              child: hasHistory
                  ? _HistoryListSection(entries: _dummyHistory)
                  : EmptyHistoryWidget(
                      onStartScreening: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScreeningPage(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _HistoryPageColors.border, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Riwayat aktif
        onTap: (index) {
          if (index == 1) return; // sudah di halaman ini
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const EducationPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _HistoryPageColors.orange,
        unselectedItemColor: _HistoryPageColors.textLight,
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

// ---------------------------------------------------------------------------
// Section daftar riwayat (hanya ditampilkan saat hasHistory == true)
// ---------------------------------------------------------------------------
class _HistoryListSection extends StatelessWidget {
  final List<_HistoryEntry> entries;

  const _HistoryListSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sub-header: judul + tombol urutkan ─────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Riwayat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _HistoryPageColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              // Tombol Urutkan
              Row(
                children: [
                  Text(
                    'Urutkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _HistoryPageColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.filter_list_rounded,
                    size: 18,
                    color: _HistoryPageColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── ListView riwayat ────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final e = entries[index];
              return HistoryCard(
                tanggal: e.tanggal,
                waktu: e.waktu,
                probabilitas: e.probabilitas,
                status: e.status,
                isPositive: e.isPositive,
               onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryDetailPage(),
                    ),
                  );
                }
              );
            },
          ),
        ),
      ],
    );
  }
}
