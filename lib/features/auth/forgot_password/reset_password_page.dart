import 'package:flutter/material.dart';
import 'package:oste/features/auth/forgot_password/password_success_page.dart';

/// Palet warna untuk halaman Reset Password
class _ResetPasswordColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color circleBg = Color(0xFFFAF4E8);
  static const Color lockGold = Color(0xFFFAB81E);
  static const Color shackleAmber = Color(0xFF8D4F0E);
  static const Color keyholeDark = Color(0xFF5D2E07);
  static const Color refreshTeal = Color(0xFF0D9488);
  static const Color requirementCardBg = Color(0xFFFFFDF8);
  static const Color requirementCardBorder = Color(0xFFFDE68A);
  static const Color requirementHeaderAmber = Color(0xFFB45309);
  static const Color radioUnchecked = Color(0xFFD4B896);
  static const Color checkSuccess = Color(0xFF16A34A);
}

/// Halaman Buat Password Baru
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMin8Chars => _passwordController.text.length >= 8;
  bool get _hasUpperAndLower =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_passwordController.text);
  bool get _hasDigits =>
      RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChars =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);

  void _handleSavePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi password baru dan konfirmasi password.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal harus 8 karakter.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan konfirmasi password tidak sama.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Jika valid, navigasi ke PasswordSuccessPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordSuccessPage(),
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
            color: _ResetPasswordColors.textDark,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Ilustrasi Gembok Kuning dengan Badge Refresh Teal
              const Center(
                child: _ResetLockIllustration(size: 160),
              ),
              const SizedBox(height: 24),

              // Judul "Buat Password Baru"
              const Center(
                child: Text(
                  'Buat Password Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _ResetPasswordColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Deskripsi
              const Center(
                child: Text(
                  'Masukkan password baru Anda untuk\nmengakses kembali akun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _ResetPasswordColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Label & Field: Password Baru
              const Text(
                'Password Baru',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _ResetPasswordColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _passwordController,
                hintText: 'Minimal 8 karakter',
                isObscured: _obscurePassword,
                onToggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Label & Field: Konfirmasi Password
              const Text(
                'Konfirmasi Password',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _ResetPasswordColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: 'Masukkan ulang password',
                isObscured: _obscureConfirmPassword,
                onToggleObscure: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              // Card Syarat Password ("Password harus mengandung:")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: _ResetPasswordColors.requirementCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _ResetPasswordColors.requirementCardBorder.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password harus mengandung:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _ResetPasswordColors.requirementHeaderAmber,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementRow(
                      'Minimal 8 karakter',
                      _hasMin8Chars,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementRow(
                      'Huruf besar dan huruf kecil',
                      _hasUpperAndLower,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementRow(
                      'Angka',
                      _hasDigits,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementRow(
                      'Karakter khusus (contoh: !@#)',
                      _hasSpecialChars,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Tombol "Simpan Password"
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _ResetPasswordColors.primaryButterYellow,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _ResetPasswordColors.primaryButterYellow.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _handleSavePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: _ResetPasswordColors.textDark,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ResetPasswordColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget TextField Password dengan toggle visibility
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleObscure,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
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
        controller: controller,
        obscureText: isObscured,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: _ResetPasswordColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: _ResetPasswordColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: _ResetPasswordColors.textLight,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 46),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _ResetPasswordColors.textLight,
            ),
            onPressed: onToggleObscure,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _ResetPasswordColors.inputBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _ResetPasswordColors.primaryButterYellow,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  /// Baris item syarat password dengan indikator lingkaran
  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet ? _ResetPasswordColors.checkSuccess : Colors.transparent,
            border: Border.all(
              color: isMet
                  ? _ResetPasswordColors.checkSuccess
                  : _ResetPasswordColors.radioUnchecked,
              width: 1.5,
            ),
          ),
          child: isMet
              ? const Center(
                  child: Icon(
                    Icons.check,
                    size: 11,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            color: isMet
                ? _ResetPasswordColors.textDark
                : _ResetPasswordColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Widget Ilustrasi Gembok Kuning dengan Badge Refresh
class _ResetLockIllustration extends StatelessWidget {
  final double size;

  const _ResetLockIllustration({this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Lingkaran Latar Belakang
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: _ResetPasswordColors.circleBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.45,
                height: size * 0.58,
                child: const CustomPaint(
                  painter: _ResetLockPainter(),
                ),
              ),
            ),
          ),

          // Badge Refresh Putih & Lingkaran Hijau Toska di kanan bawah gembok
          Positioned(
            right: size * 0.16,
            bottom: size * 0.08,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFCCFBF1),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.refresh_rounded,
                  size: 22,
                  color: _ResetPasswordColors.refreshTeal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter untuk menggambar Gembok Kuning
class _ResetLockPainter extends CustomPainter {
  const _ResetLockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Shackle (Lengkungan atas gembok)
    final shacklePaint = Paint()
      ..color = _ResetPasswordColors.shackleAmber
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

    // 2. Badan Gembok
    final bodyPaint = Paint()
      ..color = _ResetPasswordColors.lockGold
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.38, w, h * 0.62),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Highlight lembut
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
      ..color = _ResetPasswordColors.keyholeDark
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
