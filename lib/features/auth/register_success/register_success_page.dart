import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';

/// Palet warna halaman Register Success
class _RegisterSuccessColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color badgeBg = Color(0xFFFFF5DD);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Halaman Sukses Registrasi Akun Osteocare
class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  void _handleStartNow(BuildContext context) {
    // Navigasi pushAndRemoveUntil ke DashboardPage agar tidak bisa kembali ke halaman Register
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleStartNow(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Konten Utama di Tengah
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo Medallion Osteocare di bagian atas
                            const SizedBox(
                              width: 160,
                              height: 160,
                              child: CustomPaint(
                                painter: _OsteocareLogoPainter(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Judul "Akun Berhasil Dibuat!"
                            const Text(
                              'Akun Berhasil Dibuat!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _RegisterSuccessColors.textDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Deskripsi
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Selamat datang di Osteocare\nSaatnya mulai menjaga kesehatan\ntulangmu',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: _RegisterSuccessColors.textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Tombol Utama "Mulai Sekarang →"
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                color: _RegisterSuccessColors.primaryButterYellow,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: _RegisterSuccessColors.primaryButterYellow
                                        .withValues(alpha: 0.45),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _handleStartNow(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: _RegisterSuccessColors.textDark,
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
                                      'Mulai Sekarang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _RegisterSuccessColors.textDark,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: _RegisterSuccessColors.textDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Footer: Garis Hati & Motto
                        const Padding(
                          padding: EdgeInsets.only(bottom: 24, top: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 18,
                                child: CustomPaint(
                                  painter: _HeartDividerPainter(),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tulang yang Sehat,\nMasa Depan yang Lebih Kuat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: _RegisterSuccessColors.textLight,
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
      ),
    );
  }
}

// =============================================================================
// LOGO MEDALLION CUSTOM PAINTER OSTEOCARE
// =============================================================================
class _OsteocareLogoPainter extends CustomPainter {
  const _OsteocareLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Lingkaran Medallion Kuning Pastel Lembut
    final badgePaint = Paint()
      ..color = _RegisterSuccessColors.badgeBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, badgePaint);

    // 2. Kilau bintang (Sparkle) di kiri atas tulang
    final sparklePaint = Paint()
      ..color = _RegisterSuccessColors.primaryButterYellow
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(size.width * 0.44, size.height * 0.34), 7.5, sparklePaint);

    // 3. Ring orbital emas yang melingkari tulang
    final ringPaint = Paint()
      ..color = _RegisterSuccessColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
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
    canvas.rotate(-0.58);

    final boneFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boneStroke = Paint()
      ..color = _RegisterSuccessColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    // Kepala atas
    bonePath.moveTo(-10, -36);
    bonePath.cubicTo(-20, -46, -3, -51, 0, -41);
    bonePath.cubicTo(3, -51, 20, -46, 10, -36);
    // Batang kanan
    bonePath.cubicTo(8, -16, 8, 16, 10, 36);
    // Kepala bawah
    bonePath.cubicTo(20, 46, 3, 51, 0, 41);
    bonePath.cubicTo(-3, 51, -20, 46, -10, 36);
    // Batang kiri
    bonePath.cubicTo(-8, 16, -8, -16, -10, -36);
    bonePath.close();

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    canvas.restore();

    // 5. Daun herbal emas di sisi kanan bawah
    final leafPaint = Paint()
      ..color = _RegisterSuccessColors.primaryButterYellow
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
      ..color = _RegisterSuccessColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
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
    heartPath.moveTo(cx, cy + 6);
    heartPath.cubicTo(cx - 9, cy - 2, cx - 8, cy - 7, cx, cy - 3);
    heartPath.cubicTo(cx + 8, cy - 7, cx + 9, cy - 2, cx, cy + 6);
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
