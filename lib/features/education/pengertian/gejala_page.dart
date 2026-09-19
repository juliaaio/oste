import 'package:flutter/material.dart';

class GejalaPage extends StatelessWidget {
  const GejalaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8EC),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // 1. Teks pembuka
            Text(
              'Osteoporosis sering tidak menimbulkan gejala pada tahap awal. Namun, seiring berjalannya waktu, beberapa tanda berikut dapat muncul:',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 20),

            // 2. Card Nyeri Punggung
            _SymptomCard(
              assetPath: 'assets/images/education/symptom_back_pain.png',
              fallbackIllustration: _BackPainIllustration(),
              title: 'Nyeri Punggung',
              description: 'Rasa nyeri di punggung, terutama bagian bawah.',
            ),
            SizedBox(height: 14),

            // 3. Card Postur Tubuh Menjadi Bungkuk
            _SymptomCard(
              assetPath: 'assets/images/education/symptom_posture.png',
              fallbackIllustration: _SpineIllustration(),
              title: 'Postur Tubuh Menjadi Bungkuk',
              description:
                  'Tulang belakang dapat mengalami perubahan bentuk sehingga tubuh terlihat lebih bungkuk.',
            ),
            SizedBox(height: 14),

            // 4. Card Tinggi Badan Berkurang
            _SymptomCard(
              assetPath: 'assets/images/education/symptom_height.png',
              fallbackIllustration: _HeightIllustration(),
              title: 'Tinggi Badan Berkurang',
              description:
                  'Tinggi badan bisa berkurang seiring waktu akibat tulang yang mulai keropos.',
            ),
            SizedBox(height: 14),

            // 5. Card Mudah Mengalami Patah Tulang
            _SymptomCard(
              assetPath: 'assets/images/education/symptom_fracture.png',
              fallbackIllustration: _FractureIllustration(),
              title: 'Mudah Mengalami Patah Tulang',
              description:
                  'Tulang menjadi lebih rapuh dan mudah patah, bahkan akibat benturan ringan.',
            ),
            SizedBox(height: 18),

            // 6. Card warning merah "Perlu Diperhatikan"
            _WarningCard(),
            SizedBox(height: 18),

            // 7. Quote card kuning muda di bawah
            _QuoteCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Card item gejala dengan icon box krem dan ilustrasi
class _SymptomCard extends StatelessWidget {
  final String assetPath;
  final Widget fallbackIllustration;
  final String title;
  final String description;

  const _SymptomCard({
    required this.assetPath,
    required this.fallbackIllustration,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kotak ilustrasi berlatar cream/butter yellow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFDE68A).withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                assetPath,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: fallbackIllustration);
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Judul dan deskripsi gejala
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
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

/// Warning card merah lembut "Perlu Diperhatikan"
class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFECDD3),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE11D48),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perlu Diperhatikan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBE123C),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Jika Anda mengalami gejala-gejala di atas, segera lakukan pemeriksaan ke dokter untuk mendapatkan evaluasi lebih lanjut.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF9F1239),
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

/// Quote card kuning muda motivasi di bagian bawah
class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3D6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE0A1).withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: const Text(
        '“Jangan abaikan tanda-tanda kecil, karena kesehatan tulang sangat berarti untuk masa depan Anda.”',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 13.5,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B5E34),
          height: 1.45,
        ),
      ),
    );
  }
}

/// Fallback ilustrasi vektor Nyeri Punggung
class _BackPainIllustration extends StatelessWidget {
  const _BackPainIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 42),
      painter: _BackPainPainter(),
    );
  }
}

class _BackPainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cx = 20.0;

    // Kepala
    final headPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(cx, 8), 4.5, headPaint);

    // Badan / punggung
    final bodyPaint = Paint()
      ..color = const Color(0xFFFED7AA)
      ..style = PaintingStyle.fill;

    final torsoPath = Path();
    torsoPath.moveTo(cx - 7, 15);
    torsoPath.lineTo(cx + 7, 15);
    torsoPath.lineTo(cx + 5, 27);
    torsoPath.lineTo(cx + 7, 36);
    torsoPath.lineTo(cx - 7, 36);
    torsoPath.lineTo(cx - 5, 27);
    torsoPath.close();
    canvas.drawPath(torsoPath, bodyPaint);

    // Baju / atasan pink lembut
    final shirtPaint = Paint()
      ..color = const Color(0xFFFDA4AF)
      ..style = PaintingStyle.fill;
    final shirtPath = Path();
    shirtPath.moveTo(cx - 7, 15);
    shirtPath.lineTo(cx + 7, 15);
    shirtPath.lineTo(cx + 6, 25);
    shirtPath.lineTo(cx - 6, 25);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Lengan yang memegang pinggang
    final armPaint = Paint()
      ..color = const Color(0xFFFDA4AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // Lengan kiri
    canvas.drawLine(const Offset(cx - 6, 17), const Offset(cx - 12, 24), armPaint);
    canvas.drawLine(const Offset(cx - 12, 24), const Offset(cx - 5, 28), armPaint);

    // Lengan kanan
    canvas.drawLine(const Offset(cx + 6, 17), const Offset(cx + 12, 24), armPaint);
    canvas.drawLine(const Offset(cx + 12, 24), const Offset(cx + 5, 28), armPaint);

    // Efek nyeri merah di punggung bawah
    final painPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const double painY = 28.0;
    canvas.drawLine(
      const Offset(cx - 4, painY - 4),
      const Offset(cx + 4, painY + 4),
      painPaint,
    );
    canvas.drawLine(
      const Offset(cx + 4, painY - 4),
      const Offset(cx - 4, painY + 4),
      painPaint,
    );
    canvas.drawLine(
      const Offset(cx - 5, painY),
      const Offset(cx + 5, painY),
      painPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi tulang belakang bungkuk
class _SpineIllustration extends StatelessWidget {
  const _SpineIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 42),
      painter: _SpinePainter(),
    );
  }
}

class _SpinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vertFill = Paint()
      ..color = const Color(0xFFF1E4CB)
      ..style = PaintingStyle.fill;

    final vertStroke = Paint()
      ..color = const Color(0xFFD4A968)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final discPaint = Paint()
      ..color = const Color(0xFFB5874A)
      ..style = PaintingStyle.fill;

    // Koordinat ruas tulang belakang melengkung (bungkuk)
    final centers = [
      const Offset(16, 8),
      const Offset(18, 14),
      const Offset(21, 20),
      const Offset(22, 26),
      const Offset(20, 32),
      const Offset(17, 38),
    ];

    for (int i = 0; i < centers.length; i++) {
      final c = centers[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 14, height: 4.8),
        const Radius.circular(1.8),
      );
      canvas.drawRRect(rect, vertFill);
      canvas.drawRRect(rect, vertStroke);

      if (i < centers.length - 1) {
        final nextC = centers[i + 1];
        final discOffset = Offset((c.dx + nextC.dx) / 2, (c.dy + nextC.dy) / 2);
        canvas.drawCircle(discOffset, 1.3, discPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi berkurangnya tinggi badan (penggaris & orang)
class _HeightIllustration extends StatelessWidget {
  const _HeightIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(38, 42),
      painter: _HeightPainter(),
    );
  }
}

class _HeightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Penggaris ukur tinggi di sebelah kiri
    final rulerPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;
    final rulerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 6, 6, 32),
      const Radius.circular(2),
    );
    canvas.drawRRect(rulerRect, rulerPaint);

    // Garis skala penggaris
    final tickPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double y = 10; y <= 34; y += 5) {
      canvas.drawLine(Offset(10, y), Offset(14, y), tickPaint);
    }

    // Siluet orang di sebelah kanan
    final personHead = Paint()
      ..color = const Color(0xFFE5A124)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(24, 14), 3.8, personHead);

    final personBody = Paint()
      ..color = const Color(0xFFF7C948)
      ..style = PaintingStyle.fill;
    final bodyRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(21, 19, 6.5, 19),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(bodyRRect, personBody);

    // Indikator panah penurunan tinggi badan
    final arrowPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(16, 12), const Offset(20, 12), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fallback ilustrasi patah tulang dengan garis retak merah
class _FractureIllustration extends StatelessWidget {
  const _FractureIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 42),
      painter: _FracturePainter(),
    );
  }
}

class _FracturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Putar sedikit miring diagonal
    canvas.translate(20, 21);
    canvas.rotate(-0.6);

    final boneFill = Paint()
      ..color = const Color(0xFFF1E4CB)
      ..style = PaintingStyle.fill;

    final boneStroke = Paint()
      ..color = const Color(0xFFD4A968)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Tulang bagian atas
    final topBone = Path();
    topBone.moveTo(-4, -14);
    topBone.cubicTo(-8, -18, -4, -20, -1, -18);
    topBone.cubicTo(2, -20, 6, -18, 4, -14);
    topBone.lineTo(3, -2);
    topBone.lineTo(-3, -2);
    topBone.close();
    canvas.drawPath(topBone, boneFill);
    canvas.drawPath(topBone, boneStroke);

    // Tulang bagian bawah
    final bottomBone = Path();
    bottomBone.moveTo(-3, 2);
    bottomBone.lineTo(3, 2);
    bottomBone.lineTo(4, 14);
    bottomBone.cubicTo(6, 18, 2, 20, -1, 18);
    bottomBone.cubicTo(-4, 20, -8, 18, -4, 14);
    bottomBone.close();
    canvas.drawPath(bottomBone, boneFill);
    canvas.drawPath(bottomBone, boneStroke);

    // Garis patahan / retakan merah
    final crackPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final crackPath = Path();
    crackPath.moveTo(-6, -2);
    crackPath.lineTo(-1, 2);
    crackPath.lineTo(1, -2);
    crackPath.lineTo(6, 2);
    canvas.drawPath(crackPath, crackPaint);

    // Percikan retakan kecil
    canvas.drawLine(const Offset(-7, -4), const Offset(-5, -6), crackPaint);
    canvas.drawLine(const Offset(7, 4), const Offset(5, 6), crackPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}