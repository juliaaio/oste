import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oste/features/auth/forgot_password/reset_password_page.dart';

/// Palet warna untuk halaman Check Email
class _CheckEmailColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color circleBg = Color(0xFFFAF4E8);
  static const Color emailBadgeBg = Color(0xFFFFF3D6);
  static const Color envelopeGold = Color(0xFFF5A623);
  static const Color envelopeDark = Color(0xFFE08E0B);
  static const Color envelopeLight = Color(0xFFFAB81E);
  static const Color planeGold = Color(0xFFE59C0C);
  static const Color infoCardBg = Color(0xFFFFFDF7);
  static const Color infoCardBorder = Color(0xFFFDE68A);
  static const Color infoAmber = Color(0xFFB45309);
  static const Color infoIconBg = Color(0xFFFEF3C7);
  static const Color linkDark = Color(0xFF334155);
}

/// Halaman Konfirmasi Cek Email
class CheckEmailPage extends StatefulWidget {
  final String email;

  const CheckEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  int _secondsRemaining = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResendEmail() {
    setState(() {
      _secondsRemaining = 59;
    });
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email berhasil dikirim ulang.'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _CheckEmailColors.textDark,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Ilustrasi Amplop & Pesawat Kertas
              const _CheckEmailIllustration(size: 170),
              const SizedBox(height: 28),

              // Judul "Cek Email Anda"
              const Text(
                'Cek Email Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _CheckEmailColors.textDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi pengiriman
              const Text(
                'Kami telah mengirimkan tautan reset\npassword ke',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _CheckEmailColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),

              // Pill Badge Alamat Email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _CheckEmailColors.emailBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.email.isNotEmpty ? widget.email : 'risma@gmail.com',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _CheckEmailColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instruksi tambahan
              const Text(
                'Silakan buka email dan ikuti petunjuk\nyang diberikan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _CheckEmailColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Utama "Buka Email"
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _CheckEmailColors.primaryButterYellow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _CheckEmailColors.primaryButterYellow.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Sementara langsung menuju ResetPasswordPage sesuai instruksi
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: _CheckEmailColors.textDark,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Buka Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _CheckEmailColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TextButton "Kirim Ulang Email (59s)"
              InkWell(
                onTap: _secondsRemaining == 0 ? _handleResendEmail : _handleResendEmail,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    _secondsRemaining > 0
                        ? 'Kirim Ulang Email (${_secondsRemaining}s)'
                        : 'Kirim Ulang Email',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _CheckEmailColors.linkDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Card Informasi Bantuan (Spam Folder)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _CheckEmailColors.infoCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _CheckEmailColors.infoCardBorder.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: _CheckEmailColors.infoIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.info_rounded,
                          size: 19,
                          color: _CheckEmailColors.infoAmber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tidak menerima email?',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _CheckEmailColors.infoAmber,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Periksa folder spam atau coba kirim ulang email.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _CheckEmailColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget Ilustrasi Amplop dan Pesawat Kertas Emas
class _CheckEmailIllustration extends StatelessWidget {
  final double size;

  const _CheckEmailIllustration({this.size = 170});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _CheckEmailColors.circleBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.78,
          height: size * 0.78,
          child: CustomPaint(
            painter: _CheckEmailPainter(),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk Amplop, Pesawat Kertas, dan Trail Lengkung Putus-putus
class _CheckEmailPainter extends CustomPainter {
  const _CheckEmailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dotted Arc Trail (Jejak titik-titik melingkar dari amplop ke pesawat)
    final dotPaint = Paint()
      ..color = const Color(0xFFD4A359)
      ..style = PaintingStyle.fill;

    // Kumpulan titik-titik yang membentuk jejak lengkung berputar (spiral/arc)
    final trailDots = [
      Offset(w * 0.62, h * 0.38),
      Offset(w * 0.65, h * 0.34),
      Offset(w * 0.68, h * 0.30),
      Offset(w * 0.73, h * 0.28),
      Offset(w * 0.78, h * 0.28),
      Offset(w * 0.81, h * 0.32),
      Offset(w * 0.80, h * 0.38),
      Offset(w * 0.76, h * 0.40),
      Offset(w * 0.71, h * 0.37),
      Offset(w * 0.74, h * 0.22),
      Offset(w * 0.78, h * 0.18),
      Offset(w * 0.82, h * 0.16),
      Offset(w * 0.88, h * 0.12),
    ];

    for (final dot in trailDots) {
      canvas.drawCircle(dot, 1.8, dotPaint);
    }

    // 2. Amplop (Envelope)
    final envLeft = w * 0.18;
    final envTop = h * 0.30;
    final envWidth = w * 0.54;
    final envHeight = h * 0.42;
    final envRight = envLeft + envWidth;
    final envBottom = envTop + envHeight;
    final envCenter = envLeft + envWidth / 2;

    // Isi Surat Putih di dalam amplop
    final paperPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final paperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(envLeft + 6, envTop - 10, envWidth - 12, envHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(paperRect, paperPaint);

    // Flap atas yang terbuka (Segitiga menghadap atas)
    final topFlapPaint = Paint()
      ..color = _CheckEmailColors.envelopeLight
      ..style = PaintingStyle.fill;
    final topFlapPath = Path();
    topFlapPath.moveTo(envLeft, envTop + 4);
    topFlapPath.lineTo(envCenter, envTop - 18);
    topFlapPath.lineTo(envRight, envTop + 4);
    topFlapPath.close();
    canvas.drawPath(topFlapPath, topFlapPaint);

    // Badan Amplop Utama (Background kotak amplop)
    final bodyPaint = Paint()
      ..color = _CheckEmailColors.envelopeGold
      ..style = PaintingStyle.fill;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(envLeft, envTop, envWidth, envHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Lipatan samping kiri (Triangular fold)
    final sideFoldPaint = Paint()
      ..color = _CheckEmailColors.envelopeLight
      ..style = PaintingStyle.fill;
    final leftFold = Path();
    leftFold.moveTo(envLeft, envTop);
    leftFold.lineTo(envCenter, envTop + envHeight * 0.55);
    leftFold.lineTo(envLeft, envBottom);
    leftFold.close();
    canvas.drawPath(leftFold, sideFoldPaint);

    // Lipatan samping kanan
    final rightFold = Path();
    rightFold.moveTo(envRight, envTop);
    rightFold.lineTo(envCenter, envTop + envHeight * 0.55);
    rightFold.lineTo(envRight, envBottom);
    rightFold.close();
    canvas.drawPath(rightFold, sideFoldPaint);

    // Lipatan bawah (Bottom fold triangular)
    final bottomFoldPaint = Paint()
      ..color = _CheckEmailColors.envelopeDark
      ..style = PaintingStyle.fill;
    final bottomFold = Path();
    bottomFold.moveTo(envLeft, envBottom);
    bottomFold.lineTo(envCenter, envTop + envHeight * 0.45);
    bottomFold.lineTo(envRight, envBottom);
    bottomFold.close();
    canvas.drawPath(bottomFold, bottomFoldPaint);

    // Garis batas luar halus untuk ketajaman amplop
    final outlinePaint = Paint()
      ..color = const Color(0xFFC67D0A).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(bodyRect, outlinePaint);

    // 3. Pesawat Kertas (Paper Airplane) di kanan atas
    canvas.save();
    canvas.translate(w * 0.88, h * 0.16);
    canvas.rotate(-0.45); // Sudut terbang menyerong ke atas kanan

    final planeBodyPaint = Paint()
      ..color = _CheckEmailColors.planeGold
      ..style = PaintingStyle.fill;

    final planeShadowPaint = Paint()
      ..color = const Color(0xFFC67D0A)
      ..style = PaintingStyle.fill;

    final planeLightWingPaint = Paint()
      ..color = _CheckEmailColors.envelopeLight
      ..style = PaintingStyle.fill;

    // Sayap kiri
    final leftWing = Path();
    leftWing.moveTo(0, -18);
    leftWing.lineTo(-14, 12);
    leftWing.lineTo(0, 5);
    leftWing.close();
    canvas.drawPath(leftWing, planeBodyPaint);

    // Lipatan tengah / badan bawah pesawat
    final centerFold = Path();
    centerFold.moveTo(0, -18);
    centerFold.lineTo(0, 5);
    centerFold.lineTo(3, 14);
    centerFold.close();
    canvas.drawPath(centerFold, planeShadowPaint);

    // Sayap kanan
    final rightWing = Path();
    rightWing.moveTo(0, -18);
    rightWing.lineTo(0, 5);
    rightWing.lineTo(16, 10);
    rightWing.close();
    canvas.drawPath(rightWing, planeLightWingPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
