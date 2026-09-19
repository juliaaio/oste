import 'package:flutter/material.dart';

class PencegahanPage extends StatelessWidget {
  const PencegahanPage({super.key});

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
            // 1. Paragraf pembuka
            Text(
              'Osteoporosis dapat dicegah dengan menerapkan gaya hidup sehat sejak dini. Berikut langkah-langkah yang dapat Anda lakukan:',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 20),

            // 2. Card Konsumsi Kalsium yang Cukup
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_calcium.png',
              boxColor: Color(0xFFF0FDF4),
              borderColor: Color(0xFFBBF7D0),
              fallbackIllustration: _CalciumIllustration(),
              title: 'Konsumsi Kalsium yang Cukup',
              description:
                  'Sumber: susu, keju, yogurt, sayuran hijau, ikan teri,tahu, tempe.',
            ),
            SizedBox(height: 12),

            // 3. Card Penuhi Kebutuhan Vitamin D
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_vitamin_d.png',
              boxColor: Color(0xFFFFFBEB),
              borderColor: Color(0xFFFDE68A),
              fallbackIllustration: Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFF59E0B),
                size: 30,
              ),
              title: 'Penuhi Kebutuhan Vitamin D',
              description:
                  'Dapat diperoleh dari sinar matahari pagi, ikan berlemak, atau suplemen sesuai anjuran dokter.',
            ),
            SizedBox(height: 12),

            // 4. Card Lakukan Aktivitas Fisik
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_exercise.png',
              boxColor: Color(0xFFEFF6FF),
              borderColor: Color(0xFFBFDBFE),
              fallbackIllustration: Icon(
                Icons.directions_walk_rounded,
                color: Color(0xFF2563EB),
                size: 30,
              ),
              title: 'Lakukan Aktivitas Fisik',
              description:
                  'Seperti berjalan kaki, senam, atau latihan beban ringan secara rutin.',
            ),
            SizedBox(height: 12),

            // 5. Card Hindari Kebiasaan Buruk
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_habit.png',
              boxColor: Color(0xFFFEF2F2),
              borderColor: Color(0xFFFECDD3),
              fallbackIllustration: Icon(
                Icons.smoke_free_rounded,
                color: Color(0xFFEF4444),
                size: 30,
              ),
              title: 'Hindari Kebiasaan Buruk',
              description: 'Kurangi merokok dan batasi konsumsi alkohol.',
            ),
            SizedBox(height: 12),

            // 6. Card Jaga Berat Badan Ideal
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_weight.png',
              boxColor: Color(0xFFF1F5F9),
              borderColor: Color(0xFFCBD5E1),
              fallbackIllustration: Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF64748B),
                size: 30,
              ),
              title: 'Jaga Berat Badan Ideal',
              description:
                  'Berat badan yang sehat membantu menjaga kekuatan tulang.',
            ),
            SizedBox(height: 12),

            // 7. Card Periksa Kesehatan Secara Rutin
            _PreventionCard(
              assetPath: 'assets/images/education/prevention_checkup.png',
              boxColor: Color(0xFFF0F7FF),
              borderColor: Color(0xFFBFDBFE),
              fallbackIllustration: Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF1E293B),
                size: 28,
              ),
              title: 'Periksa Kesehatan Secara Rutin',
              description:
                  'Lakukan pemeriksaan kepadatan tulang, terutama jika memiliki faktor risiko.',
            ),
            SizedBox(height: 16),

            // 8. Warning card bagian bawah berwarna kuning muda ("Ingat!")
            _WarningCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Card langkah pencegahan osteoporosis
class _PreventionCard extends StatelessWidget {
  final String assetPath;
  final Color boxColor;
  final Color borderColor;
  final Widget fallbackIllustration;
  final String title;
  final String description;

  const _PreventionCard({
    required this.assetPath,
    required this.boxColor,
    required this.borderColor,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon box warna pastel sesuai tema
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                assetPath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: fallbackIllustration);
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Judul dan deskripsi langkah pencegahan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
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

/// Warning card kuning muda di bagian bawah ("Ingat!")
class _WarningCard extends StatelessWidget {
  const _WarningCard();

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
            color: const Color(0xFFE5A124).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                  'Ingat!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pencegahan lebih baik daripada pengobatan. Mulai gaya hidup sehat sekarang untuk tulang yang lebih kuat di masa depan.',
                  style: TextStyle(
                    fontSize: 13.5,
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

/// Fallback ilustrasi kalsium (gelas susu, keju, dan sayur)
class _CalciumIllustration extends StatelessWidget {
  const _CalciumIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _CalciumPainter(),
    );
  }
}

class _CalciumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gelas susu (kiri)
    final glassOutline = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final glassFill = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.fill;

    final glassPath = Path();
    glassPath.moveTo(9, 10);
    glassPath.lineTo(19, 10);
    glassPath.lineTo(17, 26);
    glassPath.lineTo(11, 26);
    glassPath.close();

    canvas.drawPath(glassPath, glassFill);
    canvas.drawPath(glassPath, glassOutline);

    // Garis susu dalam gelas
    final milkLine = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final milkPath = Path();
    milkPath.moveTo(10, 14);
    milkPath.lineTo(18, 14);
    milkPath.lineTo(17, 25);
    milkPath.lineTo(11, 25);
    milkPath.close();
    canvas.drawPath(milkPath, milkLine);

    // Sedotan kecil
    final strawPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(16, 7), const Offset(13, 16), strawPaint);

    // 2. Keju (kanan)
    final cheeseFill = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    final cheeseStroke = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final cheesePath = Path();
    cheesePath.moveTo(19, 21);
    cheesePath.lineTo(31, 15);
    cheesePath.lineTo(31, 26);
    cheesePath.lineTo(19, 26);
    cheesePath.close();

    canvas.drawPath(cheesePath, cheeseFill);
    canvas.drawPath(cheesePath, cheeseStroke);

    // Lubang keju
    final holePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(24, 21), 1.4, holePaint);
    canvas.drawCircle(const Offset(28, 23), 1.2, holePaint);

    // 3. Sayuran hijau (bawah kiri)
    final vegPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(13, 27), 3.5, vegPaint);
    canvas.drawCircle(const Offset(17, 28), 3.2, vegPaint);
    canvas.drawCircle(const Offset(15, 30), 3.0, vegPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}