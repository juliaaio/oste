import 'package:flutter/material.dart';
import '../../../models/doctor_model.dart';
import '../../../services/doctor_repository.dart';
import '../articles/admin_articles_page.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../doctors/add_doctor_page.dart';
import '../doctors/edit_doctor_page.dart';
import '../education/admin_education_page.dart';
import '../profile/admin_profile_page.dart';

/// Palet warna tema Admin Kelola Dokter Osteo sesuai spesifikasi desain & screenshot
class _AdminDoctorColors {
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowCardBg = Color(0xFFFFF4D2);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color navActivePill = Color(0xFFFDE89C);

  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7DE);
  static const Color searchBorder = Color(0xFFE2DCD5);

  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF6B635B);
  static const Color textMuted = Color(0xFF8A827A);

  // Status Badge
  static const Color activeGreen = Color(0xFF1B6B38);
  static const Color activeGreenBg = Color(0xFFD1F2D9);
  static const Color inactiveRed = Color(0xFF991B1B);
  static const Color inactiveRedBg = Color(0xFFFDE8E8);

  // Tombol Aksi
  static const Color editIcon = Color(0xFF332011);
  static const Color deleteIcon = Color(0xFFEF4444);
}

/// Painter logo tulang Osteo miring dengan outline dan fill butter yellow
class _BoneLogoPainter extends CustomPainter {
  final Color outlineColor;
  final Color fillColor;

  const _BoneLogoPainter({
    required this.outlineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-0.65); // Kemiringan proporsional sesuai logo

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.54, height: h * 0.28),
      Radius.circular(h * 0.14),
    );

    final leftX = -w * 0.26;
    final rightX = w * 0.26;
    final bumpR = h * 0.17;
    final bumpY = h * 0.12;

    final path = Path()
      ..addRRect(shaftRect)
      ..addOval(
          Rect.fromCircle(center: Offset(leftX, -bumpY), radius: bumpR))
      ..addOval(Rect.fromCircle(center: Offset(leftX, bumpY), radius: bumpR))
      ..addOval(
          Rect.fromCircle(center: Offset(rightX, -bumpY), radius: bumpR))
      ..addOval(Rect.fromCircle(center: Offset(rightX, bumpY), radius: bumpR));

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoneLogoPainter oldDelegate) =>
      outlineColor != oldDelegate.outlineColor ||
      fillColor != oldDelegate.fillColor;
}

/// Painter outline stetoskop untuk icon Bottom Navigation
class _StethoscopePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _StethoscopePainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final leftTip = Offset(w * 0.26, h * 0.16);
    final rightTip = Offset(w * 0.74, h * 0.16);
    canvas.drawCircle(leftTip, strokeWidth * 0.85, fillPaint);
    canvas.drawCircle(rightTip, strokeWidth * 0.85, fillPaint);

    final path = Path()
      ..moveTo(leftTip.dx, leftTip.dy)
      ..quadraticBezierTo(w * 0.22, h * 0.38, w * 0.50, h * 0.44)
      ..moveTo(rightTip.dx, rightTip.dy)
      ..quadraticBezierTo(w * 0.78, h * 0.38, w * 0.50, h * 0.44)
      ..lineTo(w * 0.50, h * 0.62)
      ..cubicTo(
        w * 0.50,
        h * 0.86,
        w * 0.84,
        h * 0.86,
        w * 0.84,
        h * 0.66,
      )
      ..lineTo(w * 0.84, h * 0.52);

    canvas.drawPath(path, strokePaint);

    final chestCenter = Offset(w * 0.84, h * 0.43);
    canvas.drawCircle(chestCenter, w * 0.12, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Painter outline dokumen artikel untuk Bottom Navigation
class _DocumentIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DocumentIconPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final fold = w * 0.28;
    final left = w * 0.18;
    final top = h * 0.14;
    final right = w * 0.82;
    final bottom = h * 0.86;
    final radius = w * 0.08;

    final path = Path()
      ..moveTo(left + radius, top)
      ..lineTo(right - fold, top)
      ..lineTo(right, top + fold)
      ..lineTo(right, bottom - radius)
      ..quadraticBezierTo(right, bottom, right - radius, bottom)
      ..lineTo(left + radius, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - radius)
      ..lineTo(left, top + radius)
      ..quadraticBezierTo(left, top, left + radius, top)
      ..close()
      ..moveTo(right - fold, top)
      ..lineTo(right - fold, top + fold)
      ..lineTo(right, top + fold);

    canvas.drawPath(path, strokePaint);

    final lineStartX = left + w * 0.14;
    final lineEndX = right - w * 0.14;

    canvas.drawLine(
      Offset(lineStartX, top + h * 0.34),
      Offset(lineEndX, top + h * 0.34),
      strokePaint,
    );
    canvas.drawLine(
      Offset(lineStartX, top + h * 0.48),
      Offset(lineEndX, top + h * 0.48),
      strokePaint,
    );
    canvas.drawLine(
      Offset(lineStartX, top + h * 0.62),
      Offset(lineStartX + (lineEndX - lineStartX) * 0.55, top + h * 0.62),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DocumentIconPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Halaman Admin Daftar / Kelola Dokter OSTEOCARE
/// Mengacu 1:1 pada desain visual screenshot Menu Kelola Dokter.
class AdminDoctorListPage extends StatefulWidget {
  const AdminDoctorListPage({super.key});

  @override
  State<AdminDoctorListPage> createState() => _AdminDoctorListPageState();
}

class _AdminDoctorListPageState extends State<AdminDoctorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Menampilkan dialog konfirmasi hapus dokter
  void _confirmDeleteDoctor(BuildContext context, DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: _AdminDoctorColors.deleteIcon,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                'Hapus Dokter?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _AdminDoctorColors.textMain,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data ${doctor.name}? Data dokter akan dihapus dari Cloud Firestore dan tidak dapat dikembalikan.',
            style: const TextStyle(
              fontSize: 13.5,
              color: _AdminDoctorColors.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: _AdminDoctorColors.textSecondary,
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await DoctorRepository().deleteDoctor(doctor.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Data ${doctor.name} berhasil dihapus dari sistem.'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _AdminDoctorColors.deleteIcon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = DoctorRepository();

    return Scaffold(
      backgroundColor: _AdminDoctorColors.background,
      body: Stack(
        children: [
          // 1. Latar belakang gradasi butter yellow lembut di sudut kanan atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFFFDEAA8).withValues(alpha: 0.55),
                    const Color(0xFFFFF8E5).withValues(alpha: 0.25),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Konten utama halaman
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // A. Bagian Header (Logo Osteo, Judul Kelola Dokter, Deskripsi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Logo Osteo (Tulang miring + Teks Osteo)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: CustomPaint(
                              painter: _BoneLogoPainter(
                                outlineColor: _AdminDoctorColors.textMain,
                                fillColor: _AdminDoctorColors.primaryYellow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Osteo',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _AdminDoctorColors.textMain,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Baris Tombol Kembali & Judul "Kelola Dokter"
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminDashboardPage(),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 6, top: 2, bottom: 2),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 30,
                                color: _AdminDoctorColors.textMain,
                              ),
                            ),
                          ),
                          const Text(
                            'Kelola Dokter',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _AdminDoctorColors.textMain,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Deskripsi Singkat
                      const Text(
                        'Kelola data dokter yang tersedia di aplikasi Osteo.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: _AdminDoctorColors.textMain,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // B. Search Bar ("Cari nama dokter...")
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _AdminDoctorColors.searchBorder,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: _AdminDoctorColors.textMain,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari nama dokter...',
                            hintStyle: const TextStyle(
                              color: _AdminDoctorColors.textMuted,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _AdminDoctorColors.textSecondary,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _AdminDoctorColors.textMuted,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // C. Tombol "+ Tambah Dokter" (Butter Yellow Pill Button)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddDoctorPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _AdminDoctorColors.primaryYellow,
                            foregroundColor: _AdminDoctorColors.textMain,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 22,
                                color: _AdminDoctorColors.textMain,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Dokter',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _AdminDoctorColors.textMain,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // D. Daftar Dokter Berbentuk Card (Scrollable & Realtime)
                Expanded(
                  child: AnimatedBuilder(
                    animation: repo,
                    builder: (context, _) {
                      // Filter dokter berdasarkan search query
                      final allDocs = repo.allDoctors;
                      final filteredDocs = allDocs.where((d) {
                        if (_searchQuery.isEmpty) return true;
                        final q = _searchQuery.toLowerCase();
                        return d.name.toLowerCase().contains(q) ||
                            d.specialist.toLowerCase().contains(q);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: _AdminDoctorColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada dokter dengan nama "$_searchQuery"'
                                      : 'Belum ada data dokter',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _AdminDoctorColors.textMain,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Silakan tekan tombol Tambah Dokter di atas untuk menambahkan dokter baru.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _AdminDoctorColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDocs[index];
                          return _buildDoctorCard(context, doctor);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Widget Card Dokter sesuai acuan visual screenshot
  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AdminDoctorColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // 1. Foto Dokter (Circular Avatar dengan Border Halus)
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF2ECE1),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: doctor.imageUrl.isNotEmpty
                    ? Image.network(
                        doctor.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
                      )
                    : _buildFallbackAvatar(),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Info Dokter (Nama, Spesialisasi, Status Aktif/Nonaktif)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Dokter
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _AdminDoctorColors.textMain,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Spesialisasi
                  Text(
                    doctor.specialist,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _AdminDoctorColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Status Badge: Aktif / Nonaktif
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: doctor.isActive
                          ? _AdminDoctorColors.activeGreenBg
                          : _AdminDoctorColors.inactiveRedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      doctor.isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: doctor.isActive
                            ? _AdminDoctorColors.activeGreen
                            : _AdminDoctorColors.inactiveRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 3. Tombol Aksi: Edit (Pensil) & Hapus (Tempat Sampah Merah)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditDoctorPage(doctor: doctor),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 22,
                      color: _AdminDoctorColors.editIcon,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Tombol Hapus
                InkWell(
                  onTap: () => _confirmDeleteDoctor(context, doctor),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: _AdminDoctorColors.deleteIcon,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFFF2ECE1),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 32,
          color: Color(0xFF9E948A),
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR: Beranda, Dokter (AKTIF), Edukasi, Artikel, Profil
  // ===========================================================================
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Beranda
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.home_outlined,
                  size: 22,
                  color: _AdminDoctorColors.textMain,
                ),
                label: 'Beranda',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardPage(),
                    ),
                  );
                },
              ),

              // 2. Dokter (Menu Aktif dengan Indikator Butter Yellow Pill)
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _StethoscopePainter(
                      color: _AdminDoctorColors.textMain,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                label: 'Dokter',
                isActive: true,
                onTap: () {
                  // Berada di tab Dokter
                },
              ),

              // 3. Edukasi
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.menu_book_outlined,
                  size: 22,
                  color: _AdminDoctorColors.textMain,
                ),
                label: 'Edukasi',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminEducationPage(),
                    ),
                  );
                },
              ),

              // 4. Artikel
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _DocumentIconPainter(
                      color: _AdminDoctorColors.textMain,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                label: 'Artikel',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminArticlesPage(),
                    ),
                  );
                },
              ),

              // 5. Profil
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: _AdminDoctorColors.textMain,
                ),
                label: 'Profil',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required Widget iconWidget,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: _AdminDoctorColors.navActivePill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: iconWidget,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: iconWidget,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: _AdminDoctorColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
