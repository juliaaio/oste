import 'package:flutter/material.dart';

/// Painter untuk ilustrasi tulang emas dengan percikan cahaya
class BonePainter extends CustomPainter {
  const BonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gambar percikan kecil di sekeliling
    final sparkPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.16, h * 0.28), 3.0, sparkPaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.28), 3.0, sparkPaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.76), 3.0, sparkPaint);

    // Tulang miring 45 derajat
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(0.58);

    final bonePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final boneLightPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill;

    // Batang tulang
    final shaftRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 44, height: 13),
      const Radius.circular(6),
    );
    canvas.drawRRect(shaftRRect, bonePaint);
    canvas.drawRRect(shaftRRect.deflate(1.5), boneLightPaint);

    // Ujung kiri tulang (dua benjolan)
    canvas.drawCircle(const Offset(-22, -6), 8, bonePaint);
    canvas.drawCircle(const Offset(-22, 6), 8, bonePaint);
    canvas.drawCircle(const Offset(-22, -6), 6.5, boneLightPaint);
    canvas.drawCircle(const Offset(-22, 6), 6.5, boneLightPaint);

    // Ujung kanan tulang (dua benjolan)
    canvas.drawCircle(const Offset(22, -6), 8, bonePaint);
    canvas.drawCircle(const Offset(22, 6), 8, bonePaint);
    canvas.drawCircle(const Offset(22, -6), 6.5, boneLightPaint);
    canvas.drawCircle(const Offset(22, 6), 6.5, boneLightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
