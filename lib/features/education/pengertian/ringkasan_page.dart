import 'package:flutter/material.dart';

class RingkasanPage extends StatelessWidget {
  const RingkasanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // 1. Judul "Apa itu Osteoporosis?"
            Text(
              'Apa itu Osteoporosis?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2432),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 12),

            // 2. Paragraf penjelasan
            Text(
              'Osteoporosis adalah kondisi ketika kepadatan dan kualitas tulang menurun, sehingga tulang menjadi rapuh dan lebih mudah mengalami patah tulang, bahkan akibat benturan ringan.',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 20),

            // 3. Card ilustrasi tulang sehat vs osteoporosis
            _BoneCard(),
            SizedBox(height: 16),

            // 4. Card fakta penting
            _FactCard(),
            SizedBox(height: 24),

            // 5. Section "Mengapa Perlu Diketahui?"
            Text(
              'Mengapa Perlu Diketahui?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2432),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Dengan memahami osteoporosis sejak dini, kita dapat melakukan langkah pencegahan dan menjaga kualitas melakukan langkah pencegahan dan menjaga kualitas hidup di masa depan.',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 20),

            // 6. Quote card di bawah
            _QuoteCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Card ilustrasi perbandingan tulang sehat dan tulang osteoporosis
class _BoneCard extends StatelessWidget {
  const _BoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildBoneImage(
                  assetPath: 'assets/images/education/bone_healthy.png',
                  isOsteoporosis: false,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tulang Sehat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2432),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildBoneImage(
                  assetPath: 'assets/images/education/bone_osteoporosis.png',
                  isOsteoporosis: true,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tulang dengan\nOsteoporosis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2432),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoneImage({
    required String assetPath,
    required bool isOsteoporosis,
  }) {
    return SizedBox(
      height: 140,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _BoneIllustration(isOsteoporosis: isOsteoporosis);
        },
      ),
    );
  }
}

/// Fallback ilustrasi vektor tulang dan kaca pembesar struktur pori tulang
class _BoneIllustration extends StatelessWidget {
  final bool isOsteoporosis;

  const _BoneIllustration({required this.isOsteoporosis});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(100, 140),
        painter: _BonePainter(isOsteoporosis: isOsteoporosis),
      ),
    );
  }
}

class _BonePainter extends CustomPainter {
  final bool isOsteoporosis;

  _BonePainter({required this.isOsteoporosis});

  @override
  void paint(Canvas canvas, Size size) {
    const double boneCenterX = 34.0;

    // Bentuk tulang utama
    final path = Path();
    path.moveTo(boneCenterX - 18, 18);
    path.cubicTo(boneCenterX - 18, 6, boneCenterX - 5, 5, boneCenterX, 9);
    path.cubicTo(boneCenterX + 5, 5, boneCenterX + 18, 6, boneCenterX + 18, 18);
    path.cubicTo(boneCenterX + 14, 28, boneCenterX + 10, 36, boneCenterX + 9, 50);
    path.lineTo(boneCenterX + 9, 88);
    path.cubicTo(boneCenterX + 10, 102, boneCenterX + 16, 108, boneCenterX + 16, 120);
    path.cubicTo(boneCenterX + 16, 131, boneCenterX + 5, 133, boneCenterX, 129);
    path.cubicTo(boneCenterX - 5, 133, boneCenterX - 16, 131, boneCenterX - 16, 120);
    path.cubicTo(boneCenterX - 16, 108, boneCenterX - 10, 102, boneCenterX - 9, 88);
    path.lineTo(boneCenterX - 9, 50);
    path.cubicTo(boneCenterX - 10, 36, boneCenterX - 14, 28, boneCenterX - 18, 18);
    path.close();

    // Warna dasar tulang
    final boneFillPaint = Paint()
      ..color = const Color(0xFFF1E4CB)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, boneFillPaint);

    // Outline tulang
    final boneStrokePaint = Paint()
      ..color = const Color(0xFFD4A968)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, boneStrokePaint);

    // Tekstur rongga tulang di dalam
    canvas.save();
    canvas.clipPath(path);

    final porePaint = Paint()
      ..color = const Color(0xFF9E7B45).withValues(alpha: isOsteoporosis ? 0.75 : 0.45)
      ..style = PaintingStyle.fill;

    if (isOsteoporosis) {
      // Pori-pori besar dan jarang untuk osteoporosis
      const osteoPores = [
        Offset(boneCenterX - 4, 18),
        Offset(boneCenterX + 6, 22),
        Offset(boneCenterX - 2, 34),
        Offset(boneCenterX + 3, 48),
        Offset(boneCenterX - 3, 62),
        Offset(boneCenterX + 2, 76),
        Offset(boneCenterX - 4, 90),
        Offset(boneCenterX + 5, 104),
        Offset(boneCenterX - 3, 116),
        Offset(boneCenterX + 7, 122),
        Offset(boneCenterX - 1, 100),
        Offset(boneCenterX + 1, 38),
      ];
      for (int i = 0; i < osteoPores.length; i++) {
        final p = osteoPores[i];
        final radius = (i % 3 == 0) ? 3.5 : ((i % 2 == 0) ? 2.8 : 2.2);
        canvas.drawCircle(p, radius, porePaint);
      }
    } else {
      // Pori-pori halus dan padat untuk tulang sehat
      for (double y = 14; y <= 124; y += 7) {
        for (double x = boneCenterX - 12; x <= boneCenterX + 12; x += 5.5) {
          final offset = Offset(x + ((y.toInt() % 2 == 0) ? 2.5 : 0), y);
          canvas.drawCircle(offset, 1.2, porePaint);
        }
      }
    }
    canvas.restore();

    // Kaca pembesar / Zoom lingkaran struktur tulang
    const double lensX = boneCenterX + 28;
    const double lensY = 38.0;
    const Offset lensCenter = Offset(lensX, lensY);
    const double lensRadius = 22.0;

    // Garis sambungan lensa
    final linePaint = Paint()
      ..color = const Color(0xFFD4A968)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      const Offset(boneCenterX + 8, 38),
      const Offset(lensX - lensRadius, lensY),
      linePaint,
    );

    // Latar lingkaran lensa
    final lensFillPaint = Paint()
      ..color = const Color(0xFFF3E7D3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lensCenter, lensRadius, lensFillPaint);

    // Detail pembesaran pori di dalam lensa
    canvas.save();
    final lensPath = Path()
      ..addOval(Rect.fromCircle(center: lensCenter, radius: lensRadius));
    canvas.clipPath(lensPath);

    if (isOsteoporosis) {
      final meshPaint = Paint()
        ..color = const Color(0xFFD9C398)
        ..style = PaintingStyle.fill;
      canvas.drawPaint(meshPaint);

      final bigHolePaint = Paint()
        ..color = const Color(0xFF8B6336)
        ..style = PaintingStyle.fill;

      const bigHoles = [
        Offset(lensX - 10, lensY - 10),
        Offset(lensX + 6, lensY - 11),
        Offset(lensX - 4, lensY),
        Offset(lensX + 11, lensY + 3),
        Offset(lensX - 9, lensY + 11),
        Offset(lensX + 4, lensY + 12),
      ];
      for (final h in bigHoles) {
        canvas.drawCircle(h, 4.5, bigHolePaint);
      }
    } else {
      final meshPaint = Paint()
        ..color = const Color(0xFFD9C398)
        ..style = PaintingStyle.fill;
      canvas.drawPaint(meshPaint);

      final denseHolePaint = Paint()
        ..color = const Color(0xFF8B6336)
        ..style = PaintingStyle.fill;

      for (double dy = -18; dy <= 18; dy += 5.5) {
        for (double dx = -18; dx <= 18; dx += 5.5) {
          final offsetX = dx + ((dy.toInt() % 2 == 0) ? 2.5 : 0);
          final pos = Offset(lensCenter.dx + offsetX, lensCenter.dy + dy);
          canvas.drawCircle(pos, 1.6, denseHolePaint);
        }
      }
    }
    canvas.restore();

    // Bingkai emas lingkaran lensa
    final lensBorderPaint = Paint()
      ..color = const Color(0xFFD4A968)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(lensCenter, lensRadius, lensBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _BonePainter oldDelegate) {
    return oldDelegate.isOsteoporosis != isOsteoporosis;
  }
}

/// Card Fakta Penting dengan icon lampu
class _FactCard extends StatelessWidget {
  const _FactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFF59E0B),
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fakta Penting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2432),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Osteoporosis sering disebut sebagai “silent disease” karena biasanya tidak menimbulkan gejala pada tahap awal.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF64748B),
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

/// Quote card motivasi di bagian bawah
class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3D6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE0A1).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: const Text(
        '“Tulang yang kuat hari ini, untuk langkah yang lebih pasti esok nanti.”',
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
