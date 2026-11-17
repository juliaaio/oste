import 'package:flutter/material.dart';
import '../../../models/education_model.dart';
import '../../../services/education_repository.dart';

/// Palet warna tema Tambah Edukasi sesuai identitas visual Osteo
class _AddEducationColors {
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7DE);
  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF6B635B);
  static const Color textMuted = Color(0xFF8A827A);

  // Kategori
  static const Color latihanBg = Color(0xFFE0F2FE);
  static const Color latihanText = Color(0xFF0284C7);
  static const Color nutrisiBg = Color(0xFFFEF3C7);
  static const Color nutrisiText = Color(0xFFD97706);
  static const Color vitaminBg = Color(0xFFF3E8FF);
  static const Color vitaminText = Color(0xFF9333EA);
}

/// Halaman Tambah Edukasi untuk POV Admin
class AddEducationPage extends StatefulWidget {
  const AddEducationPage({super.key});

  @override
  State<AddEducationPage> createState() => _AddEducationPageState();
}

class _AddEducationPageState extends State<AddEducationPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController(text: 'Tim Medis Osteo');

  String _selectedCategory = 'Latihan';
  bool _isLoading = false;

  final List<String> _categories = ['Latihan', 'Nutrisi', 'Vitamin'];

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final defaultImage = _selectedCategory == 'Latihan'
          ? 'assets/images/bone_peak_exercise.png'
          : (_selectedCategory == 'Nutrisi'
              ? 'assets/images/calcium_rich_foods.png'
              : 'assets/images/sun_vitamin_d_bone.png');

      final newEdu = EducationModel(
        id: 'edu_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _selectedCategory,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : defaultImage,
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim(),
        author: _authorController.text.trim().isNotEmpty
            ? _authorController.text.trim()
            : 'Tim Medis Osteo',
      );

      print("=== MULAI SIMPAN EDUKASI ===");

await EducationRepository().addEducation(newEdu);

print("=== SELESAI SIMPAN EDUKASI ===");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi edukasi berhasil ditambahkan.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan edukasi: $e'),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AddEducationColors.background,
      body: Stack(
        children: [
          // Latar belakang gradasi butter yellow di kanan atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
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

          SafeArea(
            child: Column(
              children: [
                // Header dengan tombol kembali & judul Tambah Edukasi
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                            color: _AddEducationColors.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tambah Edukasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _AddEducationColors.textMain,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Materi Edukasi
                          _buildFieldLabel('Judul Materi Edukasi *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _AddEducationColors.textMain,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: Latihan Penguatan Tulang',
                              prefixIcon: Icons.menu_book_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Judul edukasi wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Pilihan Kategori (Latihan, Nutrisi, Vitamin)
                          _buildFieldLabel('Kategori Edukasi *'),
                          const SizedBox(height: 8),
                          Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              Color chipBg;
                              Color chipText;

                              if (cat == 'Latihan') {
                                chipBg = _AddEducationColors.latihanBg;
                                chipText = _AddEducationColors.latihanText;
                              } else if (cat == 'Nutrisi') {
                                chipBg = _AddEducationColors.nutrisiBg;
                                chipText = _AddEducationColors.nutrisiText;
                              } else {
                                chipBg = _AddEducationColors.vitaminBg;
                                chipText = _AddEducationColors.vitaminText;
                              }

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = cat;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _AddEducationColors.primaryYellow
                                            : chipBg.withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? _AddEducationColors.primaryYellow
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w900
                                                : FontWeight.w700,
                                            color: isSelected
                                                ? _AddEducationColors.textMain
                                                : chipText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // URL Thumbnail / Foto
                          _buildFieldLabel('URL Thumbnail / Gambar'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _imageUrlController,
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDecoration(
                              hintText:
                                  'https://... (kosongkan untuk gambar default)',
                              prefixIcon: Icons.image_outlined,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Deskripsi Singkat
                          _buildFieldLabel('Deskripsi Singkat *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 13.5, height: 1.35),
                            decoration: _inputDecoration(
                              hintText:
                                  'Penjelasan ringkas tentang materi edukasi...',
                              prefixIcon: Icons.description_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Deskripsi singkat wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Konten Edukasi Lengkap
                          _buildFieldLabel('Konten Materi Lengkap *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _contentController,
                            maxLines: 5,
                            style: const TextStyle(fontSize: 13.5, height: 1.45),
                            decoration: _inputDecoration(
                              hintText:
                                  'Tuliskan isi materi, langkah latihan, atau panduan nutrisi...',
                              prefixIcon: Icons.article_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Konten materi lengkap wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Penulis / Tim Medis
                          _buildFieldLabel('Penulis / Sumber Medis'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _authorController,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: Tim Medis Osteo',
                              prefixIcon: Icons.verified_user_outlined,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Simpan Edukasi
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _AddEducationColors.primaryYellow,
                                foregroundColor:
                                    _AddEducationColors.textMain,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          _AddEducationColors.textMain,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Edukasi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _AddEducationColors.textMain,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: _AddEducationColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: _AddEducationColors.textSecondary,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AddEducationColors.cardBorder,
          width: 1.1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AddEducationColors.cardBorder,
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _AddEducationColors.primaryYellow,
          width: 1.5,
        ),
      ),
    );
  }
}

