import 'package:flutter/material.dart';
import 'package:oste/features/doctor_dashboard/doctor_chat_list_tab.dart';
import 'package:oste/features/doctor_dashboard/doctor_history_tab.dart';
import 'package:oste/features/doctor_dashboard/doctor_home_tab.dart';
import 'package:oste/features/doctor_dashboard/widgets/doctor_decorations.dart';
import 'package:oste/features/profile/profile_page.dart';
import 'package:oste/services/chat_service.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Utama Dashboard Dokter OSTEOCARE sesuai Desain Figma
class DoctorDashboardPage extends StatefulWidget {
  final int initialIndex;

  const DoctorDashboardPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Mulai memantau percakapan dari Firestore saat dashboard dibuka
    final doctorUid = UserService().currentUser?.uid ?? '';
    if (doctorUid.isNotEmpty) {
      ChatService().startListeningDoctorConversations(doctorUid);
    }
  }

  @override
  void dispose() {
    ChatService().stopListeningDoctorConversations();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background ornamen lengkungan butter yellow & bubble ungu pastel
          const Positioned.fill(
            child: CustomPaint(
              painter: DoctorBackgroundPainter(),
            ),
          ),

          // 2. Konten halaman berdasarkan tab aktif
          IndexedStack(
            index: _currentIndex,
            children: [
              // Tab 0: Beranda Dokter
              DoctorHomeTab(
                onNavigateToTab: _onTabSelected,
              ),

              // Tab 1: Riwayat Pasien (Skrining & Konsultasi)
              const DoctorHistoryTab(),

              // Tab 2: Chat Pasien
              const DoctorChatListTab(),

              // Tab 3: Profil (Menggunakan kembali ProfilePage yang sudah ada)
              const ProfilePage(
                showBottomNav: false,
                isDoctor: true,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildDoctorBottomNavigationBar(),
    );
  }

  /// Navigasi Bawah Dokter dengan pill highlight sesuai desain Figma
  Widget _buildDoctorBottomNavigationBar() {
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
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: ChatService(),
          builder: (context, _) {
            final totalUnread = ChatService().totalUnreadCount;
            return Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    activeIcon: Icons.home_rounded,
                    label: 'Beranda',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today_rounded,
                    label: 'Riwayat',
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: 'Chat Pasien',
                    usePillStyle: true,
                    badgeCount: totalUnread,
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Item Navigasi Bawah (dengan opsi pill styling seperti di Figma Screenshot 2)
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool usePillStyle = false,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;

    // Widget ikon dengan badge notifikasi
    Widget iconWithBadge(IconData iconData, Color iconColor) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(iconData, color: iconColor, size: 22),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Merah vivid
                  shape: badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: badgeCount > 9 ? BorderRadius.circular(8) : null,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (usePillStyle && isSelected) {
      return GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7DB), // Soft butter yellow pill
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWithBadge(activeIcon, DoctorThemeColors.orange),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DoctorThemeColors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWithBadge(
              isSelected ? activeIcon : icon,
              isSelected ? DoctorThemeColors.orange : DoctorThemeColors.textLight,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? DoctorThemeColors.orange
                    : DoctorThemeColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
