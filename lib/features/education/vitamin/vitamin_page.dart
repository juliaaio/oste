import 'package:flutter/material.dart';

class VitaminPage extends StatelessWidget {
  const VitaminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Artikel Pengobatan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // 1. Hero Section di Atas
              _HeroSection(),
              SizedBox(height: 20),

              // 2. Section "Mengapa Vitamin Penting?"
              _ArticleBlock(
                title: 'Mengapa Vitamin Penting?',
                paragraphs: [
                  'Vitamin memiliki peran penting dalam menjaga kesehatan tulang maupun sendi. Jika tidak memenuhi kebutuhan vitamin yang dibutuhkan tulang serta sendi, risiko osteoporosis dan patah tulang dapat meningkat. Vitamin D dan K adalah nutrisi utama yang dibutuhkan tulang agar tetap kuat. Berikut penjelasan mengenai manfaat vitamin D dan K dalam menjaga kesehatan tulang.',
                ],
              ),
              SizedBox(height: 22),

              // 3. Section "1. Vitamin D"
              _ArticleBlock(
                title: '1. Vitamin D',
                paragraphs: [
                  'Vitamin D dapat meningkatkan massa tulang dan membantu mencegah osteoporosis (pengeroposan tulang). Selain itu, vitamin ini juga berperan penting dalam membantu penyerapan kalsium dalam tubuh yang merupakan mineral penting untuk kesehatan tulang.',
                  'Guna memenuhi kebutuhan vitamin D harian, Anda bisa mendapatkannya dari paparan sinar matahari, makanan, atau suplemen. Namun ingat, penting untuk berkonsultasi dengan dokter atau ahli gizi mengenai dosis suplemen yang tepat sesuai kondisi kesehatan.',
                ],
              ),
              SizedBox(height: 14),

              // Info Card: Kebutuhan Harian Vitamin D
              _InfoCard(
                icon: Icons.assignment_outlined,
                title: 'Kebutuhan Harian Vitamin D\n(berdasarkan usia)',
                items: [
                  '600–700 IU untuk orang dewasa.',
                  '800 IU untuk orang berusia di atas 71 tahun.',
                  '400 IU untuk bayi yang menyusu ASI, dengan dosis maksimum per hari 1000 IU (usia 0–6 bulan) dan 1500 IU (usia 6–12 bulan).',
                  '600 IU untuk anak usia 1 tahun ke atas, dengan dosis maksimum per hari 2500 IU (usia 1–3 tahun), 3000 IU (usia 4–8 tahun), dan 4000 IU (usia 9 tahun ke atas).',
                ],
              ),
              SizedBox(height: 14),

              // Info Card: Makanan Kaya Vitamin D
              _InfoCard(
                icon: Icons.restaurant_rounded,
                title: 'Makanan Kaya Vitamin D',
                items: [
                  'Susu.',
                  'Sereal yang diperkaya vitamin D.',
                  'Ikan berlemak, seperti salmon, tuna, dan makarel.',
                  'Hati sapi.',
                  'Kuning telur.',
                  'Keju.',
                  'Jamur.',
                  'Margarin.',
                  'Yoghurt.',
                ],
              ),
              SizedBox(height: 22),

              // 4. Section "2. Vitamin K"
              _ArticleBlock(
                title: '2. Vitamin K',
                paragraphs: [
                  'Vitamin untuk membantu menjaga kesehatan tulang dan sendi yang perlu dipenuhi berikutnya adalah vitamin K. Manfaat utama vitamin K adalah mengaktifkan protein tertentu yang mendukung pembentukan tulang dan mencegah melemahnya tulang. Inilah sebabnya, vitamin K memiliki peran penting dalam menjaga kesehatan tulang.',
                  'Jurnal berjudul Effect of Vitamin K on Bone Mineral Density and Fracture Risk in Adults: Systematic Review and Meta-Analysis menyebutkan bahwa kurangnya asupan vitamin K bisa meningkatkan risiko patah tulang (fraktur) dan pengeroposan tulang (osteoporosis).',
                  'Berdasarkan Peraturan Menteri Kesehatan RI No. 28 Tahun 2019 tentang Angka Kecukupan Gizi yang Dianjurkan untuk Masyarakat Indonesia, kebutuhan vitamin K harian yang perlu dipenuhi oleh laki-laki usia 19–80 tahun ke atas sebanyak 65 mcg. Sedangkan, untuk perempuan usia 13–80 tahun ke atas sebanyak 55 mcg. Anda bisa berkonsultasi dengan dokter mengenai dosis yang tepat untuk usia atau kondisi tertentu.',
                ],
              ),
              SizedBox(height: 14),

              // Info Card: Kebutuhan Harian Vitamin K
              _InfoCard(
                icon: Icons.assignment_outlined,
                title: 'Kebutuhan Harian Vitamin K',
                items: [
                  'Laki-laki usia 19–80 tahun ke atas: 65 mcg.',
                  'Perempuan usia 13–80 tahun ke atas: 55 mcg.',
                ],
              ),
              SizedBox(height: 14),

              // Info Card: Makanan Kaya Vitamin K
              _InfoCard(
                icon: Icons.eco_rounded,
                title: 'Makanan Kaya Vitamin K',
                items: [
                  'Sayuran berdaun hijau, seperti kangkung, bayam, dan brokoli.',
                  'Minyak sayur.',
                  'Sereal dan biji-bijian.',
                  'Buah-buahan, seperti kiwi.',
                  'Susu dan turunannya seperti keju, yoghurt, dan lain-lain.',
                  'Telur.',
                  'Daging.',
                ],
              ),
              SizedBox(height: 24),

              // 5. Section "Nutrisi Lain yang Baik untuk Tulang dan Sendi"
              _ArticleBlock(
                title: 'Nutrisi Lain yang Baik untuk Tulang dan Sendi',
                paragraphs: [
                  'Selain memenuhi kebutuhan vitamin untuk menjaga kesehatan tulang dan sendi, terdapat mineral yang perannya tidak kalah penting dalam mempertahankan kekuatan dan kepadatan tulang, di antaranya kalsium dan magnesium. Berikut masing-masing penjelasannya.',
                ],
              ),
              SizedBox(height: 14),

              // Subsection 1: Kalsium
              _MineralSection(
                numberTitle: '1. Kalsium',
                icon: Icons.local_drink_rounded,
                iconColor: Color(0xFF0284C7),
                boxColor: Color(0xFFF0F9FF),
                description:
                    'Kalsium adalah komponen utama pada tulang sehingga berperan penting dalam menjaga kekuatan dan struktur tulang. Faktanya, sekitar 99% kalsium di dalam tubuh disimpan dalam tulang. Terdapat beberapa protein pada tulang yang juga bergantung pada vitamin K. Beberapa jenis makanan yang mengandung kalsium, di antaranya:',
                bulletItems: [
                  'Sayuran berdaun hijau, seperti kangkung dan brokoli.',
                  'Produk olahan susu, seperti yoghurt dan keju.',
                  'Ikan seperti salmon, sarden kalengan, dan lain-lain.',
                  'Susu nabati, jus buah, dan sereal dengan tambahan kalsium.',
                ],
              ),
              SizedBox(height: 16),

              // Subsection 2: Magnesium
              _MineralSection(
                numberTitle: '2. Magnesium',
                icon: Icons.grain_rounded,
                iconColor: Color(0xFFB45309),
                boxColor: Color(0xFFFEF3C7),
                description:
                    'Magnesium adalah mineral penting yang terlibat dalam lebih dari 300 reaksi dalam tubuh. Sebagai informasi, sebanyak 50–60% magnesium disimpan di dalam jaringan tulang. Itulah sebabnya, rendahnya kadar magnesium dalam tubuh dikaitkan dengan osteoporosis dan kepadatan tulang yang rendah.\n\nGuna memenuhi kebutuhan magnesium, Anda bisa mengonsumsi kacang-kacangan, biji-bijian, dan gandum utuh.',
                bulletItems: [],
              ),
              SizedBox(height: 16),

              // Paragraf Penutup
              Text(
                'Itulah penjelasan mengenai beberapa rekomendasi vitamin untuk menjaga kesehatan tulang dan sendi, serta jenis nutrisi lainnya. Meski bermanfaat bagi kesehatan, penggunaannya tetap perlu diperhatikan. Penting bagi Anda untuk berkonsultasi dengan dokter mengenai anjuran dosis yang sesuai kondisi kesehatan guna mencegah efek samping.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: Color(0xFF475569),
                ),
              ),
              SizedBox(height: 22),

              // 6. Section "Ingat!"
              _TipsCard(),
              SizedBox(height: 16),

              // 7. Quote Penutup
              _QuoteCard(),
              SizedBox(height: 14),

              // Home Indicator Halus di Bagian Bawah
              Center(
                child: _HomeIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero section di bagian atas dengan banner cream lembut dan ilustrasi vitamin
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Teks Hero
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Vitamin untuk\nTulang dan Sendi\nyang Lebih Sehat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tulang dan sendi yang kuat dimulai dari asupan vitamin yang cukup setiap hari.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Ilustrasi Hero Vitamin
          Expanded(
            flex: 10,
            child: Image.asset(
              'assets/images/education/vitamin_hero.png',
              height: 145,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const _VitaminHeroIllustration();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Fallback ilustrasi vektor botol vitamin, sinar matahari, dan gelas air
class _VitaminHeroIllustration extends StatelessWidget {
  const _VitaminHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: CustomPaint(
        size: const Size(130, 140),
        painter: _VitaminHeroPainter(),
      ),
    );
  }
}

class _VitaminHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width * 0.52;
    final double cy = size.height * 0.56;

    // 1. Sinar matahari kuning cerah di atas kanan
    final sunPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.22), 16, sunPaint);

    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    const rayAngles = [0.0, 0.78, 1.57, 2.35, 3.14, 3.92, 4.71, 5.49];
    for (final a in rayAngles) {
      final dx1 = (size.width * 0.68) + (19 * _cos(a));
      final dy1 = (size.height * 0.22) + (19 * _sin(a));
      final dx2 = (size.width * 0.68) + (24 * _cos(a));
      final dy2 = (size.height * 0.22) + (24 * _sin(a));
      canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), rayPaint);
    }

    // 2. Daun hijau segar di kiri bawah
    final leafPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 28, cy + 12), width: 28, height: 42),
      leafPaint,
    );

    // 3. Botol Vitamin oranye/kuning
    final bottleFill = Paint()..color = const Color(0xFFFBBF24);
    final bottleStroke = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Tutup botol
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 6, cy - 26), width: 26, height: 10),
      const Radius.circular(3),
    );
    canvas.drawRRect(capRect, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawRRect(capRect, bottleStroke);

    // Badan botol
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 6, cy + 4), width: 44, height: 52),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, bottleFill);
    canvas.drawRRect(bodyRect, bottleStroke);

    // Label botol putih
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 6, cy + 4), width: 36, height: 32),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelRect, Paint()..color = Colors.white);

    // Simbol garis pada label
    canvas.drawLine(
      Offset(cx - 10, cy + 8),
      Offset(cx - 2, cy + 8),
      Paint()
        ..color = const Color(0xFFD97706)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Teks kecil "VITAMIN"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'VITAMIN',
        style: TextStyle(
          fontSize: 6,
          fontWeight: FontWeight.bold,
          color: Color(0xFFB45309),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - 18, cy - 8));

    // 4. Gelas air di sebelah kanan
    final glassFill = Paint()..color = const Color(0xFFE0F2FE);
    final glassStroke = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final glassPath = Path();
    glassPath.moveTo(cx + 18, cy - 8);
    glassPath.lineTo(cx + 34, cy - 8);
    glassPath.lineTo(cx + 31, cy + 28);
    glassPath.lineTo(cx + 21, cy + 28);
    glassPath.close();
    canvas.drawPath(glassPath, glassFill);
    canvas.drawPath(glassPath, glassStroke);

    // 5. Butiran pil putih di depan botol
    final pillPaint = Paint()..color = Colors.white;
    final pillBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 16, cy + 28), width: 14, height: 8),
      pillPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 16, cy + 28), width: 14, height: 8),
      pillBorder,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 2, cy + 28), width: 14, height: 8),
      pillPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 2, cy + 28), width: 14, height: 8),
      pillBorder,
    );
  }

  double _cos(double a) => (a == 0.0 || a == 6.28) ? 1.0 : (a == 3.14 ? -1.0 : 0.707);
  double _sin(double a) => (a == 1.57) ? 1.0 : (a == 4.71 ? -1.0 : 0.707);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget section artikel dengan aksen kuning dan paragraf naratif
class _ArticleBlock extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _ArticleBlock({
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFF7C948),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...paragraphs.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Info card berisi icon box, judul tebal, dan daftar poin kebutuhan / makanan
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon box + Judul tebal
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE5A124),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daftar bullet points
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5A124),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subsection khusus Kalsium & Magnesium dengan avatar bulat dan penjelasan naratif
class _MineralSection extends StatelessWidget {
  final String numberTitle;
  final IconData icon;
  final Color iconColor;
  final Color boxColor;
  final String description;
  final List<String> bulletItems;

  const _MineralSection({
    required this.numberTitle,
    required this.icon,
    required this.iconColor,
    required this.boxColor,
    required this.description,
    required this.bulletItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: boxColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              numberTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Color(0xFF475569),
          ),
        ),
        if (bulletItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...bulletItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5A124),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Card Tips edukasi penting ("Ingat!")
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3D0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Color(0xFFF59E0B),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingat!',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Konsumsi vitamin dan mineral yang sesuai kebutuhan dapat membantu menjaga kesehatan tulang dan sendi. Selalu konsultasikan dengan dokter atau ahli gizi untuk mendapatkan anjuran yang tepat.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF785535),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card Quote penutup motivasi
class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE0A1).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.format_quote_rounded,
            color: Color(0xFFF59E0B),
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            '“Nutrisi yang tepat hari ini, tulang dan sendi yang lebih sehat untuk masa depan.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B5E34),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Home indicator bar di bagian paling bawah
class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFF7C948).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}