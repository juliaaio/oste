import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/core/utils/password_validator.dart';
import 'package:oste/core/widgets/password_requirements_card.dart';
import 'package:oste/features/auth/login/login_page.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/services/user_service.dart';

/// Palet warna halaman Register
class _RegisterColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color badgeBg = Color(0xFFFFF5DD);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color linkAmber = Color(0xFFE5A124);
}

/// Halaman Register Osteocare
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  bool get _hasMinLength =>
      PasswordValidator.hasMinLength(_passwordController.text);
  bool get _hasUppercase =>
      PasswordValidator.hasUppercase(_passwordController.text);
  bool get _hasLowercase =>
      PasswordValidator.hasLowercase(_passwordController.text);
  bool get _hasDigit => PasswordValidator.hasDigit(_passwordController.text);
  bool get _hasSpecialChar =>
      PasswordValidator.hasSpecialChar(_passwordController.text);

  /// Validasi format email menggunakan RegExp.
  /// Email tidak boleh kosong, tidak boleh mengandung spasi,
  /// dan harus memiliki format yang valid (contoh: user@gmail.com).
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    if (email.contains(' ')) return false;
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  bool get _isPasswordValid =>
      PasswordValidator.isValid(_passwordController.text);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    // Tutup keyboard terlebih dahulu agar layout stabil dan tidak menginterupsi klik
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final messenger = ScaffoldMessenger.of(context);

    // Validasi kelengkapan data
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua data formulir registrasi.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Validasi format email
    if (!_isValidEmail(email)) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Format email tidak valid. Contoh: user@gmail.com',
          ),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Validasi syarat password
    if (!_isPasswordValid) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password belum memenuhi seluruh syarat yang ditentukan.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Validasi kecocokan password
    if (password != confirmPassword) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password dan konfirmasi password tidak cocok.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Validasi persetujuan syarat & ketentuan
    if (!_agreedToTerms) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan serta Kebijakan Privasi.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Daftarkan ke Firebase Auth + buat dokumen Firestore + muat profil
    final error = await UserService().register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _isLoading = false);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      return;
    }

    // Registrasi berhasil → navigasi langsung ke Dashboard
    messenger.hideCurrentSnackBar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Dekorasi gradasi butter yellow lembut di atas dan bawah
          const Positioned.fill(
            child: _RegisterBackgroundGradients(),
          ),

          // 2. Konten formulir yang scrollable dan responsive
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // Logo Medallion Osteocare di bagian atas
                  const SizedBox(
                    width: 145,
                    height: 145,
                    child: CustomPaint(
                      painter: _OsteocareLogoPainter(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul "Osteocare"
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Osteo',
                          style: TextStyle(
                            color: _RegisterColors.textDark,
                          ),
                        ),
                        TextSpan(
                          text: 'care',
                          style: TextStyle(
                            color: _RegisterColors.primaryButterYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle "Selamat Datang"
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: _RegisterColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Deskripsi
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Masuk untuk melanjutkan perjalanan\nkesehatan tulangmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: _RegisterColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // 1. TextField Nama Lengkap
                  _buildInputField(
                    controller: _nameController,
                    hint: 'Nama Lengkap',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // 2. TextField Email
                  _buildInputField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // 3. TextField Nomor Telepon
                  _buildInputField(
                    controller: _phoneController,
                    hint: 'Nomor Telepon',
                    icon: Icons.smartphone_rounded,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // 4. TextField Password
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscure: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 14),

                  // 5. TextField Konfirmasi Password
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: 'Konfirmasi Pasword',
                    obscure: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),

                  // 6. Card Informasi Persyaratan Password
                  _buildPasswordRequirementsCard(),
                  const SizedBox(height: 16),

                  // 7. Checkbox Syarat & Ketentuan
                  _buildTermsCheckbox(),
                  const SizedBox(height: 22),

                  // 8. Tombol Utama "Daftar →"
                  _buildRegisterButton(),
                  const SizedBox(height: 20),

                  // 9. Divider "atau"
                  _buildDivider(),
                  const SizedBox(height: 20),

                  // 10. Tombol "Daftar dengan Google"
                  _buildGoogleSignUpButton(),
                  const SizedBox(height: 22),

                  // 11. Tulisan "Sudah punya akun? Masuk"
                  _buildLoginPrompt(),
                  const SizedBox(height: 26),

                  // 12. Footer: Garis Hati & Motto
                  const SizedBox(
                    width: 150,
                    height: 18,
                    child: CustomPaint(
                      painter: _HeartDividerPainter(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tulang yang Sehat,\nMasa Depan yang Lebih Kuat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: _RegisterColors.textLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk membuat TextField umum dengan border radius 30
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontSize: 14,
          color: _RegisterColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _RegisterColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              icon,
              size: 20,
              color: _RegisterColors.textLight,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: _RegisterColors.inputBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: _RegisterColors.primaryButterYellow,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper untuk membuat TextField Password dengan toggle visibility & border radius 30
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction textInputAction,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
        obscureText: obscure,
        textInputAction: textInputAction,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: _RegisterColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _RegisterColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: _RegisterColors.textLight,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: _RegisterColors.textLight,
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: _RegisterColors.inputBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: _RegisterColors.primaryButterYellow,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  /// Card Informasi Persyaratan Password
  Widget _buildPasswordRequirementsCard() {
    return PasswordRequirementsCard(
      hasMinLength: _hasMinLength,
      hasUppercase: _hasUppercase,
      hasLowercase: _hasLowercase,
      hasDigit: _hasDigit,
      hasSpecialChar: _hasSpecialChar,
    );
  }

  /// Checkbox Syarat & Ketentuan serta Kebijakan Privasi
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: _RegisterColors.primaryButterYellow,
            checkColor: _RegisterColors.textDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(
              color: Color(0xFFCBD5E1),
              width: 1.4,
            ),
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreedToTerms = !_agreedToTerms;
              });
            },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  color: _RegisterColors.textMuted,
                  height: 1.35,
                ),
                children: [
                  TextSpan(text: 'Saya menyetujui '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: TextStyle(
                      color: _RegisterColors.linkAmber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      color: _RegisterColors.linkAmber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tombol Utama "Daftar →" dengan border radius 30
  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: _RegisterColors.primaryButterYellow,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _RegisterColors.primaryButterYellow.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _RegisterColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _RegisterColors.textDark,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _RegisterColors.textDark,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: _RegisterColors.textDark,
                  ),
                ],
              ),
      ),
    );
  }

  /// Pembatas "atau"
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFECEFF1),
            thickness: 1.2,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _RegisterColors.textLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFECEFF1),
            thickness: 1.2,
          ),
        ),
      ],
    );
  }

  /// Tombol "Daftar dengan Google" dengan border radius 30
  Widget _buildGoogleSignUpButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _RegisterColors.inputBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            // Aksi Google SignUp belum perlu diimplementasikan
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: _GoogleLogoPainter(),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Daftar dengan Google',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _RegisterColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Teks "Sudah punya akun? Masuk"
  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun? ',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: _RegisterColors.textMuted,
          ),
        ),
        InkWell(
          onTap: () {
            // Navigasi ke LoginPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Text(
              'Masuk',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _RegisterColors.linkAmber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DEKORASI GRADASI BUTTER YELLOW LEMBUT DI ATAS & BAWAH
// =============================================================================
class _RegisterBackgroundGradients extends StatelessWidget {
  const _RegisterBackgroundGradients();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradasi lembut butter yellow di atas
        Positioned(
          top: -50,
          left: -40,
          right: -40,
          height: 260,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.4),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFF3CB).withValues(alpha: 0.65),
                  const Color(0xFFFFF8E4).withValues(alpha: 0.30),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Gradasi lembut butter yellow di bawah
        Positioned(
          bottom: -60,
          left: -40,
          right: -40,
          height: 280,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.5),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFF4D2).withValues(alpha: 0.65),
                  const Color(0xFFFFF9E7).withValues(alpha: 0.30),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// LOGO MEDALLION OSTEOCARE (CUSTOM PAINTER)
// =============================================================================
class _OsteocareLogoPainter extends CustomPainter {
  const _OsteocareLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Lingkaran Medallion Kuning Pastel Lembut
    final badgePaint = Paint()
      ..color = _RegisterColors.badgeBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, badgePaint);

    // 2. Kilau bintang (Sparkle) di kiri atas tulang
    final sparklePaint = Paint()
      ..color = _RegisterColors.primaryButterYellow
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(size.width * 0.44, size.height * 0.34), 7.0, sparklePaint);

    // 3. Ring orbital emas yang melingkari tulang
    final ringPaint = Paint()
      ..color = _RegisterColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final ringPath = Path();
    ringPath.moveTo(size.width * 0.38, size.height * 0.42);
    ringPath.cubicTo(
      size.width * 0.22,
      size.height * 0.56,
      size.width * 0.45,
      size.height * 0.70,
      size.width * 0.68,
      size.height * 0.64,
    );
    canvas.drawPath(ringPath, ringPaint);

    // 4. Tulang diagonal di tengah
    canvas.save();
    canvas.translate(size.width * 0.50, size.height * 0.50);
    canvas.rotate(-0.58);

    final boneFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final boneStroke = Paint()
      ..color = _RegisterColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    bonePath.moveTo(-10, -34);
    bonePath.cubicTo(-19, -44, -3, -49, 0, -39);
    bonePath.cubicTo(3, -49, 19, -44, 10, -34);
    bonePath.cubicTo(8, -15, 8, 15, 10, 34);
    bonePath.cubicTo(19, 44, 3, 49, 0, 39);
    bonePath.cubicTo(-3, 49, -19, 44, -10, 34);
    bonePath.cubicTo(-8, 15, -8, -15, -10, -34);
    bonePath.close();

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    canvas.restore();

    // 5. Daun herbal emas di kanan bawah
    final leafPaint = Paint()
      ..color = _RegisterColors.primaryButterYellow
      ..style = PaintingStyle.fill;

    final leafPath1 = Path();
    leafPath1.moveTo(size.width * 0.64, size.height * 0.62);
    leafPath1.quadraticBezierTo(
      size.width * 0.80,
      size.height * 0.54,
      size.width * 0.75,
      size.height * 0.68,
    );
    leafPath1.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.68,
      size.width * 0.64,
      size.height * 0.62,
    );
    leafPath1.close();
    canvas.drawPath(leafPath1, leafPaint);

    final leafPath2 = Path();
    leafPath2.moveTo(size.width * 0.64, size.height * 0.67);
    leafPath2.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.68,
      size.width * 0.74,
      size.height * 0.79,
    );
    leafPath2.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.76,
      size.width * 0.64,
      size.height * 0.67,
    );
    leafPath2.close();
    canvas.drawPath(leafPath2, leafPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// LOGO GOOGLE (CUSTOM PAINTER OTENTIK 4 WARNA)
// =============================================================================
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 3.6;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // 1. Busur Biru Google (Kanan & Atas)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, bluePaint);

    // 2. Busur Hijau Google (Kanan Bawah)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, math.pi / 4, math.pi / 2, false, greenPaint);

    // 3. Busur Kuning Google (Kiri Bawah)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 3 * math.pi / 4, math.pi / 2, false, yellowPaint);

    // 4. Busur Merah Google (Kiri Atas)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 5 * math.pi / 4, math.pi / 2, false, redPaint);

    // 5. Garis horizontal biru tengah huruf 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx - 1, center.dy),
      Offset(size.width - strokeWidth / 2, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// DIVIDER GARIS DENGAN HATI DI TENGAH
// =============================================================================
class _HeartDividerPainter extends CustomPainter {
  const _HeartDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _RegisterColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cy = size.height / 2;
    final cx = size.width / 2;

    // Garis kiri
    canvas.drawLine(Offset(0, cy), Offset(cx - 14, cy), paint);

    // Garis kanan
    canvas.drawLine(Offset(cx + 14, cy), Offset(size.width, cy), paint);

    // Bentuk loop hati di tengah
    final heartPath = Path();
    heartPath.moveTo(cx, cy + 7);
    heartPath.cubicTo(cx - 11, cy - 2, cx - 9, cy - 8, cx, cy - 3.5);
    heartPath.cubicTo(cx + 9, cy - 8, cx + 11, cy - 2, cx, cy + 7);
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
