import 'package:flutter/material.dart';

/// Painter untuk ilustrasi tunas tanaman di banner motivasi bawah
class SeedlingPainter extends CustomPainter {
  const SeedlingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gundukan tanah cokelat
    final soilPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: 28, height: 10),
      soilPaint,
    );

    // Batang tunas hijau
    final stemPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(w * 0.5, h * 0.80)
      ..lineTo(w * 0.5, h * 0.40);
    canvas.drawPath(stemPath, stemPaint);

    // Daun kiri
    final leafPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final leftLeafPath = Path()
      ..moveTo(w * 0.5, h * 0.46)
      ..quadraticBezierTo(w * 0.24, h * 0.44, w * 0.26, h * 0.30)
      ..quadraticBezierTo(w * 0.44, h * 0.32, w * 0.5, h * 0.46)
      ..close();
    canvas.drawPath(leftLeafPath, leafPaint);

    // Daun kanan
    final rightLeafPath = Path()
      ..moveTo(w * 0.5, h * 0.46)
      ..quadraticBezierTo(w * 0.76, h * 0.44, w * 0.74, h * 0.30)
      ..quadraticBezierTo(w * 0.56, h * 0.32, w * 0.5, h * 0.46)
      ..close();
    canvas.drawPath(rightLeafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
