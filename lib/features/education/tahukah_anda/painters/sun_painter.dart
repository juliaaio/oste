import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter untuk ilustrasi matahari bersinar hangat
class SunPainter extends CustomPainter {
  const SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 17.0;

    // Sinar matahari memancar melingkar
    final rayPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    const int rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final start = Offset(
        center.dx + (radius + 5) * math.cos(angle),
        center.dy + (radius + 5) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 12) * math.cos(angle),
        center.dy + (radius + 12) * math.sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }

    // Lingkaran matahari utama
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFEF08A),
          Color(0xFFF59E0B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
