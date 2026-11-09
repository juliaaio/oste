import 'package:flutter/material.dart';
import 'admin_article_model.dart';
import 'admin_article_store.dart';

/// Palet warna tema Tambah Artikel Admin sesuai acuan desain
class _AddArticleColors {
  // Background utama bernuansa krem kuning lembut
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  // Card & Permukaan
  static const Color cardSurface = Colors.white;
  static const Color inputBorder = Color(0xFFF1F5F9);

  // Aksen Ungu Pastel (Area Unggah Gambar)
  static const Color uploadCardBg = Color(0xFFF7F5FF);
  static const Color uploadCardBorder = Color(0xFFE4DCFD);
  static const Color uploadIconPurple = Color(0xFF6366F1);
  static const Color accentPurple = Color(0xFF7C3AED);

  // Aksen Kuning Butter & Tombol
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color pastelYellowBorder = Color(0xFFFDE68A);
  static const Color amberDark = Color(0xFFF59E0B);

  // Aksen Hijau & Merah
  static const Color requiredRed = Color(0xFFEF4444);
  static const Color badgeGreenBg = Color(0xFFE8F8EE);
  static const Color badgeGreenText = Color(0xFF16A34A);
  static const Color badgeDraftBg = Color(0xFFFEF3C7);
  static const Color badgeDraftText = Color(0xFFD97706);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Painter dekorasi background lengkungan lembut butter yellow di sudut kanan atas & kiri bawah
class _AddArticleBackgroundPainter extends CustomPainter {
  const _AddArticleBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = _AddArticleColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final wavePaintTop = Paint()
      ..color = _AddArticleColors.waveDecor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final pathTop = Path();
    pathTop.moveTo(size.width * 0.55, 0);
    pathTop.lineTo(size.width, 0);
    pathTop.lineTo(size.width, size.height * 0.12);
    pathTop.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.09,
      size.width * 0.55,
      0,
    );
    pathTop.close();
    canvas.drawPath(pathTop, wavePaintTop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman Tambah Artikel Admin Osteoporosis
/// Mereplikasi desain mobile (360 x 800 px) secara presisi dan responsif
class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();

  // Controller Form Input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  String? _selectedCategory;
  String _publicationStatus = 'Published'; // 'Published' atau 'Draft'
  String _selectedImageAsset = 'assets/images/osteoporosis_hero.jpg';
  bool _isLoading = false;

  // Daftar opsi kategori artikel
  final List<String> _categories = [
    'Edukasi Tulang',
    'Pencegahan',
    'Gaya Hidup',
    'Fakta Medis',
    'Diagnosis',
    'Nutrisi',
  ];

  // Koleksi gambar ilustrasi edukasi tulang yang tersedia di aplikasi
  final List<Map<String, String>> _availableImages = [
    {'title': 'Mengenal Osteoporosis', 'asset': 'assets/images/osteoporosis_hero.jpg'},
    {'title': 'Struktur Tulang', 'asset': 'assets/images/kemenkes_hero.jpg'},
    {'title': 'Olahraga Tulang', 'asset': 'assets/images/afmc_hero.jpg'},
    {'title': 'Mitos & Fakta', 'asset': 'assets/images/mitos_fakta_hero.jpg'},
    {'title': 'Skrining DEXA', 'asset': 'assets/images/rspi_hero.jpg'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  /// Membuka modal pemilihan gambar dari galeri aset internal
  void _openImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Gambar Artikel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _AddArticleColors.textHeading,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih gambar dari galeri referensi kesehatan tulang:',
                  style: TextStyle(
                    fontSize: 13,
                    color: _AddArticleColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final item = _availableImages[idx];
                      final isSelected = _selectedImageAsset == item['asset'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImageAsset = item['asset']!;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? _AddArticleColors.primaryYellow
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.asset(
                              item['asset']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Logika Simpan Artikel
  /// Disiapkan agar nantinya sangat mudah dihubungkan dengan Firestore:
  /// `await FirebaseFirestore.instance.collection('articles').add(articleData);`
  Future<void> _handleSaveArticle() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua kolom bertanda bintang (*)'),
          backgroundColor: _AddArticleColors.requiredRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori artikel terlebih dahulu.'),
          backgroundColor: _AddArticleColors.requiredRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Format tanggal sekarang dalam bahasa Indonesia
    final now = DateTime.now();
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dateFormatted = '${now.day} ${months[now.month]} ${now.year}';

    // 2. Persiapan Data Artikel
    final isPublished = _publicationStatus == 'Published';
    final statusIndo = isPublished ? 'Dipublikasikan' : 'Draft';

    final newArticle = AdminArticleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      date: dateFormatted,
      status: statusIndo,
      imageAsset: _selectedImageAsset,
      source: _sourceController.text.trim().isNotEmpty
          ? _sourceController.text.trim()
          : 'Osteo Admin',
      description: _summaryController.text.trim().isNotEmpty
          ? _summaryController.text.trim()
          : _contentController.text.trim(),
      content: _contentController.text.trim(),
    );

    // [FIREBASE_INTEGRATION_POINT]
    // Untuk tahap database nantinya, hubungkan Firestore di sini:
    // try {
    //   await FirebaseFirestore.instance.collection('articles').add({
    //     'title': newArticle.title,
    //     'category': newArticle.category,
    //     'date': newArticle.date,
    //     'status': newArticle.status,
    //     'imageAsset': newArticle.imageAsset,
    //     'source': newArticle.source,
    //     'description': newArticle.description,
    //     'content': newArticle.content,
    //     'createdAt': FieldValue.serverTimestamp(),
    //   });
    // } catch (e) { ... }

    // Simpan ke in-memory store aktif aplikasi
    AdminArticleStore().addArticle(newArticle);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Notifikasi berhasil
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artikel "${newArticle.title}" berhasil disimpan sebagai $statusIndo.'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AddArticleColors.background,
      body: Stack(
        children: [
          // 1. Ornamen Latar Belakang Krem Lembut
          const Positioned.fill(
            child: CustomPaint(
              painter: _AddArticleBackgroundPainter(),
            ),
          ),

          // 2. Konten Form Scrollable
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Header: Tombol Kembali, Judul "Tambah Artikel", & Bell
                    _buildHeader(context),

                    const SizedBox(height: 16),

                    // Area Unggah / Pilih Gambar
                    _buildImageUploadCard(),

                    const SizedBox(height: 18),

                    // 1. Judul Artikel *
                    _buildFieldLabel('Judul Artikel', isRequired: true),
                    _buildTextInput(
                      controller: _titleController,
                      hintText: 'Masukkan judul artikel',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Judul artikel wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 2. Kategori Artikel *
                    _buildFieldLabel('Kategori', isRequired: true),
                    _buildCategoryDropdown(),

                    const SizedBox(height: 16),

                    // 3. Ringkasan Artikel (Deskripsi Singkat)
                    _buildFieldLabel('Ringkasan Artikel', isRequired: false),
                    _buildTextInput(
                      controller: _summaryController,
                      hintText: 'Masukkan ringkasan singkat artikel (opsional)',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    // 4. Isi Artikel * (dengan Toolbar Editor B, I, U, Lists, Link, Image)
                    _buildFieldLabel('Isi Artikel', isRequired: true),
                    _buildRichTextEditorCard(),

                    const SizedBox(height: 16),

                    // 5. Sumber / Referensi
                    _buildFieldLabel('Sumber / Referensi', isRequired: false),
                    _buildTextInput(
                      controller: _sourceController,
                      hintText: 'Masukkan sumber artikel (opsional)',
                    ),

                    const SizedBox(height: 16),

                    // 6. Status Publikasi (Draft vs Published)
                    _buildFieldLabel('Status Publikasi', isRequired: true),
                    _buildPublicationStatusSelector(),

                    const SizedBox(height: 28),

                    // Tombol Aksi: Batal & Simpan Artikel
                    _buildActionButtons(context),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. Header: Back Button, "Tambah Artikel", & Notification Bell
  // ===========================================================================
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Kembali melingkar warna putih
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _AddArticleColors.textDark,
                size: 22,
              ),
            ),
          ),
        ),

        // Judul Halaman
        const Text(
          'Tambah Artikel',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _AddArticleColors.textDark,
            letterSpacing: -0.2,
          ),
        ),

        // Tombol Lonceng Notifikasi melingkar warna putih
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Belum ada notifikasi baru untuk Admin.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _AddArticleColors.textDark,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. Card Unggah Gambar (Aksen Ungu Pastel dengan Sudut Rounded Sesuai Desain)
  // ===========================================================================
  Widget _buildImageUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _AddArticleColors.uploadCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _AddArticleColors.uploadCardBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openImagePickerModal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Unggah Gambar bernuansa ungu dengan badge plus
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 58,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 46,
                        color: _AddArticleColors.uploadIconPurple,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _AddArticleColors.uploadIconPurple,
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 13,
                          color: _AddArticleColors.uploadIconPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teks "Unggah Gambar"
              const Text(
                'Unggah Gambar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _AddArticleColors.textHeading,
                ),
              ),
              const SizedBox(height: 4),

              // Subteks "Pilih gambar dari galeri"
              const Text(
                'Pilih gambar dari galeri',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: _AddArticleColors.textMuted,
                ),
              ),

              // Indikator gambar terpilih
              if (_selectedImageAsset.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          _selectedImageAsset,
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Gambar Dipilih',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _AddArticleColors.accentPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. Dropdown Kategori Artikel
  // ===========================================================================
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _AddArticleColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        icon: const Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _AddArticleColors.textLight,
            size: 24,
          ),
        ),
        hint: const Text(
          'Pilih kategori',
          style: TextStyle(
            fontSize: 13.5,
            color: _AddArticleColors.textLight,
            fontWeight: FontWeight.w400,
          ),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _AddArticleColors.primaryYellow,
              width: 1.5,
            ),
          ),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _AddArticleColors.textHeading,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kategori wajib dipilih';
          }
          return null;
        },
      ),
    );
  }

  // ===========================================================================
  // 4. Card Rich-Text Editor untuk "Isi Artikel"
  // ===========================================================================
  Widget _buildRichTextEditorCard() {
    return Container(
      decoration: BoxDecoration(
        color: _AddArticleColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar Format Text (B, I, U, Bullet List, Numbered List, Link, Image)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildToolbarIcon(
                  child: const Text(
                    'B',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _AddArticleColors.textDark,
                    ),
                  ),
                  tooltip: 'Tebal (Bold)',
                ),
                _buildToolbarIcon(
                  child: const Text(
                    'I',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: _AddArticleColors.textDark,
                    ),
                  ),
                  tooltip: 'Miring (Italic)',
                ),
                _buildToolbarIcon(
                  child: const Text(
                    'U',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                      color: _AddArticleColors.textDark,
                    ),
                  ),
                  tooltip: 'Garis Bawah (Underline)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.format_list_bulleted_rounded,
                    size: 19,
                    color: _AddArticleColors.textDark,
                  ),
                  tooltip: 'Daftar Poin (Bullet List)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.format_list_numbered_rounded,
                    size: 19,
                    color: _AddArticleColors.textDark,
                  ),
                  tooltip: 'Daftar Nomor (Numbered List)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.link_rounded,
                    size: 19,
                    color: _AddArticleColors.textDark,
                  ),
                  tooltip: 'Sisipkan Tautan',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.image_outlined,
                    size: 19,
                    color: _AddArticleColors.textDark,
                  ),
                  tooltip: 'Sisipkan Gambar',
                  onTap: _openImagePickerModal,
                ),
              ],
            ),
          ),

          // Garis pemisah antara toolbar dan area teks
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),

          // Area Ketik Isi Artikel
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextFormField(
              controller: _contentController,
              maxLines: 7,
              style: const TextStyle(
                fontSize: 13.5,
                color: _AddArticleColors.textDark,
                height: 1.5,
              ),
              decoration: const InputDecoration.collapsed(
                hintText: 'Tulis isi artikel di sini...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: _AddArticleColors.textLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Isi artikel tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon({
    required Widget child,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Format "$tooltip" diaktifkan'),
                  duration: const Duration(milliseconds: 900),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: child,
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. Selector Status Publikasi (Draft vs Published)
  // ===========================================================================
  Widget _buildPublicationStatusSelector() {
    return Row(
      children: [
        // Opsi Published
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _publicationStatus = 'Published';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _publicationStatus == 'Published'
                    ? _AddArticleColors.badgeGreenBg
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _publicationStatus == 'Published'
                      ? _AddArticleColors.badgeGreenText
                      : const Color(0xFFE2E8F0),
                  width: _publicationStatus == 'Published' ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Published (Publikasikan)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _publicationStatus == 'Published'
                          ? _AddArticleColors.badgeGreenText
                          : _AddArticleColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Opsi Draft
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _publicationStatus = 'Draft';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _publicationStatus == 'Draft'
                    ? _AddArticleColors.badgeDraftBg
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _publicationStatus == 'Draft'
                      ? _AddArticleColors.badgeDraftText
                      : const Color(0xFFE2E8F0),
                  width: _publicationStatus == 'Draft' ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _AddArticleColors.amberDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Draft (Simpan Draf)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _publicationStatus == 'Draft'
                          ? _AddArticleColors.badgeDraftText
                          : _AddArticleColors.textMuted,
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

  // ===========================================================================
  // 6. Tombol Aksi Bawah: Batal & Simpan Artikel
  // ===========================================================================
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Tombol Batal
        Expanded(
          flex: 4,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _AddArticleColors.pastelYellowBorder,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.pop(context),
                child: const Center(
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _AddArticleColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Tombol Simpan Artikel
        Expanded(
          flex: 6,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _AddArticleColors.primaryYellow,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _AddArticleColors.primaryYellow.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _isLoading ? null : _handleSaveArticle,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: _AddArticleColors.textDark,
                          ),
                        )
                      : const Text(
                          'Simpan Artikel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _AddArticleColors.textDark,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Helper Widgets: Label Input & TextFormField
  // ===========================================================================
  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _AddArticleColors.textDark,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _AddArticleColors.requiredRed,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _AddArticleColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 13.5,
          color: _AddArticleColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: _AddArticleColors.textLight,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _AddArticleColors.primaryYellow,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

