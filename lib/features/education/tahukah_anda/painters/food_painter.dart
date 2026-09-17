import 'package:flutter/material.dart';

/// Painter untuk ilustrasi piring makanan bergizi kaya kalsium dan susu
class FoodPainter extends CustomPainter {
  const FoodPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Percikan kuning di atas piring
    final sparkPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.85, h * 0.28), 3.2, sparkPaint);
    canvas.drawCircle(Offset(w * 0.90, h * 0.40), 3.5, sparkPaint);

    // Piring oval
    final plateOuterPaint = Paint()
      ..color = const Color(0xFFE0E7FF)
      ..style = PaintingStyle.fill;

    final plateInnerPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.70), width: 68, height: 26),
      plateOuterPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.69), width: 62, height: 21),
      plateInnerPaint,
    );

    // Sayuran brokoli hijau
    final broccoliPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.58, h * 0.54), 10, broccoliPaint);
    canvas.drawCircle(Offset(w * 0.52, h * 0.57), 8, broccoliPaint);

    // Makanan oranye / salmon / telur
    final orangeFoodPaint = Paint()
      ..color = const Color(0xFFFB923C)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.32, h * 0.68), width: 14, height: 10),
      orangeFoodPaint,
    );

    // Telur / keju kuning
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.69),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Gelas susu putih
    final glassOutline = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final milkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glassPath = Path()
      ..moveTo(w * 0.64, h * 0.50)
      ..lineTo(w * 0.76, h * 0.50)
      ..lineTo(w * 0.73, h * 0.68)
      ..lineTo(w * 0.66, h * 0.68)
      ..close();

    canvas.drawPath(glassPath, milkPaint);
    canvas.drawPath(glassPath, glassOutline);

    // Sedotan kecil di gelas
    canvas.drawLine(
      Offset(w * 0.71, h * 0.44),
      Offset(w * 0.70, h * 0.62),
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Kacang-kacangan cokelat
    final nutPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.64, h * 0.69), 3.5, nutPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.69), 3.2, nutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
