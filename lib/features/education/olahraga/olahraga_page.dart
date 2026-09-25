import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OlahragaPage extends StatelessWidget {
  const OlahragaPage({super.key});

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
          'Olahraga',
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
            children: [
              // 1. Hero Section
              const _HeroSection(),
              const SizedBox(height: 18),

              // 2. Narasi pembuka tentang manfaat olahraga
              const Text(
                'Olahraga merupakan salah satu cara terbaik untuk menjaga kesehatan tulang sepanjang hidup. Aktivitas fisik yang dilakukan secara rutin dapat membantu meningkatkan kepadatan tulang, memperkuat otot, menjaga keseimbangan tubuh, serta menurunkan risiko osteoporosis dan patah tulang. Selain itu, olahraga juga membantu tubuh tetap bugar, meningkatkan suasana hati, dan mendukung kesehatan jantung serta metabolisme secara keseluruhan.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 22),

              // 3. Section "Mengapa Olahraga Penting?"
              const _InfoSection(),
              const SizedBox(height: 22),

              // 4. Section "Rekomendasi Mingguan"
              const _RecommendationCard(),
              const SizedBox(height: 24),

              // 5. Section "Jenis Olahraga yang Direkomendasikan"
              _buildSectionTitle('Jenis Olahraga yang Direkomendasikan'),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_walking.png',
                fallbackIllustration: _WalkingIllustration(),
                title: 'Jalan Kaki',
                description:
                    'Jalan kaki adalah olahraga sederhana yang efektif untuk menjaga kesehatan tulang. Aktivitas ini termasuk latihan menahan beban pada tulang kaki, membantu meningkatkan kepadatan tulang, memperkuat otot, serta menjaga kesehatan jantung. Jalan kaki dapat dilakukan oleh semua usia dan mudah disesuaikan dengan kemampuan tubuh.',
              ),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_dumbbell.png',
                fallbackIllustration: _DumbbellIllustration(),
                title: 'Angkat Beban Ringan',
                description:
                    'Latihan angkat beban ringan seperti dumbbell, resistance band, atau alat di gym dapat merangsang pembentukan tulang baru, meningkatkan kekuatan otot, dan memperbaiki postur tubuh. Latihan ini membantu menjaga massa otot yang seiring bertambahnya usia dapat menurun.',
              ),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_yoga.png',
                fallbackIllustration: _YogaIllustration(),
                title: 'Yoga',
                description:
                    'Yoga menggabungkan gerakan tubuh, pernapasan, dan meditasi yang dapat meningkatkan fleksibilitas, keseimbangan, serta kekuatan otot. Latihan ini juga membantu memperbaiki postur tubuh, mengurangi stres, dan meningkatkan kesadaran tubuh, sehingga baik untuk kesehatan tulang dan kesehatan mental.',
              ),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_tennis.png',
                fallbackIllustration: _TennisIllustration(),
                title: 'Tenis',
                description:
                    'Tenis dan olahraga raket lainnya memicu beban dinamis dan gerakan cepat ke berbagai arah yang sangat baik untuk memicu pembentukan kepadatan mineral tulang, terutama pada lengan, pergelangan tangan, pinggul, dan tulang belakang.',
              ),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_balance.png',
                fallbackIllustration: _BalanceIllustration(),
                title: 'Latihan Keseimbangan',
                description:
                    'Latihan keseimbangan seperti berdiri dengan satu kaki, tai chi, atau gerakan sederhana lainnya dapat membantu meningkatkan stabilitas tubuh dan mengurangi risiko jatuh, terutama pada usia lanjut.',
              ),
              const SizedBox(height: 16),

              const _ExerciseCard(
                assetPath: 'assets/images/education/exercise_stretching.png',
                fallbackIllustration: _StretchingIllustration(),
                title: 'Peregangan',
                description:
                    'Peregangan membantu menjaga kelenturan otot dan sendi, mengurangi kekakuan, serta meningkatkan rentang gerak tubuh. Lakukan peregangan setelah berolahraga atau setelah aktivitas sehari-hari.',
              ),
              const SizedBox(height: 22),

              // 6. Rekomendasi Video Olahraga
              const _VideoRekomendasi(),
              const SizedBox(height: 22),

              // 7. Tips Olahraga Aman ("Ingat!")
              const _TipsCard(),
              const SizedBox(height: 16),

              // 7. Quote Penutup
              const _QuoteCard(),
              const SizedBox(height: 14),

              // Garis home indicator halus di bagian paling bawah
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7C948).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SECTION REKOMENDASI VIDEO OLAHRAGA
// =============================================================================

/// Section card video YouTube rekomendasi olahraga untuk tulang
class _VideoRekomendasi extends StatelessWidget {
  const _VideoRekomendasi();

  static const String _videoUrl =
      'https://youtu.be/YiA_n0q18LA?si=pM-L8GgM2hOOL4xw';
  static const String _thumbnailUrl =
      'https://img.youtube.com/vi/YiA_n0q18LA/hqdefault.jpg';

  Future<void> _openYoutube() async {
    final uri = Uri.parse(_videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Judul Section ---
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
              'Rekomendasi Video Olahraga',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            'Pencegahan Osteoporosis yang Bisa Anda Coba',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // --- Card Video ---
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5A124).withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            onTap: _openYoutube,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Thumbnail (65%) ---
                  Expanded(
                    flex: 65,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFFEF3C7),
                                child: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 36,
                                  color: Color(0xFFF7C948),
                                ),
                              ),
                            ),
                          ),
                          // Overlay gelap halus
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.18),
                            ),
                          ),
                          // Tombol Play YouTube di tengah
                          Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 28,
                                color: Color(0xFFFF0000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // --- Info Video (35%) ---
                  Expanded(
                    flex: 35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olahraga Mudah untuk Tulang Lebih Kuat',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Panduan latihan sederhana yang dapat dilakukan di rumah untuk membantu menjaga kesehatan tulang dan mencegah osteoporosis.',
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tombol Tonton di YouTube
                        GestureDetector(
                          onTap: _openYoutube,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7C948),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF7C948)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.smart_display_rounded,
                                  size: 13,
                                  color: Color(0xFF1E293B),
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Tonton di YouTube',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 11,
                                  color: Color(0xFF1E293B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hero section di bagian atas dengan thumbnail video latihan dan tombol putar ala jeda video
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  static const String _youtubeUrl =
      'https://youtu.be/8ZOY99SHjjA?si=GEewB-CrZK0r2B1q';
  static const String _thumbnailNetworkUrl =
      'https://img.youtube.com/vi/8ZOY99SHjjA/maxresdefault.jpg';
  static const String _thumbnailAssetPath =
      'assets/images/exercise_hero_thumbnail.jpg';

  Future<void> _openYoutube() async {
    final uri = Uri.parse(_youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A124).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openYoutube,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gambar Thumbnail Utama
                ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Image.asset(
                    _thumbnailAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      _thumbnailNetworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _HeroIllustration(),
                    ),
                  ),
                ),

                // Lapisan Overlay Redup Lembut ala Video Player
                ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.22),
                  ),
                ),

                // Tombol di Tengah ala Jeda / Pemutar Video
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.5),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Badge Indikator "Tonton Video" di Sudut Kanan Bawah
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.smart_display_rounded,
                          size: 13,
                          color: Color(0xFFFF0000),
                        ),
                        SizedBox(width: 4.5),
                        Text(
                          'Tonton Video',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback ilustrasi hero (orang berolahraga dengan dumbbell & badge)
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Latar daun / bentuk organik lembut
          CustomPaint(
            size: const Size(140, 150),
            painter: _HeroBackdropPainter(),
          ),

          // Badge motivasi atas kanan
          Positioned(
            top: 6,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
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
                    'Sehat\nBergerak\nLebih Kuat',
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
            bottom: 6,
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
                'Tulang kuat,\nhidup lebih\nberkualitas',
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

class _HeroBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Daun / bentuk organik hijau lembut di belakang
    final leafPaint = Paint()
      ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.55),
        width: 100,
        height: 110,
      ),
      leafPaint,
    );

    // Bentuk lingkaran cream cerah
    final circlePaint = Paint()
      ..color = const Color(0xFFFEF3C7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      38,
      circlePaint,
    );

    // Siluet orang berolahraga dengan dumbbell
    final double cx = size.width * 0.45;
    final double cy = size.height * 0.42;

    // Kepala & rambut kuncir
    final hairPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawCircle(Offset(cx, cy - 20), 10, hairPaint);
    // Kuncir kuda
    canvas.drawCircle(Offset(cx + 9, cy - 25), 6, hairPaint);

    // Wajah
    final facePaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawCircle(Offset(cx, cy - 18), 8, facePaint);

    // Baju kuning cerah
    final shirtPaint = Paint()..color = const Color(0xFFFBBF24);
    final shirtPath = Path();
    shirtPath.moveTo(cx - 10, cy - 8);
    shirtPath.lineTo(cx + 10, cy - 8);
    shirtPath.lineTo(cx + 8, cy + 14);
    shirtPath.lineTo(cx - 8, cy + 14);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Celana olahraga navy
    final pantsPaint = Paint()..color = const Color(0xFF1E293B);
    final pantsPath = Path();
    pantsPath.moveTo(cx - 8, cy + 14);
    pantsPath.lineTo(cx + 8, cy + 14);
    pantsPath.lineTo(cx + 16, cy + 40);
    pantsPath.lineTo(cx + 8, cy + 40);
    pantsPath.lineTo(cx, cy + 22);
    pantsPath.lineTo(cx - 8, cy + 40);
    pantsPath.lineTo(cx - 16, cy + 40);
    pantsPath.close();
    canvas.drawPath(pantsPath, pantsPaint);

    // Lengan terangkat memegang dumbbell
    final armPaint = Paint()
      ..color = const Color(0xFFFED7AA)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Lengan kiri
    canvas.drawLine(Offset(cx - 8, cy - 4), Offset(cx - 18, cy - 14), armPaint);
    // Lengan kanan
    canvas.drawLine(Offset(cx + 8, cy - 4), Offset(cx + 18, cy - 14), armPaint);

    // Dumbbell di tangan kiri
    final dumbbellPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 18, cy - 16), width: 12, height: 6),
        const Radius.circular(2),
      ),
      dumbbellPaint,
    );
    // Dumbbell di tangan kanan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 18, cy - 16), width: 12, height: 6),
        const Radius.circular(2),
      ),
      dumbbellPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Section "Mengapa Olahraga Penting?"
class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OlahragaPage._buildSectionTitle('Mengapa Olahraga Penting?'),
        const SizedBox(height: 10),
        const Text(
          'Tulang adalah jaringan hidup yang terus mengalami proses pembentukan dan penguraian. Seiring bertambahnya usia, terutama setelah usia 30 tahun, massa tulang mulai menurun. Pada kondisi tertentu seperti menopause, penurunan hormon dapat mempercepat proses kehilangan massa tulang dan meningkatkan risiko osteoporosis.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Olahraga, khususnya latihan dengan beban dan aktivitas fisik yang melibatkan gerakan tubuh, dapat merangsang pembentukan tulang baru. Selain itu, olahraga membantu memperkuat otot dan sendi, meningkatkan keseimbangan, serta mengurangi risiko jatuh yang dapat menyebabkan patah tulang. Dengan tubuh yang lebih kuat dan stabil, Anda dapat tetap aktif dan mandiri dalam menjalani aktivitas sehari-hari.',
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

/// Section "Rekomendasi Mingguan"
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OlahragaPage._buildSectionTitle('Rekomendasi Mingguan'),
        const SizedBox(height: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF475569),
            ),
            children: [
              TextSpan(
                text:
                    'Untuk mendapatkan manfaat yang optimal, olahraga dianjurkan dilakukan ',
              ),
              TextSpan(
                text: '3–5 kali dalam seminggu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextSpan(
                text: ' dengan durasi sekitar ',
              ),
              TextSpan(
                text: '30 menit setiap sesi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextSpan(
                text:
                    '. Bagi pemula atau saat baru memulai, Anda bisa melakukan olahraga dengan intensitas ringan sebanyak ',
              ),
              TextSpan(
                text: '2–3 kali per minggu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextSpan(
                text:
                    ', lalu meningkatkannya secara bertahap sesuai dengan kemampuan dan kondisi tubuh.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Pilih waktu yang nyaman, gunakan pakaian dan alas kaki yang sesuai, serta lakukan pemanasan sebelum memulai dan pendinginan setelah selesai berolahraga. Konsistensi lebih penting daripada intensitas yang berlebihan.',
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

/// Card narasi jenis olahraga yang direkomendasikan
class _ExerciseCard extends StatelessWidget {
  final String assetPath;
  final Widget fallbackIllustration;
  final String title;
  final String description;

  const _ExerciseCard({
    required this.assetPath,
    required this.fallbackIllustration,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lingkaran ilustrasi olahraga
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EC),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              assetPath,
              width: 42,
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: fallbackIllustration);
              },
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Judul & narasi artikel panjang olahraga
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card Tips Olahraga Aman ("Ingat!")
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
                  'Ingat!',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pilih olahraga yang Anda sukai dan sesuai dengan kondisi tubuh. Jika memiliki keluhan nyeri, riwayat cedera, atau penyakit tertentu, sebaiknya konsultasikan terlebih dahulu dengan dokter sebelum memulai rutinitas olahraga baru.',
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

/// Card Quote penutup motivasi olahraga
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
        '“Gerak hari ini, tulang yang lebih kuat untuk esok nanti.”',
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

// ---------------------------------------------------------------------------
// Fallback Ilustrasi Vektor untuk Tiap Jenis Olahraga
// ---------------------------------------------------------------------------

/// Fallback ilustrasi Jalan Kaki
class _WalkingIllustration extends StatelessWidget {
  const _WalkingIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _WalkingPainter(),
    );
  }
}

class _WalkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;
    const double cy = 18.0;

    // Kepala
    final headPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(cx, cy - 11), 3.5, headPaint);

    // Baju kuning/oranye
    final shirtPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx, cy - 8), const Offset(cx, cy + 1), shirtPaint);

    // Kaki berjalan
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Kaki kiri ke depan
    canvas.drawLine(const Offset(cx, cy + 1), const Offset(cx - 7, cy + 11), legPaint);
    // Kaki kanan ke belakang
    canvas.drawLine(const Offset(cx, cy + 1), const Offset(cx + 6, cy + 10), legPaint);

    // Lengan mengayun
    final armPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(cx, cy - 6), const Offset(cx + 5, cy), armPaint);
    canvas.drawLine(const Offset(cx, cy - 6), const Offset(cx - 5, cy - 2), armPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi Angkat Beban (Dumbbell)
class _DumbbellIllustration extends StatelessWidget {
  const _DumbbellIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _DumbbellPainter(),
    );
  }
}

class _DumbbellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;
    const double cy = 18.0;

    final barPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Batang tengah dumbbell
    canvas.drawLine(const Offset(cx - 9, cy), const Offset(cx + 9, cy), barPaint);

    final weightPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    // Beban kiri
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(cx - 13, cy - 8, 4.5, 16),
        const Radius.circular(2),
      ),
      weightPaint,
    );
    // Beban kanan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(cx + 8.5, cy - 8, 4.5, 16),
        const Radius.circular(2),
      ),
      weightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi Yoga (pose namaste/meditasi)
class _YogaIllustration extends StatelessWidget {
  const _YogaIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _YogaPainter(),
    );
  }
}

class _YogaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;
    const double cy = 18.0;

    // Kepala & rambut
    final headPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(cx, cy - 9), 3.8, headPaint);

    // Badan atas (baju oranye/amber)
    final bodyPaint = Paint()..color = const Color(0xFFF59E0B);
    final bodyPath = Path();
    bodyPath.moveTo(cx - 4, cy - 4);
    bodyPath.lineTo(cx + 4, cy - 4);
    bodyPath.lineTo(cx + 3, cy + 4);
    bodyPath.lineTo(cx - 3, cy + 4);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Lengan posisi namaste di depan dada
    final armPaint = Paint()
      ..color = const Color(0xFFFED7AA)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(cx - 4, cy - 3), const Offset(cx, cy - 1), armPaint);
    canvas.drawLine(const Offset(cx + 4, cy - 3), const Offset(cx, cy - 1), armPaint);

    // Kaki bersila di bawah
    final legsPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final legPath = Path();
    legPath.moveTo(cx - 10, cy + 9);
    legPath.lineTo(cx, cy + 5);
    legPath.lineTo(cx + 10, cy + 9);
    canvas.drawPath(legPath, legsPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi Tenis (raket & bola)
class _TennisIllustration extends StatelessWidget {
  const _TennisIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _TennisPainter(),
    );
  }
}

class _TennisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Kepala raket tenis
    final racketPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      const Rect.fromLTWH(10, 6, 12, 16),
      racketPaint,
    );

    // Senar raket halus
    final stringPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(16, 6), const Offset(16, 22), stringPaint);
    canvas.drawLine(const Offset(10, 14), const Offset(22, 14), stringPaint);

    // Gagang raket
    final handlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(16, 22), const Offset(16, 30), handlePaint);

    // Bola tenis hijau neon
    final ballPaint = Paint()
      ..color = const Color(0xFF84CC16)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(25, 12), 3.5, ballPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi Latihan Keseimbangan (berdiri satu kaki)
class _BalanceIllustration extends StatelessWidget {
  const _BalanceIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _BalancePainter(),
    );
  }
}

class _BalancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;
    const double cy = 18.0;

    // Kepala
    final headPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(cx, cy - 11), 3.5, headPaint);

    // Badan tegak
    final bodyPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx, cy - 8), const Offset(cx, cy + 2), bodyPaint);

    // Kedua lengan terentang lurus untuk keseimbangan
    final armPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx - 11, cy - 4), const Offset(cx + 11, cy - 4), armPaint);

    // Kaki kiri menopang lurus
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx, cy + 2), const Offset(cx, cy + 12), legPaint);

    // Kaki kanan ditekuk (pose pohon / satu kaki)
    final bendLegPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx, cy + 2), const Offset(cx + 6, cy + 6), bendLegPaint);
    canvas.drawLine(const Offset(cx + 6, cy + 6), const Offset(cx + 1, cy + 7), bendLegPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi Peregangan (stretching samping)
class _StretchingIllustration extends StatelessWidget {
  const _StretchingIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _StretchingPainter(),
    );
  }
}

class _StretchingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 18.0;
    const double cy = 18.0;

    // Kepala agak miring
    final headPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(const Offset(cx + 2, cy - 11), 3.5, headPaint);

    // Badan melengkung ke kanan (peregangan samping)
    final bodyPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spinePath = Path();
    spinePath.moveTo(cx, cy + 2);
    spinePath.quadraticBezierTo(cx - 1, cy - 4, cx + 2, cy - 8);
    canvas.drawPath(spinePath, bodyPaint);

    // Lengan kanan melengkung ke atas kepala
    final armPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final armPath = Path();
    armPath.moveTo(cx + 2, cy - 6);
    armPath.quadraticBezierTo(cx - 2, cy - 14, cx - 7, cy - 12);
    canvas.drawPath(armPath, armPaint);

    // Kaki terbuka menopang
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(cx, cy + 2), const Offset(cx - 6, cy + 12), legPaint);
    canvas.drawLine(const Offset(cx, cy + 2), const Offset(cx + 6, cy + 12), legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
