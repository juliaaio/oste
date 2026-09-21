import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Palet warna sesuai DashboardPage
// ---------------------------------------------------------------------------
class _EmptyHistoryColors {
  static const Color primaryYellow  = Color(0xFFF7C948);
  static const Color orange         = Color(0xFFF59E0B);
  static const Color yellowCircleBg = Color(0xFFFFF8D6);
  static const Color textDark       = Color(0xFF1E293B);
  static const Color textMuted      = Color(0xFF64748B);
}

/// Widget keadaan kosong untuk halaman Riwayat.
class EmptyHistoryWidget extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onStartScreening;

  const EmptyHistoryWidget({
    super.key,
    this.title = 'Belum ada riwayat',
    this.description = 'Hasil skrining Anda akan muncul di sini setelah melakukan skrining.',
    this.buttonText = 'Mulai Skrining',
    this.onStartScreening,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ilustrasi clipboard + jam ─────────────────────────────
            const SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _ClipboardClockPainter(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Judul ─────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _EmptyHistoryColors.textDark,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 8),

            // ── Teks deskripsi ────────────────────────────────────────
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _EmptyHistoryColors.textMuted,
                height: 1.45,
              ),
            ),

            if (onStartScreening != null) ...[
              const SizedBox(height: 24),

              // ── Tombol Aksi ──────────────────────────────────────────
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: onStartScreening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _EmptyHistoryColors.primaryYellow,
                    foregroundColor: _EmptyHistoryColors.textDark,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _EmptyHistoryColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painter – Ilustrasi clipboard + jam
// ---------------------------------------------------------------------------
class _ClipboardClockPainter extends CustomPainter {
  const _ClipboardClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Lingkaran latar kuning muda
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.52),
      w * 0.42,
      Paint()
        ..color = _EmptyHistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );

    // 2. Sparkle / kilau bintang
    final sparklePaint = Paint()
      ..color = _EmptyHistoryColors.primaryYellow
      ..style = PaintingStyle.fill;

    _sparkle(canvas, Offset(w * 0.06, h * 0.28), 6.0, sparklePaint);
    _sparkle(canvas, Offset(w * 0.94, h * 0.18), 5.5, sparklePaint);
    _sparkle(canvas, Offset(w * 0.90, h * 0.74), 4.5, sparklePaint);
    _sparkle(canvas, Offset(w * 0.08, h * 0.72), 4.0, sparklePaint);

    // 3. Badan clipboard
    final cbL = w * 0.18;
    final cbT = h * 0.14;
    final cbR = w * 0.78;
    final cbB = h * 0.86;

    final clipFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final clipStroke = Paint()
      ..color = _EmptyHistoryColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeJoin = StrokeJoin.round;

    final cbRRect = RRect.fromLTRBR(cbL, cbT, cbR, cbB, const Radius.circular(14));
    canvas.drawRRect(cbRRect, clipFill);
    canvas.drawRRect(cbRRect, clipStroke);

    // 4. Tab klip di atas
    final tabL = w * 0.36;
    final tabT = h * 0.08;
    final tabR = w * 0.60;
    final tabB = h * 0.20;

    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(6)),
      Paint()
        ..color = _EmptyHistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(6)),
      Paint()
        ..color = _EmptyHistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Lubang kecil di tab
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.14),
      3.5,
      Paint()..color = Colors.white,
    );

    // 5. Garis-garis teks di clipboard
    final linePaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.26, h * 0.34), Offset(w * 0.70, h * 0.34), linePaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.44), Offset(w * 0.70, h * 0.44), linePaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.54), Offset(w * 0.54, h * 0.54), linePaint);

    // 6. Lingkaran jam di pojok kanan bawah
    final clockCx = w * 0.72;
    final clockCy = h * 0.77;
    const clockR  = 23.0;

    canvas.drawCircle(
      Offset(clockCx, clockCy + 2.0),
      clockR,
      Paint()
        ..color = const Color(0x20000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _EmptyHistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _EmptyHistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final handPaint = Paint()
      ..color = _EmptyHistoryColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final hourA = math.pi * (-0.40);
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 11 * math.cos(hourA), clockCy + 11 * math.sin(hourA)),
      handPaint,
    );

    final minA = -math.pi / 2;
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 16 * math.cos(minA), clockCy + 16 * math.sin(minA)),
      handPaint,
    );

    canvas.drawCircle(
      Offset(clockCx, clockCy),
      2.5,
      Paint()..color = _EmptyHistoryColors.orange,
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
