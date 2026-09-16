import 'package:flutter/material.dart';
import 'package:oste/features/auth/login/login_page.dart';

/// Palet warna untuk halaman Password Success
class _PasswordSuccessColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color checkGreen = Color(0xFF48BB78);
  static const Color checkBgMint = Color(0xFFE8F7ED);
}

/// Halaman Sukses Reset Password
class PasswordSuccessPage extends StatelessWidget {
  const PasswordSuccessPage({super.key});

  void _handleGoToLogin(BuildContext context) {
    // Navigasi pushAndRemoveUntil menuju LoginPage agar riwayat halaman reset terhapus
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleGoToLogin(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Ilustrasi Centang Hijau
                const _SuccessCheckIllustration(size: 165),
                const SizedBox(height: 36),

                // Judul "Password Berhasil Diubah"
                const Text(
                  'Password Berhasil\nDiubah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _PasswordSuccessColors.textDark,
                    letterSpacing: -0.4,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Deskripsi
                const Text(
                  'Password Anda telah berhasil diperbarui.\nSekarang Anda bisa masuk dengan\npassword baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _PasswordSuccessColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Tombol Utama "Masuk Sekarang"
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _PasswordSuccessColors.primaryButterYellow,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _PasswordSuccessColors.primaryButterYellow.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _handleGoToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: _PasswordSuccessColors.textDark,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _PasswordSuccessColors.textDark,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget Ilustrasi Centang Hijau Bertingkat (Green Checkmark Badge)
class _SuccessCheckIllustration extends StatelessWidget {
  final double size;

  const _SuccessCheckIllustration({this.size = 165});

  @override
  Widget build(BuildContext context) {
    final innerSize = size * 0.65;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _PasswordSuccessColors.checkBgMint,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            color: _PasswordSuccessColors.checkGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _PasswordSuccessColors.checkGreen.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}
