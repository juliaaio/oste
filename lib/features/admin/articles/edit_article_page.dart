import 'package:flutter/material.dart';
import 'admin_article_model.dart';
import 'admin_article_store.dart';

/// Palet warna tema Edit Artikel Admin sesuai acuan desain
class _EditArticleColors {
  // Background utama bernuansa krem kuning lembut
  static const Color background = Color(0xFFFFF9E8);
  static const Color waveDecor = Color(0xFFFEED9F);

  // Card & Permukaan
  static const Color cardSurface = Colors.white;
  static const Color inputBorder = Color(0xFFF1F5F9);

  // Aksen Kuning Butter & Tombol
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color pastelYellowBorder = Color(0xFFFDE68A);
  static const Color amberDark = Color(0xFFF59E0B);
  static const Color amberButtonText = Color(0xFFD97706);

  // Aksen Hijau & Merah
  static const Color requiredRed = Color(0xFFEF4444);
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusAmber = Color(0xFFD97706);

  // Tipografi
  static const Color textDark = Color(0xFF1E293B);
  static const Color textHeading = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}

/// Painter dekorasi background lengkungan lembut butter yellow di sudut kanan atas
class _EditArticleBackgroundPainter extends CustomPainter {
  const _EditArticleBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = _EditArticleColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    final wavePaintTop = Paint()
      ..color = _EditArticleColors.waveDecor.withValues(alpha: 0.45)
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

/// Halaman Edit Artikel Admin Osteoporosis
/// Menerima data artikel yang dipilih dan memungkinkan pengubahan seluruh data
class EditArticlePage extends StatefulWidget {
  final AdminArticleItem article;

  const EditArticlePage({
    super.key,
    required this.article,
  });

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _sourceController;

  late String _selectedCategory;
  late String _selectedImageAsset;
  late bool _isPublished;
  bool _isLoading = false;

  final List<String> _categories = [
    'Edukasi',
    'Edukasi Tulang',
    'Pencegahan',
    'Gaya Hidup',
    'Fakta Medis',
    'Diagnosis',
    'Nutrisi',
  ];

  final List<Map<String, String>> _availableImages = [
    {'title': 'Tulang Belakang', 'asset': 'assets/images/osteoporosis_hero.jpg'},
    {'title': 'Struktur Tulang', 'asset': 'assets/images/kemenkes_hero.jpg'},
    {'title': 'Olahraga Tulang', 'asset': 'assets/images/afmc_hero.jpg'},
    {'title': 'Mitos & Fakta', 'asset': 'assets/images/mitos_fakta_hero.jpg'},
    {'title': 'Skrining DEXA', 'asset': 'assets/images/rspi_hero.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.article;

    _titleController = TextEditingController(text: a.title);
    _summaryController = TextEditingController(text: a.description);
    _contentController = TextEditingController(
      text: a.content.isNotEmpty ? a.content : a.description,
    );
    _sourceController = TextEditingController(
      text: a.source.isNotEmpty ? a.source : 'Alodokter, 2024',
    );

    // Kategori
    if (_categories.contains(a.category)) {
      _selectedCategory = a.category;
    } else if (a.category.toLowerCase().contains('edukasi')) {
      _selectedCategory = 'Edukasi';
    } else {
      _categories.insert(0, a.category);
      _selectedCategory = a.category;
    }

    _selectedImageAsset = a.imageAsset;
    _isPublished = a.isPublished;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  /// Membuka modal ganti gambar dari galeri referensi aset tulang
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
                  'Ubah Gambar Artikel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _EditArticleColors.textHeading,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih gambar baru dari galeri referensi kesehatan tulang:',
                  style: TextStyle(
                    fontSize: 13,
                    color: _EditArticleColors.textMuted,
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
                                  ? _EditArticleColors.primaryYellow
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

  /// Logika Simpan Perubahan Artikel
  /// Disiapkan agar siap dihubungkan langsung ke Firestore:
  /// `await FirebaseFirestore.instance.collection('articles').doc(widget.article.id).update(updatedData);`
  Future<void> _handleSaveArticle() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi kolom bertanda bintang (*)'),
          backgroundColor: _EditArticleColors.requiredRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final statusText = _isPublished ? 'Dipublikasikan' : 'Draft';

    final updated = widget.article.copyWith(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      imageAsset: _selectedImageAsset,
      source: _sourceController.text.trim().isNotEmpty
          ? _sourceController.text.trim()
          : 'Alodokter, 2024',
      description: _summaryController.text.trim().isNotEmpty
          ? _summaryController.text.trim()
          : _contentController.text.trim(),
      content: _contentController.text.trim(),
      status: statusText,
    );

    // [FIREBASE_INTEGRATION_POINT]
    // Untuk tahap Firestore nantinya, aktifkan perintah berikut:
    // try {
    //   await FirebaseFirestore.instance.collection('articles').doc(widget.article.id).update({
    //     'title': updated.title,
    //     'category': updated.category,
    //     'imageAsset': updated.imageAsset,
    //     'source': updated.source,
    //     'description': updated.description,
    //     'content': updated.content,
    //     'status': updated.status,
    //     'updatedAt': FieldValue.serverTimestamp(),
    //   });
    // } catch (e) { ... }

    // Simpan ke in-memory store aktif aplikasi
    AdminArticleStore().updateArticle(updated);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perubahan artikel "${updated.title}" berhasil disimpan.'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EditArticleColors.background,
      body: Stack(
        children: [
          // 1. Ornamen Latar Belakang Krem Lembut
          const Positioned.fill(
            child: CustomPaint(
              painter: _EditArticleBackgroundPainter(),
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

                    // Header: Tombol Kembali, Judul "Edit Artikel", & Bell
                    _buildHeader(context),

                    const SizedBox(height: 18),

                    // Tampilan Gambar Saat Ini & Tombol "Ubah Gambar" Sesuai Screenshot
                    _buildCurrentImageSection(),

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
                      hintText: 'Masukkan ringkasan singkat artikel',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    // 4. Isi Artikel * (dengan Toolbar Format)
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

                    // 6. Status Publikasi (Switch Toggle Sesuai Screenshot)
                    _buildPublicationStatusSwitch(),

                    const SizedBox(height: 28),

                    // Tombol Aksi: Batal & Perbarui Artikel
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
  // 1. Header: Back Button, "Edit Artikel", & Notification Bell
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
                color: _EditArticleColors.textDark,
                size: 22,
              ),
            ),
          ),
        ),

        // Judul Halaman
        const Text(
          'Edit Artikel',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _EditArticleColors.textDark,
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
                color: _EditArticleColors.textDark,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. Bagian Gambar Artikel Saat Ini & Tombol "Ubah Gambar"
  // ===========================================================================
  Widget _buildCurrentImageSection() {
    return Row(
      children: [
        // Thumbnail Gambar Saat Ini (Sudut Membulat Sesuai Screenshot)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            _selectedImageAsset,
            width: 120,
            height: 78,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 120,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: _EditArticleColors.textLight,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Tombol "Ubah Gambar" (Pill Bergaris Kuning Pastel Sesuai Screenshot)
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _openImagePickerModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _EditArticleColors.pastelYellowBorder,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: _EditArticleColors.amberDark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ubah Gambar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _EditArticleColors.amberButtonText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. Dropdown Kategori Artikel
  // ===========================================================================
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _EditArticleColors.cardSurface,
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
            color: _EditArticleColors.textLight,
            size: 24,
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
              color: _EditArticleColors.primaryYellow,
              width: 1.5,
            ),
          ),
        ),
        items: _categories.map((cat) {
          return DropdownMenuItem<String>(
            value: cat,
            child: Text(
              cat,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _EditArticleColors.textHeading,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedCategory = val;
            });
          }
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
        color: _EditArticleColors.cardSurface,
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
                      color: _EditArticleColors.textDark,
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
                      color: _EditArticleColors.textDark,
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
                      color: _EditArticleColors.textDark,
                    ),
                  ),
                  tooltip: 'Garis Bawah (Underline)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.format_list_bulleted_rounded,
                    size: 19,
                    color: _EditArticleColors.textDark,
                  ),
                  tooltip: 'Daftar Poin (Bullet List)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.format_list_numbered_rounded,
                    size: 19,
                    color: _EditArticleColors.textDark,
                  ),
                  tooltip: 'Daftar Nomor (Numbered List)',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.link_rounded,
                    size: 19,
                    color: _EditArticleColors.textDark,
                  ),
                  tooltip: 'Sisipkan Tautan',
                ),
                _buildToolbarIcon(
                  child: const Icon(
                    Icons.image_outlined,
                    size: 19,
                    color: _EditArticleColors.textDark,
                  ),
                  tooltip: 'Sisipkan Gambar',
                  onTap: _openImagePickerModal,
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: TextFormField(
              controller: _contentController,
              maxLines: 7,
              style: const TextStyle(
                fontSize: 13.5,
                color: _EditArticleColors.textDark,
                height: 1.5,
              ),
              decoration: const InputDecoration.collapsed(
                hintText: 'Tulis isi artikel di sini...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: _EditArticleColors.textLight,
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
  // 5. Status Publikasi (Switch Toggle Sesuai Screenshot)
  // ===========================================================================
  Widget _buildPublicationStatusSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status Publikasi',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _EditArticleColors.textDark,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.88,
              child: Switch(
                value: _isPublished,
                onChanged: (val) {
                  setState(() {
                    _isPublished = val;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: _EditArticleColors.amberDark,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _isPublished ? 'Publikasikan' : 'Draft',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isPublished
                    ? _EditArticleColors.statusGreen
                    : _EditArticleColors.statusAmber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 6. Tombol Aksi Bawah: Batal & Perbarui Artikel
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
                color: _EditArticleColors.pastelYellowBorder,
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
                      color: _EditArticleColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Tombol Perbarui Artikel
        Expanded(
          flex: 6,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _EditArticleColors.primaryYellow,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _EditArticleColors.primaryYellow.withValues(alpha: 0.45),
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
                            color: _EditArticleColors.textDark,
                          ),
                        )
                      : const Text(
                          'Perbarui Artikel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _EditArticleColors.textDark,
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
              color: _EditArticleColors.textDark,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _EditArticleColors.requiredRed,
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
        color: _EditArticleColors.cardSurface,
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
          color: _EditArticleColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: _EditArticleColors.textLight,
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
              color: _EditArticleColors.primaryYellow,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias untuk mempertahankan kompatibilitas jika dibutuhkan
typedef AdminEditArticlePage = EditArticlePage;

