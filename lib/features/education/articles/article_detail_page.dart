import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'article_model.dart';

/// Halaman detail artikel yang memenuhi seluruh layar ponsel Android (responsif)
/// dan mereplikasi desain visual dari screenshot referensi secara presisi.
class ArticleDetailPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailPage({
    super.key,
    required this.article,
  });

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Abaikan error jika url tidak bisa dibuka
    }
  }

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
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          article.appBarTitle,
          style: const TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gambar Utama / Hero Banner
              _buildHeroBanner(context),
              const SizedBox(height: 22),

              // 2. Daftar Seksi Konten Artikel
              ...article.sections.map((section) => _buildSection(context, section)),

              // 3. Tautan Sumber Eksternal di Bagian Bawah
              _buildExternalSourceFooter(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner gambar utama yang responsif terhadap lebar layar perangkat
  /// Banner gambar utama yang responsif terhadap lebar layar perangkat.
  /// Menampilkan ilustrasi statis proporsional dengan BoxFit.cover tanpa tombol play.
  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            article.heroAssetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.network(
              article.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFFFFBEB),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Color(0xFFE5A124),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Menampilkan satu bab / section bernomor dengan garis kuning aksen
  Widget _buildSection(BuildContext context, ArticleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Judul dengan Garis Kuning Aksen
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4.5,
                height: 19,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B), // Kuning aksen
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${section.number}.  ${section.title}',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Paragraf-paragraf penjelasan, subjudul, dan daftar bernomor
          ...section.paragraphs.map((p) => _buildParagraphOrItem(context, p)),

          // Kartu Informasi Tambahan (Faktor Risiko, Alert Gejala, dll)
          ...section.infoCards.map((card) => _buildInfoCard(context, card)),

          // Bagian Konsultasi Dokter (Seksi 5)
          if (section.doctorConsultation != null)
            _buildDoctorConsultationBox(context, section.doctorConsultation!),

          // Bagian Diagnosis & Tabel T-score (Seksi 6)
          if (section.diagnosisBox != null)
            _buildDiagnosisBox(context, section.diagnosisBox!),
        ],
      ),
    );
  }

  /// Merender paragraf, subjudul (jika diawali "### "), atau item daftar bernomor
  Widget _buildParagraphOrItem(BuildContext context, String p) {
    // 1. Subheading / Subjudul (diawali "### ")
    if (p.startsWith('### ')) {
      final subtitle = p.replaceFirst('### ', '');
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 3.5,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Item Daftar Bernomor (misal "1.  Tinggi badan berkurang.")
    final numberMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(p);
    if (numberMatch != null) {
      final numStr = numberMatch.group(1)!;
      final textStr = numberMatch.group(2)!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 10, top: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  numStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00796B),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                textStr,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Paragraf teks biasa
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        p,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  /// Kartu info berlatar kuning/krim atau alert bahaya dengan bullet list
  Widget _buildInfoCard(BuildContext context, ArticleInfoCard card) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card.isAlert ? const Color(0xFFFFFBEB) : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu dengan Ikon & Judul
          if (card.icon != null || card.title != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (card.icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: card.iconBgColor ?? const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        card.icon,
                        size: 19,
                        color: card.iconColor ?? const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (card.title != null)
                  Expanded(
                    child: Text(
                      card.title!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
              ],
            ),

          // Deskripsi singkat di dalam kartu
          if (card.description != null) ...[
            const SizedBox(height: 8),
            Text(
              card.description!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF1E293B),
              ),
            ),
          ],

          if (card.bulletPoints.isNotEmpty) const SizedBox(height: 10),

          // Jika kartu adalah Alert Gejala (tampilan khas screenshot dengan ikon segitiga kuning)
          if (card.isAlert && card.title == null && card.icon == Icons.warning_amber_rounded)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 28,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: card.bulletPoints
                        .map(
                          (bp) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 8),
                                  child: Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    bp,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            )
          else
            // Bullet points reguler dengan dot kuning
            ...card.bulletPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(
                        Icons.circle,
                        size: 5.5,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFF1E293B),
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

  /// Kotak Konsultasi Dokter dengan Ikon Stetoskop (Seksi 5)
  Widget _buildDoctorConsultationBox(
    BuildContext context,
    ArticleDoctorConsultation doc,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Stetoskop Medis
          CustomPaint(
            size: const Size(36, 42),
            painter: const _StethoscopePainter(color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 14),

          // Teks penjelasan dengan teks sumber berwarna kuning aksen yang dapat diklik
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF1E293B),
                ),
                children: [
                  TextSpan(
                    text: doc.text.replaceAll(
                      'Chat Bersama Dokter atau booking dokter di aplikasi ${doc.highlightedSource}.',
                      '',
                    ),
                  ),
                  const TextSpan(text: 'Bila keluhan ringan mengarah pada osteoporosis, jangan tunda berkonsultasi ke dokter melalui '),
                  TextSpan(
                    text: 'Chat Bersama Dokter',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const TextSpan(text: ' atau '),
                  TextSpan(
                    text: 'booking',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const TextSpan(text: ' dokter di aplikasi '),
                  TextSpan(
                    text: '${doc.highlightedSource}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
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

  /// Kotak Diagnosis dengan Ikon Kaca Pembesar & Dua Card (Pemeriksaan & Tabel T-score)
  Widget _buildDiagnosisBox(BuildContext context, ArticleDiagnosisBox box) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Pengantar dengan Ikon Kaca Pembesar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.search_rounded,
                size: 26,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                box.introText,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Dua kartu: Pemeriksaan Penunjang (Kiri) dan Interpretasi T-Score (Kanan)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 540;

            final leftCard = Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: box.procedures
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5, right: 6),
                              child: Icon(
                                Icons.circle,
                                size: 5,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Color(0xFF1E293B),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${item.name} ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: item.description,
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );

            final rightCard = Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interpretasi T-score (DXA):',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...box.tScores.map(
                    (ts) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 5,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 74,
                            child: Text(
                              ts.scoreRange,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          const Text(
                            ': ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ts.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ts.status == 'Normal'
                                    ? const Color(0xFF16A34A)
                                    : (ts.status.contains('Osteopenia')
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFFDC2626)),
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

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: leftCard),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: rightCard),
                ],
              );
            } else {
              return Column(
                children: [
                  leftCard,
                  const SizedBox(height: 10),
                  rightCard,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  /// Bagian Footer untuk membuka tautan sumber artikel eksternal
  Widget _buildExternalSourceFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: article.sourceColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    article.sourceInitial,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: article.sourceColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sumber Resmi: ${article.source}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Materi di atas dirangkum dari publikasi kesehatan resmi untuk memberikan edukasi terpercaya seputar pencegahan dan penanganan osteoporosis.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),

          // Tautan URL Sumber Berwarna Kuning dan tetap bisa diklik
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchExternalUrl(article.url),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        article.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF59E0B),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tombol Buka Website Eksternal berwarna kuning dan tetap bisa diklik
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchExternalUrl(article.url),
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF1E293B)),
              label: Text(
                article.sourceActionLabel,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF1E293B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk menggambar stetoskop medis yang presisi
class _StethoscopePainter extends CustomPainter {
  final Color color;
  const _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Earpieces (ujung telinga)
    canvas.drawCircle(Offset(w * 0.22, h * 0.12), 2.2, fillPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.12), 2.2, fillPaint);

    // Tabung binaural atas
    final path = Path();
    path.moveTo(w * 0.22, h * 0.14);
    path.cubicTo(w * 0.22, h * 0.40, w * 0.48, h * 0.43, w * 0.50, h * 0.46);
    path.moveTo(w * 0.78, h * 0.14);
    path.cubicTo(w * 0.78, h * 0.40, w * 0.52, h * 0.43, w * 0.50, h * 0.46);

    // Selang bawah berbelok ke chestpiece
    path.lineTo(w * 0.50, h * 0.64);
    path.cubicTo(w * 0.50, h * 0.94, w * 0.82, h * 0.94, w * 0.82, h * 0.72);

    canvas.drawPath(path, strokePaint);

    // Chestpiece (diafragma stetoskop)
    canvas.drawCircle(Offset(w * 0.82, h * 0.67), 4.5, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      oldDelegate.color != color;
}
