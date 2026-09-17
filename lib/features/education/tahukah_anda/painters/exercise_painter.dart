import 'package:flutter/material.dart';

/// Painter untuk ilustrasi figur aktif berolahraga / peregangan
class ExercisePainter extends CustomPainter {
  const ExercisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Percikan kuning di kanan
    final sparkPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.88, h * 0.28), 3.2, sparkPaint);
    canvas.drawCircle(Offset(w * 0.90, h * 0.42), 3.5, sparkPaint);

    // Figur orang peregangan aktif
    final skinPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final hairPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.fill;

    final outfitPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    // Rambut belakang
    canvas.drawCircle(Offset(w * 0.45, h * 0.30), 12, hairPaint);

    // Kepala / Wajah
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.28),
      9,
      Paint()..color = const Color(0xFFFEF08A),
    );

    // Lengan terangkat ke atas / memeluk leher
    final armPath = Path()
      ..moveTo(w * 0.45, h * 0.38)
      ..quadraticBezierTo(w * 0.60, h * 0.26, w * 0.56, h * 0.20)
      ..lineTo(w * 0.50, h * 0.20)
      ..close();
    canvas.drawPath(armPath, skinPaint);

    // Tubuh / Kaos
    final bodyPath = Path()
      ..moveTo(w * 0.42, h * 0.38)
      ..lineTo(w * 0.58, h * 0.38)
      ..lineTo(w * 0.55, h * 0.56)
      ..lineTo(w * 0.44, h * 0.56)
      ..close();
    canvas.drawPath(bodyPath, skinPaint);

    // Celana aktif / Kaki melangkah
    final legPath = Path()
      ..moveTo(w * 0.44, h * 0.56)
      ..lineTo(w * 0.32, h * 0.74)
      ..lineTo(w * 0.38, h * 0.76)
      ..lineTo(w * 0.50, h * 0.58)
      ..lineTo(w * 0.62, h * 0.74)
      ..lineTo(w * 0.68, h * 0.71)
      ..lineTo(w * 0.54, h * 0.56)
      ..close();
    canvas.drawPath(legPath, outfitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
