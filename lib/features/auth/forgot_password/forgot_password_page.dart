import 'package:flutter/material.dart';
import 'package:oste/features/auth/forgot_password/check_email_page.dart';
import 'package:oste/features/auth/login/login_page.dart';

/// Palet warna untuk halaman Forgot Password
class _ForgotPasswordColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color linkAmber = Color(0xFFE5A124);
  static const Color circleBg = Color(0xFFFAF4E8);
  static const Color lockGold = Color(0xFFFAB81E);
  static const Color shackleAmber = Color(0xFF8D4F0E);
  static const Color keyholeDark = Color(0xFF5D2E07);
}

/// Halaman Lupa Password
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Alamat email tidak boleh kosong.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat email tidak boleh kosong.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Format email tidak valid.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid. Pastikan contoh: nama@email.com'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Navigasi ke CheckEmailPage dan kirim email yang diinput
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckEmailPage(email: email),
      ),
    );
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
            color: _ForgotPasswordColors.textDark,
            size: 26,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Ilustrasi Gembok Kuning
                      const _LockIllustration(size: 160),
                      const SizedBox(height: 28),

                      // Judul "Lupa Password?"
                      const Text(
                        'Lupa Password?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _ForgotPasswordColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Deskripsi
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Masukkan alamat email yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang password Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _ForgotPasswordColors.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // TextField Email
                      _buildEmailField(),
                      const SizedBox(height: 22),

                      // Tombol "Kirim Link Reset"
                      _buildSubmitButton(),
                      const SizedBox(height: 24),

                      // TextButton "Kembali ke Login"
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _ForgotPasswordColors.linkAmber,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'Kembali ke Login',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _ForgotPasswordColors.linkAmber,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget TextField Email
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSendResetLink(),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
            style: const TextStyle(
              fontSize: 14,
              color: _ForgotPasswordColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: const TextStyle(
                color: _ForgotPasswordColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: _ForgotPasswordColors.textLight,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 46),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _errorMessage != null
                      ? const Color(0xFFE11D48)
                      : _ForgotPasswordColors.inputBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _errorMessage != null
                      ? const Color(0xFFE11D48)
                      : _ForgotPasswordColors.primaryButterYellow,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// Widget Tombol "Kirim Link Reset"
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: _ForgotPasswordColors.primaryButterYellow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _ForgotPasswordColors.primaryButterYellow.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSendResetLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _ForgotPasswordColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Kirim Link Reset',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _ForgotPasswordColors.textDark,
          ),
        ),
      ),
    );
  }
}

/// Widget Ilustrasi Gembok Kuning
class _LockIllustration extends StatelessWidget {
  final double size;

  const _LockIllustration({this.size = 160});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _ForgotPasswordColors.circleBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.45,
          height: size * 0.58,
          child: CustomPaint(
            painter: _LockPainter(),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar gembok kuning presisi
class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Shackle (Lengkungan atas gembok)
    final shacklePaint = Paint()
      ..color = _ForgotPasswordColors.shackleAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.16
      ..strokeCap = StrokeCap.round;

    final shacklePath = Path();
    final shackleLeft = w * 0.23;
    final shackleRight = w * 0.77;
    final shackleTop = h * 0.08;
    final shackleBottom = h * 0.48;

    shacklePath.moveTo(shackleLeft, shackleBottom);
    shacklePath.lineTo(shackleLeft, shackleTop + (shackleRight - shackleLeft) / 2);
    shacklePath.arcToPoint(
      Offset(shackleRight, shackleTop + (shackleRight - shackleLeft) / 2),
      radius: Radius.circular((shackleRight - shackleLeft) / 2),
      clockwise: true,
    );
    shacklePath.lineTo(shackleRight, shackleBottom);

    canvas.drawPath(shacklePath, shacklePaint);

    // 2. Badan Gembok (Kotak melengkung kuning emas)
    final bodyPaint = Paint()
      ..color = _ForgotPasswordColors.lockGold
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.38, w, h * 0.62),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Highlight lembut pada bagian atas badan gembok
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.42, w * 0.84, h * 0.10),
      const Radius.circular(6),
    );
    canvas.drawRRect(highlightRect, highlightPaint);

    // 3. Lubang Kunci (Keyhole)
    final keyholePaint = Paint()
      ..color = _ForgotPasswordColors.keyholeDark
      ..style = PaintingStyle.fill;

    final keyholeCenter = Offset(w * 0.5, h * 0.65);
    final keyholeCircleRadius = w * 0.085;
    canvas.drawCircle(keyholeCenter, keyholeCircleRadius, keyholePaint);

    final slotPath = Path();
    slotPath.moveTo(keyholeCenter.dx - w * 0.045, keyholeCenter.dy + keyholeCircleRadius * 0.4);
    slotPath.lineTo(keyholeCenter.dx + w * 0.045, keyholeCenter.dy + keyholeCircleRadius * 0.4);
    slotPath.lineTo(keyholeCenter.dx + w * 0.07, keyholeCenter.dy + h * 0.17);
    slotPath.lineTo(keyholeCenter.dx - w * 0.07, keyholeCenter.dy + h * 0.17);
    slotPath.close();

    canvas.drawPath(slotPath, keyholePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
