import 'dart:math' as math;
import 'package:flutter/material.dart';

class _HistoryColors {
  static const Color primaryYellow  = Color(0xFFF7C948);
  static const Color orange         = Color(0xFFF59E0B);
  static const Color yellowCircleBg = Color(0xFFFFF8D6);
  static const Color textDark       = Color(0xFF1E293B);
  static const Color textMuted      = Color(0xFF64748B);
}

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _HistoryColors.textDark,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lihat kembali hasil skrining dan pantau perubahan kesehatan tulang Anda.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _HistoryColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: _ClipboardIllustrationPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipboardIllustrationPainter extends CustomPainter {
  const _ClipboardIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.46, h * 0.52),
      w * 0.40,
      Paint()
        ..color = _HistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );

    final sparklePaint = Paint()
      ..color = _HistoryColors.primaryYellow
      ..style = PaintingStyle.fill;
    _sparkle(canvas, Offset(w * 0.06, h * 0.22), 5.0, sparklePaint);
    _sparkle(canvas, Offset(w * 0.94, h * 0.12), 4.5, sparklePaint);
    _sparkle(canvas, Offset(w * 0.88, h * 0.72), 3.5, sparklePaint);

    final cbL = w * 0.14;
    final cbT = h * 0.14;
    final cbR = w * 0.76;
    final cbB = h * 0.86;
    final clipFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final clipStroke = Paint()
      ..color = _HistoryColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    final cbRRect = RRect.fromLTRBR(cbL, cbT, cbR, cbB, const Radius.circular(10));
    canvas.drawRRect(cbRRect, clipFill);
    canvas.drawRRect(cbRRect, clipStroke);

    final tabL = w * 0.34;
    final tabT = h * 0.08;
    final tabR = w * 0.56;
    final tabB = h * 0.20;
    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(5)),
      Paint()
        ..color = _HistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(5)),
      Paint()
        ..color = _HistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      Offset(w * 0.45, h * 0.14),
      2.6,
      Paint()..color = Colors.white,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.22, h * 0.34), Offset(w * 0.68, h * 0.34), linePaint);
    canvas.drawLine(Offset(w * 0.22, h * 0.43), Offset(w * 0.68, h * 0.43), linePaint);
    canvas.drawLine(Offset(w * 0.22, h * 0.52), Offset(w * 0.52, h * 0.52), linePaint);

    final clockCx = w * 0.73;
    final clockCy = h * 0.76;
    const clockR = 17.0;
    canvas.drawCircle(
      Offset(clockCx, clockCy + 1.5),
      clockR,
      Paint()
        ..color = const Color(0x20000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _HistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _HistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final handPaint = Paint()
      ..color = _HistoryColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final hourA = math.pi * (-0.40);
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 8 * math.cos(hourA), clockCy + 8 * math.sin(hourA)),
      handPaint,
    );
    final minA = -math.pi / 2;
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 12 * math.cos(minA), clockCy + 12 * math.sin(minA)),
      handPaint,
    );
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      2.2,
      Paint()
        ..color = _HistoryColors.orange
        ..style = PaintingStyle.fill,
    );

    _drawMascot(canvas, w, h);
  }

  void _drawMascot(Canvas canvas, double w, double h) {
    final cx = w * 0.88;
    final cy = h * 0.20;
    canvas.drawCircle(
      Offset(cx, cy),
      8.5,
      Paint()
        ..color = _HistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      8.5,
      Paint()
        ..color = _HistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(cx - 6.5, cy - 6.5),
      3.5,
      Paint()
        ..color = _HistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 6.5, cy - 6.5),
      3.5,
      Paint()
        ..color = _HistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx - 3.0, cy - 1.0),
      1.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 3.0, cy - 1.0),
      1.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy + 1.5),
      1.0,
      Paint()
        ..color = _HistoryColors.orange
        ..style = PaintingStyle.fill,
    );
  }

  void _sparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
