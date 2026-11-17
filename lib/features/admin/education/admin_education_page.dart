import 'package:flutter/material.dart';
import '../../../models/education_model.dart';
import '../../../services/education_repository.dart';
import '../articles/admin_articles_page.dart';
import '../chat/admin_doctor_list_page.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../profile/admin_profile_page.dart';
import 'add_education_page.dart';
import 'edit_education_page.dart';

/// Palet warna tema Admin Kelola Edukasi sesuai spesifikasi desain & screenshot
class _AdminEducationColors {
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowCardBg = Color(0xFFFFF4D2);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color navActivePill = Color(0xFFFDE89C);

  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7DE);
  static const Color searchBorder = Color(0xFFE2DCD5);
  static const Color chipInactiveBg = Color(0xFFF7F5F0);

  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF6B635B);
  static const Color textMuted = Color(0xFF8A827A);

  // Kategori Badges
  static const Color latihanBg = Color(0xFFE0F2FE);
  static const Color latihanText = Color(0xFF0284C7);
  static const Color nutrisiBg = Color(0xFFFEF3C7);
  static const Color nutrisiText = Color(0xFFD97706);
  static const Color vitaminBg = Color(0xFFF3E8FF);
  static const Color vitaminText = Color(0xFF9333EA);

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
    canvas.rotate(-0.65);

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

/// Painter outline stetoskop untuk Bottom Navigation
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

/// Halaman Admin Kelola Edukasi OSTEOCARE
/// Mengacu 1:1 pada desain visual screenshot Menu Kelola Edukasi.
class AdminEducationPage extends StatefulWidget {
  const AdminEducationPage({super.key});

  @override
  State<AdminEducationPage> createState() => _AdminEducationPageState();
}

class _AdminEducationPageState extends State<AdminEducationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Latihan',
    'Nutrisi',
    'Vitamin',
  ];

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

  /// Menampilkan dialog konfirmasi hapus materi edukasi
  void _confirmDeleteEducation(BuildContext context, EducationModel education) {
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
                color: _AdminEducationColors.deleteIcon,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                'Hapus Edukasi?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _AdminEducationColors.textMain,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus materi "${education.title}"? Data akan dihapus dari Cloud Firestore.',
            style: const TextStyle(
              fontSize: 13.5,
              color: _AdminEducationColors.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: _AdminEducationColors.textSecondary,
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await EducationRepository().deleteEducation(education.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Materi "${education.title}" berhasil dihapus dari sistem.'),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus edukasi: $e'),
                      backgroundColor: const Color(0xFFE11D48),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _AdminEducationColors.deleteIcon,
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
    final repo = EducationRepository();
    repo.ensureListener();

    return Scaffold(
      backgroundColor: _AdminEducationColors.background,
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

                // A. Bagian Header (Logo Osteo, Judul Kelola Edukasi, Deskripsi)
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
                                outlineColor: _AdminEducationColors.textMain,
                                fillColor: _AdminEducationColors.primaryYellow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Osteo',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _AdminEducationColors.textMain,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Baris Tombol Kembali & Judul "Kelola Edukasi"
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
                                color: _AdminEducationColors.textMain,
                              ),
                            ),
                          ),
                          const Text(
                            'Kelola Edukasi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _AdminEducationColors.textMain,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Deskripsi Singkat
                      const Text(
                        'Kelola materi edukasi (latihan, nutrisi, dan vitamin).',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: _AdminEducationColors.textMain,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // B. Search Bar ("Cari judul edukasi...")
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _AdminEducationColors.searchBorder,
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
                            color: _AdminEducationColors.textMain,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari judul edukasi...',
                            hintStyle: const TextStyle(
                              color: _AdminEducationColors.textMuted,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _AdminEducationColors.textSecondary,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _AdminEducationColors.textMuted,
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

                      // C. Tombol "+ Tambah Edukasi" (Butter Yellow Pill Button)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddEducationPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _AdminEducationColors.primaryYellow,
                            foregroundColor: _AdminEducationColors.textMain,
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
                                color: _AdminEducationColors.textMain,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Edukasi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _AdminEducationColors.textMain,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // D. Filter Kategori Chips: Semua, Latihan, Nutrisi, Vitamin
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _AdminEducationColors.primaryYellow
                                        : _AdminEducationColors.chipInactiveBg,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? _AdminEducationColors.primaryYellow
                                          : const Color(0xFFEFECE6),
                                      width: 1.1,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: _AdminEducationColors.textMain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                // E. Daftar Edukasi Berbentuk Card (Scrollable & Realtime)
                Expanded(
                  child: AnimatedBuilder(
                    animation: repo,
                    builder: (context, _) {
                      // Ambil berdasarkan kategori aktif
                      final categoryFiltered =
                          repo.getEducationsByCategory(_selectedCategory);

                      // Filter berdasarkan pencarian
                      final filteredList = categoryFiltered.where((e) {
                        if (_searchQuery.isEmpty) return true;
                        final q = _searchQuery.toLowerCase();
                        return e.title.toLowerCase().contains(q) ||
                            e.description.toLowerCase().contains(q) ||
                            e.category.toLowerCase().contains(q);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: _AdminEducationColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada materi edukasi dengan judul "$_searchQuery"'
                                      : 'Belum ada materi untuk kategori $_selectedCategory',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _AdminEducationColors.textMain,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Silakan tekan tombol Tambah Edukasi di atas untuk menambahkan materi baru.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color:
                                        _AdminEducationColors.textSecondary,
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
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildEducationCard(context, item);
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

  /// Card Materi Edukasi sesuai tampilan screenshot
  Widget _buildEducationCard(BuildContext context, EducationModel item) {
    Color badgeBg;
    Color badgeTextColor;

    final catLower = item.category.toLowerCase().trim();
    if (catLower == 'latihan') {
      badgeBg = _AdminEducationColors.latihanBg;
      badgeTextColor = _AdminEducationColors.latihanText;
    } else if (catLower == 'nutrisi') {
      badgeBg = _AdminEducationColors.nutrisiBg;
      badgeTextColor = _AdminEducationColors.nutrisiText;
    } else {
      badgeBg = _AdminEducationColors.vitaminBg;
      badgeTextColor = _AdminEducationColors.vitaminText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _AdminEducationColors.cardBorder,
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
            // 1. Thumbnail Gambar Edukasi (Rounded Rect)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEFEAE2),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildThumbnailImage(item),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Info Edukasi (Judul & Badge Kategori)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Edukasi
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _AdminEducationColors.textMain,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Badge Kategori (Latihan: Biru, Nutrisi: Oranye, Vitamin: Ungu)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

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
                        builder: (_) => EditEducationPage(education: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 22,
                      color: _AdminEducationColors.editIcon,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Tombol Hapus
                InkWell(
                  onTap: () => _confirmDeleteEducation(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: _AdminEducationColors.deleteIcon,
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

  Widget _buildThumbnailImage(EducationModel item) {
    if (item.imageUrl.startsWith('http://') ||
        item.imageUrl.startsWith('https://')) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(item.category),
      );
    } else if (item.imageUrl.isNotEmpty) {
      return Image.asset(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(item.category),
      );
    } else {
      return _buildFallbackIcon(item.category);
    }
  }

  Widget _buildFallbackIcon(String category) {
    IconData icon;
    Color color;

    final catLower = category.toLowerCase().trim();
    if (catLower == 'latihan') {
      icon = Icons.directions_run_rounded;
      color = _AdminEducationColors.latihanText;
    } else if (catLower == 'nutrisi') {
      icon = Icons.restaurant_rounded;
      color = _AdminEducationColors.nutrisiText;
    } else {
      icon = Icons.medication_rounded;
      color = _AdminEducationColors.vitaminText;
    }

    return Center(
      child: Icon(icon, size: 28, color: color),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR: Beranda, Dokter, Edukasi (AKTIF), Artikel, Profil
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
                  color: _AdminEducationColors.textMain,
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

              // 2. Dokter
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _StethoscopePainter(
                      color: _AdminEducationColors.textMain,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                label: 'Dokter',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDoctorListPage(),
                    ),
                  );
                },
              ),

              // 3. Edukasi (Menu Aktif dengan Indikator Butter Yellow Pill)
              _buildBottomNavItem(
                iconWidget: const Icon(
                  Icons.menu_book_rounded,
                  size: 22,
                  color: _AdminEducationColors.textMain,
                ),
                label: 'Edukasi',
                isActive: true,
                onTap: () {
                  // Berada di tab Edukasi
                },
              ),

              // 4. Artikel
              _buildBottomNavItem(
                iconWidget: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CustomPaint(
                    painter: _DocumentIconPainter(
                      color: _AdminEducationColors.textMain,
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
                  color: _AdminEducationColors.textMain,
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
                  color: _AdminEducationColors.navActivePill,
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
                color: _AdminEducationColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

