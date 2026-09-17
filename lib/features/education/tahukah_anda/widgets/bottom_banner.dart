import 'package:flutter/material.dart';
import 'package:oste/features/education/tahukah_anda/widgets/illustrations.dart';

/// Banner motivasi kuning di bagian paling bawah halaman Tahukah Anda
class TahukahBottomBanner extends StatelessWidget {
  const TahukahBottomBanner({super.key});

  static const Color butterYellow = Color(0xFFF7C948);
  static const Color textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: butterYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18F7C948),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          SeedlingIllustration(),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Tulang yang sehat hari ini, untuk masa depan yang lebih baik! 💛',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
