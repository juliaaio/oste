import 'package:flutter/material.dart';

/// Tab bar pilihan riwayat (Skrining & Konsultasi Dokter) sesuai desain Figma
class HistoryTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const HistoryTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tab 1: Skrining
              Expanded(
                child: _buildTabButton(
                  index: 0,
                  icon: Icons.calendar_today_outlined,
                  label: 'Skrining',
                ),
              ),
              const SizedBox(width: 12),
              // Tab 2: Konsultasi Dokter
              Expanded(
                child: _buildTabButton(
                  index: 1,
                  icon: Icons.person_outline_rounded,
                  label: 'Konsultasi Dokter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    final Color bgColor = isSelected
        ? const Color(0xFFFDE68A) // Kuning hangat Figma
        : const Color(0xFFF0F4F8); // Abu-abu muda

    final Color contentColor = isSelected
        ? const Color(0xFF1E293B)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: contentColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: contentColor,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
