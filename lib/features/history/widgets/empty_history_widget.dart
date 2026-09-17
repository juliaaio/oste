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
///
/// Ditampilkan ketika pengguna belum memiliki riwayat skrining apapun.
/// Terdiri atas ilustrasi clipboard-jam, judul, teks deskripsi,
/// dan tombol "Mulai Skrining".
class EmptyHistoryWidget extends StatelessWidget {
  /// Callback dipanggil ketika tombol "Mulai Skrining" ditekan.
  /// Jika null, tombol tetap ditampilkan namun tidak melakukan navigasi.
  final VoidCallback? onStartScreening;

  const EmptyHistoryWidget({
    super.key,
    this.onStartScreening,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ilustrasi clipboard + jam ─────────────────────────────
            const SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _ClipboardClockPainter(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Judul ─────────────────────────────────────────────────
            const Text(
              'Belum ada riwayat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _EmptyHistoryColors.textDark,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 10),

            // ── Teks deskripsi ────────────────────────────────────────
            const Text(
              'Hasil skrining Anda akan muncul di sini setelah melakukan skrining.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: _EmptyHistoryColors.textMuted,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 28),

            // ── Tombol "Mulai Skrining" ───────────────────────────────
            SizedBox(
              width: 180,
              height: 50,
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
                child: const Text(
                  'Mulai Skrining',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _EmptyHistoryColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painter – Ilustrasi besar clipboard + jam (versi centered/besar)
// ---------------------------------------------------------------------------
class _ClipboardClockPainter extends CustomPainter {
  const _ClipboardClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Lingkaran latar kuning muda ───────────────────────────────
    canvas.drawCircle(
      Offset(w * 0.48, h * 0.52),
      w * 0.42,
      Paint()
        ..color = _EmptyHistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );

    // ── 2. Sparkle / kilau bintang ───────────────────────────────────
    final sparklePaint = Paint()
      ..color = _EmptyHistoryColors.primaryYellow
      ..style = PaintingStyle.fill;

    _sparkle(canvas, Offset(w * 0.06, h * 0.28), 7.0, sparklePaint);
    _sparkle(canvas, Offset(w * 0.94, h * 0.18), 6.0, sparklePaint);
    _sparkle(canvas, Offset(w * 0.90, h * 0.74), 5.0, sparklePaint);
    _sparkle(canvas, Offset(w * 0.08, h * 0.72), 4.5, sparklePaint);

    // ── 3. Badan clipboard ───────────────────────────────────────────
    final cbL = w * 0.16;
    final cbT = h * 0.14;
    final cbR = w * 0.78;
    final cbB = h * 0.86;

    final clipFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final clipStroke = Paint()
      ..color = _EmptyHistoryColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;

    final cbRRect = RRect.fromLTRBR(cbL, cbT, cbR, cbB, const Radius.circular(16));
    canvas.drawRRect(cbRRect, clipFill);
    canvas.drawRRect(cbRRect, clipStroke);

    // ── 4. Tab klip di atas ──────────────────────────────────────────
    final tabL = w * 0.34;
    final tabT = h * 0.07;
    final tabR = w * 0.58;
    final tabB = h * 0.20;

    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(7)),
      Paint()
        ..color = _EmptyHistoryColors.primaryYellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(tabL, tabT, tabR, tabB, const Radius.circular(7)),
      Paint()
        ..color = _EmptyHistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Lubang kecil di tab
    canvas.drawCircle(
      Offset(w * 0.46, h * 0.135),
      4.0,
      Paint()..color = Colors.white,
    );

    // ── 5. Garis-garis teks di clipboard ─────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.24, h * 0.34), Offset(w * 0.70, h * 0.34), linePaint);
    canvas.drawLine(Offset(w * 0.24, h * 0.44), Offset(w * 0.70, h * 0.44), linePaint);
    canvas.drawLine(Offset(w * 0.24, h * 0.54), Offset(w * 0.54, h * 0.54), linePaint);

    // ── 6. Lingkaran jam di pojok kanan bawah ────────────────────────
    final clockCx = w * 0.72;
    final clockCy = h * 0.77;
    const clockR  = 26.0;

    // Bayangan lembut
    canvas.drawCircle(
      Offset(clockCx, clockCy + 2.0),
      clockR,
      Paint()
        ..color = const Color(0x20000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Latar jam kuning muda
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _EmptyHistoryColors.yellowCircleBg
        ..style = PaintingStyle.fill,
    );
    // Border jam
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      clockR,
      Paint()
        ..color = _EmptyHistoryColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    // Jarum jam (pendek) – mengarah ~jam 10
    final handPaint = Paint()
      ..color = _EmptyHistoryColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final hourA = math.pi * (-0.40);
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 13 * math.cos(hourA), clockCy + 13 * math.sin(hourA)),
      handPaint,
    );

    // Jarum menit (panjang) – mengarah ke atas
    final minA = -math.pi / 2;
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 19 * math.cos(minA), clockCy + 19 * math.sin(minA)),
      handPaint,
    );

    // Titik pusat jam
    canvas.drawCircle(
      Offset(clockCx, clockCy),
      3.0,
      Paint()
        ..color = _EmptyHistoryColors.orange
        ..style = PaintingStyle.fill,
    );
  }

  /// Menggambar sparkle (bintang 4 sisi) di [center] dengan ukuran [size].
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
