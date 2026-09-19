import 'package:flutter/material.dart';
class NutrisiPage extends StatelessWidget {
  const NutrisiPage({super.key});

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
          'Makanan & Minuman',
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
              // 1. Hero Section / Banner Atas
              _HeroSection(),
              SizedBox(height: 18),

              // 2. Narasi Pembuka
              Text(
                'Makanan dan minuman yang kita konsumsi setiap hari memiliki peran yang sangat krusial dalam menentukan kepadatan dan kekuatan struktur tulang. Tulang merupakan organ hidup dinamis yang terus-menerus mengalami perombakan dan pembentukan kembali. Dengan memberikan asupan nutrisi makro dan mikro yang tepat secara konsisten, proses regenerasi sel tulang dapat berjalan optimal, memperlambat pengeroposan alami akibat penuaan, serta secara signifikan menurunkan risiko osteoporosis dan patah tulang di masa depan.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: Color(0xFF475569),
                ),
              ),
              SizedBox(height: 22),

              // 3. Section Narasi Pentingnya Nutrisi
              _ArticleSection(),
              SizedBox(height: 24),

              // 4. Subsection Cards Nutrisi & Makanan Rekomendasi
              _NutrientCard(
                icon: Icons.local_drink_rounded,
                iconColor: Color(0xFFE5A124),
                boxColor: Color(0xFFFFF8EC),
                title: 'Sumber Kalsium',
                description:
                    'Kalsium adalah blok pembangun utama dari kerangka tulang tubuh kita, di mana sekitar 99% kalsium tubuh tersimpan di dalam tulang dan gigi. Mengonsumsi makanan tinggi kalsium secara teratur sangat dianjurkan untuk mempertahankan densitas mineral tulang. Anda dapat memperoleh kalsium berkualitas tinggi dari susu rendah lemak, yogurt tanpa pemanis, dan keju. Bagi yang menjalani pola makan nabati atau intoleransi laktosa, sumber kalsium nabati yang luar biasa mencakup tahu, tempe, edamame, serta ikan teri dan sarden yang dikonsumsi bersama tulang halusnya. Pastikan membagi asupan kalsium sepanjang hari agar penyerapannya di usus berlangsung maksimal.',
              ),
              SizedBox(height: 16),

              _NutrientCard(
                icon: Icons.wb_sunny_rounded,
                iconColor: Color(0xFFF59E0B),
                boxColor: Color(0xFFFFFBEB),
                title: 'Sumber Vitamin D',
                description:
                    'Tanpa vitamin D yang cukup, tubuh hanya mampu menyerap sekitar 10–15% kalsium dari makanan yang dikonsumsi. Vitamin D berperan seperti kunci yang membuka gerbang penyerapan kalsium di dinding saluran cerna dan membantu mengendapkannya ke jaringan tulang. Selain paparan sinar matahari pagi yang memicu sintesis vitamin D alami di kulit, Anda dapat memenuhi kebutuhannya melalui konsumsi ikan berlemak sehat seperti salmon, makerel, dan tuna. Kuning telur dari ayam kampung, jamur yang terpapar sinar UV, serta produk susu atau jus nabati yang telah difortifikasi vitamin D juga merupakan pilihan harian yang sangat baik.',
              ),
              SizedBox(height: 16),

              _NutrientCard(
                icon: Icons.eco_rounded,
                iconColor: Color(0xFF10B981),
                boxColor: Color(0xFFF0FDF4),
                title: 'Sayuran dan Buah-buahan',
                description:
                    'Sayuran berdaun hijau gelap seperti bayam, brokoli, pokcoy, dan kale mengandung vitamin K yang sangat krusial dalam mengaktifkan osteokalsin—protein yang mengikat kalsium ke matriks tulang. Selain itu, buah-buahan segar seperti jeruk, kiwi, stroberi, dan pepaya kaya akan vitamin C yang dibutuhkan untuk pembentukan kolagen, yaitu jaringan serat lentur yang mencegah tulang menjadi terlalu getas. Kandungan kalium dan magnesium dalam buah dan sayur juga membantu menetralkan keasaman metabolik dalam darah, sehingga tubuh tidak perlu mengikis mineral kalsium dari tulang.',
              ),
              SizedBox(height: 16),

              _NutrientCard(
                icon: Icons.grain_rounded,
                iconColor: Color(0xFFB45309),
                boxColor: Color(0xFFFEF3C7),
                title: 'Kacang-kacangan dan Biji-bijian',
                description:
                    'Kacang-kacangan seperti almond, kenari, dan kacang merah serta biji-bijian seperti biji chia, wijen, dan biji labu adalah sumber mineral penunjang tulang yang kaya. Biji wijen dan chia khususnya memiliki konsentrasi kalsium nabati yang sangat tinggi. Selain itu, kacang-kacangan menyediakan magnesium dan fosfor yang bekerja sinergis dengan kalsium untuk memperkuat struktur kristal hidroksiapatit pada tulang. Menambahkan segenggam kacang panggang tanpa garam atau menaburkan biji-bijian ke dalam sereal pagi adalah langkah praktis yang memberikan proteksi jangka panjang bagi tulang.',
              ),
              SizedBox(height: 16),

              _NutrientCard(
                icon: Icons.water_drop_rounded,
                iconColor: Color(0xFF0284C7),
                boxColor: Color(0xFFF0F9FF),
                title: 'Minuman yang Disarankan',
                description:
                    'Air putih bersih tetap merupakan prioritas utama untuk menjaga hidrasi seluler dan memperlancar transportasi nutrisi ke seluruh jaringan muskuloskeletal. Selain air putih, susu sapi segar atau susu nabati fortifikasi (seperti susu kedelai atau susu almond) sangat disarankan untuk dikonsumsi setiap hari. Teh hijau tanpa gula juga terbukti mengandung senyawa polifenol dan epigallocatechin gallate (EGCG) yang memiliki sifat antioksidan kuat, mampu merangsang aktivitas osteoblas (sel pembentuk tulang) serta menghambat laju kerusakan sel tulang.',
              ),
              SizedBox(height: 16),

              _NutrientCard(
                icon: Icons.no_food_rounded,
                iconColor: Color(0xFFE11D48),
                boxColor: Color(0xFFFFF1F2),
                title: 'Makanan dan Minuman yang Sebaiknya Dibatasi',
                description:
                    'Beberapa jenis makanan dan minuman dapat mengganggu keseimbangan kalsium dan mempercepat ekskresi mineral penting melalui ginjal. Asupan natrium atau garam berlebih dari makanan olahan dan makanan cepat saji dapat menarik kalsium keluar bersama urine. Minuman bersoda yang mengandung asam fosfat tinggi berpotensi mengganggu rasio kalsium-fosfor dalam tubuh. Begitu pula dengan konsumsi alkohol berlebihan serta kafein dalam jumlah tinggi (lebih dari 3–4 cangkir kopi per hari) yang dapat menghambat penyerapan kalsium di usus serta melemahkan kepadatan tulang.',
              ),
              SizedBox(height: 22),

              // 5. Section Tips Pola Makan
              _TipsCard(),
              SizedBox(height: 16),

              // 6. Quote Penutup
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

/// Hero section di bagian atas dengan banner cream lembut dan ilustrasi
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
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pilihan Makanan & Minuman untuk Tulang Sehat',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nutrisi bergizi hari ini, pondasi tulang kokoh dan aktif hingga hari tua.',
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

          // Ilustrasi Hero Nutrisi
          Expanded(
            flex: 11,
            child: Image.asset(
              'assets/images/education/nutrition_hero.png',
              height: 155,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const _NutritionHeroIllustration();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Fallback ilustrasi vektor komposisi makanan & minuman bergizi
class _NutritionHeroIllustration extends StatelessWidget {
  const _NutritionHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Latar daun dan bentuk organik lembut
          CustomPaint(
            size: const Size(140, 145),
            painter: _NutritionBackdropPainter(),
          ),

          // Badge motivasi atas kanan
          Positioned(
            top: 4,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Gizi Seimbang\nUntuk Tulang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Icon(
                    Icons.favorite,
                    size: 10,
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),

          // Badge motivasi bawah kanan
          Positioned(
            bottom: 4,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 0.8,
                ),
              ),
              child: const Text(
                'Kaya Kalsium\n& Vitamin D',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF78350F),
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Daun hijau lembut di latar belakang
    final leafPaint = Paint()
      ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.52),
        width: 100,
        height: 105,
      ),
      leafPaint,
    );

    // Lingkaran kuning mentega lembut
    final sunCircle = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.46),
      36,
      sunCircle,
    );

    final double cx = size.width * 0.42;
    final double cy = size.height * 0.46;

    // 1. Gelas Susu
    final glassFill = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.fill;
    final glassStroke = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final glassPath = Path();
    glassPath.moveTo(cx - 24, cy - 8);
    glassPath.lineTo(cx - 10, cy - 8);
    glassPath.lineTo(cx - 12, cy + 18);
    glassPath.lineTo(cx - 22, cy + 18);
    glassPath.close();

    canvas.drawPath(glassPath, glassFill);
    canvas.drawPath(glassPath, glassStroke);

    // Sedotan oranye
    final strawPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 14, cy - 18), Offset(cx - 17, cy), strawPaint);

    // 2. Irisan Keju
    final cheeseFill = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    final cheeseStroke = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final cheesePath = Path();
    cheesePath.moveTo(cx - 10, cy + 18);
    cheesePath.lineTo(cx + 10, cy + 6);
    cheesePath.lineTo(cx + 12, cy + 20);
    cheesePath.lineTo(cx - 10, cy + 20);
    cheesePath.close();

    canvas.drawPath(cheesePath, cheeseFill);
    canvas.drawPath(cheesePath, cheeseStroke);

    final holePaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(Offset(cx - 1, cy + 14), 1.6, holePaint);
    canvas.drawCircle(Offset(cx + 5, cy + 16), 1.4, holePaint);

    // 3. Brokoli / Sayuran Hijau
    final brocPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(cx + 16, cy + 2), 6.5, brocPaint);
    canvas.drawCircle(Offset(cx + 22, cy - 2), 5.5, brocPaint);
    canvas.drawCircle(Offset(cx + 23, cy + 7), 5.0, brocPaint);

    final stemPaint = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 18, cy + 6), Offset(cx + 15, cy + 18), stemPaint);

    // 4. Irisan Buah Jeruk / Ikan
    final orangePaint = Paint()..color = const Color(0xFFF97316);
    canvas.drawCircle(Offset(cx + 4, cy - 10), 7, orangePaint);
    final orangeInner = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawCircle(Offset(cx + 4, cy - 10), 4.5, orangeInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Section artikel penjelasan mengapa nutrisi tulang sangat penting
class _ArticleSection extends StatelessWidget {
  const _ArticleSection();

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
            const Text(
              'Mengapa Nutrisi Tulang Sangat Penting?',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Kepadatan massa tulang mencapai puncaknya pada usia sekitar 20 hingga 30 tahun. Setelah melewati fase tersebut, laju perombakan kalsium oleh tubuh mulai melampaui laju pembentukan tulang baru. Apabila asupan nutrisi harian tidak mencukupi, tubuh terpaksa mengambil cadangan kalsium langsung dari matriks tulang demi mempertahankan fungsi saraf dan detak jantung yang normal.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Oleh karena itu, memenuhi kebutuhan nutrisi esensial bukan hanya penting bagi anak-anak dan remaja dalam masa pertumbuhan, melainkan juga investasi vital bagi orang dewasa dan lansia agar tulang tetap padat, lentur, serta terlindung dari risiko kerapuhan saat beraktivitas sehari-hari.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

/// Card narasi artikel untuk setiap subtopik makanan dan minuman bergizi
class _NutrientCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color boxColor;
  final String title;
  final String description;

  const _NutrientCard({
    required this.icon,
    required this.iconColor,
    required this.boxColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.7),
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
          // Header card: icon bulat lembut + judul tebal
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Paragraf narasi artikel panjang
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card Tips pola makan bergizi untuk kesehatan tulang
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Icons.lightbulb_rounded,
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
                  'Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Terapkan pola makan yang bervariasi dengan porsi seimbang antara sumber kalsium, protein berkualitas, sayuran kaya serat, dan hidrasi yang cukup setiap hari. Hindari diet ekstrem yang membatasi kelompok makanan secara berlebihan karena dapat mengorbankan kepadatan massa tulang. Apabila memiliki kondisi medis khusus, intoleransi laktosa, atau telah memasuki masa menopause, konsultasikan dengan dokter atau ahli gizi untuk mengevaluasi apakah suplementasi kalsium dan vitamin D tambahan diperlukan.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
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

/// Card Quote penutup motivasi nutrisi tulang
class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFDE0A1).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: const Text(
        '“Gizi seimbang yang kita santap hari ini adalah investasi kekuatan tulang untuk melangkah bebas di hari tua.”',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.5,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B5E34),
          height: 1.4,
        ),
      ),
    );
  }
}

/// Home indicator pill di bagian paling bawah
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
 