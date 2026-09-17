import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter untuk ilustrasi larangan rokok / kebiasaan tidak sehat
class HealthyHabitPainter extends CustomPainter {
  const HealthyHabitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 22.0;

    // Percikan kuning di kiri
    final sparkPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.22), 3.0, sparkPaint);
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.78), 3.2, sparkPaint);

    // Batang rokok di dalam
    final cigWhite = Paint()..color = const Color(0xFFE2E8F0);
    final cigFilter = Paint()..color = const Color(0xFFF59E0B);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 28, height: 6),
        const Radius.circular(2),
      ),
      cigWhite,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx - 9, center.dy), width: 8, height: 6),
        const Radius.circular(2),
      ),
      cigFilter,
    );

    // Lingkaran larangan merah
    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, radius, redPaint);

    // Garis diagonal larangan merah
    final slashStart = Offset(
      center.dx + radius * math.cos(-math.pi * 0.75),
      center.dy + radius * math.sin(-math.pi * 0.75),
    );
    final slashEnd = Offset(
      center.dx + radius * math.cos(math.pi * 0.25),
      center.dy + radius * math.sin(math.pi * 0.25),
    );
    canvas.drawLine(slashStart, slashEnd, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
