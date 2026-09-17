import 'package:flutter/material.dart';
import 'package:oste/features/education/tahukah_anda/widgets/bottom_banner.dart';
import 'package:oste/features/education/tahukah_anda/widgets/fakta_card.dart';
import 'package:oste/features/education/tahukah_anda/widgets/illustrations.dart';

/// Halaman Edukasi: Tahukah Anda?
///
/// Menampilkan 5 kartu fakta seputar kesehatan tulang dengan ilustrasi menarik
/// dan banner motivasi di bagian bawah.
class TahukahAndaPage extends StatelessWidget {
  const TahukahAndaPage({super.key});

  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgGradientTop = Color(0xFFFFFDE8);
  static const Color bgGradientBtm = Color(0xFFFAFAF7);

  @override
  Widget build(BuildContext context) {
    const List<FaktaCardData> cards = [
      FaktaCardData(
        number: '01',
        title: 'Setelah usia 50 tahun,',
        description:
            'kepadatan tulang mulai berkurang secara alami. Menjaga asupan kalsium dan vitamin D dapat membantu memperlambat proses tersebut.',
        isIllustrationLeft: true,
        illustration: BoneIllustration(),
      ),
      FaktaCardData(
        number: '02',
        title: 'Massa tulang mencapai puncaknya',
        description:
            'pada usia 20–30 tahun. Oleh karena itu, pola hidup sehat sejak dini sangat penting untuk menjaga tulang tetap kuat.',
        isIllustrationLeft: false,
        illustration: ExercisePersonIllustration(),
      ),
      FaktaCardData(
        number: '03',
        title: 'Paparan sinar matahari pagi',
        description:
            'selama 10–15 menit dapat membantu tubuh memproduksi vitamin D, yang berperan penting dalam penyerapan kalsium.',
        isIllustrationLeft: true,
        illustration: SunIllustration(),
      ),
      FaktaCardData(
        number: '04',
        title: 'Kalsium tidak hanya dari susu,',
        description:
            'tetapi juga dapat diperoleh dari sayuran hijau seperti brokoli, ikan, kacang-kacangan, serta produk olahan susu lainnya.',
        isIllustrationLeft: false,
        illustration: FoodPlateIllustration(),
      ),
      FaktaCardData(
        number: '05',
        title: 'Gaya hidup juga berpengaruh.',
        description:
            'Merokok, konsumsi alkohol berlebihan, kurang aktivitas fisik, dan pola makan tidak sehat dapat meningkatkan risiko osteoporosis.',
        isIllustrationLeft: true,
        illustration: HealthyHabitIllustration(),
      ),
    ];

    return Scaffold(
      backgroundColor: bgGradientBtm,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgGradientTop,
              bgGradientBtm,
              Colors.white,
            ],
            stops: [0.0, 0.25, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar: Back Button ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 32,
                        color: textDark,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Content ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      // ── Judul & Subtitle ─────────────────────────
                      const Text(
                        'Tahukah Anda?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Fakta menarik seputar kesehatan tulang',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Daftar 5 Kartu Fakta ─────────────────────
                      for (int i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: 16),
                        FaktaCard(data: cards[i]),
                      ],

                      const SizedBox(height: 22),

                      // ── Banner Motivasi Kuning di Bagian Bawah ───
                      const TahukahBottomBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
