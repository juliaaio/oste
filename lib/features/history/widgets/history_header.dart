import 'package:flutter/material.dart';

/// Header Halaman Riwayat sesuai desain Figma
class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Teks Judul & Subjudul ─────────────────────────────────
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Lihat kembali hasil skrining dan pantau perubahan kesehatan tulang Anda.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Ilustrasi Bone & Clipboard Kanan Atas ─────────────────
          const SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _BoneClipboardIllustrationPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter untuk menggambar maskot tulang tersenyum bersama papan klip catatan dan jam
class _BoneClipboardIllustrationPainter extends CustomPainter {
  const _BoneClipboardIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Tulang (Bone) di latar belakang ───────────────────────────
    final boneStroke = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final boneFill = Paint()
      ..color = const Color(0xFFFFFBEB)
      ..style = PaintingStyle.fill;

    // Path bentuk tulang berdiri
    final bonePath = Path();
    // Kepala atas tulang (2 tonjolan rounded)
    bonePath.moveTo(w * 0.44, h * 0.12);
    bonePath.cubicTo(w * 0.42, h * 0.04, w * 0.28, h * 0.04, w * 0.26, h * 0.13);
    bonePath.cubicTo(w * 0.20, h * 0.13, w * 0.18, h * 0.22, w * 0.25, h * 0.27);
    // Batang kiri menuju bawah
    bonePath.cubicTo(w * 0.25, h * 0.45, w * 0.20, h * 0.55, w * 0.18, h * 0.65);
    // Lobe kiri bawah
    bonePath.cubicTo(w * 0.12, h * 0.72, w * 0.20, h * 0.82, w * 0.28, h * 0.80);
    // Lobe kanan bawah
    bonePath.cubicTo(w * 0.35, h * 0.86, w * 0.45, h * 0.80, w * 0.42, h * 0.68);
    // Batang kanan menuju atas
    bonePath.cubicTo(w * 0.40, h * 0.50, w * 0.42, h * 0.35, w * 0.44, h * 0.27);
    // Lobe kanan atas
    bonePath.cubicTo(w * 0.52, h * 0.22, w * 0.50, h * 0.12, w * 0.44, h * 0.12);
    bonePath.close();

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    // Wajah tersenyum pada tulang (mata & senyum)
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.31, h * 0.18), 1.8, eyePaint);
    canvas.drawCircle(Offset(w * 0.41, h * 0.18), 1.8, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(w * 0.33, h * 0.22)
      ..quadraticBezierTo(w * 0.36, h * 0.25, w * 0.39, h * 0.22);
    canvas.drawPath(mouthPath, mouthPaint);

    // ── 2. Papan Klip (Clipboard) di depan ───────────────────────────
    final cbStroke = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cbFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cbRRect = RRect.fromLTRBR(
      w * 0.36,
      h * 0.20,
      w * 0.84,
      h * 0.82,
      const Radius.circular(10),
    );

    canvas.drawRRect(cbRRect, cbFill);
    canvas.drawRRect(cbRRect, cbStroke);

    // Klip penjepit di bagian atas clipboard
    final clipStroke = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final clipFill = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final clipRRect = RRect.fromLTRBR(
      w * 0.50,
      h * 0.14,
      w * 0.70,
      h * 0.24,
      const Radius.circular(5),
    );
    canvas.drawRRect(clipRRect, clipFill);
    canvas.drawRRect(clipRRect, clipStroke);

    // ── 3. Baris Checklist di dalam Clipboard ───────────────────────
    final checkPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Check 1
    final c1 = Path()
      ..moveTo(w * 0.44, h * 0.34)
      ..lineTo(w * 0.49, h * 0.38)
      ..lineTo(w * 0.58, h * 0.31);
    canvas.drawPath(c1, checkPaint);

    // Check 2
    final c2 = Path()
      ..moveTo(w * 0.44, h * 0.45)
      ..lineTo(w * 0.49, h * 0.49)
      ..lineTo(w * 0.58, h * 0.42);
    canvas.drawPath(c2, checkPaint);

    // Check 3
    final c3 = Path()
      ..moveTo(w * 0.44, h * 0.56)
      ..lineTo(w * 0.49, h * 0.60)
      ..lineTo(w * 0.58, h * 0.53);
    canvas.drawPath(c3, checkPaint);

    // ── 4. Ikon Jam di pojok kanan bawah ────────────────────────────
    final clockCx = w * 0.82;
    final clockCy = h * 0.78;
    const clockR = 14.0;

    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final clockStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset(clockCx, clockCy), clockR, clockStroke);

    // Jarum jam
    final handPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Jarum pendek (arah jam 10)
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx - 5.5, clockCy - 4.5),
      handPaint,
    );
    // Jarum panjang (arah jam 3)
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 6.5, clockCy),
      handPaint,
    );

    // Titik tengah jam
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      1.6,
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
