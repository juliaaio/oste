import 'package:flutter/material.dart';

/// Model data kartu fakta edukasi
class FaktaCardData {
  final String number;
  final String title;
  final String description;
  final bool isIllustrationLeft;
  final Widget illustration;

  const FaktaCardData({
    required this.number,
    required this.title,
    required this.description,
    required this.isIllustrationLeft,
    required this.illustration,
  });
}

/// Kartu fakta edukasi seputar kesehatan tulang
class FaktaCard extends StatelessWidget {
  final FaktaCardData data;

  const FaktaCard({
    super.key,
    required this.data,
  });

  static const Color yellowBadgeBg = Color(0xFFFEF08A);
  static const Color yellowBadgeText = Color(0xFF854D0E);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Baris Badge Nomor + Judul
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: yellowBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.number,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: yellowBadgeText,
                  ),
                ),
              ),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: data.isIllustrationLeft
            ? [
                data.illustration,
                const SizedBox(width: 16),
                textColumn,
              ]
            : [
                textColumn,
                const SizedBox(width: 16),
                data.illustration,
              ],
      ),
    );
  }
}
