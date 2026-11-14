import 'package:flutter/material.dart';

/// Widget tampilan saat data riwayat skrining belum cukup (< 2 data)
/// untuk membentuk grafik perkembangan risiko osteoporosis.
class EmptyProgress extends StatelessWidget {
  const EmptyProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lingkaran ikon hangat sesuai tema Butter Yellow
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_graph_rounded,
                size: 28,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada cukup data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lakukan minimal dua kali skrining agar perkembangan risiko dapat ditampilkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

