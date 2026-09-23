import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oste/services/user_service.dart';

/// Halaman Edit Profil pengguna aplikasi Oste.
/// Didesain dengan tampilan pixel-perfect sesuai referensi, menggunakan Material 3.
class EditPage extends StatefulWidget {
  /// Parameter opsional untuk memuat data awal dari [UserService.currentUser].
  /// Default adalah `false` agar tampilan awal identik dengan gambar referensi yang kosong.
  final bool prefillFromUser;

  const EditPage({
    super.key,
    this.prefillFromUser = false,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  String? _selectedGender;

  // Palet warna resmi halaman Edit Profil
  static const Color _butterYellow = Color(0xFFF7C948);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textLabel = Color(0xFF334155);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _iconGrey = Color(0xFF94A3B8);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    final user = widget.prefillFromUser ? UserService().currentUser : null;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _birthDateController = TextEditingController(text: user?.birthDate ?? '');
    _weightController = TextEditingController(
      text: user?.weight != null ? user!.weight!.toStringAsFixed(0) : '',
    );
    _heightController = TextEditingController(
      text: user?.height != null ? user!.height!.toStringAsFixed(0) : '',
    );

    if (user != null && user.gender.isNotEmpty) {
      _selectedGender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(1998, 5, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _butterYellow,
              onPrimary: _textDark,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      const monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      setState(() {
        _birthDateController.text =
            '${picked.day} ${monthNames[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    await UserService().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      birthDate: _birthDateController.text.trim(),
      weight: weight,
      height: height,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: _textDark,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }
  InputDecoration _inputDecoration({
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _butterYellow, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: _textLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.22, 0.55, 1.0],
            colors: [
              Color(0xFFFCE6A3), // Gradasi butter yellow lembut di bagian atas
              Color(0xFFFEF5DF),
              Colors.white,
              Color(0xFFFEF8ED), // Sentuhan warm cream di bagian bawah
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ── Custom Header ─────────────────────────────────────────
                  const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Foto Profil & Ikon Kamera ────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: _iconGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _butterYellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.photo_camera_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── Card Data Pribadi ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Pribadi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Lengkapi dan perbarui data diri Anda',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: _textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 1. Nama Lengkap
                          _buildFieldLabel('Nama Lengkap'),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: _iconGrey,
                                size: 21,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama Lengkap wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 2. Email
                          _buildFieldLabel('Email'),
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.mail_outline_rounded,
                                color: _iconGrey,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 3. Nomor HP
                          _buildFieldLabel('Nomor HP'),
                          TextFormField(
                            controller: _phoneController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: _iconGrey,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nomor HP wajib diisi';
                              }
                              if (value.trim().length < 8) {
                                return 'Nomor HP minimal 8 digit angka';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 4. Jenis Kelamin (Dropdown)
                          _buildFieldLabel('Jenis Kelamin'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _iconGrey,
                                size: 22,
                              ),
                            ),
                            decoration: _inputDecoration(
                              prefixIcon: Icon(
                                _selectedGender == 'Laki-laki'
                                    ? Icons.male_rounded
                                    : Icons.female_rounded,
                                color: _iconGrey,
                                size: 22,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Laki-laki',
                                child: Text('Laki-laki'),
                              ),
                              DropdownMenuItem(
                                value: 'Perempuan',
                                child: Text('Perempuan'),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedGender = val;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jenis Kelamin wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 5. Tanggal Lahir (Date Picker)
                          _buildFieldLabel('Tanggal Lahir'),
                          TextFormField(
                            controller: _birthDateController,
                            readOnly: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            onTap: () => _pickBirthDate(context),
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: _iconGrey,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: _iconGrey,
                                  size: 20,
                                ),
                                onPressed: () => _pickBirthDate(context),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tanggal Lahir wajib diisi';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 6. Berat Badan
                          _buildFieldLabel('Berat Badan'),
                          TextFormField(
                            controller: _weightController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.scale_outlined,
                                color: _iconGrey,
                                size: 20,
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  child: Text(
                                    'kg',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Berat Badan wajib diisi';
                              }
                              final n = double.tryParse(value.trim());
                              if (n == null || n <= 0) {
                                return 'Berat Badan harus angka valid';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // 7. Tinggi Badan
                          _buildFieldLabel('Tinggi Badan'),
                          TextFormField(
                            controller: _heightController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: _inputDecoration(
                              prefixIcon: const Icon(
                                Icons.accessibility_new_rounded,
                                color: _iconGrey,
                                size: 20,
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  child: Text(
                                    'cm',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tinggi Badan wajib diisi';
                              }
                              final n = double.tryParse(value.trim());
                              if (n == null || n <= 0) {
                                return 'Tinggi Badan harus angka valid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Tombol Simpan Perubahan ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _butterYellow.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _butterYellow,
                          foregroundColor: _textDark,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
