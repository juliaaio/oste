import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/auth/login/login_page.dart';

/// Palet warna utama halaman Welcome
class _WelcomeColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color warmCream = Color(0xFFFFF8EC);
  static const Color badgeBg = Color(0xFFFFF6E3);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color sloganTan = Color(0xFFC6923C);
}

/// Halaman Welcome / Onboarding Osteocare
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Dekorasi gradasi kuning muda lembut di latar belakang
          const Positioned.fill(
            child: _BackgroundGradients(),
          ),

          // 2. Dekorasi gelombang halus di bagian bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70,
            child: CustomPaint(
              painter: _BottomWavePainter(),
            ),
          ),

          // 3. Konten utama yang responsive & aman di SafeArea
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bagian Atas: Slogan miring "Healthy Bones Brighter Tomorrow 💛"
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Transform.rotate(
                                angle: -0.16,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Healthy',
                                      style: TextStyle(
                                        fontFamily: 'Caveat',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        color: _WelcomeColors.sloganTan,
                                        height: 1.15,
                                      ),
                                    ),
                                    Text(
                                      'Bones',
                                      style: TextStyle(
                                        fontFamily: 'Caveat',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        color: _WelcomeColors.sloganTan,
                                        height: 1.15,
                                      ),
                                    ),
                                    Text(
                                      'Brighter',
                                      style: TextStyle(
                                        fontFamily: 'Caveat',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        color: _WelcomeColors.sloganTan,
                                        height: 1.15,
                                      ),
                                    ),
                                    Text(
                                      'Tomorrow 💛',
                                      style: TextStyle(
                                        fontFamily: 'Caveat',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        color: _WelcomeColors.sloganTan,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Bagian Tengah: Logo Medallion, Judul Osteocare, & Subtitle
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo Tulang & Daun Emas
                              SizedBox(
                                width: math.min(size.width * 0.58, 220),
                                height: math.min(size.width * 0.58, 220),
                                child: Image.asset(
                                  'assets/images/logo_bone.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Heart kecil di atas judul
                              const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: _WelcomeColors.primaryButterYellow,
                              ),
                              const SizedBox(height: 2),

                              // Judul "Osteocare"
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Osteo',
                                      style: TextStyle(
                                        color: _WelcomeColors.textDark,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'care',
                                      style: TextStyle(
                                        color: _WelcomeColors.primaryButterYellow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Subtitle
                              const Text(
                                'Kenali Risiko Osteoporosis\nSejak Dini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: _WelcomeColors.textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),

                          // Bagian Bawah: Tombol Mulai, Garis Hati, & Motto
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Besar "Mulai →"
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _WelcomeColors.primaryButterYellow,
                                      foregroundColor: _WelcomeColors.textDark,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Mulai',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: _WelcomeColors.textDark,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: _WelcomeColors.textDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Garis dekorasi dengan loop hati di tengah
                                const SizedBox(
                                  width: 170,
                                  height: 22,
                                  child: CustomPaint(
                                    painter: _HeartDividerPainter(),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Teks Motto
                                const Text(
                                  'Tulang yang Sehat,\nMasa Depan yang Lebih Kuat',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: _WelcomeColors.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DEKORASI BACKGROUND GRADASI KUNING MUDA
// =============================================================================
class _BackgroundGradients extends StatelessWidget {
  const _BackgroundGradients();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradasi radial kuning muda di pojok kiri atas
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF5D6).withValues(alpha: 0.7),
                  const Color(0xFFFFF9E8).withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Gradasi radial kuning muda di sisi kanan tengah
        Positioned(
          top: 140,
          right: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF7DD).withValues(alpha: 0.6),
                  const Color(0xFFFFFBF0).withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LOGO MEDALLION CUSTOM PAINTER
// =============================================================================
class _OsteocareLogoPainter extends CustomPainter {
  const _OsteocareLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Lingkaran Medallion Kuning Pastel Lembut
    final badgePaint = Paint()
      ..color = _WelcomeColors.badgeBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, badgePaint);

    // 2. Kilau bintang (Sparkle) di kiri atas tulang
    final sparklePaint = Paint()
      ..color = _WelcomeColors.primaryButterYellow
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(size.width * 0.44, size.height * 0.34), 8.5, sparklePaint);

    // 3. Ring orbital emas yang melingkari tulang (bagian belakang)
    final ringPaint = Paint()
      ..color = _WelcomeColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final ringPath = Path();
    ringPath.moveTo(size.width * 0.38, size.height * 0.42);
    ringPath.cubicTo(
      size.width * 0.22,
      size.height * 0.56,
      size.width * 0.45,
      size.height * 0.70,
      size.width * 0.68,
      size.height * 0.64,
    );
    canvas.drawPath(ringPath, ringPaint);

    // 4. Tulang diagonal di tengah
    canvas.save();
    canvas.translate(size.width * 0.50, size.height * 0.50);
    canvas.rotate(-0.58); // Miring sekitar 33 derajat

    final boneFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boneStroke = Paint()
      ..color = _WelcomeColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    // Kepala atas
    bonePath.moveTo(-12, -42);
    bonePath.cubicTo(-24, -54, -4, -60, 0, -48);
    bonePath.cubicTo(4, -60, 24, -54, 12, -42);
    // Batang kanan
    bonePath.cubicTo(10, -20, 10, 20, 12, 42);
    // Kepala bawah
    bonePath.cubicTo(24, 54, 4, 60, 0, 48);
    bonePath.cubicTo(-4, 60, -24, 54, -12, 42);
    // Batang kiri
    bonePath.cubicTo(-10, 20, -10, -20, -12, -42);
    bonePath.close();

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    canvas.restore();

    // 5. Daun-daun herbal emas di sisi kanan bawah
    final leafPaint = Paint()
      ..color = _WelcomeColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    // Daun atas
    final leafPath1 = Path();
    leafPath1.moveTo(size.width * 0.64, size.height * 0.62);
    leafPath1.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.54,
      size.width * 0.76,
      size.height * 0.68,
    );
    leafPath1.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.68,
      size.width * 0.64,
      size.height * 0.62,
    );
    leafPath1.close();
    canvas.drawPath(leafPath1, leafPaint);

    // Daun bawah
    final leafPath2 = Path();
    leafPath2.moveTo(size.width * 0.64, size.height * 0.67);
    leafPath2.quadraticBezierTo(
      size.width * 0.84,
      size.height * 0.68,
      size.width * 0.75,
      size.height * 0.79,
    );
    leafPath2.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.76,
      size.width * 0.64,
      size.height * 0.67,
    );
    leafPath2.close();
    canvas.drawPath(leafPath2, leafPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// DIVIDER GARIS DENGAN HATI DI TENGAH
// =============================================================================
class _HeartDividerPainter extends CustomPainter {
  const _HeartDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _WelcomeColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;
    final cx = size.width / 2;

    // Garis kiri
    canvas.drawLine(Offset(0, cy), Offset(cx - 15, cy), paint);

    // Garis kanan
    canvas.drawLine(Offset(cx + 15, cy), Offset(size.width, cy), paint);

    // Bentuk loop hati di tengah
    final heartPath = Path();
    heartPath.moveTo(cx, cy + 8);
    heartPath.cubicTo(cx - 12, cy - 2, cx - 10, cy - 9, cx, cy - 4);
    heartPath.cubicTo(cx + 10, cy - 9, cx + 12, cy - 2, cx, cy + 8);
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// DEKORASI GELOMBANG HALUS DI BAWAH (BOTTOM WAVE)
// =============================================================================
class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _WelcomeColors.warmCream
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.15,
      size.width,
      size.height * 0.40,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
