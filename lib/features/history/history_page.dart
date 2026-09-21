import 'package:flutter/material.dart';
import 'package:oste/features/consultation/consultation_summary_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/education/education_page.dart';
import 'package:oste/features/history/models/history_model.dart';
import 'package:oste/features/history/widgets/consultation_history_card.dart';
import 'package:oste/features/history/widgets/empty_history_widget.dart';
import 'package:oste/features/history/widgets/history_header.dart';
import 'package:oste/features/history/widgets/history_summary_card.dart';
import 'package:oste/features/history/widgets/history_tab_bar.dart';
import 'package:oste/features/history/widgets/screening_history_card.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/features/screening/hasil_page.dart';
import 'package:oste/features/screening/screening_page.dart';
import 'package:oste/services/consultation_history_service.dart';
import 'package:oste/services/history_service.dart';

// ---------------------------------------------------------------------------
// Palet warna lokal (konsisten dengan DashboardPage & Figma)
// ---------------------------------------------------------------------------
class _HistoryPageColors {
  static const Color border     = Color(0xFFEAEAEA);
  static const Color textLight  = Color(0xFF94A3B8);
  static const Color orange     = Color(0xFFF59E0B);
}

/// Halaman Riwayat (Skrining Osteoporosis & Konsultasi Dokter) sesuai desain Figma.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedTabIndex = 0; // 0 = Skrining, 1 = Konsultasi Dokter

  static String _formatLongDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatShortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final historyService = HistoryService();
    final consultationService = ConsultationHistoryService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([historyService, consultationService]),
          builder: (context, _) {
            final screeningList = historyService.screeningHistories;
            final consultationList = consultationService.allConsultations;
            final latestScreening = historyService.latestScreening;

            // Perhitungan Ringkasan Riwayat
            final totalScreenings = screeningList.length;
            final latestResult = latestScreening != null
                ? '${latestScreening.probabilitas}%'
                : '-';
            final latestDate = latestScreening != null
                ? _formatShortDate(latestScreening.tanggal)
                : '-';

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Header Riwayat ──────────────────────────────────
                const SliverToBoxAdapter(
                  child: HistoryHeader(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                // ── Card Ringkasan Riwayat ──────────────────────────
                SliverToBoxAdapter(
                  child: HistorySummaryCard(
                    totalScreening: totalScreenings,
                    latestResult: latestResult,
                    latestDate: latestDate,
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 22),
                ),

                // ── Tab Bar (Skrining & Konsultasi Dokter) ───────────
                SliverToBoxAdapter(
                  child: HistoryTabBar(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                // ── Konten Tab Aktif ────────────────────────────────
                if (_selectedTabIndex == 0)
                  _buildScreeningTabContent(screeningList)
                else
                  _buildConsultationTabContent(consultationList),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Daftar riwayat skrining mandiri
  Widget _buildScreeningTabContent(List<HistoryModel> screenings) {
    if (screenings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: EmptyHistoryWidget(
            title: 'Belum ada riwayat',
            description:
                'Hasil skrining Anda akan muncul di sini setelah melakukan skrining.',
            buttonText: 'Mulai Skrining',
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
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = screenings[index];
            return ScreeningHistoryCard(
              tanggal: _formatLongDate(item.tanggal),
              waktu: item.waktu,
              probabilitas: item.probabilitas.toDouble(),
              status: item.status,
              isPositive: item.isPositive,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HasilScreeningPage(
                      scorePercentage: item.probabilitas.toDouble(),
                      riskTitle: item.riskCategory ??
                          (item.isPositive ? 'risiko sedang' : 'risiko rendah'),
                      riskDescription: item.summary ?? '',
                      predictionData: item.predictionData,
                      recommendations: item.recommendations,
                      screeningId: item.id,
                      autoSave: false,
                    ),
                  ),
                );
              },
            );
          },
          childCount: screenings.length,
        ),
      ),
    );
  }

  /// Daftar riwayat sesi konsultasi dokter
  Widget _buildConsultationTabContent(List<dynamic> consultations) {
    if (consultations.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: EmptyHistoryWidget(
            title: 'Belum ada riwayat konsultasi',
            description:
                'Konsultasi yang telah selesai akan tersimpan secara otomatis di sini.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = consultations[index];
            return ConsultationHistoryCard(
              consultation: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsultationSummaryPage(
                      consultation: item,
                    ),
                  ),
                );
              },
            );
          },
          childCount: consultations.length,
        ),
      ),
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
