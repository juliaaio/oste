import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oste/features/dashboard/dashboard_page.dart';
import 'package:oste/features/auth/register/register_page.dart';
import 'package:oste/features/auth/forgot_password/forgot_password_page.dart';

/// Palet warna halaman Login
class _LoginColors {
  static const Color primaryButterYellow = Color(0xFFF7C948);
  static const Color badgeBg = Color(0xFFFFF5DD);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color linkAmber = Color(0xFFE5A124);
}

/// Halaman Login Osteocare
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Dekorasi gradasi butter yellow lembut di atas dan bawah
          const Positioned.fill(
            child: _LoginBackgroundGradients(),
          ),

          // 2. Konten utama yang responsive dan scrollable
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 28),

                  // Logo Medallion Osteocare di bagian atas
                  const SizedBox(
                    width: 155,
                    height: 155,
                    child: CustomPaint(
                      painter: _OsteocareLogoPainter(),
                    ),
                  ),
                  const SizedBox(height: 18),

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
                            color: _LoginColors.textDark,
                          ),
                        ),
                        TextSpan(
                          text: 'care',
                          style: TextStyle(
                            color: _LoginColors.primaryButterYellow,
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
                      color: _LoginColors.textDark,
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
                        color: _LoginColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // TextField Email
                  _buildEmailField(),
                  const SizedBox(height: 14),

                  // TextField Password
                  _buildPasswordField(),
                  const SizedBox(height: 10),

                  // Tombol "Lupa Password?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _LoginColors.linkAmber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tombol Utama "Masuk →"
                  _buildLoginButton(),
                  const SizedBox(height: 20),

                  // Divider "atau"
                  _buildDivider(),
                  const SizedBox(height: 20),

                  // Tombol "Masuk dengan Google"
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 22),

                  // Teks "Belum punya akun? Daftar"
                  _buildRegisterPrompt(),
                  const SizedBox(height: 28),

                  // Footer: Garis Hati & Motto
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
                      color: _LoginColors.textLight,
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

  /// Widget TextField Email dengan rounded border lembut
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 14,
          color: _LoginColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: const TextStyle(
            color: _LoginColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.mail_outline_rounded,
              size: 20,
              color: _LoginColors.textLight,
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
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: _LoginColors.inputBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: _LoginColors.primaryButterYellow,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget TextField Password dengan fitur show/hide password
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          fontSize: 14,
          color: _LoginColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(
            color: _LoginColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: _LoginColors.textLight,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: _LoginColors.textLight,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: _LoginColors.inputBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: _LoginColors.primaryButterYellow,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget Tombol Utama "Masuk →"
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: _LoginColors.primaryButterYellow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _LoginColors.primaryButterYellow.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigasi ke DashboardPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _LoginColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _LoginColors.textDark,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: _LoginColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Pembatas "atau"
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
              color: _LoginColors.textLight,
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

  /// Widget Tombol "Masuk dengan Google"
  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _LoginColors.inputBorder,
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
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // Aksi login Google sementara kosong
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
                'Masuk dengan Google',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _LoginColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget "Belum punya akun? Daftar"
  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: _LoginColors.textMuted,
          ),
        ),
        InkWell(
          onTap: () {
            // Navigasi ke RegisterPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RegisterPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Text(
              'Daftar',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _LoginColors.linkAmber,
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
class _LoginBackgroundGradients extends StatelessWidget {
  const _LoginBackgroundGradients();

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
      ..color = _LoginColors.badgeBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, badgePaint);

    // 2. Kilau bintang (Sparkle) di kiri atas tulang
    final sparklePaint = Paint()
      ..color = _LoginColors.primaryButterYellow
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(size.width * 0.44, size.height * 0.34), 7.5, sparklePaint);

    // 3. Ring orbital emas yang melingkari tulang
    final ringPaint = Paint()
      ..color = _LoginColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
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
      ..color = _LoginColors.primaryButterYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bonePath = Path();
    // Kepala atas
    bonePath.moveTo(-10, -36);
    bonePath.cubicTo(-20, -46, -3, -51, 0, -41);
    bonePath.cubicTo(3, -51, 20, -46, 10, -36);
    // Batang kanan
    bonePath.cubicTo(8, -16, 8, 16, 10, 36);
    // Kepala bawah
    bonePath.cubicTo(20, 46, 3, 51, 0, 41);
    bonePath.cubicTo(-3, 51, -20, 46, -10, 36);
    // Batang kiri
    bonePath.cubicTo(-8, 16, -8, -16, -10, -36);
    bonePath.close();

    canvas.drawPath(bonePath, boneFill);
    canvas.drawPath(bonePath, boneStroke);

    canvas.restore();

    // 5. Daun herbal emas di kanan bawah
    final leafPaint = Paint()
      ..color = _LoginColors.primaryButterYellow
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
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
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
      ..color = _LoginColors.primaryButterYellow
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


