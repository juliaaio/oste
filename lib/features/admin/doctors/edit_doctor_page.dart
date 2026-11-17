import 'package:flutter/material.dart';
import '../../../models/doctor_model.dart';
import '../../../services/doctor_repository.dart';

/// Palet warna tema Admin Edit Dokter sesuai identitas visual Osteo
class _EditDoctorColors {
  static const Color primaryYellow = Color(0xFFF7C948);
  static const Color softYellowBg = Color(0xFFFFFBEA);
  static const Color yellowBorder = Color(0xFFFEED9F);
  static const Color background = Colors.white;
  static const Color cardBorder = Color(0xFFEDE7DE);
  static const Color textMain = Color(0xFF332011);
  static const Color textSecondary = Color(0xFF6B635B);
  static const Color textMuted = Color(0xFF8A827A);
  static const Color activeGreen = Color(0xFF1B6B38);
  static const Color activeGreenBg = Color(0xFFD1F2D9);
  static const Color inactiveRed = Color(0xFF991B1B);
  static const Color inactiveRedBg = Color(0xFFFDE8E8);
}

/// Halaman Edit Dokter untuk POV Admin
class EditDoctorPage extends StatefulWidget {
  final DoctorModel doctor;

  const EditDoctorPage({
    super.key,
    required this.doctor,
  });

  @override
  State<EditDoctorPage> createState() => _EditDoctorPageState();
}

class _EditDoctorPageState extends State<EditDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _specialistController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _experienceController;
  late final TextEditingController _consultationFeeController;
  late final TextEditingController _schedulesController;
  late final TextEditingController _biographyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late bool _isActive;
  bool _isLoading = false;

  final List<String> _specialistSuggestions = [
    'Spesialis Penyakit Dalam',
    'Spesialis Ortopedi',
    'Spesialis Kedokteran Fisik dan Rehabilitasi',
    'Sp. Orthopaedi & Traumatologi',
    'Spesialis Bedah Panggul & Lutut',
    'Sp. OT (Subspesialis Orthopaedi Anak)',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _nameController = TextEditingController(text: d.name);
    _specialistController = TextEditingController(text: d.specialist);
    _photoUrlController = TextEditingController(text: d.imageUrl);
    _hospitalController = TextEditingController(text: d.hospital);
    _experienceController =
        TextEditingController(text: d.experienceYears.toString());
    _consultationFeeController =
        TextEditingController(text: d.consultationFee.toString());
    _schedulesController = TextEditingController(text: d.schedules);
    _biographyController = TextEditingController(text: d.biography);
    _emailController = TextEditingController(text: d.email);
    _phoneController = TextEditingController(text: d.phone);
    _isActive = d.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialistController.dispose();
    _photoUrlController.dispose();
    _hospitalController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _schedulesController.dispose();
    _biographyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final feeNum = int.tryParse(
            _consultationFeeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          widget.doctor.consultationFee;
      final expYears = int.tryParse(_experienceController.text.trim()) ??
          widget.doctor.experienceYears;

      final feeFormatted = 'Rp ${feeNum.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

      final updated = widget.doctor.copyWith(
        name: _nameController.text.trim(),
        specialist: _specialistController.text.trim(),
        imageUrl: _photoUrlController.text.trim().isNotEmpty
            ? _photoUrlController.text.trim()
            : widget.doctor.imageUrl,
        hospital: _hospitalController.text.trim().isNotEmpty
            ? _hospitalController.text.trim()
            : widget.doctor.hospital,
        experienceYears: expYears,
        consultationFee: feeNum,
        consultationFeeFormatted: feeFormatted,
        schedules: _schedulesController.text.trim().isNotEmpty
            ? _schedulesController.text.trim()
            : widget.doctor.schedules,
        biography: _biographyController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        isActive: _isActive,
      );

      await DoctorRepository().updateDoctor(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan data dokter berhasil disimpan.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data dokter: $e'),
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
      backgroundColor: _EditDoctorColors.background,
      body: Stack(
        children: [
          // Latar belakang gradasi butter yellow lembut di sudut kanan atas
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
                // Header dengan tombol kembali & judul Edit Dokter
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
                            color: _EditDoctorColors.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Edit Dokter',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _EditDoctorColors.textMain,
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
                          // Preview Avatar Foto Dokter
                          Center(
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _EditDoctorColors.primaryYellow,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _photoUrlController.text
                                        .trim()
                                        .isNotEmpty
                                    ? Image.network(
                                        _photoUrlController.text.trim(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _buildDefaultAvatar(),
                                      )
                                    : _buildDefaultAvatar(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Nama Dokter
                          _buildFieldLabel('Nama Dokter *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _EditDoctorColors.textMain,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: dr. Amira Salsabila, Sp.PD',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nama dokter wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Spesialisasi
                          _buildFieldLabel('Spesialisasi *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _specialistController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _EditDoctorColors.textMain,
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: Spesialis Penyakit Dalam',
                              prefixIcon: Icons.medical_services_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Spesialisasi wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Chip Saran Spesialisasi
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _specialistSuggestions.map((s) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _specialistController.text = s;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _EditDoctorColors.softYellowBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _EditDoctorColors.yellowBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _EditDoctorColors.textMain,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),

                          // URL Foto Dokter
                          _buildFieldLabel('URL Foto Dokter'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _photoUrlController,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(fontSize: 13),
                            decoration: _inputDecoration(
                              hintText: 'https://images.unsplash.com/...',
                              prefixIcon: Icons.image_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Tempat Praktik / Rumah Sakit
                          _buildFieldLabel('Tempat Praktik / Rumah Sakit'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hospitalController,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: RS OSTEOCARE',
                              prefixIcon: Icons.local_hospital_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Pengalaman & Biaya Konsultasi (Row)
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Pengalaman (Tahun)'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _experienceController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: _inputDecoration(
                                        hintText: 'Contoh: 8',
                                        prefixIcon: Icons.work_outline_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Biaya Konsultasi (Rp)'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _consultationFeeController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: _inputDecoration(
                                        hintText: '50000',
                                        prefixIcon:
                                            Icons.monetization_on_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Jadwal Praktik
                          _buildFieldLabel('Jadwal Praktik'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _schedulesController,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration(
                              hintText: 'Contoh: Senin - Jumat, 09:00 - 16:00',
                              prefixIcon: Icons.schedule_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Bio / Tentang Dokter
                          _buildFieldLabel('Biografi / Tentang Dokter'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _biographyController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 13.5, height: 1.4),
                            decoration: _inputDecoration(
                              hintText:
                                  'Tuliskan latar belakang keahlian dokter...',
                              prefixIcon: Icons.info_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Status Aktif / Nonaktif Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _EditDoctorColors.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isActive
                                        ? _EditDoctorColors.activeGreenBg
                                        : _EditDoctorColors.inactiveRedBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _isActive
                                          ? _EditDoctorColors.activeGreen
                                          : _EditDoctorColors.inactiveRed,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _isActive
                                        ? 'Dokter akan langsung tampil di daftar pasien.'
                                        : 'Dokter tidak akan muncul di daftar pasien.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _EditDoctorColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _isActive,
                                  activeColor: _EditDoctorColors.primaryYellow,
                                  onChanged: (val) =>
                                      setState(() => _isActive = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Simpan Perubahan
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _EditDoctorColors.primaryYellow,
                                foregroundColor: _EditDoctorColors.textMain,
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
                                          _EditDoctorColors.textMain,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Perubahan',
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFF0EAE1),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 44,
          color: Color(0xFF9E948A),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _EditDoctorColors.textMain,
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
        color: _EditDoctorColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: _EditDoctorColors.textSecondary,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _EditDoctorColors.cardBorder,
          width: 1.1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _EditDoctorColors.cardBorder,
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _EditDoctorColors.primaryYellow,
          width: 1.5,
        ),
      ),
    );
  }
}

