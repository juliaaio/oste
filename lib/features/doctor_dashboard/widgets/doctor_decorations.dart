import 'package:flutter/material.dart';

/// Palet warna tema Doctor Dashboard sesuai desain Figma
class DoctorThemeColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color softButterYellow = Color(0xFFFFF7DB);
  static const Color lightButterYellow = Color(0xFFFFFBEF);
  static const Color cardButterYellow = Color(0xFFFFF9E5);
  static const Color borderButterYellow = Color(0xFFFEE685);
  
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeDeep = Color(0xFFD97706);
  static const Color creamPill = Color(0xFFFFF6D8);

  static const Color pastelPurple = Color(0xFFC4B5FD);
  static const Color pastelPurpleLight = Color(0xFFEDE9FE);
  static const Color purpleDeep = Color(0xFF7C3AED);

  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  static const Color surfaceWhite = Colors.white;
  static const Color cardBorder = Color(0xFFF1F5F9);
}

/// Painter latar belakang bernuansa butter yellow dan aksen lavender/ungu pastel sesuai Figma
class DoctorBackgroundPainter extends CustomPainter {
  const DoctorBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Lengkungan butter yellow lembut di sudut kiri atas & kanan atas
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFF6D3).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final yellowPath = Path();
    yellowPath.moveTo(0, 0);
    yellowPath.lineTo(size.width * 0.32, 0);
    yellowPath.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.08,
      0,
      size.height * 0.06,
    );
    yellowPath.close();
    canvas.drawPath(yellowPath, yellowPaint);

    final yellowPathTopRight = Path();
    yellowPathTopRight.moveTo(size.width * 0.75, 0);
    yellowPathTopRight.lineTo(size.width, 0);
    yellowPathTopRight.lineTo(size.width, size.height * 0.09);
    yellowPathTopRight.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.06,
      size.width * 0.75,
      0,
    );
    yellowPathTopRight.close();
    canvas.drawPath(yellowPathTopRight, yellowPaint);

    // 2. Bubble pastel ungu di sisi kiri atas
    final purplePaint = Paint()
      ..color = const Color(0xFFD8D0F0).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, size.height * 0.08), 38, purplePaint);

    // 3. Bubble ungu pastel kecil di kiri tengah
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.58), 11, purplePaint);
    canvas.drawCircle(Offset(size.width * 0.06, size.height * 0.69), 7, purplePaint);

    // 4. Bubble ungu pastel di kanan
    final purpleLightPaint = Paint()
      ..color = const Color(0xFFE2DCF7).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.51), 8, purpleLightPaint);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.81), 10, purpleLightPaint);
    canvas.drawCircle(Offset(size.width * 0.98, size.height * 0.71), 22, purpleLightPaint);

    // 5. Garis lengkung tipis ungu pastel di kiri bawah
    final arcPaint = Paint()
      ..color = const Color(0xFFC7BEE8).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final arcPath = Path();
    arcPath.moveTo(0, size.height * 0.64);
    arcPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.67,
      size.width * 0.16,
      size.height * 0.69,
    );
    canvas.drawPath(arcPath, arcPaint);

    // 6. Lengkungan gelombang butter yellow hangat di bagian bawah
    final bottomWavePaint = Paint()
      ..color = const Color(0xFFFFF4C9).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final bottomWave = Path();
    bottomWave.moveTo(0, size.height * 0.83);
    bottomWave.cubicTo(
      size.width * 0.25,
      size.height * 0.90,
      size.width * 0.12,
      size.height * 0.72,
      size.width * 0.45,
      size.height * 0.80,
    );
    bottomWave.cubicTo(
      size.width * 0.75,
      size.height * 0.87,
      size.width * 0.85,
      size.height * 0.72,
      size.width,
      size.height * 0.82,
    );
    bottomWave.lineTo(size.width, size.height);
    bottomWave.lineTo(0, size.height);
    bottomWave.close();
    canvas.drawPath(bottomWave, bottomWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
